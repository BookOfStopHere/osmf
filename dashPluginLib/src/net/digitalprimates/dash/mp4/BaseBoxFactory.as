package net.digitalprimates.dash.mp4
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.mp4.boxes.*;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class BaseBoxFactory implements IBoxFactory
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function getInstance(input:IDataInput, readData:Boolean = false):BoxInfo {
			if (input.bytesAvailable < BoxInfo.SIZE_AND_TYPE_LENGTH)
				return null;
			
			const size:uint = input.readUnsignedInt();
			const type:String = input.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);
			
			var box:BoxInfo;
			var boxData:ByteArray;
			
			if (readData) {
				boxData = new ByteArray();
				input.readBytes(boxData, 0, size - BoxInfo.SIZE_AND_TYPE_LENGTH);
			}
			
			switch (type) {
				case BoxInfo.BOX_TYPE_FTYP:
					box = new FtypBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MVHD:
					box = new MvhdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MVEX:
					box = new MvexBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MEHD:
					box = new MehdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TREX:
					box = new TrexBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TRAK:
					box = new TrakBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TKHD:
					box = new TkhdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MDIA:
					box = new MdiaBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MDHD:
					box = new MdhdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_HDLR:
					box = new HdlrBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MINF:
					box = new MinfBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_DINF:
					box = new DinfBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_STBL:
					box = new StblBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_STSD:
					box = new StsdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_STSC:
					box = new StscBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MDAT:
					box = new MdatBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MOOF:
					box = new MoofBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MFHD:
					box = new MfhdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TRAF:
					box = new TrafBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TFHD:
					box = new TfhdBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TFDT:
					box = new TfdtBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_TRUN:
					box = new TrunBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MOOV:
					box = new MoovBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_AVCC:
					box = new AvccBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_ESDS:
					box = new EsdsBox(size, boxData);
					break;
				case BoxInfo.BOX_TYPE_MP4V:
				case BoxInfo.BOX_TYPE_AVC1:
					box = new Mp4vBox(size, type, boxData);
					break;
				case BoxInfo.BOX_TYPE_MP4A:
					box = new Mp4aBox(size, type, boxData);
					break;
				default:
					box = new BoxInfo(size, type, boxData);
					break;
			}
			
			return box;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function BaseBoxFactory() {
			
		}
	}
}