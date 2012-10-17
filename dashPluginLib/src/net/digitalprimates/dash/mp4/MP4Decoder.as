package net.digitalprimates.dash.mp4
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.decoders.IDecoder;
	import net.digitalprimates.dash.mp4.boxes.BoxInfo;
	import net.digitalprimates.dash.mp4.boxes.MdatBox;
	import net.digitalprimates.dash.mp4.boxes.MoofBox;
	import net.digitalprimates.dash.mp4.boxes.MoovBox;
	import net.digitalprimates.dash.mp4.boxes.TfdtBox;
	import net.digitalprimates.dash.mp4.boxes.TfhdBox;
	import net.digitalprimates.dash.mp4.boxes.TrafBox;
	import net.digitalprimates.dash.mp4.boxes.TrakBox;
	import net.digitalprimates.dash.mp4.boxes.TrexBox;
	import net.digitalprimates.dash.mp4.boxes.TrunBox;
	import net.digitalprimates.dash.utils.Log;
	
	import org.osmf.net.httpstreaming.flv.FLVTag;

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
		
		private var currentMoov:MoovBox;
		private var currentMoof:MoofBox;
		
		private var boxFactory:IBoxFactory;
		
		private var decoderInitialized:Boolean = false;
		
		/**
		 * @private 
		 * If we have multiple tracks in a single segment stream we have to wait for the entire box
		 * to be downloaded before we can parse any of it.
		 * The reason for this is because the tracks need to be sycned and playing them as they download
		 * will cause them to be out of sync.
		 */		
		protected function get shouldProcessEntireBox():Boolean {
			return true;
			
			/*if (currentMoof && currentMoof.tracks) {
				return (currentMoof.tracks.length > 1);
			}
			if (currentMoov && currentMoov.tracks) {
				return (currentMoov.tracks.length > 1);
			}
			return false;*/
		}
		
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
			decoderInitialized = false;
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
			}
			
			// have a box, but not the contents
			if ((currentBox && !currentBox.ready) || bytesPending) {
				readBoxData(currentBox, input, limit);
			}
			
			// we have a full box, so handle it
			if (currentBox && currentBox.ready) {
				CONFIG::LOGGING
				{
					Log.log("trying to use box", currentBox.type);
				}
				
				switch (currentBox.type) {
					case BoxInfo.BOX_TYPE_MOOV:
						/*
						The moov box will be defined in the header file.
						We need to read out the header data and save it so that we can write it out
						to the NetStream later.
						We also need to save the tags because they'll be referenced later when we
						decode the video/audio frames.
						The tags from here will be asked for later when we build the FLV bytes.
						*/
						// save this off for later, we'll need it when we build the stream fragments
						currentMoov = currentBox as MoovBox;
						clearCurrentBox();
						break;
					
					case BoxInfo.BOX_TYPE_MOOF:
						// save this off for later, we'll need it when we build the stream fragments
						currentMoof = currentBox as MoofBox;
						clearCurrentBox();
						break;
					
					case BoxInfo.BOX_TYPE_MDAT:
						/*
						The mdat box contains all of the stream samples.  This is where the magic happens.
						We have to grab each frame's data and repackage it as FLV data.  NetStream.appendBytes()
						only accept FLV packaged data.  Passing anything else simply won't work.
						OSMF has some convenience classes to package the stream data into FLV format..
						FLVTag, FLVTagAudio, and FLVTagVideo.
						We use these above when decoding the header.
						We'll also use them below when decoding the stream frames.
						See TrunBox for more information about how the frames are decoded.
						*/
						// process each track in the moof - we might have an audio and video track in the same moof
						var mdatBox:MdatBox = (currentBox as MdatBox);
						var mdatData:ByteArray = mdatBox.existingData;
						
						if (!returnByteArray) returnByteArray = new ByteArray();
						
						if (!decoderInitialized && currentMoov) {
							for each (var box:TrafBox in currentMoof.tracks) {
								var trak:TrakBox = getTrakForTraf(currentMoov, box);
								if (trak.configTag) {
									CONFIG::LOGGING
									{
										Log.log("write header");
									}
									trak.configTag.timestamp = box.tfdt.baseMediaDecodeTime / trak.mdia.mdhd.timescale * 1000;
									trak.configTag.write(returnByteArray);
								}
							}
							decoderInitialized = true;
						}
						
						for each (var traf:TrafBox in currentMoof.tracks) {
							var flv:ByteArray = getFLVBytes(mdatData, traf);
							
							if (flv) {
								returnByteArray.writeBytes(flv);
							}
						}
						
						// start over if the video fragment is done being loaded
						// the box will contain a limited amount of data based on how
						// much we processed this pass
						// check to see if we've gone through the entire mdat box
						if (processingFLVBytesFinished) {
							CONFIG::LOGGING
							{
								Log.log("finished a video fragment");
							}
							currentMoof = null;
							clearCurrentBox();
						}
						
						break;
					
					default:
						// this will make the process start over
						clearCurrentBox();
						break;
				}
			}
			
			// reset the position to 0, otherwise HTTPStreamMixer will fail
			if (returnByteArray) {
				returnByteArray.position = 0;
				return returnByteArray;
			}
			
			return null;
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
			if (input == null)
				return null;
			
			var box:BoxInfo = boxFactory.getInstance(input);
			
			// wan't enough data or something!
			if (!box)
				return null;
						
			readBoxData(box, input, limit);
			
			return box;
		}
		
		private function readBoxData(box:BoxInfo, input:IDataInput, limit:Number = 0):Boolean {
			var bytesNeeded:int = (box.size - box.length);
			
			// this forces the box to be processed as it is downloaded, even if the entire box isn't finished
			// if false, the box won't be processed until the entire box is available
			// for performance we may want to set this to true for MDAT (video data) boxes
			// however, there's a bug that will cause mdats with multiple tracks to have the second track delayed
			// the multiple tracks should play at the same time!
			// leave as false for now..
			var forced:Boolean = !shouldProcessEntireBox && (box.type == BoxInfo.BOX_TYPE_MDAT);
			
			// not enough data
			if ((input.bytesAvailable < bytesNeeded) && !forced)
				return false;
			
			CONFIG::LOGGING
			{
				Log.log("getting box contents", box.type, input.bytesAvailable, bytesNeeded, limit);
			}
			
			var data:ByteArray;
			
			bytesPending = false;
			
			var numBytesToRead:Number = bytesNeeded;
			
			if (input.bytesAvailable < bytesNeeded) {
				numBytesToRead = input.bytesAvailable;
				bytesPending = true;
			}
			
			if (limit > 0 && numBytesToRead > limit) {
				numBytesToRead = limit;
				bytesPending = true;
			}
			
			// append to the box's data if it's already been created
			if (box.ready) {
				data = box.existingData;
			}
			else {
				data = new ByteArray();
			}
			
			if (numBytesToRead <= 0)
				return false; // throw an error here?
			
			input.readBytes(data, data.length, numBytesToRead);
			
			if (!box.existingData)
				box.data = data;
			
			return true;
		}
		
		private function get processingFLVBytesFinished():Boolean {
			var trun:TrunBox;
			var doneProcessing:Boolean;
			var doneLoading:Boolean;
			
			for each (var traf:TrafBox in currentMoof.tracks) {
				trun = traf.trun;
				doneProcessing = !trun.hasNext();
				doneLoading = (currentBox.length == currentBox.size);
				
				if (!doneProcessing || !doneLoading) {
					return false;
				}
			}
			
			return true;
		}
		
		private function getTrakForTraf(moov:MoovBox, traf:TrafBox):TrakBox {
			if (!moov || !traf) {
				return null;
			}
			
			for each (var trak:TrakBox in moov.tracks) {
				if (trak.tkhd.trackId == traf.tfhd.trackId) {
					return trak;
				}
			}
			
			return null;
		}
		
		/**
		 * @private 
		 * Returns the FLV data for an mdat.
		 */		
		private function getFLVBytes(bytes:ByteArray, traf:TrafBox):ByteArray {
			if (bytes) {
				var trak:TrakBox = getTrakForTraf(currentMoov, traf);
				if (!trak)
					throw new Error("Missing track information!");
				
				var flvBytes:ByteArray = new ByteArray();
				
				// get some boxes we need
				var trex:TrexBox = currentMoov.mvex.trex;
				var tfdt:TfdtBox = traf.tfdt;
				var trun:TrunBox = traf.trun;
				var tfhd:TfhdBox = traf.tfhd;
				
				// without these we don't have enough information to continue
				// if these aren't here the video is probably malformed
				if (!trex || !tfdt || !trun || !tfhd)
					throw new Error("Missing video information!");
				
				// check to see if this track is already finished
				if (!trun.hasNext())
					return null;
				
				// the samples start at the position defined by the data offset
				// be sure we have that data position loaded before we try processing
				if (trun.currentSample == 0) {
					var offset:Number = 0;
					if (tfhd.baseDataOffset > 0) {
						offset += tfhd.baseDataOffset;
					}
					if (trun.dataOffset > 0) {
						offset += trun.dataOffset;
					}
					
					// the data for THIS TRACK starts at offset
					// be sure we've loaded to that point!
					if (bytes.length < offset)
						return null;
				}
				
				var configTag:FLVTag = trak.configTag;
				var timescale:Number = trak.mdia.mdhd.timescale;
				
				if (!configTag) {
					throw new Error("Missing config tag in track!");
				}
				
				// if we haven't written the headers to NetStream, do that FIRST
				if (!trun.initialized) {
					trun.startSampling(tfdt.baseMediaDecodeTime, configTag);
				}
				
				var defaultDuration:int = (tfhd.defSampleDuration > 0) ? tfhd.defSampleDuration : trex.defSampleDuration;
				var defaultFlags:uint = (tfhd.defSampleFlags > 0) ? tfhd.defSampleFlags : trex.defSampleFlags;
				
				// check to see that we have more to process and that we have enough data to process the next tag
				while (trun.hasNext() && trun.canReadNextTag(bytes)) {
					// get the tag from the trun - let it do the heavy lifting - and then write it to the FLV byte array
					var tag:FLVTag = trun.getNextTag(timescale, defaultDuration, defaultFlags, bytes);
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
			boxFactory = new BaseBoxFactory();
		}
	}
}