package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class TrafBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			/*
			moof			movie fragment
				mfhd		movie fragment header
				traf		track fragment
					tfhd	track fragment header
					tfdt	track fragment decode time
					trun	track fragment run
			*/
			
			childrenBoxes = new Vector.<BoxInfo>();
			
			var ba:ByteArray;
			var size:int;
			var type:String;
			var boxData:ByteArray;
			var box:BoxInfo;
			
			while (data.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				ba = new ByteArray();
				data.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);
				
				size = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
				type = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);
				
				boxData = new ByteArray();
				data.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);
				
				switch (type) {
					case BOX_TYPE_TFHD:
						box = new TfhdBox(size, boxData);
						break;
					case BOX_TYPE_TFDT:
						box = new TfdtBox(size, boxData);
						break;
					case BOX_TYPE_TRUN:
						box = new TrunBox(size, boxData);
						break;
					default:
						box = new BoxInfo(size, type, boxData);
						break;
				}
				
				childrenBoxes.push(box);
			}
			
			// reset
			data.position = 0;
		}
		
		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Lifecycle
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function TrafBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TRAF, data);
		}
	}
}