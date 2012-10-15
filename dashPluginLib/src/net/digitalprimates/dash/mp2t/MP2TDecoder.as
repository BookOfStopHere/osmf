package net.digitalprimates.dash.mp2t
{
	import com.longtailvideo.adaptive.muxing.TS;
	import com.longtailvideo.adaptive.muxing.Tag;
	import com.longtailvideo.adaptive.streaming.Parser;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import net.digitalprimates.dash.decoders.IDecoder;

	/**
	 * Decodes TS files.
	 * TODO : Doesn't work with Dash yet.
	 *
	 * @author Nathan Weber
	 */
	public class MP2TDecoder implements IDecoder
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		private static const DEFAULT_PROCESSING_LIMIT:uint = 8192;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		public function beginProcessData():void {
			
		}
		
		public function processData(input:IDataInput, limit:Number = 0):ByteArray {
			// Longtail - JW Player HLS
			if (input.bytesAvailable > 0) {
				//if (isNaN(limit))
				//	limit = DEFAULT_PROCESSING_LIMIT;
				
				var tmp:ByteArray = new ByteArray();
				input.readBytes(tmp, 0, limit);

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
			if ((ts.audioTags.length != 0) || (ts.videoTags.length != 0)) {

				// Save codecprivate when not available.
				if (!_levels[_level].avcc && !_levels[_level].adif) {
					_levels[_level].avcc = ts.getAVCC();
					_levels[_level].adif = ts.getADIF();
				}
				// Push codecprivate tags only when switching.
				//if(_switched) {
				var avccTag:Tag = new Tag(Tag.AVC_HEADER, ts.videoTags[0].pts, ts.videoTags[0].dts, true, _level, _fragment);

				avccTag.push(_levels[_level].avcc, 0, _levels[_level].avcc.length);
				tags.push(avccTag);
				if (ts.audioTags[0].type == Tag.AAC_RAW) {
					var adifTag:Tag = new Tag(Tag.AAC_HEADER, ts.audioTags[0].pts, ts.audioTags[0].dts, true, _level, _fragment);
					adifTag.push(_levels[_level].adif, 0, 2)
					tags.push(adifTag);
				}
				//}
				// Push regular tags into buffer.
				for (var i:Number = 0; i < ts.videoTags.length; i++) {
					ts.videoTags[i].level = _level;
					ts.videoTags[i].fragment = _fragment;
					//trace("ts.videoTags["+i+"].type = "+ts.videoTags[i].type);
					tags.push(ts.videoTags[i]);
				}
				for (var j:Number = 0; j < ts.audioTags.length; j++) {
					ts.audioTags[j].level = _level;
					ts.audioTags[j].fragment = _fragment;
					//trace("ts.audioTags["+j+"].type = "+ts.audioTags[j].type);
					tags.push(ts.audioTags[j]);
				}
			}
			return tags;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MP2TDecoder() {
			
		}
	}
}
