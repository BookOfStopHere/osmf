package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MoofBox extends ParentBox
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var mfhd:MfhdBox;
		public var tracks:Vector.<TrafBox>;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function setChildBox(box:BoxInfo):void {
			if (!tracks)
				tracks = new Vector.<TrafBox>();
			
			if (box is TrafBox) {
				tracks.push(box as TrafBox);
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

		public function MoofBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_MOOF, data);
		}
	}
}
