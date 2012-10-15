package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdiaBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var mdhd:MdhdBox;
		public var hdlr:HdlrBox;
		public var minf:MinfBox;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MdiaBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MDIA, data);
		}
	}
}
