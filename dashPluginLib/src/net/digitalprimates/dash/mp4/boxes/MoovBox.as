package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoovBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var mvhd:MvhdBox;
		public var mvex:MvexBox;
		public var tracks:Vector.<TrakBox>;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function setChildBox(box:BoxInfo):void {
			if (!tracks)
				tracks = new Vector.<TrakBox>();
			
			if (box is TrakBox) {
				tracks.push(box as TrakBox);
			}
			else {
				super.setChildBox(box);
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MoovBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MOOV, data);
		}
	}
}
