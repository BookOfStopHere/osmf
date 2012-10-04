package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoofBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _mfhd:MfhdBox;

		public function get mfhd():MfhdBox {
			return _mfhd;
		}

		public function set mfhd(value:MfhdBox):void {
			_mfhd = value;
		}

		private var _tracks:Vector.<TrafBox>;

		public function get tracks():Vector.<TrafBox> {
			return _tracks;
		}

		public function set tracks(value:Vector.<TrafBox>):void {
			_tracks = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function setChildBox(box:BoxInfo):void {
			if (!tracks)
				tracks = new Vector.<TrafBox>();
			
			if (box is TrafBox) {
				tracks.push(box as TrafBox);
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

		public function MoofBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MOOF, data);
		}
	}
}
