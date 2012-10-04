package net.digitalprimates.dash.valueObjects
{
	import net.digitalprimates.dash.utils.BaseDescriptorFactory;
	import net.digitalprimates.dash.utils.IDescriptorFactory;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DecoderConfigDescriptor extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _objectTypeIndication:uint;

		public function get objectTypeIndication():uint {
			return _objectTypeIndication;
		}

		public function set objectTypeIndication(value:uint):void {
			_objectTypeIndication = value;
		}

		private var _streamType:uint;

		public function get streamType():uint {
			return _streamType;
		}

		public function set streamType(value:uint):void {
			_streamType = value;
		}

		private var _upStream:uint;

		public function get upStream():uint {
			return _upStream;
		}

		public function set upStream(value:uint):void {
			_upStream = value;
		}

		private var _bufferSizeDB:uint;

		public function get bufferSizeDB():uint {
			return _bufferSizeDB;
		}

		public function set bufferSizeDB(value:uint):void {
			_bufferSizeDB = value;
		}

		private var _reservedFlag:uint;

		public function get reservedFlag():uint {
			return _reservedFlag;
		}

		public function set reservedFlag(value:uint):void {
			_reservedFlag = value;
		}

		private var _bufferSize:uint;

		public function get bufferSize():uint {
			return _bufferSize;
		}

		public function set bufferSize(value:uint):void {
			_bufferSize = value;
		}

		private var _maxBitRate:uint;

		public function get maxBitRate():uint {
			return _maxBitRate;
		}

		public function set maxBitRate(value:uint):void {
			_maxBitRate = value;
		}

		private var _avgBitRate:uint;

		public function get avgBitRate():uint {
			return _avgBitRate;
		}

		public function set avgBitRate(value:uint):void {
			_avgBitRate = value;
		}

		private var _decoderSpecificInfo:DecoderSpecificInfo;

		public function get decoderSpecificInfo():DecoderSpecificInfo {
			return _decoderSpecificInfo;
		}

		public function set decoderSpecificInfo(value:DecoderSpecificInfo):void {
			_decoderSpecificInfo = value;
		}

		private var _audioSpecificInfo:AudioSpecificInfo;

		public function get audioSpecificInfo():AudioSpecificInfo {
			return _audioSpecificInfo;
		}

		public function set audioSpecificInfo(value:AudioSpecificInfo):void {
			_audioSpecificInfo = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			if (bitStream && bitStream.bytesAvailable > 0) {
				super.parse();

				objectTypeIndication = bitStream.readUInt8();

				var bits:int = bitStream.readUInt8();
				streamType = bits >>> 2;
				upStream = (bits >> 1) & 0x1;

				bufferSizeDB = bitStream.readUInt24();
				maxBitRate = bitStream.readUInt32();
				avgBitRate = bitStream.readUInt32();
				
				parseChildrenDescriptors(objectTypeIndication);
			}
		}
		
		override protected function setChildDescriptor(descriptor:Descriptor):void {
			if (descriptor is DecoderSpecificInfo) {
				decoderSpecificInfo = (descriptor as DecoderSpecificInfo);
			}
			if (descriptor is AudioSpecificInfo) {
				audioSpecificInfo = (descriptor as AudioSpecificInfo);
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DecoderConfigDescriptor(data:BitStream = null) {
			super(data);
		}
	}
}
