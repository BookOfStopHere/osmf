package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.utils.Log;

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

		private var _baseMediaDecodeTime:uint;

		public function get baseMediaDecodeTime():uint {
			return _baseMediaDecodeTime;
		}

		public function set baseMediaDecodeTime(value:uint):void {
			_baseMediaDecodeTime = value;
		}

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

			bitStream.position = 0;
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
