package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StsdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _sampleEntries:Array;

		public function get sampleEntries():Array {
			return _sampleEntries;
		}

		public function set sampleEntries(value:Array):void {
			_sampleEntries = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			stsd			sample descriptions (codec types, initialization etc.)
				avc1
					avcC
				mp4a
					esds
			*/

			readFullBox(bitStream, this);

			var nbEntries:int = data.readUnsignedInt(); //number of child boxes

			var ba:ByteArray;
			var size:int;
			var type:String;
			var boxData:ByteArray;
			var box:BoxInfo;

			while (data.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				ba = new ByteArray();
				data.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);

				size = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
				type = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);

				if (size < BoxInfo.SIZE_AND_TYPE_LENGTH)
					continue;

				boxData = new ByteArray();
				data.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);

				sampleEntries = [];
				
				switch (type) {
					case BOX_TYPE_MP4V:
					case BOX_TYPE_AVC1:
						box = new Mp4vBox(size, type, boxData);
						break;
					case BOX_TYPE_MP4A:
						box = new Mp4aBox(size, type, boxData);
						break;
				}
				
				sampleEntries.push(box);
			}

			// reset
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StsdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_STSD, data);
		}
	}
}
