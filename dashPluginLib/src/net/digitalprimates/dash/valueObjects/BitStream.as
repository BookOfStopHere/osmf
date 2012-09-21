package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BitStream
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const NO_VALUE:int = -1;
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var lastPos:int;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var current:int;
		public var nbBits:uint;
		public var data:ByteArray;
		
		public function get position():uint {
			return (data != null) ? data.position : 0;
		}
		
		public function set position(value:uint):void {
			if (data)
				data.position = value;
		}
		
		//----------------------------------------
		//
		// Public
		//
		//----------------------------------------
		
		public function mark():void {
			lastPos = data.position;
		}
		
		public function reset():void {
			data.position = lastPos;
		}
		
		private static const bit_mask:Array = [0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1];
		private static const bits_mask:Array = [0x0, 0x1, 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F];
		
		public static function gf_bs_read_int(bs:BitStream, nBits:uint):uint
		{
			var ret:uint;
			var bit:uint;
			
			if (bs.current == BitStream.NO_VALUE) {
				bs.current = bs.data.readByte();
			}
			
			ret = 0;
			while (nBits-- > 0) {
				ret <<= 1;
				
				if (bs.nbBits == 8) {
					bs.current = bs.data.readByte();
					bs.nbBits = 0;
				}
				
				bit = ((bs.current & bit_mask[bs.nbBits++]) ? 1 : 0);
				
				ret |= bit;
			}
			
			return ret;
		}
		
		public static function gf_bs_read_u24(bs:BitStream):uint
		{
			var ret:uint;
			ret = bs.data.readByte();
			ret<<=8;
			ret |= bs.data.readByte();
			ret<<=8;
			ret |= bs.data.readByte();
			return ret;
		}
		
		public static function gf_bs_read_u32(bs:BitStream):uint {
			var ret:uint = bs.data.readByte();
			ret <<= 8;
			ret |= bs.data.readByte();
			ret <<= 8;
			ret |= bs.data.readByte();
			ret <<= 8;
			ret |= bs.data.readByte();
			return ret;
		}
		
		public static function gf_bs_read_u64(bs:BitStream):uint
		{
			var ret:uint;
			ret = gf_bs_read_u32(bs);
			ret<<=32;
			ret |= gf_bs_read_u32(bs);
			return ret;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BitStream(data:ByteArray) {
			this.data = data;
			nbBits = 0;
			current = NO_VALUE;
			lastPos = 0;
		}
	}
}