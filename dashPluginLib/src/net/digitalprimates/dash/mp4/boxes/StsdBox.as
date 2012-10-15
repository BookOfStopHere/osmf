package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StsdBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var sampleEntries:Array;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			/*
			stsd			sample descriptions (codec types, initialization etc.)
				avc1
					avcC
				mp4a
					esds
			*/
			parseVersionAndFlags();
			
			var nbEntries:int = bitStream.readUInt32(); //number of child boxes
			sampleEntries = [];
			
			super.parse();
		}
		
		override protected function setChildBox(box:BoxInfo):void {
			sampleEntries.push(box);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StsdBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_STSD, data);
		}
	}
}
