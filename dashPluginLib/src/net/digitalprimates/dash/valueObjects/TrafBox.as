package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrafBox extends BoxInfo
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
					case BOX_TYPE_TFHD:
						tfhd = new TfhdBox(size, boxData);
						break;
					case BOX_TYPE_TFDT:
						tfdt = new TfdtBox(size, boxData);
						break;
					case BOX_TYPE_TRUN:
						trun = new TrunBox(size, boxData);
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

		public function TrafBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TRAF, data);
		}
	}
}
