package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MehdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var fragmentDuration:Number;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			if (version == 1) {
				fragmentDuration = bitStream.readUInt64();
			}
			else {
				fragmentDuration = bitStream.readUInt32();
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MehdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MEHD, data);
		}
	}
}
