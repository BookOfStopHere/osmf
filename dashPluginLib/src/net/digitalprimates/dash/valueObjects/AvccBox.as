package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class AvccBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _configRecord:ByteArray;

		public function get configRecord():ByteArray {
			return _configRecord;
		}

		public function set configRecord(value:ByteArray):void {
			_configRecord = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			configRecord = new ByteArray();
			data.readBytes(configRecord, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function AvccBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_AVCC, data);
		}
	}
}
