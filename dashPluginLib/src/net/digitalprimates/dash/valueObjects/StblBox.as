package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StblBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _stsd:StsdBox;

		public function get stsd():StsdBox {
			return _stsd;
		}

		public function set stsd(value:StsdBox):void {
			_stsd = value;
		}

		private var _stts:BoxInfo;

		public function get stts():BoxInfo {
			return _stts;
		}

		public function set stts(value:BoxInfo):void {
			_stts = value;
		}

		private var _stsc:StscBox;

		public function get stsc():StscBox {
			return _stsc;
		}

		public function set stsc(value:StscBox):void {
			_stsc = value;
		}

		private var _stsz:BoxInfo;

		public function get stsz():BoxInfo {
			return _stsz;
		}

		public function set stsz(value:BoxInfo):void {
			_stsz = value;
		}

		private var _stco:BoxInfo;

		public function get stco():BoxInfo {
			return _stco;
		}

		public function set stco(value:BoxInfo):void {
			_stco = value;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StblBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_STBL, data);
		}
	}
}
