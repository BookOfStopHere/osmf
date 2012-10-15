package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	
	import org.osmf.net.httpstreaming.flv.FLVTag;
	import org.osmf.net.httpstreaming.flv.FLVTagAudio;
	import org.osmf.net.httpstreaming.flv.FLVTagVideo;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrakBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var tkhd:TkhdBox;
		public var mdia:MdiaBox;
		
		private var _configTag:FLVTag;
		
		/**
		 * Returns the configuration header tag for this track. 
		 */		
		public function get configTag():FLVTag {
			if (!_configTag) {
				var hdlr:HdlrBox = mdia.hdlr;
				
				if (hdlr.handlerType == HdlrBox.HANDLER_TYPE_VIDEO) {
					var videoTag:FLVTagVideo = new FLVTagVideo();
					videoTag.codecID = FLVTagVideo.CODEC_ID_AVC;
					videoTag.frameType = FLVTagVideo.FRAME_TYPE_KEYFRAME;
					videoTag.avcPacketType = FLVTagVideo.AVC_PACKET_TYPE_SEQUENCE_HEADER;
					
					var avcC:AvccBox = mdia.minf.stbl.stsd.sampleEntries[0].avcC;
					videoTag.data = avcC.configRecord;
					
					_configTag = videoTag;
				}
				else if (hdlr.handlerType == HdlrBox.HANDLER_TYPE_AUDIO) {
					var mp4a:Mp4aBox = (mdia.minf.stbl.stsd.sampleEntries[0] as Mp4aBox);
					
					var audioTag:FLVTagAudio = new FLVTagAudio();
					audioTag.soundFormat = FLVTagAudio.SOUND_FORMAT_AAC;
					audioTag.soundChannels = mp4a.channelCount;
					audioTag.soundRate = FLVTagAudio.SOUND_RATE_44K; // force to 44k | specification indicates AAC should always be set to 44k
					audioTag.soundSize = mp4a.bitsPerSample;
					audioTag.isAACSequenceHeader = true;
					audioTag.data = mp4a.esds.es.decoderConfigDescriptor.decoderSpecificInfo.configData;
					
					_configTag = audioTag;
				}
			}
			
			return _configTag;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TrakBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TRAK, data);
		}
	}
}
