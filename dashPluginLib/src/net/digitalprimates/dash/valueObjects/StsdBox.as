package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StsdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _sampleEntries:Array;

		public function get sampleEntries():Array {
			return _sampleEntries;
		}

		public function set sampleEntries(value:Array):void {
			_sampleEntries = value;
		}

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
			parseChildrenBoxes();
			bitStream.position = 0;
		}
		
		override protected function setChildBox(box:BoxInfo):void {
			sampleEntries.push(box);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StsdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_STSD, data);
		}
	}
}
