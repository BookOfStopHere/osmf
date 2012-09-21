package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoofBox extends BoxInfo
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

		private var _traf:TrafBox;

		public function get traf():TrafBox {
			return _traf;
		}

		public function set traf(value:TrafBox):void {
			_traf = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			moof			movie fragment
				mfhd		movie fragment header
				traf		track fragment
					tfhd	track fragment header
					tfdt	track fragment decode time
					trun	track fragment run
			*/

			var ba:ByteArray;
			var size:int;
			var type:String;
			var boxData:ByteArray;

			while (data.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				ba = new ByteArray();
				data.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);

				size = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
				type = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);

				boxData = new ByteArray();
				data.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);

				switch (type) {
					case BOX_TYPE_MFHD:
						mfhd = new MfhdBox(size, boxData);
						break;
					case BOX_TYPE_TRAF:
						traf = new TrafBox(size, boxData);
						break;
				}
			}

			// reset
			data.position = 0;
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
