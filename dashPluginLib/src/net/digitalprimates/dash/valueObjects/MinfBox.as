package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MinfBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _vmhd:BoxInfo;

		public function get vmhd():BoxInfo {
			return _vmhd;
		}

		public function set vmhd(value:BoxInfo):void {
			_vmhd = value;
		}

		private var _dinf:DinfBox;

		public function get dinf():DinfBox {
			return _dinf;
		}

		public function set dinf(value:DinfBox):void {
			_dinf = value;
		}

		private var _stbl:StblBox;

		public function get stbl():StblBox {
			return _stbl;
		}

		public function set stbl(value:StblBox):void {
			_stbl = value;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MinfBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MINF, data);
		}
	}
}
