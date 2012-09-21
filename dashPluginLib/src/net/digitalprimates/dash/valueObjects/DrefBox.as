package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DrefBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);
			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DrefBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_DREF, data);
		}
	}
}
