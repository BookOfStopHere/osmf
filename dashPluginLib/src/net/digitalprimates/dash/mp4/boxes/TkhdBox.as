package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TkhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var creationTime:Number;
		public var modificationTime:Number;
		public var trackId:int;
		public var duration:Number;
		public var layer:uint;
		public var alternateGroup:uint;
		public var volume:uint;
		public var matrix:Array;
		public var width:Number;
		public var height:Number;

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
				trackId = bitStream.readUInt32();
				bitStream.readUInt32();
				duration = bitStream.readUInt64();
			}
			else {
				creationTime = bitStream.readUInt32();
				modificationTime = bitStream.readUInt32();
				trackId = bitStream.readUInt32();
				bitStream.readUInt32();
				duration = bitStream.readUInt32();
			}
			
			bitStream.readUInt32();
			bitStream.readUInt32();
			layer = bitStream.readUInt16();
			alternateGroup = bitStream.readUInt16();
			volume = bitStream.readFixedPoint88();
			bitStream.readUInt16();
			
			matrix = [];
			for (var i:int = 0; i < 9; i++) {
				matrix[i] = bitStream.readUInt32();
			}
			
			width = bitStream.readFixedPoint1616();
			height = bitStream.readFixedPoint1616();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TkhdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TKHD, data);
		}
	}
}
