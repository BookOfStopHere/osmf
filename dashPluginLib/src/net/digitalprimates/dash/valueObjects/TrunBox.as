package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.utils.Log;
	
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;
	
	/**
	 * Holds the information about each frame in the stream.
	 * <p>Repsonsible for creating a <code>FLVTag</code> to hold each frame's
	 * data.</code>
	 * 
	 * @author Nathan Weber
	 */
	public class TrunBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const GF_ISOM_TRUN_DATA_OFFSET:uint = 0x01;
		private static const GF_ISOM_TRUN_FIRST_FLAG:uint = 0x04;
		private static const GF_ISOM_TRUN_DURATION:uint = 0x100;
		private static const GF_ISOM_TRUN_SIZE:uint = 0x200;
		private static const GF_ISOM_FIRST_SAMPLE_FLAGS:uint = 4;
		private static const GF_ISOM_TRUN_FLAGS:uint = 0x400;
		private static const GF_ISOM_TRUN_CTS_OFFSET:uint = 0x800;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var sampleCount:int;
		public var dataOffset:int;
		public var firstSampleFlags:int;
		public var samples:Vector.<Sample>;

		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var currentSample:int = 0;
		private var configTag:FLVTag;
		private var decodeTime:Number;
		private var initialized:Boolean = false;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		/**
		 * Call this before asking for any tags.
		 *  
		 * @param decodeTime
		 * @param configTag
		 */		
		public function startSampling(decodeTime:Number, configTag:FLVTag):void {
			this.decodeTime = decodeTime;
			this.configTag = configTag;
			currentSample = 0;
			initialized = true;
		}
		
		/**
		 * Whether or not we are in the process of reading tags.
		 *  
		 * @return 
		 */		
		public function isProcessing():Boolean {
			return initialized;
		}
		
		/**
		 * Whether or not another tag is available to be read.
		 *  
		 * @return 
		 */		
		public function hasNext():Boolean {
			return currentSample < sampleCount;
		}
		
		/**
		 * Whether or not we are capable of reading another tag, given the amount of data available.
		 *  
		 * @param fragmentData
		 * @return 
		 */		
		public function canReadNextTag(fragmentData:ByteArray):Boolean {
			var sample:Sample = samples[currentSample];
			
			// TODO : Weird edge case.. There's no size for the sample.  Probably a way to fix that.
			if (sample.size == 0 && fragmentData.bytesAvailable > 0) {
				return true;
			}
			
			return (fragmentData.bytesAvailable >= sample.size);
		}
		
		/**
		 * Returns a FLVTag with the next stream frame's data.
		 *  
		 * @param timescale
		 * @param defaultDuration
		 * @param defaultFlags
		 * @param fragmentData
		 * @return 
		 */		
		public function getNextTag(timescale:Number, defaultDuration:Number, defaultFlags:uint, fragmentData:ByteArray):FLVTag {
			if (!initialized) {
				throw new Error("Must initialize with startSampling() before reading samples.");
			}
			
			var tag:FLVTag;
			// grab the sample we're on
			var sample:Sample = samples[currentSample];
			
			// get information from sample / defaults
			
			var flags:uint = sample.flags != -1 ? sample.flags : defaultFlags;
			
			var duration:Number = sample.duration != -1 ? sample.duration : defaultDuration;
			if (duration == 0) duration = 1000;
			
			// figure out the timestamps
			
			var startTime:Number = (decodeTime / timescale) * 1000;
			var sampleTime:Number = (sample.CTSOffset / timescale) * 1000;
			
			// based on the type of configTag, we know if we're video or audio
			
			if (configTag is FLVTagVideo) {
				var videoTag:FLVTagVideo = new FLVTagVideo();
				videoTag.timestamp = startTime;
				videoTag.codecID = FLVTagVideo.CODEC_ID_AVC;
				videoTag.frameType = ((flags & 65536) == 0) ? FLVTagVideo.FRAME_TYPE_KEYFRAME : FLVTagVideo.FRAME_TYPE_INTER;
				videoTag.avcPacketType = FLVTagVideo.AVC_PACKET_TYPE_NALU;
				videoTag.avcCompositionTimeOffset = sampleTime;
				
				tag = videoTag;
			}
			else if (configTag is FLVTagAudio) {
				var audioTag:FLVTagAudio = new FLVTagAudio();
				var referenceTag:FLVTagAudio = (configTag as FLVTagAudio);
				audioTag.timestamp = startTime;
				audioTag.soundFormat = referenceTag.soundFormat;
				audioTag.soundChannels = referenceTag.soundChannels;
				audioTag.soundRate = referenceTag.soundRate;
				audioTag.soundSize = referenceTag.soundSize;
				
				tag = audioTag;
			}
			else {
				throw new Error("Invalid config tag type.");
			}
			
			var tagBytes:ByteArray = new ByteArray();
			
			var bytesNeeded:Number = sample.size;
			if (bytesNeeded == 0) bytesNeeded = fragmentData.length; // TODO : Edge case...  what to do?
			
			// write the bytes into the tag
			fragmentData.readBytes(tagBytes, 0, sample.size);
			tag.data = tagBytes;
			
			decodeTime += duration;
			
			currentSample++;
			
			// we are done, don't let this method get called again
			if (currentSample >= sampleCount)
				initialized = false;
			
			return tag;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			readFullBox(bitStream, this);
			
			sampleCount = data.readInt();
			
			var hasFirstSampleFlags:Boolean = false;
			
			if (flags & GF_ISOM_TRUN_DATA_OFFSET) {
				dataOffset = data.readInt();
			}
			if (flags & GF_ISOM_TRUN_FIRST_FLAG) {
				firstSampleFlags = data.readInt();
				hasFirstSampleFlags = true;
			}
			
			samples = new Vector.<Sample>();
			for (var i:int=0; i < sampleCount; i++) {
				var p:Sample = new Sample();
				
				if (flags & GF_ISOM_TRUN_DURATION) {
					p.duration = data.readInt();
				}
				
				if (flags & GF_ISOM_TRUN_SIZE) {
					p.size = data.readInt();
				}
				
				if (flags & GF_ISOM_FIRST_SAMPLE_FLAGS) {
					p.flags = firstSampleFlags;
				}
				
				if (!hasFirstSampleFlags) {
					if (flags & GF_ISOM_TRUN_FLAGS) {
						p.flags = data.readInt();
					}
				}
				
				if (flags & GF_ISOM_TRUN_CTS_OFFSET) {
					p.CTSOffset = data.readInt();
				}
				
				samples.push(p);
			}	
			
			data.position = 0;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function TrunBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TRUN, data);
		}
	}
}