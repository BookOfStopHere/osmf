package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DinfBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		private var _dref:DrefBox;

		public function get dref():DrefBox {
			return _dref;
		}

		public function set dref(value:DrefBox):void {
			_dref = value;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			/*
			dinf				data information box, container
				dref			data reference box, declares source(s) of media data in track
					url			
			*/
			
			var ba:ByteArray;
			var size:int;
			var type:String;
			var boxData:ByteArray;
			
			while (data.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				ba = new ByteArray();
				data.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);
				
				size = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
				type = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);
				
				boxData = new ByteArray();
				data.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);
				
				switch (type) {
					case BOX_TYPE_DREF:
						dref = new DrefBox(size, boxData);
						break;
				}
			}
			
			// reset
			data.position = 0;
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