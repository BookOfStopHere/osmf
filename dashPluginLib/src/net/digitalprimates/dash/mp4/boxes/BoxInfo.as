package net.digitalprimates.dash.mp4.boxes
{
	import flash.utils.ByteArray;
	
	import net.digitalprimates.dash.mp4.BaseBoxFactory;
	import net.digitalprimates.dash.mp4.BaseDescriptorFactory;
	import net.digitalprimates.dash.mp4.IBoxFactory;
	import net.digitalprimates.dash.mp4.IDescriptorFactory;
	import net.digitalprimates.dash.valueObjects.BitStream;

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
		public static const VERSION_AND_FLAGS_LENGTH:uint = 4;

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

		public var flags:uint;
		public var size:int;
		public var type:String;
		public var version:int;
		public var ready:Boolean = false;
		
		private var _data:ByteArray;
		
		public function set data(value:ByteArray):void {
			_data = value;
			
			if (_data == null) {
				bitStream = null;
				ready = false;
			}
			else {
				bitStream = new BitStream(_data);
				ready = true;
				parse();
			}
		}
		
		public function get existingData():ByteArray {
			return _data;
		}
		
		public function get length():int {
			var l:int = SIZE_AND_TYPE_LENGTH; // assume we have a type and size at least
			if (_data)
				l += _data.length;
			
			return l;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		private var _boxFactory:IBoxFactory;

		protected function get boxFactory():IBoxFactory {
			if (!_boxFactory) {
				_boxFactory = new BaseBoxFactory();
			}

			return _boxFactory;
		}

		private var _descriptorFactory:IDescriptorFactory;

		protected function get descriptorFactory():IDescriptorFactory {
			if (!_descriptorFactory) {
				_descriptorFactory = new BaseDescriptorFactory();
			}

			return _descriptorFactory;
		}

		protected function parseVersionAndFlags():void {
			if (bitStream.length < VERSION_AND_FLAGS_LENGTH)
				return;

			version = bitStream.readUInt8();
			flags = bitStream.readUInt24();
		}

		protected function parse():void {
			parseVersionAndFlags();
		}

		protected function parseChildrenBoxes():void {
			while (bitStream.bytesAvailable > SIZE_AND_TYPE_LENGTH) {
				var box:BoxInfo = boxFactory.getInstance(bitStream, true);
				setChildBox(box);
			}
		}

		protected function setChildBox(box:BoxInfo):void {
			if (box.type in this) {
				this[box.type] = box;
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function BoxInfo(size:int, type:String, data:ByteArray=null) {
			this.size = size;
			this.type = type;
			this.data = data;
		}
	}
}
