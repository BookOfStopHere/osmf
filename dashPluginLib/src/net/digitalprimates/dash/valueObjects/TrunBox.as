package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class TrunBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const GF_ISOM_TRUN_DATA_OFFSET:uint = 0x01;
		private static const GF_ISOM_TRUN_FIRST_FLAG:uint = 0x04;
		private static const GF_ISOM_TRUN_DURATION:uint = 0x100;
		private static const GF_ISOM_TRUN_SIZE:uint = 0x200;
		private static const GF_ISOM_TRUN_FLAGS:uint = 0x400;
		private static const GF_ISOM_TRUN_CTS_OFFSET:uint = 0x800;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var sampleCount:int;
		public var dataOffset:int;
		public var firstSampleFlags:int;
		public var samples:Array;

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			var childDescriptor:Object = readFullBox(data);
			
			subType = childDescriptor.type;
			flags = childDescriptor.flags;
			
			sampleCount = data.readInt();
			
			//The rest depends on the flags
			if (flags & GF_ISOM_TRUN_DATA_OFFSET) {
				dataOffset = data.readInt();
			}
			if (flags & GF_ISOM_TRUN_FIRST_FLAG) {
				firstSampleFlags = data.readInt();
			}
			
			samples = [];
			//read each entry (even though nothing may be written)
			for (var i:int=0; i < sampleCount; i++) {
				var p:Object = {};
				
				if (flags & GF_ISOM_TRUN_DURATION) {
					p.duration = data.readInt();
				}
				if (flags & GF_ISOM_TRUN_SIZE) {
					p.size = data.readInt();
				}
				
				//SHOULDN'T BE USED IF GF_ISOM_TRUN_FIRST_FLAG IS DEFINED
				if (flags & GF_ISOM_TRUN_FLAGS) {
					p.flags = data.readInt();
				}
				if (flags & GF_ISOM_TRUN_CTS_OFFSET) {
					p.CTSOffset = data.readInt();
				}
				
				samples.push(p);
			}	
			
			data.position = 0;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function TrunBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_TRUN, data);
		}
	}
}