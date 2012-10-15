package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	
	/**
	 * A box that only contains children boxes.
	 * 
	 * @author Nathan Weber
	 */
	public class ParentBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			parseChildrenBoxes();
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function ParentBox(size:int, type:String, data:ByteArray=null) {
			super(size, type, data);
		}
	}
}