package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var creationTime:Number;
		public var modificationTime:Number;
		public var timescale:Number;
		public var duration:Number;
		public var preferredRate:int;
		public var preferredVolume:int;
		public var matrixA:int;
		public var matrixB:int;
		public var matrixU:int;
		public var matrixC:int;
		public var matrixD:int;
		public var matrixV:int;
		public var matrixX:int;
		public var matrixY:int;
		public var matrixW:int;
		public var previewTime:int;
		public var previewDuration:int;
		public var posterTime:int;
		public var selectionTime:int;
		public var selectionDuration:int;
		public var currentTime:int;
		public var nextTrackID:int;

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

			preferredRate = bitStream.readUInt32();
			preferredVolume = bitStream.readUInt16();

			bitStream.readUTFBytes(10); // reserved

			matrixA = bitStream.readUInt32();
			matrixB = bitStream.readUInt32();
			matrixU = bitStream.readUInt32();
			matrixC = bitStream.readUInt32();
			matrixD = bitStream.readUInt32();
			matrixV = bitStream.readUInt32();
			matrixX = bitStream.readUInt32();
			matrixY = bitStream.readUInt32();
			matrixW = bitStream.readUInt32();
			previewTime = bitStream.readUInt32();
			previewDuration = bitStream.readUInt32();
			posterTime = bitStream.readUInt32();
			selectionTime = bitStream.readUInt32();
			selectionDuration = bitStream.readUInt32();
			currentTime = bitStream.readUInt32();
			nextTrackID = bitStream.readUInt32();
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvhdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MVHD, data);
		}
	}
}
