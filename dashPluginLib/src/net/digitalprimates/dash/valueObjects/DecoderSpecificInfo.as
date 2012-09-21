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
			if (data && data.bytesAvailable > 0) {
				super.parse();

				configData = new ByteArray();
				data.readBytes(configData, 0, size);
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DecoderSpecificInfo(data:ByteArray = null) {
			super(data);
		}
	}
}
