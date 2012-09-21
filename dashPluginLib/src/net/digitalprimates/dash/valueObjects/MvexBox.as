package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvexBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _mehd:MehdBox;

		public function get mehd():MehdBox {
			return _mehd;
		}

		public function set mehd(value:MehdBox):void {
			_mehd = value;
		}

		private var _trex:TrexBox;

		public function get trex():TrexBox {
			return _trex;
		}

		public function set trex(value:TrexBox):void {
			_trex = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			mvex							movie extends box
				mehd						movie extends header box
				trex						track extends defaults
			*/

			var ba:ByteArray;
			var size:int;
			var type:String;
			var boxData:ByteArray;

			while (data.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				ba = new ByteArray();
				data.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);

				size = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
				type = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);

				boxData = new ByteArray();
				data.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);

				switch (type) {
					case BOX_TYPE_MEHD:
						mehd = new MehdBox(size, boxData);
						break;
					case BOX_TYPE_TREX:
						trex = new TrexBox(size, boxData);
						break;
				}
			}

			// reset
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvexBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MVEX, data);
		}
	}
}
