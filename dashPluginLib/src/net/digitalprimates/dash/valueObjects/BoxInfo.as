package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BoxInfo
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const BOX_TYPE_STYP:String = "styp";
		public static const BOX_TYPE_SIDX:String = "sidx";
		public static const BOX_TYPE_MDAT:String = "mdat";
		public static const BOX_TYPE_MOOF:String = "moof";
		public static const BOX_TYPE_MFHD:String = "mfhd";
		public static const BOX_TYPE_TRAF:String = "traf";
		public static const BOX_TYPE_TFHD:String = "tfhd";
		public static const BOX_TYPE_TFDT:String = "tfdt";
		public static const BOX_TYPE_TRUN:String = "trun";
		
		public static const FIELD_SIZE_LENGTH:uint = 4;
		public static const FIELD_TYPE_LENGTH:uint = 4;
		public static const SIZE_AND_TYPE_LENGTH:uint = FIELD_SIZE_LENGTH + FIELD_TYPE_LENGTH;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var childrenBoxes:Vector.<BoxInfo>;
		
		private var _subType:uint;
		
		public function get subType():uint {
			return _subType;
		}
		
		public function set subType(value:uint):void {
			_subType = value;
		}
		
		private var _flags:uint;
		
		public function get flags():uint {
			return _flags;
		}
		
		public function set flags(value:uint):void {
			_flags = value;
		}
		
		private var _size:int;
		
		public function get size():int {
			return _size;
		}
		
		private var _type:String;
		
		public function get type():String {
			return _type;
		}
		
		private var _data:ByteArray;
		
		public function get data():ByteArray {
			return _data;
		}

		public function set data(value:ByteArray):void {
			_data = value;
			
			if (_data && _data.bytesAvailable > 0)
				parse();
		}
		
		public function get length():int {
			var l:int = SIZE_AND_TYPE_LENGTH; // assume we have a type and size at least
			if (data)
				l += data.length;
			
			return l;
		}
		
		private var _version:int;
		
		public function get version():int {
			return _version;
		}

		public function set version(value:int):void {
			_version = value;
		}

		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function readBoxSize():void {
			// MUST IMPLEMENT IN SUB-CLASS
		}
		
		internal static function readFullBox(data:ByteArray):Object
		{
			if (data.length < 4)
				return null;
			
			var obj:Object = {};
			obj.type = uint(data.readByte());
			obj.flags = gf_bs_read_u24(data);
			return obj;
		}
		
		internal static const bit_mask:Array = [0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1];
		internal static const bits_mask:Array = [0x0, 0x1, 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F];
		
		internal static function gf_bs_read_int(bs:BitStream, nBits:uint):uint
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
		
		internal static function gf_bs_read_u24(bs:ByteArray):uint
		{
			var ret:uint;
			ret = bs.readByte();
			ret<<=8;
			ret |= bs.readByte();
			ret<<=8;
			ret |= bs.readByte();
			return ret;
		}
		
		internal static function gf_bs_read_u32(bs:ByteArray):uint {
			var ret:uint = bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			return ret;
		}
		
		internal static function gf_bs_read_u64(bs:ByteArray):uint
		{
			var ret:uint;
			ret = gf_bs_read_u32(bs);
			ret<<=32;
			ret |= gf_bs_read_u32(bs);
			return ret;
		}
		
		protected function parse():void {
			// override in a subclass if required
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BoxInfo(size:int, type:String, data:ByteArray=null) {
			_size = size;
			_type = type;
			this.data = data;
		}
	}
}