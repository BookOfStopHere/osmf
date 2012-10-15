package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MinfBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var vmhd:BoxInfo;
		public var dinf:DinfBox;
		public var stbl:StblBox;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MinfBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MINF, data);
		}
	}
}
