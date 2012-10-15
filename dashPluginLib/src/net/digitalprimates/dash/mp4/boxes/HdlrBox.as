package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class HdlrBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const HANDLER_TYPE_VIDEO:String = "vide";
		public static const HANDLER_TYPE_AUDIO:String = "soun";
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var handlerType:String;
		public var name:String;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			bitStream.readUInt32(); // reserved
			handlerType = bitStream.readUTFBytes(4);
			
			bitStream.readUTFBytes(12); // reserved
			
			name = bitStream.readUTFBytes(bitStream.bytesAvailable);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function HdlrBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_HDLR, data);
		}
	}
}
