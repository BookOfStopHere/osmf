package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

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
		public var reservedFlag:uint;
		public var bufferSize:uint;
		public var maxBitRate:uint;
		public var avgBitRate:uint;
		public var decoderSpecificInfo:DecoderSpecificInfo;
		public var audioSpecificInfo:Object;
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			if (data && data.bytesAvailable > 0) {
				super.parse();
				
				objectTypeIndication = data.readUnsignedByte();
				streamType = data.readUnsignedByte();
				bufferSize = data.readUnsignedShort() + data.readUnsignedByte();
				maxBitRate = data.readUnsignedInt();
				avgBitRate = data.readUnsignedInt();
				
				if (objectTypeIndication == 64) {
					decoderSpecificInfo = new DecoderSpecificInfo(data);
				}
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DecoderConfigDescriptor(data:ByteArray = null) {
			super(data);
		}
	}
}