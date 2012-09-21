package net.digitalprimates.dash.valueObjects
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
			readFullBox(bitStream, this);

			nbEntries = data.readUnsignedInt();
			entries = [];
			
			for (var i:int = 0; i < nbEntries; i++) {
				entries[i] = {};
				entries[i].firstChunk = data.readUnsignedInt();
				entries[i].samplesPerChunk = data.readUnsignedInt();
				entries[i].sampleDescriptionIndex = data.readUnsignedInt();
				entries[i].isEdited = 0;
				entries[i].nextChunk = 0;
				
				//update the next chunk in the previous entry
				if (i) entries[i-1].nextChunk = entries[i].firstChunk;
			}
			
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StscBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_STSC, data);
		}
	}
}
