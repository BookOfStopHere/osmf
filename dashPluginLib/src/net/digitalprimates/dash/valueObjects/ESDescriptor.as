package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

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

		private var _esId:int;

		public function get esId():int {
			return _esId;
		}

		public function set esId(value:int):void {
			_esId = value;
		}

		private var _bits:int;

		public function get bits():int {
			return _bits;
		}

		public function set bits(value:int):void {
			_bits = value;
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
			if (data && data.bytesAvailable > 0) {
				super.parse();

				esId = data.readUnsignedShort();
				bits = data.readUnsignedByte();
				decoderConfigDescriptor = new DecoderConfigDescriptor(data);
				slConfigDescriptor = new SLConfigDescriptor(data);
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function ESDescriptor(data:ByteArray = null) {
			super(data);
		}
	}
}
