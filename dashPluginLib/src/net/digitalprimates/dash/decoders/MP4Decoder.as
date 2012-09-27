package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.*;
	
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;

	/**
	 * Parses MP4 fragments.
	 * 
	 * @author Nathan Weber
	 */
	public class MP4Decoder implements IDecoder
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var currentBox:BoxInfo;
		private var bytes:ByteArray;
		private var bytesPending:Boolean = false;
		
		private var initialized:Boolean = false;
		private var timescale:Number;
		private var headerVideoTag:FLVTagVideo;
		private var headerAudioTag:FLVTagAudio;
		private var currentMoof:MoofBox;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		/**
		 * @copy net.digitalprimates.dash.decoders.IDecoder#beginProcessData() 
		 */		
		public function beginProcessData():void {
			currentBox = null;
			initialized = false;
		}
		
		/**
		 * @copy net.digitalprimates.dash.decoders.IDecoder#processData() 
		 * 
		 * @private
		 * 
		 * mp4 fragments contain a series of boxes which hold all of the information about the video.
		 * Below is a tree defining the box structure seen in a sample mp4.
		 * The .mp4 file that is loaded from the initialization URL has the header data for the video file.
		 * The contents of the initialization URL must be loaded into NetStream before any other data!
		 * After the header has been loaded, the m4s fragment data can be pushed into NetStream.
		 */		
		public function processData(input:IDataInput, limit:Number = 0):ByteArray {
			/*
			MP4 INITIALIZATION CONTENTS
			
			ftyp								file type and compatibility
			free								free space
			moov								container for all the metadata
				mvhd							movie header, overall declarations
				mvex							movie extends box
					mehd						movie extends header box
					trex						track extends defaults
				trak							container for an individual track or stream
					tkhd						track header, overall information about the track
					mdia						container for the media information in a track
						mdhd					media header, overall information about the media
						hdlr					handler, declares the media (handler) type
						minf					media information container
							vmhd				video media header, overall information (video track only)
							dinf				data information box, container
								dref			data reference box, declares source(s) of media data in track
									url			
							stbl				sample table box, container for the time/space map
								stsd			sample descriptions (codec types, initialization etc.)
									avc1		
										avcC	
								stts			(decoding) time-to-sample
								stsc			sample-to-chunk, partial data-offset information
								stsz			sample sizes (framing)
								stco			chunk offset, partial data-offset information
			
			M4S FRAGMENT CONTENTS
			
			styp								segment type
			sidx								segment index
			moof								movie fragment
				mfhd							movie fragment header
				traf							track fragment
					tfhd						track fragment header
					tfdt						track fragment decode time
					trun						track fragment run
			mdat								media data container
			*/
			
			var returnByteArray:ByteArray = null;
			
			// waiting for a box
			if (!currentBox) {
				currentBox = getNextBox(input, limit);
				
				if (currentBox != null) {
					Log.log("parsed a box of type", currentBox.type);
					if (currentBox.data != null) {
						Log.log("box data ready");
					}
					else {
						Log.log("waiting for box contents");
					}
				}
				else {
					Log.log("could not parse a box");
				}
			}
			
			// have a box, but not the contents
			if ((currentBox && currentBox.data == null) || bytesPending) {
				var read:Boolean = readBoxData(currentBox, input, limit);
				
				if (read) {
					Log.log("box contents read");
				}
				else {
					Log.log("still waiting for box contents");
				}
			}
			
			// we have a full box, so handle it
			if (currentBox && currentBox.data != null) {
				Log.log("trying to use box", currentBox.type);
				switch (currentBox.type) {
					case BoxInfo.BOX_TYPE_MOOV:
						Log.log("got a MOOV box - parse header tags");
						
						/*
						The moov box will be defined in the header file.
						We need to read out the header data and save it so that we can write it out
						to the NetStream later.
						We also need to save the tags because they'll be referenced later when we
						decode the video/audio frames.
						*/
						
						// get the timescale for later
						var moov:MoovBox = currentBox as MoovBox;
						var hdlr:HdlrBox = moov.trak.mdia.hdlr;
						
						timescale = moov.trak.mdia.mdhd.timeScale;
						
						// build the configuration tag for video
						if (hdlr.handlerType == HdlrBox.HANDLER_TYPE_VIDEO) {
							headerVideoTag = new FLVTagVideo();
							headerVideoTag.codecID = FLVTagVideo.CODEC_ID_AVC;
							headerVideoTag.frameType = FLVTagVideo.FRAME_TYPE_KEYFRAME;
							headerVideoTag.avcPacketType = FLVTagVideo.AVC_PACKET_TYPE_SEQUENCE_HEADER;
							
							var avcc:AvccBox = moov.trak.mdia.minf.stbl.stsd.sampleEntries[0].avcc;
							headerVideoTag.data = avcc.configRecord;
						}
						// build the configuration tag for audio
						else if (hdlr.handlerType == HdlrBox.HANDLER_TYPE_AUDIO) {
							var mp4a:Mp4aBox = (moov.trak.mdia.minf.stbl.stsd.sampleEntries[0] as Mp4aBox);
							
							headerAudioTag = new FLVTagAudio();
							headerAudioTag.soundFormat = FLVTagAudio.SOUND_FORMAT_AAC;
							headerAudioTag.soundChannels = mp4a.channelCount;
							headerAudioTag.soundRate = FLVTagAudio.SOUND_RATE_44K; // mp4a.sampleRateHi;
							headerAudioTag.soundSize = mp4a.bitsPerSample;
							headerAudioTag.isAACSequenceHeader = true;
							headerAudioTag.data = mp4a.esds.es.decoderConfigDescriptor.decoderSpecificInfo.configData;
						}
						// we don't know how to handle this
						else {
							throw new Error("Unkown handler type!");
						}
						break;
					
					case BoxInfo.BOX_TYPE_MOOF:
						Log.log("got a MOOF box");
						// save this off for later, we'll need it when we build the stream fragments
						currentMoof = currentBox as MoofBox;
						clearCurrentBox();
						break;
					
					case BoxInfo.BOX_TYPE_MDAT:
						Log.log("got a MDAT box");
						
						/*
						The mdat box contains all of the stream frames.  This is where the magic happens.
						We have to grab each frame's data and repackage it as FLV data.  NetStream.appendBytes()
						only accept FLV packaged data.  Passing anything else simply won't work.
						OSMF has some convenience classes to package the stream data into FLV format..
						FLVTag, FLVTagAudio, and FLVTagVideo.
						We use these above when decoding the header.
						We'll also use them below when decoding the stream frames.
						See TrunBox for more information about how the frames are decoded.
						*/
						
						// get the video data in FLV format
						returnByteArray = getFLVBytes(currentBox.data);
						
						// start over if the video fragment is done being loaded
						// the box will contain a limited amount of data based on how
						// much we processed this pass
						// check to see if we've gone through the entire mdat box
						if (processingFLVBytesFinished) {
							Log.log("finished a video fragment");
							currentMoof = null;
							clearCurrentBox();
						}
						break;
					
					default:
						Log.log("got a box we don't care about", currentBox.type);
						// this will make the process start over
						clearCurrentBox();
						break;
				}
			}
			
			return returnByteArray;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function clearCurrentBox():void {
			currentBox = null;
		}
		
		private function getNextBox(input:IDataInput, limit:Number = 0):BoxInfo {
			// not enough data!
			if (input == null || input.bytesAvailable < BoxInfo.SIZE_AND_TYPE_LENGTH)
				return null;
			
			var ba:ByteArray = new ByteArray();
			input.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);
			
			var size:int = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
			var type:String = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);
			
			var box:BoxInfo;
			
			switch (type) {
				case BoxInfo.BOX_TYPE_FTYP:
					box = new FtypBox(size);
					break;
				case BoxInfo.BOX_TYPE_MOOF:
					box = new MoofBox(size);
					break;
				case BoxInfo.BOX_TYPE_MDAT:
					box = new MdatBox(size);
					break;
				case BoxInfo.BOX_TYPE_MOOV:
					box = new MoovBox(size);
					break;
				default:
					box = new BoxInfo(size, type);
					break;
			}
			
			readBoxData(box, input, limit);
			
			return box;
		}
		
		private function readBoxData(box:BoxInfo, input:IDataInput, limit:Number = 0):Boolean {
			var bytesNeeded:int = (box.size - box.length);
			
			// mdat boxes will be processed as they download
			// force the reading of the available data
			var forced:Boolean = (box.type == BoxInfo.BOX_TYPE_MDAT);
			
			// not enough data
			if ((input.bytesAvailable < bytesNeeded) && !forced)
				return false;
			
			Log.log("getting box contents", box.type, input.bytesAvailable, bytesNeeded);
			
			var data:ByteArray;
			
			bytesPending = false;
			
			var numBytesToRead:Number = bytesNeeded;
			if (input.bytesAvailable < bytesNeeded) {
				numBytesToRead = input.bytesAvailable;
				bytesPending = true;
				Log.log("not enough bytes, reading everything in");
			}
			
			if (limit > 0 && numBytesToRead > limit) {
				numBytesToRead = limit;
				bytesPending = true;
				Log.log("hit byte processing limit");
			}
			
			// append to the box's data if it's already been created
			if (box.data != null) {
				Log.log("appending to existing data");
				data = box.data;
			}
			else {
				data = new ByteArray();
			}
			
			input.readBytes(data, data.length, numBytesToRead);
			
			box.data = data;
			
			return true;
		}
		
		private function get processingFLVBytesFinished():Boolean {
			var trun:TrunBox = currentMoof.traf.trun;
			return !trun.hasNext();
		}
		
		/**
		 * @private 
		 * Returns the FLV data for an mdat.
		 */		
		private function getFLVBytes(bytes:ByteArray):ByteArray {
			if (bytes) {
				var flvBytes:ByteArray = new ByteArray();
				
				// get some boxes we need
				var tfdt:TfdtBox = currentMoof.traf.tfdt;
				var trun:TrunBox = currentMoof.traf.trun;
				var tfhd:TfhdBox = currentMoof.traf.tfhd;
				
				// without these we don't have enough information to continue
				// if these aren't here the video is probably malformed
				if (!tfdt || !trun || !tfhd)
					throw new Error("Missing video information!");
				
				// if we haven't written the headers to NetStream, do that FIRST
				if (!initialized) {
					Log.log("init decoding", tfdt.baseMediaDecodeTime);
					if (headerVideoTag) {
						headerVideoTag.timestamp = tfdt.baseMediaDecodeTime / timescale * 1000;
						headerVideoTag.write(flvBytes);
						initialized = true;
					}
					else if (headerAudioTag) {
						headerAudioTag.timestamp = tfdt.baseMediaDecodeTime / timescale * 1000;
						headerAudioTag.write(flvBytes);
					}
					initialized = true;
				}
				
				// check to see if the trun has already started
				// again, we only process so much each pass, so this may have already been kicked off
				if (!trun.isProcessing()) {
					if (headerVideoTag) {
						trun.startSampling(tfdt.baseMediaDecodeTime, headerVideoTag);
					}
					else if (headerAudioTag) {
						trun.startSampling(tfdt.baseMediaDecodeTime, headerAudioTag);
					}
					else {
						throw new Error("Missing configuration tag.");
					}
				}
				
				// check to see that we have more to process and that we have enough data to process the next tag
				while (trun.hasNext() && trun.canReadNextTag(bytes)) {
					// get the tag from the trun - let it do the heavy lifting - and then write it to the FLV byte array
					var tag:FLVTag = trun.getNextTag(timescale, tfhd.defSampleDuration, tfhd.defSampleFlags, bytes);
					tag.write(flvBytes);
				}
				
				// reset this to be nice for somebody else that wants to use it
				flvBytes.position = 0;
				return flvBytes;
			}
			
			return null;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		/**
		 * Constructor. 
		 */		
		public function MP4Decoder() {
			
		}
	}
}