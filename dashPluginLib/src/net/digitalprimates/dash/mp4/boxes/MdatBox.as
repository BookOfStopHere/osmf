package net.digitalprimates.dash.mp4.boxes
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