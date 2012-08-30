package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.FLVConverter;
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.BoxInfo;
	import net.digitalprimates.dash.valueObjects.MoofBox;
	import net.digitalprimates.dash.valueObjects.NALActions;
	import net.digitalprimates.dash.valueObjects.SidxBox;
	import net.digitalprimates.dash.valueObjects.TfdtBox;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class MP4Decoder implements IDecoder
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var flvConverter:FLVConverter;
		
		private var currentBox:BoxInfo;
		private var bytes:ByteArray;
		
		public var mediaDecodeTime:int = -1;
		
		private var seiMessage:Object; //SEIMessage
		private var currentScSize:int;
		private var prevScSize:int;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function beginProcessData():void {
			currentBox = null;
		}
		
		public function processData(input:IDataInput, limit:Number = 0):ByteArray {
			
			/*
			M4S FRAGMENT CONTENTS
			
			styp			segment type
			sidx			segment index
			moof			movie fragment
				mfhd		movie fragment header
				traf		track fragment
					tfhd	track fragment header
					tfdt	track fragment decode time
					trun	track fragment run
			mdat			media data container
			*/
			
			var returnByteArray:ByteArray = null;
			
			// waiting for a box
			if (!currentBox) {
				currentBox = getNextBox(input);
				
				if (currentBox != null) {
					Log.log("parsed a box of type", currentBox.type);
					if (currentBox.data != null) {
						Log.log("box data ready");
					}
					else {
						Log.log("waiting for box contents");
					}
				}
				else {
					Log.log("could not parse a box");
				}
			}
			// have a box, but not the contents
			else if (currentBox.data == null) {
				var read:Boolean = readBoxData(currentBox, input);
				
				if (read) {
					Log.log("box contents read");
				}
				else {
					Log.log("still waiting for box contents");
				}
			}
			else {
				// pull out the time
				if (currentBox.type == BoxInfo.BOX_TYPE_MOOF) {
					for each (var box:BoxInfo in currentBox.childrenBoxes) {
						// get track info
						if (box.type == BoxInfo.BOX_TYPE_TRAF) {
							for each (var childBox:BoxInfo in box.childrenBoxes) {
								if (childBox.type == BoxInfo.BOX_TYPE_TFDT) {
									mediaDecodeTime = (childBox as TfdtBox).baseMediaDecodeTime;
									break;
								}
							}
							break;
						}
					}
					if (mediaDecodeTime == -1) {
						throw new Error("No time for movie fragment!");
					}
				}
				
				// we only care about the mdat box, so throw away any other boxes
				if (currentBox.type != BoxInfo.BOX_TYPE_MDAT) {
					Log.log("got a box we don't care about", currentBox.type);
					// this will make the process start over
					currentBox = null;
				}
				else {
					Log.log("got an MDAT box");
					returnByteArray = getFLVBytes(currentBox.data);
					// and start over
					mediaDecodeTime = -1;
					currentBox = null;
				}
			}
			
			return returnByteArray;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function getNextBox(input:IDataInput):BoxInfo {
			// not enough data!
			if (input == null || input.bytesAvailable < BoxInfo.SIZE_AND_TYPE_LENGTH)
				return null;
			
			var ba:ByteArray = new ByteArray();
			input.readBytes(ba, 0, BoxInfo.SIZE_AND_TYPE_LENGTH);
			
			var size:int = ba.readUnsignedInt(); // BoxInfo.FIELD_SIZE_LENGTH
			var type:String = ba.readUTFBytes(BoxInfo.FIELD_TYPE_LENGTH);
			
			// TODO : check for large size... needed?
			
			var box:BoxInfo;
			
			switch (type) {
				case BoxInfo.BOX_TYPE_MOOF:
					box = new MoofBox(size);
					break;
				case BoxInfo.BOX_TYPE_SIDX:
					box = new SidxBox(size);
					break;
				default:
					box = new BoxInfo(size, type);
					break;
			}
			
			readBoxData(box, input);
			
			if (box.type == BoxInfo.BOX_TYPE_MDAT && box.data) {
				var temp:ByteArray = new ByteArray();
				box.data.position = 615;
				box.data.readBytes(temp, 0, 0);
				box.data = temp;
			}
			
			return box;
		}
		
		private function readBoxData(box:BoxInfo, input:IDataInput):Boolean {
			var bytesNeeded:int = (box.size - box.length);
			
			// not enough data
			if (input.bytesAvailable < bytesNeeded)
				return false;
			
			Log.log("getting box contents", box.type, input.bytesAvailable, bytesNeeded);
			
			var data:ByteArray = new ByteArray();
			input.readBytes(data, 0, bytesNeeded);
			
			box.data = data;
			
			return true;
		}
		
		private function getFLVBytes(bytes:ByteArray):ByteArray {
			if (bytes) {
				var avccBytes:ByteArray = getAvccBytes(bytes);
				flvConverter.appendBytes(avccBytes);
				return flvConverter.flush();
			}
			
			return null;
		}
		
		public function findNextStartCode(bytes:ByteArray):Boolean {
			var test:Array = [-1, -1, -1, -1];
			
			var c:int;
			while ((c = bytes.readByte()) != -1 && bytes.bytesAvailable > 0) {
				test[0] = test[1];
				test[1] = test[2];
				test[2] = test[3];
				test[3] = c;
				if (test[0] == 0 && test[1] == 0 && test[2] == 0 && test[3] == 1) {
					prevScSize = currentScSize;
					currentScSize = 4;
					return true;
				}
				if (test[0] == 0 && test[1] == 0 && test[2] == 1) {
					prevScSize = currentScSize;
					currentScSize = 3;
					return true;
				}
			}
			return false;
		}
		
		private var lastPos:int = 0;
		
		private function mark(bytes:ByteArray):void {
			lastPos = bytes.position;
		}
		
		private function reset(bytes:ByteArray):void {
			bytes.position = lastPos;
		}
		
		private function handleNALUnit(nal_ref_idc:int, nal_unit_type:int, data:Array):NALActions {
			var action:NALActions;
			switch (nal_unit_type) {
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
					action = NALActions.STORE; // Will only work in single slice per frame mode!
					break;
				
				case 6:
					//seiMessage = new SEIMessage(cleanBuffer(data), seqParameterSet);
					action = NALActions.BUFFER;
					break;
				
				case 9:
					//                printAccessUnitDelimiter(data);
					var type:int = data[1] >> 5;
					Log.log("Access unit delimiter type: " + type);
					action = NALActions.BUFFER;
					break;
				
				case 7:
					/*if (seqParameterSet == null) {
						ByteArrayInputStream is = cleanBuffer(data);
						is.read();
						seqParameterSet = SeqParameterSet.read(is);
						seqParameterSetList.add(data);
						configureFramerate();
					}*/
					action = NALActions.IGNORE;
					break;
				
				case 8:
				/*if (pictureParameterSet == null) {
					ByteArrayInputStream is = new ByteArrayInputStream(data);
					is.read();
					pictureParameterSet = PictureParameterSet.read(is);
					pictureParameterSetList.add(data);
				}*/
				action = NALActions.IGNORE;
				break;
				
				case 10:
				case 11:
					action = NALActions.END;
					break;
				
				default:
				throw new Error("Unknown NAL unit type: " + nal_unit_type);
				action = NALActions.IGNORE;
			}
			
			return action;
		}
		
		private function getNALs(bytes:ByteArray):Array {
			var nals:Array;
			
			if (!findNextStartCode(bytes)) {
				throw new Error("No start code.");
			}
			
			mark(bytes);
			var pos:uint = bytes.position;
			
			while (findNextStartCode(bytes)) {
				var newpos:uint = bytes.position;
				var size:int = int(newpos - pos - prevScSize);
				reset(bytes);
				var data:Array = [];
				var type:int = bytes.readByte();
				var nal_ref_idc:int = (type >> 5) & 3;
				var nal_unit_type:int = type & 0x1f;
				Log.log("Found startcode at " + (pos -4)  + " Type: " + nal_unit_type + " ref idc: " + nal_ref_idc + " (size " + size + ")");
				var action:NALActions = handleNALUnit(nal_ref_idc, nal_unit_type, data);
				switch (action) {
					case NALActions.IGNORE:
						break;
					
					case NALActions.BUFFER:
						//buffered.add(data);
						break;
					
					case NALActions.STORE:
						/*
						int stdpValue = 22;
						frameNr++;
						buffered.add(data);
						ByteBuffer bb = createSample(buffered);
						boolean IdrPicFlag = false;
						if (nal_unit_type == 5) {
							stdpValue += 16;
							IdrPicFlag = true;
						}
						ByteArrayInputStream bs = cleanBuffer(buffered.get(buffered.size() - 1));
						SliceHeader sh = new SliceHeader(bs, seqParameterSet, pictureParameterSet, IdrPicFlag);
						if (sh.slice_type == SliceHeader.SliceType.B) {
							stdpValue += 4;
						}
						LOG.fine("Adding sample with size " + bb.capacity() + " and header " + sh);
						buffered.clear();
						samples.add(bb);
						stts.add(new TimeToSampleBox.Entry(1, frametick));
						if (nal_unit_type == 5) { // IDR Picture
							stss.add(frameNr);
						}
						if (seiMessage.n_frames == 0) {
							frameNrInGop = 0;
						}
						int offset = 0;
						if (seiMessage.clock_timestamp_flag) {
							offset = seiMessage.n_frames - frameNrInGop;
						} else if (seiMessage.removal_delay_flag) {
							offset = seiMessage.dpb_removal_delay / 2;
						}
						ctts.add(new CompositionTimeToSample.Entry(1, offset * frametick));
						sdtp.add(new SampleDependencyTypeBox.Entry(stdpValue));
						frameNrInGop++;
						*/
						break;
					
					case NALActions.END:
						//return true;
						
						
				}
				pos = newpos;
				bytes.position = currentScSize;
				mark(bytes);
			}
			
			return nals;
		}
		
		private function getAvccBytes(bytes:ByteArray):ByteArray {
			var avcc:ByteArray = new ByteArray;
			
			var nals:Array = getNALs(bytes);
			
			avcc.writeByte(0x01);			// avcC version 1
			
			
			
			
			
			/*
			avcc.writeByte(0x01); // avcC version 1
			// profile, compatibility, level
			avcc.writeBytes(spsNAL.NALdata, 1, 3);
			avcc.writeByte(0xff); // 111111 + 2 bit NAL size - 1
			avcc.writeByte(0xe1); // number of SPS
			avcc.writeByte(spsLength >> 8); // 16-bit SPS byte count
			avcc.writeByte(spsLength);
			avcc.writeBytes(spsNAL.NALdata, 0, spsLength); // the SPS
			avcc.writeByte(0x01); // number of PPS
			avcc.writeByte(ppsLength >> 8); // 16-bit PPS byte count
			avcc.writeByte(ppsLength);
			avcc.writeBytes(ppsNAL.NALdata, 0, ppsLength);
			*/
			
			/*
			avcc[cursor++] = 0;
			avcc[cursor++] = 0;
			avcc[cursor++] = 0;
			avcc[cursor++] = 1; // version
			avcc[cursor++] = m_sps[1]; // profile
			avcc[cursor++] = m_sps[2]; // compatiblity
			avcc[cursor++] = m_sps[3]; // level
			avcc[cursor++] = 0xff; // nalu length length = 4 bytes: 111111xx, 00=1, 01=2, 10=3, 11=4
			avcc[cursor++] = 0x01; // one SPS
			avcc[cursor++] = (spsLength >> 8) & 0xff;
			avcc[cursor++] = (spsLength     ) & 0xff;
			avcc.position = cursor;
			avcc.writeBytes(m_sps);
			cursor += spsLength;
			avcc[cursor++] = 1; // one PPS
			avcc[cursor++] = (ppsLength >> 8) & 0xff;
			avcc[cursor++] = (ppsLength     ) & 0xff;
			avcc.position = cursor;
			avcc.writeBytes(m_pps);
			*/
			
			return avcc;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function MP4Decoder() {
			flvConverter = new FLVConverter();
		}
	}
}