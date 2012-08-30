package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class TfdtBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _baseMediaDecodeTime:Number;

		public function get baseMediaDecodeTime():Number {
			return _baseMediaDecodeTime;
		}

		public function set baseMediaDecodeTime(value:Number):void {
			_baseMediaDecodeTime = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			var childDescriptor:Object = readFullBox(data);

			subType = childDescriptor.type;
			flags = childDescriptor.flags;

			baseMediaDecodeTime = data.readInt();
			trace("tfdt:", baseMediaDecodeTime);
			
			/*if (ptr->version==1) {
				ptr->baseMediaDecodeTime = gf_bs_read_u64(bs);
				ptr->size -= 8;
			} else {
				ptr->baseMediaDecodeTime = (u32) gf_bs_read_u32(bs);
				ptr->size -= 4;
			}*/

			data.position = 0;
		}

		/*
		GF_Err tfdt_Size(GF_Box *s)
		{
		GF_Err e;
		GF_TFBaseMediaDecodeTimeBox *ptr = (GF_TFBaseMediaDecodeTimeBox *)s;
		e = gf_isom_full_box_get_size(s);
		if (e) return e;
		if (ptr->baseMediaDecodeTime<=0xFFFFFFFF) {
		ptr->version = 0;
		ptr->size += 4;
		} else {
		ptr->version = 1;
		ptr->size += 8;
		}
		return GF_OK;
		}
		*/
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function TfdtBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_TFDT, data);
		}
	}
}
