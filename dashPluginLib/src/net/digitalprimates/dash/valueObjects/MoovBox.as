package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoovBox extends BoxInfo
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

		private var _trak:TrakBox;

		public function get trak():TrakBox {
			return _trak;
		}

		public function set trak(value:TrakBox):void {
			_trak = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			moov								container for all the metadata
				mvhd							movie header, overall declarations
				mvex							movie extends box
					mehd						movie extends header box
					trex						track extends defaults
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
					case BOX_TYPE_MVHD:
						mvhd = new MvhdBox(size, boxData);
						break;
					case BOX_TYPE_MVEX:
						mvex = new MvexBox(size, boxData);
						break;
					case BOX_TYPE_TRAK:
						trak = new TrakBox(size, boxData);
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

		public function MoovBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MOOV, data);
		}
	}
}
