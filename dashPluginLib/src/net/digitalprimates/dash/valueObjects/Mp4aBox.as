package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Mp4aBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _dataReferenceIndex:int;

		public function get dataReferenceIndex():int {
			return _dataReferenceIndex;
		}

		public function set dataReferenceIndex(value:int):void {
			_dataReferenceIndex = value;
		}

		private var _revision:int;

		public function get revision():int {
			return _revision;
		}

		public function set revision(value:int):void {
			_revision = value;
		}

		private var _vendor:int;

		public function get vendor():int {
			return _vendor;
		}

		public function set vendor(value:int):void {
			_vendor = value;
		}

		private var _channelCount:int;

		public function get channelCount():int {
			return _channelCount;
		}

		public function set channelCount(value:int):void {
			_channelCount = value;
		}

		private var _bitsPerSample:int;

		public function get bitsPerSample():int {
			return _bitsPerSample;
		}

		public function set bitsPerSample(value:int):void {
			_bitsPerSample = value;
		}

		private var _compressionId:int;

		public function get compressionId():int {
			return _compressionId;
		}

		public function set compressionId(value:int):void {
			_compressionId = value;
		}

		private var _packetSize:int;

		public function get packetSize():int {
			return _packetSize;
		}

		public function set packetSize(value:int):void {
			_packetSize = value;
		}

		private var _sampleRateHi:int;

		public function get sampleRateHi():int {
			return _sampleRateHi;
		}

		public function set sampleRateHi(value:int):void {
			_sampleRateHi = value;
		}

		private var _sampleRateLo:int;

		public function get sampleRateLo():int {
			return _sampleRateLo;
		}

		public function set sampleRateLo(value:int):void {
			_sampleRateLo = value;
		}

		private var _esds:EsdsBox;

		public function get esds():EsdsBox {
			return _esds;
		}

		public function set esds(value:EsdsBox):void {
			_esds = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			data.position += 6;

			dataReferenceIndex = data.readUnsignedShort();
			version = data.readUnsignedShort();
			revision = data.readUnsignedShort();
			vendor = data.readUnsignedInt();
			channelCount = data.readUnsignedShort();
			bitsPerSample = data.readUnsignedShort();
			compressionId = data.readUnsignedShort();
			packetSize = data.readUnsignedShort();
			sampleRateHi = data.readUnsignedShort();
			sampleRateLo = data.readUnsignedShort();

			if (version == 1) {
				data.position += 16;
			}
			else if (version == 2) {
				data.position += 36;
			}

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
					case BOX_TYPE_ESDS:
						esds = new EsdsBox(size, boxData);
						break;
				}
			}

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Mp4aBox(size:int, type:String, data:ByteArray = null) {
			super(size, type, data);
		}
	}
}
