package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MfhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var sequenceNumber:int;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();
			sequenceNumber = bitStream.readUInt32();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MfhdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MFHD, data);
		}
	}
}
