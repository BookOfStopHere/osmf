package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrakBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _tkhd:TkhdBox;

		public function get tkhd():TkhdBox {
			return _tkhd;
		}

		public function set tkhd(value:TkhdBox):void {
			_tkhd = value;
		}

		private var _mdia:MdiaBox;

		public function get mdia():MdiaBox {
			return _mdia;
		}

		public function set mdia(value:MdiaBox):void {
			_mdia = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			trak							container for an individual track or stream
				tkhd						track header, overall information about the track
				mdia						container for the media information in a track
					mdhd					media header, overall information about the media
					hdlr					handler, declares the media (handler) type
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
					case BOX_TYPE_TKHD:
						tkhd = new TkhdBox(size, boxData);
						break;
					case BOX_TYPE_MDIA:
						mdia = new MdiaBox(size, boxData);
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

		public function TrakBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TRAK, data);
		}
	}
}
