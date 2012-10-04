package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoovBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _mvhd:MvhdBox;

		public function get mvhd():MvhdBox {
			return _mvhd;
		}

		public function set mvhd(value:MvhdBox):void {
			_mvhd = value;
		}

		private var _mvex:MvexBox;

		public function get mvex():MvexBox {
			return _mvex;
		}

		public function set mvex(value:MvexBox):void {
			_mvex = value;
		}

		private var _tracks:Vector.<TrakBox>;

		public function get tracks():Vector.<TrakBox> {
			return _tracks;
		}

		public function set tracks(value:Vector.<TrakBox>):void {
			_tracks = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function setChildBox(box:BoxInfo):void {
			if (!tracks)
				tracks = new Vector.<TrakBox>();
			
			if (box is TrakBox) {
				tracks.push(box as TrakBox);
			}
			else {
				super.setChildBox(box);
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MoovBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MOOV, data);
		}
	}
}
