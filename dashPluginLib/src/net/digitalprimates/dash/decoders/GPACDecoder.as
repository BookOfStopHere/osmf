package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import mx.containers.utilityClasses.PostScaleAdapter;
	
	import org.osmf.net.httpstreaming.f4f.MediaDataBox;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class GPACDecoder implements IDecoder
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		private const GF_ISOM_BOX_TYPE_VOID:uint = GF_4CC("void");
		private const GF_ISOM_BOX_TYPE_STYP:uint = GF_4CC("styp");
		private const GF_ISOM_BOX_TYPE_SIDX:uint = GF_4CC("sidx");
		private const GF_ISOM_BOX_TYPE_TOTL:uint = GF_4CC("totl");
		private const GF_ISOM_BOX_TYPE_TREF:uint = GF_4CC("tref");
		private const GF_ISOM_BOX_TYPE_REFT:uint = GF_4CC("reft");
		private const GF_ISOM_BOX_TYPE_UUID:uint = GF_4CC("uuid");
		private const GF_ISOM_BOX_TYPE_STDP:uint = GF_4CC("stdp");
		private const GF_ISOM_BOX_TYPE_SDTP:uint = GF_4CC("sdtp");
		private const GF_ISOM_BOX_TYPE_MOOF:uint = GF_4CC("moof");
		private const GF_ISOM_BOX_TYPE_MFHD:uint = GF_4CC("mfhd");
		private const GF_ISOM_BOX_TYPE_TRAF:uint = GF_4CC("traf");
		private const GF_ISOM_BOX_TYPE_PSSH:uint = GF_4CC("pssh");
		private const GF_ISOM_BOX_TYPE_TRUN:uint = GF_4CC("trun");
		
		private const GF_ISOM_TRUN_DATA_OFFSET:uint	= 0x01;
		private const GF_ISOM_TRUN_FIRST_FLAG:uint = 0x04;
		private const GF_ISOM_TRUN_DURATION:uint = 0x100;
		private const GF_ISOM_TRUN_SIZE:uint = 0x200;
		private const GF_ISOM_TRUN_FLAGS:uint = 0x400;
		private const GF_ISOM_TRUN_CTS_OFFSET:uint = 0x800;
		
		private var pendingData:ByteArray;
		
		public function beginProcessData():void {
			
		}
		
		public function processData(input:IDataInput, limit:Number = 0):ByteArray {
			var bs:ByteArray = new ByteArray();
			input.readBytes(bs, 0, 0);
			
			var type:String;
			var size:int;
			
			/*while (bs.bytesAvailable > 0) {
				trace("POSITION:", bs.position);
				size = gf_bs_read_u32(bs);
				type = gf_bs_read_u32(bs);
				var stringType:String = gf_4cc_to_str(type);
				trace("TEST:", stringType, "|", size);
				bs.position = size;
				
				//POSITION: 176
				//TEST: moof
			}*/
			
			//-----
			
			/*
			moof			movie fragment
				mfhd		movie fragment header
				traf		track fragment
					tfhd	track fragment header
					tfdt	track fragment decode time
					trun	track fragment run
			*/
			
			var mdatBytes:ByteArray;
			
			if (pendingData) {
				pendingData.readBytes(bs, 0);
			}
			
			while (bs.bytesAvailable > 8) {
				size = bs.readUnsignedInt();
				type = bs.readUTFBytes(4);
				
				trace("TEST:", type, "|", size);
				
				if (type == "mdat") {
					if (bs.position - 8 + size > bs.bytesAvailable) {
						trace("Don't have the entire MDAT, so bail.");
						bs.position -= 8;
						pendingData = bs;
						return mdatBytes;
					}
					
					var orig:uint = bs.position;
					
					mdatBytes = new ByteArray();
					bs.readBytes(mdatBytes, 0, size-8);
					
					bs.position = orig;
				}
				
				bs.position += size - 8;
			}
			
			return mdatBytes;
				/*
				if (type == GF_ISOM_BOX_TYPE_MOOF) {
					trace("BOO");
				}
				
				if (type == GF_ISOM_BOX_TYPE_TRUN) {
					trace("FOUND TRUN");
					var box:Object = {};
					gf_isom_full_box_read(box, bs);
					box.size = size;
					box.sample_count = gf_bs_read_u32(bs);
					box.offset_or_first_sample = gf_bs_read_u32(bs);
					
					box.pieces = [];
					var i:int;
					for (i=0; i<box.sample_count; i++) {
						var trun_size:uint = 0;
						var p:Object = {};
						
						if (box.flags & GF_ISOM_TRUN_DURATION) {
							p.Duration = gf_bs_read_u32(bs);
							trun_size += 4;
						}
						if (box.flags & GF_ISOM_TRUN_SIZE) {
							p.size = gf_bs_read_u32(bs);
							trun_size += 4;
						}
						//SHOULDN'T BE USED IF GF_ISOM_TRUN_FIRST_FLAG IS DEFINED
						if (box.flags & GF_ISOM_TRUN_FLAGS) {
							p.flags = gf_bs_read_u32(bs);
							trun_size += 4;
						}
						if (box.flags & GF_ISOM_TRUN_CTS_OFFSET) {
							p.CTS_Offset = gf_bs_read_u32(bs);
						}
						
						box.pieces.push(p);
						//gf_list_add(ptr.entries, p);
						if (box.size<trun_size) throw new Error("Invalid file.");
						box.size-=trun_size;
					}
					//break;
				}
			}
			*/
			/*if (box) {
				bs.position += box.size;
				var tmp:ByteArray = new ByteArray();
				bs.readBytes(tmp, 0, bs.bytesAvailable);
				
				return tmp;
			}
			else {
				return null;
			}*/
			
			//-----
			
			//bs.position = 176;
			//box = readBox(bs);
			/*
			return null;
			
			while (bs.bytesAvailable > 0) {
				box = readBox(bs);
				if (box) {
					trace("BUILDING BOX FOR TYPE:", gf_4cc_to_str(box.type));
					
					/*for (var prop:String in box) {
						trace(prop + "|" + box[prop], "|", gf_4cc_to_str(box[prop]));
					}*/
				/*}
				else {
					trace("NO BOX");
					bs.readByte();
					
					/*var tmp:ByteArray = new ByteArray();
					bs.readBytes(tmp, 0, 0);
					return tmp;*/
				/*}
			}
			
			return null;*/
		}
		
		// GF_Err gf_isom_parse_box_ex(GF_Box **outBox, GF_BitStream *bs, u32 parent_type)
		// box_funcs.c, line 78
		private function readBox(bs:ByteArray):Object {
			var parent_type:uint = 0; // sent as 0 in a bunch of the calls, but also is an actual value sometimes
			
			if (bs.bytesAvailable < 8) {
				return null;
			}
			
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
					if (type == GF_ISOM_BOX_TYPE_TOTL)
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
			
			if (parent_type && (parent_type==GF_ISOM_BOX_TYPE_TREF)) {
				//newBox = gf_isom_box_new(GF_ISOM_BOX_TYPE_REFT); TODO!
				//if (!newBox) return GF_OUT_OF_MEM; // probably don't need
				//((GF_TrackReferenceTypeBox*)newBox).reference_type = type;
				newBox.reference_type = type;
			} else {
				//OK, create the box based on the type
				var desiredType:uint = uuid_type ? uuid_type : type;
				//trace("BUILDING BOX FOR TYPE:", gf_4cc_to_str(desiredType), "|", desiredType);
				newBox = gf_isom_box_new(desiredType);
				//newBox = gf_isom_box_new(uuid_type ? uuid_type : type);
				//if (!newBox) return GF_OUT_OF_MEM; // probably don't need...
			}
			
			if (newBox == null) {
				//trace("NO BOX FOR SEGMENT");
				return null;
			}
			else {
				//trace("GOT A BOX");
			}
			
			//OK, init and read this box
			if (type==GF_ISOM_BOX_TYPE_UUID) {
				//memcpy(((GF_UUIDBox *)newBox).uuid, uuid, 16);
				//((GF_UnknownUUIDBox *)newBox).internal_4cc = uuid_type;
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
			*outBox = null;
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
			
			return outBox;
		}
		
		//////////  DECODER METHODS
		
		private function gf_isom_box_new(boxType:uint):Object {
			var a:Object;
			
			trace( "TRYING TO BUILD BOX FOR:", gf_4cc_to_str(boxType) );
			
			switch (boxType) {
				case GF_ISOM_BOX_TYPE_STYP: 
					//a = ftyp_New();
					a = {};
					if (a) a.type = boxType;
					break;
				case GF_ISOM_BOX_TYPE_SIDX:
					//return sidx_New();
					a = {};
					if (a) a.type = boxType; // nweber: added!
					break;
				case GF_ISOM_BOX_TYPE_MOOF:
					//return moof_New();
					a = {};
					if (a) a.type = boxType; // nweber: added!
					break;
			}
			
			return a;
		}
		
		//GF_Err gf_isom_box_read(GF_Box *a, GF_BitStream *bs)
		private function gf_isom_box_read(a:Object, bs:ByteArray):void {
			switch (a.type) {
				case GF_ISOM_BOX_TYPE_STYP: 
					return ftyp_Read(a, bs);
					break;
				case GF_ISOM_BOX_TYPE_SIDX:
					return sidx_Read(a, bs);
					break;
				case GF_ISOM_BOX_TYPE_MOOF:
					return moof_Read(a, bs);
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
			
			//ptr.altBrand = (u32*)gf_malloc(sizeof(u32)*ptr.altCount);
			ptr.altBrand = [];
			for (i = 0; i<ptr.altCount; i++) {
				ptr.altBrand[i] = gf_bs_read_u32(bs);
			}
			
			//return GF_OK;
		}
		
		//GF_Err sidx_Read(GF_Box *s,GF_BitStream *bs)
		private function sidx_Read(s:Object, bs:ByteArray):void
		{
			//GF_Err e;
			var i:uint;
			//GF_SegmentIndexBox *ptr = (GF_SegmentIndexBox*) s;
			var ptr:Object = s;
			
			//e = gf_isom_full_box_read(s, bs);
			gf_isom_full_box_read(s, bs);
			//if (e) return e;
			
			ptr.reference_ID = gf_bs_read_u32(bs);
			ptr.timescale = gf_bs_read_u32(bs);
			ptr.size -= 8;
			
			if (ptr.version==0) {
				ptr.earliest_presentation_time = gf_bs_read_u32(bs);
				ptr.first_offset = gf_bs_read_u32(bs);
				ptr.size -= 8;
			} else {
				ptr.earliest_presentation_time = gf_bs_read_u64(bs);
				ptr.first_offset = gf_bs_read_u64(bs);
				ptr.size -= 16;
			}
			
			gf_bs_read_u16(bs); /* reserved */
			ptr.nb_refs = gf_bs_read_u16(bs);
			ptr.size -= 4;
			ptr.refs = []; //gf_malloc(sizeof(GF_SIDXReference)*ptr.nb_refs);
			
			for (i=0; i<ptr.nb_refs; i++) {
				ptr.refs[i] = {};
				ptr.refs[i].reference_type = gf_bs_read_int(bs, 1);
				ptr.refs[i].reference_size = gf_bs_read_int(bs, 31);
				ptr.refs[i].subsegment_duration = gf_bs_read_u32(bs);
				ptr.refs[i].starts_with_SAP = gf_bs_read_int(bs, 1);
				ptr.refs[i].SAP_type = gf_bs_read_int(bs, 3);
				ptr.refs[i].SAP_delta_time = gf_bs_read_int(bs, 28);
				ptr.size -= 12;
			}
			
			//return GF_OK;
		}
		
		//GF_Err moof_Read(GF_Box *s, GF_BitStream *bs)
		private function moof_Read(s:Object, bs:ByteArray):void
		{
			return gf_isom_read_box_list(s, bs, moof_AddBox);
		}
		
		//GF_Err moof_AddBox(GF_Box *s, GF_Box *a)
		private function moof_AddBox(s:Object, a:Object):void
		{
			var ptr:Object = s;
			var stringType:String = gf_4cc_to_str(a.type);
			switch (stringType) {
				case GF_ISOM_BOX_TYPE_MFHD:
					if (ptr.mfhd) throw new Error("Invalid file.");
					ptr.mfhd = a;
					break;
					
				case GF_ISOM_BOX_TYPE_TRAF:
					//gf_list_add(ptr.TrackList, a);
					break;
					
				case GF_ISOM_BOX_TYPE_PSSH:
				default:
					//gf_isom_box_add_default(s, a);
					break;
			}
		}
		
		//GF_Err gf_isom_read_box_list_ex(GF_Box *parent, GF_BitStream *bs, GF_Err (*add_box)(GF_Box *par, GF_Box *b), u32 parent_type)
		private function gf_isom_read_box_list(parent:Object, bs:ByteArray, add_box:Function):void
		{
			gf_isom_read_box_list_ex(parent, bs, add_box, 0);
		}
		
		//GF_Err gf_isom_read_box_list_ex(GF_Box *parent, GF_BitStream *bs, GF_Err (*add_box)(GF_Box *par, GF_Box *b), u32 parent_type)
		private function gf_isom_read_box_list_ex(parent:Object, bs:ByteArray, add_box:Function, parent_type:uint):void
		{
			var a:Object;
			while (parent.size) {
				gf_isom_parse_box_ex(a, bs, parent_type);
				if (parent.size < a.size) {
					if (a) gf_isom_box_del(a);
					//return GF_OK;
				}
				parent.size -= a.size;
				add_box(parent, a);
			}
			//return GF_OK;
		}
		
		private function isalnum(character:Number):Boolean {
			var strChar:String = String.fromCharCode(character);
			return /\W/.test(strChar);
		}
		
		private function strnicmp(string1:String, string2:String, length:int):Boolean
		{
			if (string1.substr(0, length) == string2.substr(0, length)) return true;
			else return false;
		}
		
		private function gf_isom_solve_uuid_box(UUID:String):uint
		{
			var i:uint;
			var strUUID:String;
			var strChar:String;
			
			//strUUID[0] = 0;
			strUUID = "0";
			for (i=0; i<16; i++) {
				//sprintf(strChar, "%02X", (unsigned char) UUID[i]);
				//strcat(strUUID, strChar);
				strChar = UUID.charAt(i);
				if (strChar.length < 2) strChar = "0" + strChar;
				strUUID += strChar;
			}
			/*
			TODO
			if (!strnicmp(strUUID, "8974dbce7be74c5184f97148f9882554", 32)) 
				return GF_ISOM_BOX_UUID_TENC;
			if (!strnicmp(strUUID, "D4807EF2CA3946958E5426CB9E46A79F", 32)) 
				return GF_ISOM_BOX_UUID_TFRF;
			if (!strnicmp(strUUID, "6D1D9B0542D544E680E2141DAFF757B2", 32)) 
				return GF_ISOM_BOX_UUID_TFXD;
			if (!strnicmp(strUUID, "A2394F525A9B4F14A2446C427C648DF4", 32)) 
				return GF_ISOM_BOX_UUID_PSEC;
			if (!strnicmp(strUUID, "D08A4F1810F34A82B6C832D8ABA183D3", 32)) 
				return GF_ISOM_BOX_UUID_PSSH;
			*/
			return 0;
		}
		
		//GF_Err gf_isom_parse_box_ex(GF_Box **outBox, GF_BitStream *bs, u32 parent_type)
		private function gf_isom_parse_box_ex(outBox:Object, bs:ByteArray, parent_type:uint):void
		{
			var type:uint;
			var uuid_type:uint;
			var hdr_size:uint;
			var size:uint;
			var start:uint;
			var end:uint;
			var uuid:String;
			var newBox:Object;
			
			if (bs == null) throw new Error("Bad param.");
			outBox = null;
			
			start = bs.position;
			
			uuid_type = 0;
			size = gf_bs_read_u32(bs);
			hdr_size = 4;
			/*fix for some boxes found in some old hinted files*/
			if ((size >= 2) && (size <= 4)) {
				size = 4;
				type = GF_ISOM_BOX_TYPE_VOID;
			} else {
				/*now here's a bad thing: some files use size 0 for void atoms, some for "till end of file" indictaion..*/
				var proceed_box:Boolean = true;
				if (!size) {
					type = gf_bs_peek_bits(bs, 32, 0);
					if (!isalnum((type>>24)&0xFF) || !isalnum((type>>16)&0xFF) || !isalnum((type>>8)&0xFF) || !isalnum(type&0xFF)) {
						size = 4;
						type = GF_ISOM_BOX_TYPE_VOID;
						proceed_box = false;
					} else {
						//goto proceed_box;
						proceed_box = true;
					}
				}
				
				if (proceed_box) {
				//else {
					//proceed_box:
					type = gf_bs_read_u32(bs);
					hdr_size += 4;
					/*no size means till end of file - EXCEPT FOR some old QuickTime boxes...*/
					if (type == GF_ISOM_BOX_TYPE_TOTL)
						size = 12;
					if (!size) {
						//GF_LOG(GF_LOG_DEBUG, GF_LOG_CONTAINER, ("[iso file] Warning Read Box type %s size 0 reading till the end of file\n", gf_4cc_to_str(type)));
						size = gf_bs_available(bs) + 8;
					}
				}
			}
			/*handle uuid*/
			//memset(uuid, 0, 16);
			if (type == GF_ISOM_BOX_TYPE_UUID ) {
				gf_bs_read_data(bs, uuid, 16);
				hdr_size += 16;
				uuid_type = gf_isom_solve_uuid_box(uuid);
			} 
			
			//handle large box
			if (size == 1) {
				size = gf_bs_read_u64(bs);
				hdr_size += 8;
			}
			//GF_LOG(GF_LOG_DEBUG, GF_LOG_CONTAINER, ("[iso file] Read Box type %s size "LLD" start "LLD"\n", gf_4cc_to_str(type), LLD_CAST size, LLD_CAST start));
			
			if ( size < hdr_size ) {
				//GF_LOG(GF_LOG_DEBUG, GF_LOG_CONTAINER, ("[iso file] Box size "LLD" less than box header size %d\n", LLD_CAST size, hdr_size));
				throw new Error("ISOM Invalid file.");
			}
			
			if (parent_type && (parent_type==GF_ISOM_BOX_TYPE_TREF)) {
				newBox = gf_isom_box_new(GF_ISOM_BOX_TYPE_REFT);
				if (!newBox) throw new Error();
				newBox.reference_type = type;
			} else {
				//OK, create the box based on the type
				newBox = gf_isom_box_new(uuid_type ? uuid_type : type);
				if (!newBox) throw new Error();
			}
			
			//OK, init and read this box
			if (type==GF_ISOM_BOX_TYPE_UUID) {
				newBox.uuid = uuid;
				newBox.internal_4cc = uuid_type;
			}
			
			if (!newBox.type) newBox.type = type; 
			
			end = gf_bs_available(bs);
			if (size - hdr_size > end ) {
				newBox.size = size - hdr_size - end;
				outBox = newBox;
				throw new Error("ISOM Incomplete file.");
			}
			//we need a special reading for these boxes...
			if ((newBox.type == GF_ISOM_BOX_TYPE_STDP) || (newBox.type == GF_ISOM_BOX_TYPE_SDTP)) {
				newBox.size = size;
				outBox = newBox;
				//return GF_OK;
			}
			
			newBox.size = size - hdr_size;
			gf_isom_box_read(newBox, bs);	
			newBox.size = size;
			end = bs.position;
			
			/*if (e && (e != GF_ISOM_INCOMPLETE_FILE)) {
				gf_isom_box_del(newBox);
				*outBox = null;
				GF_LOG(GF_LOG_ERROR, GF_LOG_CONTAINER, ("[iso file] Read Box \"%s\" failed (%s)\n", gf_4cc_to_str(type), gf_error_to_string(e)));
				return e;
			}*/
			
			if (end-start > size) {
				//GF_LOG(GF_LOG_WARNING, GF_LOG_CONTAINER, ("[iso file] Box \"%s\" size "LLU" invalid (read "LLU")\n", gf_4cc_to_str(type), LLU_CAST size, LLU_CAST (end-start) ));
				/*let's still try to load the file since no error was notified*/
				gf_bs_seek(bs, start+size);
			} else if (end-start < size) {
				var to_skip:uint = (size-(end-start));
				//GF_LOG(GF_LOG_WARNING, GF_LOG_CONTAINER, ("[iso file] Box \"%s\" has %d extra bytes\n", gf_4cc_to_str(type), to_skip));
				gf_bs_skip_bytes(bs, to_skip);
			}
			outBox = newBox;
			//return e;
		}
		
		private function gf_isom_box_del(a:Object):void
		{
			if (!a) return;
			if (a.other_boxes) {
				gf_isom_box_array_del(a.other_boxes);
				a.other_boxes = null;
			}
			switch (a.type) {
				
			}
		}
		
		private function gf_isom_box_array_del(other_boxes:Array):void
		{
			var count:uint;
			var i:uint;
			var a:Object;
			if (!other_boxes) return;
			count = other_boxes.length; 
			for (i = 0; i < count; i++) {
				a = other_boxes[i];
				if (a) gf_isom_box_del(a);
			}
			//gf_list_del(other_boxes);
		}
		
		//GF_Err gf_isom_full_box_read(GF_Box *ptr, GF_BitStream *bs)
		private function gf_isom_full_box_read(ptr:Object, bs:ByteArray):void
		{
			//GF_FullBox *self = (GF_FullBox *) ptr;
			var self:Object = ptr;
			
			if (ptr.size < 4) {
				//return GF_ISOM_INVALID_FILE;
				return;
			}
			
			self.version = gf_bs_read_u8(bs);
			self.flags = gf_bs_read_u24(bs);
			ptr.size -= 4;
			
			//return GF_OK;
		}
		
		//////////  4CC METHODS
		
		private function gf_4cc_compare(type:uint, value:String):Boolean {
			return (gf_4cc_to_str(type) == value);
		}
		
		private function GF_4CC(str:String):uint {
			var a:Number = str.charCodeAt(0);
			var b:Number = str.charCodeAt(1);
			var c:Number = str.charCodeAt(2);
			var d:Number = str.charCodeAt(3);
			
			return (((a)<<24)|((b)<<16)|((c)<<8)|(d));
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
			//warning: we allow offset = bs.length for WRITE buffers
			if (offset > bs.bytesAvailable) return; // GF_BAD_PARAM;
			
			gf_bs_align(bs);
			return BS_SeekIntern(bs, offset);
		}
		
		private function gf_bs_align(bs:ByteArray):uint
		{
			var res:uint = 8 - bs.nbBits;
			if ( (bs.bsmode == GF_BITSTREAM_READ) || (bs.bsmode == GF_BITSTREAM_FILE_READ)) {
				if (res > 0) {
					gf_bs_read_int(bs, res);
				}
				return res;
			}
			if (bs.nbBits > 0) {
				gf_bs_write_int (bs, 0, res);
				return res;
			}
			return 0;
		}*/
		
		private function gf_bs_available(bs:ByteArray):uint
		{
			var cur:uint;
			var end:uint;
			
			/*in WRITE mode only, this should not be called, but return something big in case ...*/
			/*
			if ( (bs.bsmode == GF_BITSTREAM_WRITE) 
				|| (bs.bsmode == GF_BITSTREAM_WRITE_DYN) 
			)
				return (u64) -1;
			*/
			
			/*we are in MEM mode*/
			//if (bs.bsmode == GF_BITSTREAM_READ) {
				if (bs.length - bs.position < 0)
					return 0;
				else
				return (bs.length - bs.position);
			//}
			/*FILE READ: assume size hasn't changed, otherwise the user shall call gf_bs_get_refreshed_size*/
			//if (bs.bsmode==GF_BITSTREAM_FILE_READ)
				//return (bs.length - bs.position);
			
			cur = gf_f64_tell(bs.stream);
			gf_f64_seek(bs.stream, 0, SEEK_END);
			end = gf_f64_tell(bs.stream);
			gf_f64_seek(bs.stream, cur, SEEK_SET);	
			return (u64) (end - cur);
		}
		
		private function gf_bs_peek_bits(bs:ByteArray, numBits:uint, byte_offset:uint):uint {
			var curPos:uint;
			var curBits:uint;
			var ret:uint;
			var current:uint;
			
			// probably not applicable!
			//if ( (bs.bsmode != GF_BITSTREAM_READ) && (bs.bsmode != GF_BITSTREAM_FILE_READ)) return 0;
			
			if (!numBits || (bs.length < bs.position + byte_offset)) return 0;
			
			/*store our state*/
			curPos = bs.position;
			//curBits = bs.nbBits;
			//current = bs.current;
			
			if (byte_offset) gf_bs_seek(bs, bs.position + byte_offset);
			ret = gf_bs_read_int(bs, numBits);
			
			/*restore our cache - position*/
			gf_bs_seek(bs, curPos);
			/*to avoid re-reading our bits ...*/
			//bs.nbBits = curBits;
			//bs.current = current;
			
			return ret;
		}
		
		private function gf_bs_seek(bs:ByteArray, offset:uint):void
		{
			/*warning: we allow offset = bs.length for WRITE buffers*/
			if (offset > bs.length) throw new Error("Bad param.");
			
			gf_bs_align(bs);
			return BS_SeekIntern(bs, offset);
		}
		
		private function gf_bs_align(bs:ByteArray):uint
		{
			/*
			TODO : stupid nbbits
			u8 res = 8 - bs.nbBits;
			if ( (bs.bsmode == GF_BITSTREAM_READ) || (bs.bsmode == GF_BITSTREAM_FILE_READ)) {
				if (res > 0) {
					gf_bs_read_int(bs, res);
				}
				return res;
			}
			if (bs.nbBits > 0) {
				gf_bs_write_int (bs, 0, res);
				return res;
			}
			*/
			return 0;
		}
		
		private static function BS_SeekIntern(bs:ByteArray, offset:uint):void
		{
			var i:uint;
			/*if mem, do it */
			//if ((bs.bsmode == GF_BITSTREAM_READ) || (bs.bsmode == GF_BITSTREAM_WRITE) || (bs.bsmode == GF_BITSTREAM_WRITE_DYN)) {
				if (offset > 0xFFFFFFFF) throw new Error("IO error.");
				/*0 for write, read will be done automatically*/
				if (offset >= bs.length) {
					//if ( (bs.bsmode == GF_BITSTREAM_READ) || (bs.bsmode == GF_BITSTREAM_WRITE) )
						throw new Error("Bad param.");
					/*in DYN, gf_realloc ...*/
					/*
					bs.original = (char*)gf_realloc(bs.original, (u32) (offset + 1));
					for (i = 0; i < (u32) (offset + 1 - bs.length); i++) {
						bs.original[bs.length + i] = 0;
					}
					bs.length = offset + 1;
						*/
				}
				//bs.current = bs.original[offset];
				bs.position = offset;
				//bs.nbBits = (bs.bsmode == GF_BITSTREAM_READ) ? 8 : 0;
				//return GF_OK;
				return;
			//}
			/*
			gf_f64_seek(bs.stream, offset, SEEK_SET);
			
			bs.position = offset;
			bs.current = 0;
			/*setup NbBits so that next acccess to the buffer will trigger read/write*/
			//bs.nbBits = (bs.bsmode == GF_BITSTREAM_FILE_READ) ? 8 : 0;
			//return GF_OK;
		}
		
		private static function BS_IsAlign(bs:ByteArray):Boolean
		{
			//switch (bs.bsmode) {
				//case GF_BITSTREAM_READ:
				//case GF_BITSTREAM_FILE_READ:
					//return ( (8 == bs.nbBits) ? 1 : 0);
					return true;
				//default:
					//return !bs.nbBits;
			//}
		}
		
		//#define NO_OPTS
		
		//#ifndef NO_OPTS
		private static var bit_mask:Array = [0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1];
		private static var bits_mask:Array = [0x0, 0x1, 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F];
		//#endif
		
		//u8 gf_bs_read_bit(GF_BitStream *bs)
		private function gf_bs_read_bit(bs:ByteArray):uint
		{
			var current:uint = 0;
			
			// nbBits = the number of bits in the current byte
			// it appears from bitstream.c that nbBits is 8 is in read mode
			// so assume 8 here...?
			var nbBits:uint = 0; //8;
			
			//if (bs.nbBits == 8) {
			if (nbBits == 8) {
				//bs.current = BS_ReadByte(bs);
				current = bs.readByte();
				//bs.nbBits = 0;
				nbBits = 0;
			}
			
			/*#ifdef NO_OPTS
			{
				s32 ret;
				bs.current <<= 1;
				bs.nbBits++;
				ret = (bs.current & 0x100) >> 8;
				return (u8) ret;
			}
			#else*/
			//return (u8) (bs.current & bit_mask[bs.nbBits++]) ? 1 : 0;
			return uint((current & bit_mask[nbBits++]) ? 1 : 0);
			//#endif
			
		}
		
		//u32 gf_bs_read_int(GF_BitStream *bs, u32 nBits)
		private function gf_bs_read_int(bs:ByteArray, nBits:uint):uint
		{
			var ret:uint;
			
			/*
			#ifndef NO_OPTS
			if (nBits + bs.nbBits <= 8) {
				bs.nbBits += nBits;
				ret = (bs.current >> (8 - bs.nbBits) ) & bits_mask[nBits];
				return ret;
			}
			#endif
			*/
			
			ret = 0;
			while (nBits-- > 0) {
				ret <<= 1;
				ret |= gf_bs_read_bit(bs);
			}
			return ret;
		}
		
		private function gf_bs_read_data(bs:ByteArray, data:String, nbBytes:uint):uint
		{
			var orig:uint = bs.position;
			
			if (bs.position+nbBytes > bs.length) return 0;
			
			if (BS_IsAlign(bs)) {
				//switch (bs.bsmode) {
				//case GF_BITSTREAM_READ:
				//memcpy(data, bs.original + bs.position, nbBytes); TODO
				bs.position += nbBytes;
				return nbBytes;
				/*case GF_BITSTREAM_FILE_READ:
				case GF_BITSTREAM_FILE_WRITE:
				nbBytes = fread(data, 1, nbBytes, bs.stream);
				bs.position += nbBytes;
				return nbBytes;
				default:
				return 0;
				}*/
			}
			
			/*while (nbBytes-- > 0) {
				data++ = gf_bs_read_int(bs, 8);
			}*/
			return (bs.position - orig);
		}
		
		private function gf_bs_skip_bytes(bs:ByteArray, nbBytes:uint):void
		{
			if (!bs || !nbBytes) return;
			
			gf_bs_align(bs);
			
			/*special case for file skipping...*/
			/*if ((bs.bsmode == GF_BITSTREAM_FILE_WRITE) || (bs.bsmode == GF_BITSTREAM_FILE_READ)) {
				gf_f64_seek(bs.stream, nbBytes, SEEK_CUR);
				bs.position += nbBytes;
				return;
			}*/
			
			/*special case for reading*/
			//if (bs.bsmode == GF_BITSTREAM_READ) {
				bs.position += nbBytes;
				return;
			//}
			/*for writing we must do it this way, otherwise pb in dynamic buffers*/
			/*while (nbBytes) {
				gf_bs_write_int(bs, 0, 8);
				nbBytes--;
			}*/
		}
		
		private function gf_bs_read_u8(bs:ByteArray):uint
		{
			return uint(bs.readByte());
		}
		
		private function gf_bs_read_u16(bs:ByteArray):uint
		{
			var ret:uint;
			ret = bs.readByte();
			ret<<=8;
			ret |= bs.readByte();
			return ret;
		}
		
		private function gf_bs_read_u24(bs:ByteArray):uint
		{
			var ret:uint;
			ret = bs.readByte();
			ret<<=8;
			ret |= bs.readByte();
			ret<<=8;
			ret |= bs.readByte();
			return ret;
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
		
		public function GPACDecoder() {
			
		}
	}
}