package net.digitalprimates.dash.net
{
	import com.longtailvideo.adaptive.muxing.TS;
	import com.longtailvideo.adaptive.muxing.Tag;
	import com.longtailvideo.adaptive.streaming.Parser;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DashFileHandler extends HTTPStreamingFileHandlerBase
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const MAX_PROCESS_SEGMENT_BYTES:uint = 8192;
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		override public function beginProcessFile(seek:Boolean, seekTime:Number):void
		{
			trace("beginProcessFile");
		}
		
		override public function get inputBytesNeeded():Number
		{
			return 0;
		}
		
		override public function processFileSegment(input:IDataInput):ByteArray
		{
			trace("processFileSegment");
			return basicProcessFileSegment(input, MAX_PROCESS_SEGMENT_BYTES, false);
		}
		
		override public function endProcessFile(input:IDataInput):ByteArray
		{
			trace("endProcessFile");
			var rv:ByteArray = basicProcessFileSegment(input, uint.MAX_VALUE, false);
			
			dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.FRAGMENT_DURATION, false, false, 10));
			
			return rv;
		}
		
		override public function flushFileSegment(input:IDataInput):ByteArray
		{
			trace("flushFileSegment");
			return basicProcessFileSegment(input || new ByteArray(), uint.MAX_VALUE, true);
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private var _parser:Parser = new Parser(null);
		private var _levels:Array;
		private var _level:Number = 0;
		private var _fragment:Number = 0;
		
		private function _parseTS(tags:Vector.<Tag>):Vector.<Tag> {
			// hack
			if (!_levels) {
				_levels = [];
				_levels[_level] = {};
			}
			//--
			
			//var ts:TS = new TS(_loader.data);
			var ts:TS = _parser.parseData();
			if( (ts.audioTags.length != 0) || (ts.videoTags.length != 0) ) {
				
				// Save codecprivate when not available.
				if(!_levels[_level].avcc && !_levels[_level].adif) {
					_levels[_level].avcc = ts.getAVCC();
					_levels[_level].adif = ts.getADIF();
				}
				// Push codecprivate tags only when switching.
				//if(_switched) {
					var avccTag:Tag = new Tag(Tag.AVC_HEADER,ts.videoTags[0].pts,ts.videoTags[0].dts,true,_level,_fragment);
					
					avccTag.push(_levels[_level].avcc,0,_levels[_level].avcc.length);
					tags.push(avccTag);
					if(ts.audioTags[0].type == Tag.AAC_RAW) {
						var adifTag:Tag = new Tag(Tag.AAC_HEADER,ts.audioTags[0].pts,ts.audioTags[0].dts,true,_level,_fragment);
						adifTag.push(_levels[_level].adif,0,2)
						tags.push(adifTag);
					}
				//}
				// Push regular tags into buffer.
				for(var i:Number=0; i < ts.videoTags.length; i++) {
					ts.videoTags[i].level = _level;
					ts.videoTags[i].fragment = _fragment;
					//trace("ts.videoTags["+i+"].type = "+ts.videoTags[i].type);
					tags.push(ts.videoTags[i]);
				}
				for(var j:Number=0; j < ts.audioTags.length; j++) {
					ts.audioTags[j].level = _level;
					ts.audioTags[j].fragment = _fragment;
					//trace("ts.audioTags["+j+"].type = "+ts.audioTags[j].type);
					tags.push(ts.audioTags[j]);
				}
			}
			return tags;
		}
		
		private function basicProcessFileSegment(input:IDataInput, limit:uint, flush:Boolean):ByteArray
		{
			// Longtail - JW Player HLS
			if (input.bytesAvailable > 0) {
				var tmp:ByteArray = new ByteArray();
				input.readBytes(tmp, 0, 0);
				
				_parser.appendData(tmp);
				
				var _tags:Vector.<Tag> = new Vector.<Tag>;
				_tags = _parseTS(_tags);
				
				var ba:ByteArray = new ByteArray();
				for each (var tag:Tag in _tags) {
					ba.writeBytes(tag.data);
				}
				return ba;
			}
			
			return null;
		}
		
		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Lifecycle
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DashFileHandler() {
			super();
		}
	}
}