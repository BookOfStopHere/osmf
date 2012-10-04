package net.digitalprimates.dash.valueObjects
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

		private var _fragmentDuration:Number;

		public function get fragmentDuration():Number {
			return _fragmentDuration;
		}

		public function set fragmentDuration(value:Number):void {
			_fragmentDuration = value;
		}

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

			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MehdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MEHD, data);
		}
	}
}
