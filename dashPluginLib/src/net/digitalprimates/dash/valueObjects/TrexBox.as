package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrexBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _trackID:int;

		public function get trackID():int {
			return _trackID;
		}

		public function set trackID(value:int):void {
			_trackID = value;
		}

		private var _defSampleDescIndex:int;

		public function get defSampleDescIndex():int {
			return _defSampleDescIndex;
		}

		public function set defSampleDescIndex(value:int):void {
			_defSampleDescIndex = value;
		}

		private var _defSampleDuration:int;

		public function get defSampleDuration():int {
			return _defSampleDuration;
		}

		public function set defSampleDuration(value:int):void {
			_defSampleDuration = value;
		}

		private var _defSampleSize:int;

		public function get defSampleSize():int {
			return _defSampleSize;
		}

		public function set defSampleSize(value:int):void {
			_defSampleSize = value;
		}

		private var _defSampleFlags:int;

		public function get defSampleFlags():int {
			return _defSampleFlags;
		}

		public function set defSampleFlags(value:int):void {
			_defSampleFlags = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			trackID = bitStream.readUInt32();
			defSampleDescIndex = bitStream.readUInt32();
			defSampleDuration = bitStream.readUInt32();
			defSampleSize = bitStream.readUInt32();
			defSampleFlags = bitStream.readUInt32();

			bitStream.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TrexBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TREX, data);
		}
	}
}
