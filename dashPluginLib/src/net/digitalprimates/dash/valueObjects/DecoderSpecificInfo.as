package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DecoderSpecificInfo extends Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _configData:ByteArray;

		public function get configData():ByteArray {
			return _configData;
		}

		public function set configData(value:ByteArray):void {
			_configData = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			if (bitStream && bitStream.bytesAvailable > 0) {
				super.parse();

				configData = new ByteArray();
				bitStream.readBytes(configData, 0, sizeOfInstance);
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DecoderSpecificInfo(data:BitStream = null) {
			super(data);
		}
	}
}
