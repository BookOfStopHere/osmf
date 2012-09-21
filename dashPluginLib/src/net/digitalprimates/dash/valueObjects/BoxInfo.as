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
		
		public static const BOX_TYPE_FTYP:String = "ftyp";
		public static const BOX_TYPE_FREE:String = "free";
		public static const BOX_TYPE_MVHD:String = "mvhd";
		public static const BOX_TYPE_MVEX:String = "mvex";
		public static const BOX_TYPE_MEHD:String = "mehd";
		public static const BOX_TYPE_TREX:String = "trex";
		public static const BOX_TYPE_TRAK:String = "trak";
		public static const BOX_TYPE_TKHD:String = "tkhd";
		public static const BOX_TYPE_MDIA:String = "mdia";
		public static const BOX_TYPE_MDHD:String = "mdhd";
		public static const BOX_TYPE_HDLR:String = "hdlr";
		public static const BOX_TYPE_MINF:String = "minf";
		public static const BOX_TYPE_VMHD:String = "vmhd";
		public static const BOX_TYPE_DINF:String = "dinf";
		public static const BOX_TYPE_DREF:String = "dref";
		public static const BOX_TYPE_STBL:String = "stbl";
		public static const BOX_TYPE_STSD:String = "stsd";
		public static const BOX_TYPE_STTS:String = "stts";
		public static const BOX_TYPE_STSC:String = "stsc";
		public static const BOX_TYPE_STSZ:String = "stsz";
		public static const BOX_TYPE_STCO:String = "stco";
		public static const BOX_TYPE_STYP:String = "styp";
		public static const BOX_TYPE_SIDX:String = "sidx";
		public static const BOX_TYPE_MDAT:String = "mdat";
		public static const BOX_TYPE_MOOF:String = "moof";
		public static const BOX_TYPE_MFHD:String = "mfhd";
		public static const BOX_TYPE_TRAF:String = "traf";
		public static const BOX_TYPE_TFHD:String = "tfhd";
		public static const BOX_TYPE_TFDT:String = "tfdt";
		public static const BOX_TYPE_TRUN:String = "trun";
		public static const BOX_TYPE_MOOV:String = "moov";
		public static const BOX_TYPE_MP4A:String = "mp4a";
		public static const BOX_TYPE_MP4V:String = "mp4v";
		public static const BOX_TYPE_AVC1:String = "avc1";
		public static const BOX_TYPE_AVCC:String = "avcC";
		public static const BOX_TYPE_ESDS:String = "esds";
		
		public static const FIELD_SIZE_LENGTH:uint = 4;
		public static const FIELD_TYPE_LENGTH:uint = 4;
		public static const SIZE_AND_TYPE_LENGTH:uint = FIELD_SIZE_LENGTH + FIELD_TYPE_LENGTH;
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		protected var bitStream:BitStream;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
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
			
			bitStream = new BitStream(_data);
			
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
		
		internal static function readFullBox(bs:BitStream, source:BoxInfo):void
		{
			if (bs.data.length < 4)
				return;
			
			source.version = uint(bs.data.readByte());
			source.flags = BitStream.gf_bs_read_u24(bs);
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