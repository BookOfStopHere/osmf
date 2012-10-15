package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DinfBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var dref:BoxInfo;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DinfBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_DINF, data);
		}
	}
}