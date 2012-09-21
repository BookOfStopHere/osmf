package net.digitalprimates.dash.valueObjects
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
			readFullBox(bitStream, this);

			data.readUnsignedInt(); // reserved
			handlerType = data.readUTFBytes(4);
			
			data.readUTFBytes(12); // reserved
			name = data.readUTFBytes(data.bytesAvailable);
			
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function HdlrBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_HDLR, data);
		}
	}
}
