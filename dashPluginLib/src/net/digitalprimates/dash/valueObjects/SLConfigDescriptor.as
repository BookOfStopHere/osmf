package net.digitalprimates.dash.valueObjects
{
	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class SLConfigDescriptor extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _predefined:int;

		public function get predefined():int {
			return _predefined;
		}

		public function set predefined(value:int):void {
			_predefined = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			if (bitStream && bitStream.bytesAvailable > 0) {
				super.parse();

				predefined = bitStream.readUInt8();
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function SLConfigDescriptor(data:BitStream = null) {
			super(data);
		}
	}
}
