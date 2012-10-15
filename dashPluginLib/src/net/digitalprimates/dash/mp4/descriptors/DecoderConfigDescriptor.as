package net.digitalprimates.dash.mp4.descriptors
{
	import net.digitalprimates.dash.valueObjects.BitStream;

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

		public var objectTypeIndication:uint;
		public var streamType:uint;
		public var upStream:uint;
		public var bufferSizeDB:uint;
		public var reservedFlag:uint;
		public var bufferSize:uint;
		public var maxBitRate:uint;
		public var avgBitRate:uint;
		public var decoderSpecificInfo:DecoderSpecificInfo;
		public var audioSpecificInfo:AudioSpecificInfo;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
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
