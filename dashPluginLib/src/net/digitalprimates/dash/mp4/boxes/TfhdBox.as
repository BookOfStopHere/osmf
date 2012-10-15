package net.digitalprimates.dash.mp4.boxes
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

		public static const GF_ISOM_TRAF_BASE_OFFSET:uint = 0x01;
		public static const GF_ISOM_TRAF_SAMPLE_DESC:uint = 0x02;
		public static const GF_ISOM_TRAF_SAMPLE_DUR:uint = 0x08;
		public static const GF_ISOM_TRAF_SAMPLE_SIZE:uint = 0x10;
		public static const GF_ISOM_TRAF_SAMPLE_FLAGS:uint = 0x20;
		public static const GF_ISOM_TRAF_DUR_EMPTY:uint = 0x10000;

		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var trackId:int = 0;
		public var baseDataOffset:Number = 0;
		public var sampleDescIndex:int = 0;
		public var defSampleDuration:int = 0;
		public var defSampleSize:int = 0;
		public var defSampleFlags:int = 0;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			trackId = bitStream.readUInt32();

			//The rest depends on the flags
			if (flags & GF_ISOM_TRAF_BASE_OFFSET) {
				baseDataOffset = bitStream.readUInt64();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_DESC) {
				sampleDescIndex = bitStream.readUInt32();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_DUR) {
				defSampleDuration = bitStream.readUInt32();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_SIZE) {
				defSampleSize = bitStream.readUInt32();
			}
			if (flags & GF_ISOM_TRAF_SAMPLE_FLAGS) {
				defSampleFlags = bitStream.readUInt32();
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TfhdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TFHD, data);
		}
	}
}
