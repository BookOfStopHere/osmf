package net.digitalprimates.dash.mp4.descriptors
{
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class ESDescriptor extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var esId:uint;
		public var streamDependenceFlag:int;
		public var URLFlag:int;
		public var oCRstreamFlag:int;
		public var streamPriority:int;
		public var dependsOnEsId:int;
		public var URLLength:int;
		public var URLString:String;
		public var oCREsId:int;
		public var decoderConfigDescriptor:DecoderConfigDescriptor;
		public var slConfigDescriptor:SLConfigDescriptor;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			super.parse();

			esId = bitStream.readUInt16();

			var bits:int = bitStream.readUInt8();
			streamDependenceFlag = bits >>> 7;
			URLFlag = (bits >>> 6) & 0x1;
			oCRstreamFlag = (bits >>> 5) & 0x1;
			streamPriority = bits & 0x1f;

			if (streamDependenceFlag == 1) {
				dependsOnEsId = bitStream.readUInt16();
			}
			if (URLFlag == 1) {
				URLLength = bitStream.readUInt8();
				URLString = bitStream.readUTFBytes(URLLength);
			}
			if (oCRstreamFlag == 1) {
				oCREsId = bitStream.readUInt16();
			}
			
			parseChildrenDescriptors();
		}

		override protected function setChildDescriptor(descriptor:Descriptor):void {
			if (descriptor is DecoderConfigDescriptor) {
				decoderConfigDescriptor = (descriptor as DecoderConfigDescriptor);
			}
			if (descriptor is SLConfigDescriptor) {
				slConfigDescriptor = (descriptor as SLConfigDescriptor);
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function ESDescriptor(data:BitStream = null) {
			super(data);
		}
	}
}
