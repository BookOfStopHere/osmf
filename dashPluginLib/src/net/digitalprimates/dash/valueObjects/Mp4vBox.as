package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Mp4vBox extends BoxInfo
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

		private var _temporalQuality:int;

		public function get temporalQuality():int {
			return _temporalQuality;
		}

		public function set temporalQuality(value:int):void {
			_temporalQuality = value;
		}

		private var _spatialQuality:int;

		public function get spatialQuality():int {
			return _spatialQuality;
		}

		public function set spatialQuality(value:int):void {
			_spatialQuality = value;
		}

		private var _width:int;

		public function get width():int {
			return _width;
		}

		public function set width(value:int):void {
			_width = value;
		}

		private var _height:int;

		public function get height():int {
			return _height;
		}

		public function set height(value:int):void {
			_height = value;
		}

		private var _horizRes:int;

		public function get horizRes():int {
			return _horizRes;
		}

		public function set horizRes(value:int):void {
			_horizRes = value;
		}

		private var _vertRes:int;

		public function get vertRes():int {
			return _vertRes;
		}

		public function set vertRes(value:int):void {
			_vertRes = value;
		}

		private var _entryDataSize:int;

		public function get entryDataSize():int {
			return _entryDataSize;
		}

		public function set entryDataSize(value:int):void {
			_entryDataSize = value;
		}

		private var _framesPerSample:int;

		public function get framesPerSample():int {
			return _framesPerSample;
		}

		public function set framesPerSample(value:int):void {
			_framesPerSample = value;
		}

		private var _compressorName:String;

		public function get compressorName():String {
			return _compressorName;
		}

		public function set compressorName(value:String):void {
			_compressorName = value;
		}

		private var _bitDepth:int;

		public function get bitDepth():int {
			return _bitDepth;
		}

		public function set bitDepth(value:int):void {
			_bitDepth = value;
		}

		private var _colorTableIndex:int;

		public function get colorTableIndex():int {
			return _colorTableIndex;
		}

		public function set colorTableIndex(value:int):void {
			_colorTableIndex = value;
		}
		
		private var _avcC:AvccBox;

		public function get avcC():AvccBox {
			return _avcC;
		}

		public function set avcC(value:AvccBox):void {
			_avcC = value;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			bitStream.position += 6;

			dataReferenceIndex = bitStream.readUInt16();
			version = bitStream.readUInt16();
			revision = bitStream.readUInt16();
			vendor = bitStream.readUInt32();
			temporalQuality = bitStream.readUInt32();
			spatialQuality = bitStream.readUInt32();
			width = bitStream.readUInt16();
			height = bitStream.readUInt16();
			horizRes = bitStream.readUInt16();
			bitStream.readUInt16(); // TODO : This is a uint32 read in gpac, but to get the right value I have to read two shorts and toss the second one.
			vertRes = bitStream.readUInt16();
			bitStream.readUInt16(); // TODO : This is a uint32 read in gpac, but to get the right value I have to read two shorts and toss the second one.
			entryDataSize = bitStream.readUInt32();
			framesPerSample = bitStream.readUInt16();
			compressorName = bitStream.readUTFBytes(32);
			bitDepth = bitStream.readUInt16();
			colorTableIndex = bitStream.readUInt16();

			parseChildrenBoxes();
			
			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Mp4vBox(size:int, type:String, data:ByteArray = null) {
			super(size, type, data);
		}
	}
}
