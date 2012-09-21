package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StblBox extends BoxInfo
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

		private var _stts:SttsBox;

		public function get stts():SttsBox {
			return _stts;
		}

		public function set stts(value:SttsBox):void {
			_stts = value;
		}

		private var _stsc:StscBox;

		public function get stsc():StscBox {
			return _stsc;
		}

		public function set stsc(value:StscBox):void {
			_stsc = value;
		}

		private var _stsz:StszBox;

		public function get stsz():StszBox {
			return _stsz;
		}

		public function set stsz(value:StszBox):void {
			_stsz = value;
		}

		private var _stco:StcoBox;

		public function get stco():StcoBox {
			return _stco;
		}

		public function set stco(value:StcoBox):void {
			_stco = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			stbl				sample table box, container for the time/space map
				stsd			sample descriptions (codec types, initialization etc.)
					avc1
						avcC
				stts			(decoding) time-to-sample
				stsc			sample-to-chunk, partial data-offset information
				stsz			sample sizes (framing)
				stco			chunk offset, partial data-offset information
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
					case BOX_TYPE_STSD:
						stsd = new StsdBox(size, boxData);
						break;
					case BOX_TYPE_STTS:
						stts = new SttsBox(size, boxData);
						break;
					case BOX_TYPE_STSC:
						stsc = new StscBox(size, boxData);
						break;
					case BOX_TYPE_STSZ:
						stsz = new StszBox(size, boxData);
						break;
					case BOX_TYPE_STCO:
						stco = new StcoBox(size, boxData);
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

		public function StblBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_STBL, data);
		}
	}
}
