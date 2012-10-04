package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdiaBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _mdhd:MdhdBox;

		public function get mdhd():MdhdBox {
			return _mdhd;
		}

		public function set mdhd(value:MdhdBox):void {
			_mdhd = value;
		}

		private var _hdlr:HdlrBox;

		public function get hdlr():HdlrBox {
			return _hdlr;
		}

		public function set hdlr(value:HdlrBox):void {
			_hdlr = value;
		}

		private var _minf:MinfBox;

		public function get minf():MinfBox {
			return _minf;
		}

		public function set minf(value:MinfBox):void {
			_minf = value;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MdiaBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MDIA, data);
		}
	}
}
