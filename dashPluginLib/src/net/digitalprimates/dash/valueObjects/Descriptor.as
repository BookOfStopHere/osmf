package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Descriptor
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _data:ByteArray;

		public function get data():ByteArray {
			return _data;
		}

		public function set data(value:ByteArray):void {
			if (data == value)
				return;

			_data = value;
			parse();
		}

		private var _id:int;

		public function get id():int {
			return _id;
		}

		public function set id(value:int):void {
			_id = value;
		}

		private var _size:int;

		public function get size():int {
			return _size;
		}

		public function set size(value:int):void {
			_size = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		protected function parse():void {
			if (data && data.bytesAvailable > 0) {
				id = data.readUnsignedByte();
				size = data.readUnsignedByte();
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Descriptor(data:ByteArray = null) {
			this.data = data;
		}
	}
}
