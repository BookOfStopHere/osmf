package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class StblBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var stsd:StsdBox;
		public var stts:BoxInfo;
		public var stsc:StscBox;
		public var stsz:BoxInfo;
		public var stco:BoxInfo;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function StblBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_STBL, data);
		}
	}
}
