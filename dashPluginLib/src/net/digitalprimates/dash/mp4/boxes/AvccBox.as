package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class AvccBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var configRecord:ByteArray;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			configRecord = new ByteArray();
			bitStream.readBytes(configRecord, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function AvccBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_AVCC, data);
		}
	}
}
