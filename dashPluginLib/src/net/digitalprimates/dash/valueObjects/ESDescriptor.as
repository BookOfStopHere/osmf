package net.digitalprimates.dash.valueObjects
{
	import net.digitalprimates.dash.utils.BaseDescriptorFactory;
	import net.digitalprimates.dash.utils.IDescriptorFactory;

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

		private var _esId:uint;

		public function get esId():uint {
			return _esId;
		}

		public function set esId(value:uint):void {
			_esId = value;
		}

		private var _streamDependenceFlag:int;

		public function get streamDependenceFlag():int {
			return _streamDependenceFlag;
		}

		public function set streamDependenceFlag(value:int):void {
			_streamDependenceFlag = value;
		}

		private var _URLFlag:int;

		public function get URLFlag():int {
			return _URLFlag;
		}

		public function set URLFlag(value:int):void {
			_URLFlag = value;
		}

		private var _oCRstreamFlag:int;

		public function get oCRstreamFlag():int {
			return _oCRstreamFlag;
		}

		public function set oCRstreamFlag(value:int):void {
			_oCRstreamFlag = value;
		}

		private var _streamPriority:int;

		public function get streamPriority():int {
			return _streamPriority;
		}

		public function set streamPriority(value:int):void {
			_streamPriority = value;
		}

		private var _dependsOnEsId:int;

		public function get dependsOnEsId():int {
			return _dependsOnEsId;
		}

		public function set dependsOnEsId(value:int):void {
			_dependsOnEsId = value;
		}

		private var _URLLength:int;

		public function get URLLength():int {
			return _URLLength;
		}

		public function set URLLength(value:int):void {
			_URLLength = value;
		}

		private var _URLString:String;

		public function get URLString():String {
			return _URLString;
		}

		public function set URLString(value:String):void {
			_URLString = value;
		}

		private var _oCREsId:int;

		public function get oCREsId():int {
			return _oCREsId;
		}

		public function set oCREsId(value:int):void {
			_oCREsId = value;
		}

		private var _decoderConfigDescriptor:DecoderConfigDescriptor;

		public function get decoderConfigDescriptor():DecoderConfigDescriptor {
			return _decoderConfigDescriptor;
		}

		public function set decoderConfigDescriptor(value:DecoderConfigDescriptor):void {
			_decoderConfigDescriptor = value;
		}

		private var _slConfigDescriptor:SLConfigDescriptor;

		public function get slConfigDescriptor():SLConfigDescriptor {
			return _slConfigDescriptor;
		}

		public function set slConfigDescriptor(value:SLConfigDescriptor):void {
			_slConfigDescriptor = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			if (bitStream && bitStream.bytesAvailable > 0) {
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
