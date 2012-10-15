package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var creationTime:Number;
		public var modificationTime:Number;
		public var timescale:int;
		public var duration:Number;
		public var language:String;
		public var reserved:uint;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			if (version == 1) {
				creationTime = bitStream.readUInt64();
				modificationTime = bitStream.readUInt64();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt64();
			}
			else {
				creationTime = bitStream.readUInt32();
				modificationTime = bitStream.readUInt32();
				timescale = bitStream.readUInt32();
				duration = bitStream.readUInt32();
			}

			language = bitStream.readIso639();
			reserved = bitStream.readUInt16();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MdhdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MDHD, data);
		}
	}
}
