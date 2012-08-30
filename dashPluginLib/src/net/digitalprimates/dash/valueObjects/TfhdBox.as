package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TfhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------

		private static const GF_ISOM_TRAF_BASE_OFFSET:uint = 0x01;
		private static const GF_ISOM_TRAF_SAMPLE_DESC:uint = 0x02;
		private static const GF_ISOM_TRAF_SAMPLE_DUR:uint = 0x08;
		private static const GF_ISOM_TRAF_SAMPLE_SIZE:uint = 0x10;
		private static const GF_ISOM_TRAF_SAMPLE_FLAGS:uint = 0x20;
		private static const GF_ISOM_TRAF_DUR_EMPTY:uint = 0x10000;

		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _trackID:int = -1;

		public function get trackID():int {
			return _trackID;
		}

		public function set trackID(value:int):void {
			_trackID = value;
		}

		private var _baseDataOffset:Number = -1;

		public function get baseDataOffset():Number {
			return _baseDataOffset;
		}

		public function set baseDataOffset(value:Number):void {
			_baseDataOffset = value;
		}

		private var _sampleDescIndex:int = -1;

		public function get sampleDescIndex():int {
			return _sampleDescIndex;
		}

		public function set sampleDescIndex(value:int):void {
			_sampleDescIndex = value;
		}

		private var _defSampleDuration:int = -1;

		public function get defSampleDuration():int {
			return _defSampleDuration;
		}

		public function set defSampleDuration(value:int):void {
			_defSampleDuration = value;
		}

		private var _defSampleSize:int = -1;

		public function get defSampleSize():int {
			return _defSampleSize;
		}

		public function set defSampleSize(value:int):void {
			_defSampleSize = value;
		}

		private var _defSampleFlags:int = -1;

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
			var childDescriptor:Object = readFullBox(data);

			subType = childDescriptor.type;
			flags = childDescriptor.flags;
			trackID = data.readInt();

			//The rest depends on the flags
			if (flags & GF_ISOM_TRAF_BASE_OFFSET) {
				baseDataOffset = data.readDouble();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_DESC) {
				sampleDescIndex = data.readInt();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_DUR) {
				defSampleDuration = data.readInt();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_SIZE) {
				defSampleSize = data.readInt();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_FLAGS) {
				defSampleFlags = data.readInt();
			}

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TfhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TFHD, data);
		}
	}
}
