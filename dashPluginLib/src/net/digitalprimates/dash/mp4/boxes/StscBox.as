package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StscBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var nbEntries:int;
		private var entries:Array;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			parseVersionAndFlags();

			nbEntries = bitStream.readUInt32();
			entries = [];
			
			for (var i:int = 0; i < nbEntries; i++) {
				entries[i] = {};
				entries[i].firstChunk = bitStream.readUInt32();
				entries[i].samplesPerChunk = bitStream.readUInt32();
				entries[i].sampleDescriptionIndex = bitStream.readUInt32();
				entries[i].isEdited = 0;
				entries[i].nextChunk = 0;
				
				//update the next chunk in the previous entry
				if (i) entries[i-1].nextChunk = entries[i].firstChunk;
			}
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StscBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_STSC, data);
		}
	}
}
