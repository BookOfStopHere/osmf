package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MfhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _sequenceNumber:int;

		public function get sequenceNumber():int {
			return _sequenceNumber;
		}

		public function set sequenceNumber(value:int):void {
			_sequenceNumber = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			var childDescriptor:Object = readFullBox(data);

			subType = childDescriptor.type;
			flags = childDescriptor.flags;
			sequenceNumber = data.readInt();
			
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MfhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MFHD, data);
		}
	}
}
