package net.digitalprimates.dash.valueObjects
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

		private var _baseMediaDecodeTime:Number;

		public function get baseMediaDecodeTime():Number {
			return _baseMediaDecodeTime;
		}

		public function set baseMediaDecodeTime(value:Number):void {
			_baseMediaDecodeTime = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);

			if (version == 1) {
				baseMediaDecodeTime = data.readDouble();
			} else {
				baseMediaDecodeTime = data.readUnsignedInt();
			}

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TfdtBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TFDT, data);
		}
	}
}
