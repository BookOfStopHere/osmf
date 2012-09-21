package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MdhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _creationTime:Number;

		public function get creationTime():Number {
			return _creationTime;
		}

		public function set creationTime(value:Number):void {
			_creationTime = value;
		}

		private var _modificationTime:Number;

		public function get modificattionTime():Number {
			return _modificationTime;
		}

		public function set modificationTime(value:Number):void {
			_modificationTime = value;
		}

		private var _timeScale:int;

		public function get timeScale():int {
			return _timeScale;
		}

		public function set timeScale(value:int):void {
			_timeScale = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
		}

		private var _language:String;

		public function get language():String {
			return _language;
		}

		public function set language(value:String):void {
			_language = value;
		}

		private var _reserved:uint;

		public function get reserved():uint {
			return _reserved;
		}

		public function set reserved(value:uint):void {
			_reserved = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);

			if (version == 1) {
				creationTime = data.readDouble();
				modificationTime = data.readDouble();
				timeScale = data.readUnsignedInt();
				duration = data.readDouble();
			}
			else {
				creationTime = data.readUnsignedInt();
				modificationTime = data.readUnsignedInt();
				timeScale = data.readUnsignedInt();
				duration = data.readUnsignedInt();
			}

			//our padding bit
			BitStream.gf_bs_read_int(bitStream, 1);
			
			//the spec is unclear here, just says "the value 0 is interpreted as undetermined"
			var packedLanguage:Array = [];
			packedLanguage[0] = String.fromCharCode(BitStream.gf_bs_read_int(bitStream, 5) + 0x60);
			packedLanguage[1] = String.fromCharCode(BitStream.gf_bs_read_int(bitStream, 5) + 0x60);
			packedLanguage[2] = String.fromCharCode(BitStream.gf_bs_read_int(bitStream, 5) + 0x60);

			//but before or after compaction ?? We assume before
			if (!packedLanguage[0] && !packedLanguage[1] && !packedLanguage[2]) {
				packedLanguage[0] = 'u';
				packedLanguage[1] = 'n';
				packedLanguage[2] = 'd';
			}
			
			language = packedLanguage.join("");
			
			reserved = data.readUnsignedShort();

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MdhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MDHD, data);
		}
	}
}
