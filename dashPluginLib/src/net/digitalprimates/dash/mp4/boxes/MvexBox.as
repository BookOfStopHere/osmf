package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvexBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var mehd:MehdBox;
		public var trex:TrexBox;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvexBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MVEX, data);
		}
	}
}
