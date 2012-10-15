package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Mp4aBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var bitStreamReferenceIndex:int;
		public var revision:int;
		public var vendor:int;
		public var channelCount:int;
		public var bitsPerSample:int;
		public var compressionId:int;
		public var packetSize:int;
		public var sampleRateHi:int;
		public var sampleRateLo:int;
		public var esds:EsdsBox;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			bitStream.readUTFBytes(6); // reserved

			bitStreamReferenceIndex = bitStream.readUInt16();
			version = bitStream.readUInt16();
			revision = bitStream.readUInt16();
			vendor = bitStream.readUInt32();
			channelCount = bitStream.readUInt16();
			bitsPerSample = bitStream.readUInt16();
			compressionId = bitStream.readUInt16();
			packetSize = bitStream.readUInt16();
			sampleRateHi = bitStream.readUInt16();
			sampleRateLo = bitStream.readUInt16();

			if (version == 1) {
				bitStream.readUTFBytes(16); // reserved
			}
			else if (version == 2) {
				bitStream.readUTFBytes(36); // reserved
			}
			
			super.parse();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Mp4aBox(size:int, type:String, data:ByteArray = null) {
			super(size, type, data);
		}
	}
}
