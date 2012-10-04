package net.digitalprimates.dash.valueObjects
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
		
		private var _dref:BoxInfo;

		public function get dref():BoxInfo {
			return _dref;
		}

		public function set dref(value:BoxInfo):void {
			_dref = value;
		}

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