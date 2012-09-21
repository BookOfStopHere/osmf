package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MinfBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _vmhd:VmhdBox;

		public function get vmhd():VmhdBox {
			return _vmhd;
		}

		public function set vmhd(value:VmhdBox):void {
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
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			minf					media information container
				vmhd				video media header, overall information (video track only)
				dinf				data information box, container
					dref			data reference box, declares source(s) of media data in track
						url
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
					case BOX_TYPE_VMHD:
						vmhd = new VmhdBox(size, boxData);
						break;
					case BOX_TYPE_DINF:
						dinf = new DinfBox(size, boxData);
						break;
					case BOX_TYPE_STBL:
						stbl = new StblBox(size, boxData);
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

		public function MinfBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MINF, data);
		}
	}
}
