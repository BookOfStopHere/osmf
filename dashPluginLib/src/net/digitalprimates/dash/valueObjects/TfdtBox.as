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
			readFullBox(bitStream, this);

			if (version == 1) {
				baseMediaDecodeTime = BitStream.gf_bs_read_u64(this.bitStream);
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
