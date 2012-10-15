package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TfdtBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var baseMediaDecodeTime:uint;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			if (version == 1) {
				baseMediaDecodeTime = bitStream.readUInt64();
			} else {
				baseMediaDecodeTime = bitStream.readUInt32();
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TfdtBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TFDT, data);
		}
	}
}
