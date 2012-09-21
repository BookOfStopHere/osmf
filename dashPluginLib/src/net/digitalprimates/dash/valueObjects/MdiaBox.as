package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdiaBox extends BoxInfo
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
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
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
					case BOX_TYPE_MDHD:
						mdhd = new MdhdBox(size, boxData);
						break;
					case BOX_TYPE_HDLR:
						hdlr = new HdlrBox(size, boxData);
						break;
					case BOX_TYPE_MINF:
						minf = new MinfBox(size, boxData);
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

		public function MdiaBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MDIA, data);
		}
	}
}
