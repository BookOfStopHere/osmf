package net.digitalprimates.dash.decoders
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.FLVConverter;
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.BoxInfo;
	import net.digitalprimates.dash.valueObjects.MoofBox;
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
				flvConverter.appendBytes(bytes);
				return flvConverter.flush();
			}
			
			return null;
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