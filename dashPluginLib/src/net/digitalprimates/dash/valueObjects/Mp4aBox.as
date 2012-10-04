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

		private var _bitStreamReferenceIndex:int;

		public function get bitStreamReferenceIndex():int {
			return _bitStreamReferenceIndex;
		}

		public function set bitStreamReferenceIndex(value:int):void {
			_bitStreamReferenceIndex = value;
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
			bitStream.position += 6;

			bitStreamReferenceIndex = bitStream.readUInt16();
			version = bitStream.readUInt16();
			revision = bitStream.readUInt16();
			vendor = bitStream.readUInt32();
			channelCount = bitStream.readUInt16();
			bitsPerSample = bitStream.readUInt16();
			compressionId = bitStream.readUInt16();
			packetSize = bitStream.readUInt16();
			sampleRateHi = bitStream.readUInt16();
			sampleRateLo = bitStream.readUInt16();

			if (version == 1) {
				bitStream.position += 16;
			}
			else if (version == 2) {
				bitStream.position += 36;
			}
			
			parseChildrenBoxes();
			
			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Mp4aBox(size:int, type:String, bitStream:ByteArray = null) {
			super(size, type, bitStream);
		}
	}
}
