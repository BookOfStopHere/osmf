package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class SidxBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var referenceID:int;
		public var timescale:int;
		public var earliestPresentationTime:int;
		public var firstOffset:int;
		public var numRefs:uint;
		public var refs:Array;
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		override protected function parse():void {
			var i:uint;
			var byte:int;
			var nBits:uint;
			var eBits:uint;
			var childDescriptor:Object = readFullBox(data);
			
			referenceID = data.readUnsignedInt();
			timescale = data.readUnsignedInt();
			
			//if (ptr->version==0) {
				earliestPresentationTime = data.readUnsignedInt();
				firstOffset = data.readUnsignedInt();
			/*} else {
				earliestPresentationTime = data.readDouble();
				firstOffset = data.readDouble();
			}*/
			
			data.readShort(); /* reserved */
			
			numRefs = data.readShort();
			
			refs = [];
			
			var bs:BitStream = new BitStream(data);
			
			for (i=0; i < numRefs; i++) {
				refs[i] = {};
				
				refs[i].referenceType = gf_bs_read_int(bs, 1);
				refs[i].referenceSize = gf_bs_read_int(bs, 31);
				
				refs[i].subsegmentDuration = data.readUnsignedInt();
				
				refs[i].startsWithSAP = gf_bs_read_int(bs, 1);
				refs[i].SAPType = gf_bs_read_int(bs, 3);
				refs[i].SAPDeltaTime = gf_bs_read_int(bs, 28);
			}
			
			data.position = 0;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function SidxBox(size:int, data:ByteArray=null) {
			super(size, BOX_TYPE_SIDX, data);
		}
	}
}