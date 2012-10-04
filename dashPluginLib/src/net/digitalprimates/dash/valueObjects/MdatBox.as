package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class MdatBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public function get sampleData():ByteArray {
			return existingData;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function MdatBox(size:int, data:ByteArray=null) {
			super(size, BoxInfo.BOX_TYPE_MDAT, data);
		}
	}
}