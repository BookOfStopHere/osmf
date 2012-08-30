package net.digitalprimates.dash
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class FLVConverter
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		/*public static const FLVTAG_HEADER_LENGTH:int = 11;
		public static const FLVTAG_HEADER_VIDEO_FLAG:int = 0x01;
		public static const FLVTAG_HEADER_AUDIO_FLAG:int = 0x04;
		public static const FLVTAG_PREVIOUS_LENGTH_LENGTH:int = 4;
		
		public static const FLVTAG_TYPE_AUDIO:int = 0x08;
		public static const FLVTAG_TYPE_VIDEO:int = 0x09;
		
		public static const FLVTAG_AUDIO_CODEC_MP3:int = 0x2f;
		public static const FLVTAG_AUDIO_CODEC_AAC:int = 0xaf;
		
		public static const FLVTAG_VIDEO_CODEC_AVC_KEYFRAME:int = 0x17;
		public static const FLVTAG_VIDEO_CODEC_AVC_PREDICTIVEFRAME:int = 0x27;
		
		public static const FLVTAG_AVC_MODE_AVCC:int = 0x00;
		public static const FLVTAG_AVC_MODE_PICTURE:int = 0x01;
		
		public static const FLVTAG_AAC_MODE_CONFIG:int = 0x00;
		public static const FLVTAG_AAC_MODE_FRAME:int = 0x01;
		
		public static const ADTS_FRAME_HEADER_LENGTH:uint = 7;*/
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var bytes:ByteArray;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function clear():void {
			bytes = null;
		}
		
		public function appendBytes(avcc:ByteArray):void {
			if (!avcc)
				return;
			
			if (!bytes)
				bytes = new ByteArray();
			
			avcc.readBytes(bytes, bytes.length);
		}
		private var boo:uint = 0;
		public function flush():ByteArray {
			// Documentation : http://download.macromedia.com/f4v/video_file_format_spec_v10_1.pdf, page 68
			
			// video body
			
			var videoBytes:ByteArray = new ByteArray();
			
			
			
			
			// FLV
			
			var flvBytes:ByteArray = new ByteArray();
			
			// FLV header
			
			flvBytes.writeByte(0x46);						// F
			flvBytes.writeByte(0x4c);						// L
			flvBytes.writeByte(0x56);						// V
			flvBytes.writeByte(0x01);						// version
			flvBytes.writeByte(0x01 + 0x04);				// flags, audio+video
			
			const offset:uint = 9;							// min header size
			flvBytes.writeUnsignedInt(offset);
			
			flvBytes.writeUnsignedInt(0);					// previous tag size
			
			// tag header
			
			flvBytes.writeByte(0x00);						// reserved for FMS
			flvBytes.writeByte(0x00);						// unencrypted
			
			flvBytes.writeByte(0x09);						// type, video
			
			var length:uint = bytes.length - 11;			// body length
			flvBytes.writeByte((length >> 16) & 0xff);		// 24 bit
			flvBytes.writeByte((length >>  8) & 0xff);
			flvBytes.writeByte((length      ) & 0xff);
			
			var timestamp:uint = boo;						// timestamp
			flvBytes.writeByte((timestamp >> 16) & 0xff);	// 24 bit
			flvBytes.writeByte((timestamp >>  8) & 0xff);
			flvBytes.writeByte((timestamp      ) & 0xff);
			flvBytes.writeByte((timestamp >> 24) & 0xff);	// extended 8 bit
			boo += 25000;
			
			flvBytes.writeByte(0x00); 						// stream id
			flvBytes.writeByte(0x00); 						// stream id
			flvBytes.writeByte(0x00); 						// stream id
			
			// video tag header
			
			
			
			// video data
			
			flvBytes.writeBytes(bytes);
			
			clear();
			
			return flvBytes;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function FLVConverter() {
			
		}
	}
}