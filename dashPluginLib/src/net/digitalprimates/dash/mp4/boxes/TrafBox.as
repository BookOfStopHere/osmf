package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TrafBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var tfhd:TfhdBox;
		public var tfdt:TfdtBox;
		public var trun:TrunBox;
		
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
