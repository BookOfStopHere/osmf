package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrafBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _tfhd:TfhdBox;

		public function get tfhd():TfhdBox {
			return _tfhd;
		}

		public function set tfhd(value:TfhdBox):void {
			_tfhd = value;
		}

		private var _tfdt:TfdtBox;

		public function get tfdt():TfdtBox {
			return _tfdt;
		}

		public function set tfdt(value:TfdtBox):void {
			_tfdt = value;
		}

		private var _trun:TrunBox;

		public function get trun():TrunBox {
			return _trun;
		}

		public function set trun(value:TrunBox):void {
			_trun = value;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TrafBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TRAF, data);
		}
	}
}
