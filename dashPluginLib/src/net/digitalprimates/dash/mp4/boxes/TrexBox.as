package net.digitalprimates.dash.mp4.boxes
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

		public var trackID:int;
		public var defSampleDescIndex:int;
		public var defSampleDuration:int;
		public var defSampleSize:int;
		public var defSampleFlags:int;

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
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TrexBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TREX, data);
		}
	}
}
