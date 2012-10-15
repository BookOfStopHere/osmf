package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
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
		public var currentSample:int = 0;
		public var dataOffset:int;
		public var firstSampleFlags:int;
		public var samples:Vector.<Sample>;

		private var _initialized:Boolean = false;
		
		public function get initialized():Boolean {
			return _initialized;
		}
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var configTag:FLVTag;
		private var decodeTime:Number;
		
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
			_initialized = true;
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
		public function canReadNextTag(fragmentData:IDataInput):Boolean {
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
		public function getNextTag(timescale:Number, defaultDuration:Number, defaultFlags:uint, fragmentData:IDataInput):FLVTag {
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
			
			// write the bytes into the tag
			fragmentData.readBytes(tagBytes, 0, sample.size);
			tag.data = tagBytes;
			
			decodeTime += duration;
			
			currentSample++;
			
			return tag;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			parseVersionAndFlags();
			
			sampleCount = bitStream.readUInt32();
			
			var hasFirstSampleFlags:Boolean = false;
			
			if (flags & GF_ISOM_TRUN_DATA_OFFSET) {
				dataOffset = bitStream.readUInt32();
			}
			if (flags & GF_ISOM_TRUN_FIRST_FLAG) {
				firstSampleFlags = bitStream.readUInt32();
				hasFirstSampleFlags = true;
			}
			
			samples = new Vector.<Sample>();
			for (var i:int=0; i < sampleCount; i++) {
				var p:Sample = new Sample();
				
				if (flags & GF_ISOM_TRUN_DURATION) {
					p.duration = bitStream.readUInt32();
				}
				
				if (flags & GF_ISOM_TRUN_SIZE) {
					p.size = bitStream.readUInt32();
				}
				
				if (flags & GF_ISOM_FIRST_SAMPLE_FLAGS) {
					p.flags = firstSampleFlags;
				}
				
				if (!hasFirstSampleFlags) {
					if (flags & GF_ISOM_TRUN_FLAGS) {
						p.flags = bitStream.readUInt32();
					}
				}
				
				if (flags & GF_ISOM_TRUN_CTS_OFFSET) {
					p.CTSOffset = bitStream.readUInt32();
				}
				
				samples.push(p);
			}	
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