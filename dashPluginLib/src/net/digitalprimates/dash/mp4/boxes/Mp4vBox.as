package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Mp4vBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var dataReferenceIndex:int;
		public var revision:int;
		public var vendor:int;
		public var temporalQuality:int;
		public var spatialQuality:int;
		public var width:int;
		public var height:int;
		public var horizRes:int;
		public var vertRes:int;
		public var entryDataSize:int;
		public var framesPerSample:int;
		public var compressorName:String;
		public var bitDepth:int;
		public var colorTableIndex:int;
		public var avcC:AvccBox;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function setChildBox(box:BoxInfo):void {
			if (box.type == BoxInfo.BOX_TYPE_AVCC)
				avcC = box as AvccBox;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			bitStream.readUTFBytes(6); // reserved

			dataReferenceIndex = bitStream.readUInt16();
			version = bitStream.readUInt16();
			revision = bitStream.readUInt16();
			vendor = bitStream.readUInt32();
			temporalQuality = bitStream.readUInt32();
			spatialQuality = bitStream.readUInt32();
			width = bitStream.readUInt16();
			height = bitStream.readUInt16();
			horizRes = bitStream.readUInt16();
			bitStream.readUInt16(); // TODO : This is a uint32 read in gpac, but to get the right value I have to read two shorts and toss the second one.
			vertRes = bitStream.readUInt16();
			bitStream.readUInt16(); // TODO : This is a uint32 read in gpac, but to get the right value I have to read two shorts and toss the second one.
			entryDataSize = bitStream.readUInt32();
			framesPerSample = bitStream.readUInt16();
			compressorName = bitStream.readUTFBytes(32);
			bitDepth = bitStream.readUInt16();
			colorTableIndex = bitStream.readUInt16();
			
			super.parse();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Mp4vBox(size:int, type:String, data:ByteArray = null) {
			super(size, type, data);
		}
	}
}
