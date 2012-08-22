package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class MP4Decoder implements IDecoder
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		private const GF_ISOM_BOX_TYPE_VOID:String = "void";
		private const GF_ISOM_BOX_TYPE_STYP:String = "styp";
		private const GF_ISOM_BOX_TYPE_TOTL:String = "totl";
		private const GF_ISOM_BOX_TYPE_TREF:String = "tref";
		private const GF_ISOM_BOX_TYPE_REFT:String = "reft";
		private const GF_ISOM_BOX_TYPE_UUID:String = "uuid";
		private const GF_ISOM_BOX_TYPE_STDP:String = "stdp";
		private const GF_ISOM_BOX_TYPE_SDTP:String = "sdtp";
		
		public function processData(input:IDataInput, limit:Number = 0):ByteArray {
			var parent_type:uint = 0; // sent as 0 in a bunch of the calls, but also is an actual value sometimes
			
			if (input.bytesAvailable < 8) {
				return null;
			}
			
			// GF_Err gf_isom_parse_box_ex(GF_Box **outBox, GF_BitStream *bs, u32 parent_type)
			// box_funcs.c, line 78
			
			var bs:ByteArray = new ByteArray();
			input.readBytes(bs, 0, 0);
			
			var type:uint;
			var uuid_type:uint;
			var size:uint;
			var hdr_size:uint;
			var start:uint;
			var end:uint;
			
			var uuid:String; //char uuid[16]
			var newBox:Object;
			var outBox:Object;
			
			start = bs.position;
			uuid_type = 0;
			size = gf_bs_read_u32(bs);
			hdr_size = 4;
			
			/*fix for some boxes found in some old hinted files*/
			if ((size >= 2) && (size <= 4)) {
				size = 4;
				//type = GF_ISOM_BOX_TYPE_VOID; // TODO : This line won't work because constants aren't uints like they should be!
			}
			else {
				/*now here's a bad thing: some files use size 0 for void atoms, some for "till end of file" indictaion..*/
				if (!size) {
					// do later - line 101
					/*type = gf_bs_peek_bits(bs, 32, 0);
					if (!isalnum((type>>24)&0xFF) || !isalnum((type>>16)&0xFF) || !isalnum((type>>8)&0xFF) || !isalnum(type&0xFF)) {
						size = 4;
						type = GF_ISOM_BOX_TYPE_VOID;
					} else {
						goto proceed_box;
					}*/
				}
				else {
//proceed_box:
					type = gf_bs_read_u32(bs);
					hdr_size += 4;
					/*no size means till end of file - EXCEPT FOR some old QuickTime boxes...*/
					//if (type == GF_ISOM_BOX_TYPE_TOTL)
					if (gf_4cc_compare(type, GF_ISOM_BOX_TYPE_TOTL))
						size = 12;
					if (!size) {
						//size = gf_bs_available(bs) + 8;
						size = bs.bytesAvailable + 8;
					}
				}
			}
			
			// TODO
			/*handle uuid*/
			/*memset(uuid, 0, 16);
			if (type == GF_ISOM_BOX_TYPE_UUID ) {
				gf_bs_read_data(bs, uuid, 16);
				hdr_size += 16;
				uuid_type = gf_isom_solve_uuid_box(uuid);
			}*/
			
			//handle large box
			if (size == 1) {
				size = gf_bs_read_u64(bs);
				hdr_size += 8;
			}
			
			if ( size < hdr_size ) {
				throw new Error("Invalid fragment!");
				return null;
			}
			
			//if (parent_type && (parent_type==GF_ISOM_BOX_TYPE_TREF)) {
			if (parent_type && gf_4cc_compare(parent_type, GF_ISOM_BOX_TYPE_TREF)) {
				//newBox = gf_isom_box_new(GF_ISOM_BOX_TYPE_REFT); TODO!
				//if (!newBox) return GF_OUT_OF_MEM; // probably don't need
				//((GF_TrackReferenceTypeBox*)newBox)->reference_type = type;
				newBox.reference_type = type;
			} else {
				//OK, create the box based on the type
				var desiredType:uint = uuid_type ? uuid_type : type;
				trace("BUILDING BOX FOR TYPE:", gf_4cc_to_str(desiredType), "|", desiredType);
				newBox = gf_isom_box_new(desiredType);
				//newBox = gf_isom_box_new(uuid_type ? uuid_type : type);
				//if (!newBox) return GF_OUT_OF_MEM; // probably don't need...
			}
			
			if (newBox == null) {
				trace("NO BOX FOR SEGMENT");
				bs.position = 0;
				return bs;
			}
			else {
				trace("GOT A BOX");
			}
			
			//OK, init and read this box
			//if (type==GF_ISOM_BOX_TYPE_UUID) {
			if (gf_4cc_compare(type, GF_ISOM_BOX_TYPE_UUID)) {
				//memcpy(((GF_UUIDBox *)newBox)->uuid, uuid, 16);
				//((GF_UnknownUUIDBox *)newBox)->internal_4cc = uuid_type;
				newBox.uuid = uuid;
				newBox.internal_4cc = uuid_type;
			}
			
			if (!newBox.type) newBox.type = type; 
			
			//end = gf_bs_available(bs);
			end = bs.bytesAvailable;
			
			/*if (size - hdr_size > end ) {
				newBox.size = size - hdr_size - end;
				outBox = newBox;
				return GF_ISOM_INCOMPLETE_FILE; // ??????
			}*/
			//we need a special reading for these boxes...
			//if ((newBox.type == GF_ISOM_BOX_TYPE_STDP) || (newBox.type == GF_ISOM_BOX_TYPE_SDTP)) {
			/*if (gf_4cc_compare(newBox.type, GF_ISOM_BOX_TYPE_STDP) || gf_4cc_compare(newBox.type, GF_ISOM_BOX_TYPE_SDTP)) {
				newBox.size = size;
				outBox = newBox;
				return GF_OK; // ???????
			}*/
			
			newBox.size = size - hdr_size;
			//e = gf_isom_box_read(newBox, bs); // saving the error, probably don't need to do!
			gf_isom_box_read(newBox, bs);
			newBox.size = size;
			//end = gf_bs_get_position(bs);
			end = bs.position;
			
			// got an error
			/*if (e && (e != GF_ISOM_INCOMPLETE_FILE)) {
				gf_isom_box_del(newBox);
				*outBox = NULL;
				GF_LOG(GF_LOG_ERROR, GF_LOG_CONTAINER, ("[iso file] Read Box \"%s\" failed (%s)\n", gf_4cc_to_str(type), gf_error_to_string(e)));
				return e;
			}*/
			
			/*if (end-start > size) {
				//GF_LOG(GF_LOG_WARNING, GF_LOG_CONTAINER, ("[iso file] Box \"%s\" size "LLU" invalid (read "LLU")\n", gf_4cc_to_str(type), LLU_CAST size, LLU_CAST (end-start) ));
				//let's still try to load the file since no error was notified
				gf_bs_seek(bs, start+size);
			} else if (end-start < size) {
				var to_skip:uint = (size-(end-start));
				//GF_LOG(GF_LOG_WARNING, GF_LOG_CONTAINER, ("[iso file] Box \"%s\" has %d extra bytes\n", gf_4cc_to_str(type), to_skip));
				gf_bs_skip_bytes(bs, to_skip);
			}*/
			
			outBox = newBox;
			
			//return e;
			
			//-------------------------------------------
			
			/*var type:uint = gf_bs_read_u32(bs);
			trace("type:", type, "|", gf_4cc_to_str(type));
			trace("const:", GF_ISOM_BOX_TYPE_STYP);
			hdr_size += 4;
			size = bs.bytesAvailable + 8;*/
			
			var tmp:ByteArray = new ByteArray();
			bs.readBytes(tmp, 0, 0);
			
			return tmp;
			
			//return null;
		}
		
		//////////  DECODER METHODS
		
		private function gf_isom_box_new(boxType:uint):Object {
			var stringType:String = gf_4cc_to_str(boxType);
			var a:Object;
			
			switch (stringType) {
				case GF_ISOM_BOX_TYPE_STYP: 
					//a = ftyp_New();
					a = {};
					if (a) a.type = boxType;
					break;
			}
			
			return a;
		}
		
		//GF_Err gf_isom_box_read(GF_Box *a, GF_BitStream *bs)
		private function gf_isom_box_read(a:Object, bs:ByteArray):void {
			var stringType:String = gf_4cc_to_str(a.type);
			switch (stringType) {
				case GF_ISOM_BOX_TYPE_STYP: 
					return ftyp_Read(a, bs);
					break;
			}
		}
		
		//GF_Err ftyp_Read(GF_Box *s,GF_BitStream *bs)
		private function ftyp_Read(s:Object, bs:ByteArray):void
		{
			var i:uint;
			//GF_FileTypeBox *ptr = (GF_FileTypeBox *)s;
			var ptr:Object = s;
			
			ptr.majorBrand = gf_bs_read_u32(bs);
			ptr.minorVersion = gf_bs_read_u32(bs);
			ptr.size -= 8;
			
			ptr.altCount = (ptr.size) / 4;
			if (!ptr.altCount) return; // GF_OK;
			if (ptr.altCount * 4 != (ptr.size)) {
				throw new Error( "Invalid file!" );
				return;
			}
			
			//ptr->altBrand = (u32*)gf_malloc(sizeof(u32)*ptr->altCount);
			ptr.altBrand = [];
			for (i = 0; i<ptr.altCount; i++) {
				ptr.altBrand[i] = gf_bs_read_u32(bs);
			}
			
			//return GF_OK;
		}
		
		//////////  4CC METHODS
		
		private function gf_4cc_compare(type:uint, value:String):Boolean {
			return (gf_4cc_to_str(type) == value);
		}
		
		private function GF_4CC(str:String):uint {
			//  todo
			return 0;
		}
		
		private function gf_4cc_to_str(type:uint):String {
			var name:String = "";
			var ch:uint;
			
			for (var i:int = 0; i < 4; i++) {
				ch = type >> (8 * (3-i) ) & 0xff;
				if ( ch >= 0x20 && ch <= 0x7E ) {
					name += String.fromCharCode(ch);
				} else {
					name += '.';
				}
			}
			return name;
		}
		
		//////////  BITSTREAM METHODS
		
		/*private function gf_bs_seek(bs:ByteArray, offset:uint)
		{
			//warning: we allow offset = bs->size for WRITE buffers
			if (offset > bs.bytesAvailable) return; // GF_BAD_PARAM;
			
			gf_bs_align(bs);
			return BS_SeekIntern(bs, offset);
		}
		
		private function gf_bs_align(bs:ByteArray):uint
		{
			var res:uint = 8 - bs.nbBits;
			if ( (bs->bsmode == GF_BITSTREAM_READ) || (bs->bsmode == GF_BITSTREAM_FILE_READ)) {
				if (res > 0) {
					gf_bs_read_int(bs, res);
				}
				return res;
			}
			if (bs->nbBits > 0) {
				gf_bs_write_int (bs, 0, res);
				return res;
			}
			return 0;
		}*/
		
		private function gf_bs_peek_bits(bs:ByteArray, numBits:uint, byte_offset:uint):uint {
			/*var curPos:uint;
			var curBits:uint;
			var ret:uint;
			var current:uint;
			
			if (!numBits)
				return 0;
			
			if (bs.bytesAvailable < bs.position + byte_offset)
				return 0;
			
			curPos = bs.position;
			
			
			
			*/
			return 0;
		}
		
		private function gf_bs_read_u32(bs:ByteArray):uint {
			var ret:uint = bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			ret <<= 8;
			ret |= bs.readByte();
			return ret;
		}
		
		private function gf_bs_read_u64(bs:ByteArray):uint
		{
			var ret:uint;
			ret = gf_bs_read_u32(bs); ret<<=32;
			ret |= gf_bs_read_u32(bs);
			return ret;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function MP4Decoder() {
			
		}
	}
}