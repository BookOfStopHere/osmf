package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvexBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _mehd:MehdBox;

		public function get mehd():MehdBox {
			return _mehd;
		}

		public function set mehd(value:MehdBox):void {
			_mehd = value;
		}

		private var _trex:TrexBox;

		public function get trex():TrexBox {
			return _trex;
		}

		public function set trex(value:TrexBox):void {
			_trex = value;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvexBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MVEX, data);
		}
	}
}
