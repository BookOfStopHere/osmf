package com.longtailvideo.adaptive.streaming {


    import com.longtailvideo.adaptive.*;
    import com.longtailvideo.adaptive.muxing.*;
    import com.longtailvideo.adaptive.streaming.*;
    import com.longtailvideo.adaptive.utils.*;
    
    import flash.events.*;
    import flash.net.*;
    import flash.utils.ByteArray;


    /** Class that fetches fragments. **/
    public class Loader {


        /** Multiplier for bitrate/bandwidth comparison. **/
        public static const BITRATE_FACTOR:Number = 1.50;
        /** Multiplier for level/display width comparison. **/
        public static const WIDTH_FACTOR:Number = 1.50;


        /** Reference to the adaptive controller. **/
        private var _adaptive:Adaptive;
        /** Bandwidth of the last fragment load. **/
        private var _bandwidth:Number = 5;
        /** Callback for passing forward the fragment tags. **/
        private var _callback:Function;
		/** Callback for end of file load **/
		private var _finishCallback:Function;
        /** Fragment that's currently loading. **/
        private var _fragment:Number;
        /** Quality level of the last fragment load. **/
        private var _level:Number = 0;
        /** Reference to the manifest levels. **/
        private var _levels:Array;
        /** Util for loading the fragment. **/
        private var _loader:URLLoader;
		/** Util for loading the fragment **/
		private var _streamLoader:URLStream;
        /** Time the loading started. **/
        private var _started:Number;
        /** Did the stream switch quality levels. **/
        private var _switched:Boolean;
        /** Width of the stage. **/
        private var _width:Number = 480;
		/** Reference to the parsing buffer. **/
		private var _parser:Parser;
		/** Flag for load finish **/
		private var _loadFinished:Boolean = false;


        /** Create the loader. **/
        public function Loader(adaptive:Adaptive,parser:Parser):void {
            _adaptive = adaptive;
            _adaptive.addEventListener(AdaptiveEvent.MANIFEST, _levelsHandler);
			_parser = parser;
            //_loader = new URLLoader();
            //_loader.dataFormat = URLLoaderDataFormat.BINARY;
            //_loader.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
            //_loader.addEventListener(Event.COMPLETE, _completeHandler);
			_streamLoader = new URLStream();
			_streamLoader.addEventListener(Event.COMPLETE, _completeHandler);
			//_streamLoader.addEventListener(IOErrorEvent.IO_ERROR, _errorHandler);
		};
		
		
		/** Clear the loader **/
		public function clearLoader():void {
			if( _streamLoader.connected ) {
				//trace("closed stream in clearLoader, bytesAvail = "+_streamLoader.bytesAvailable);
				_streamLoader.close();
			}
			_started = 0;
			_bandwidth = 5;
			_width = 480;
			_loadFinished = false;
		}


        /** Fragment load completed. **/
        private function _completeHandler(event:Event):void {
			_loadFinished = true;
			//trace("complete handler, bytesAvailable = "+_streamLoader.bytesAvailable+", = "+_streamLoader.bytesAvailable/188+" pkts");
            // Calculate bandwidth
			if( _started ) {
				var delay:Number = (new Date().valueOf() - _started) / 1000;
				_bandwidth = Math.round(_streamLoader.bytesAvailable * 8 / delay);
				_started = 0;
			}
			// Add new data to parsing buffer, if any left
			//trace("loaded data, # packets: " + _loader.data.length/188);
			if( _streamLoader.bytesAvailable > 0 ) {
				//trace("loaded data, # packets: " + _loader.data.length/188);
				var streamBytes:ByteArray = new ByteArray();
				_streamLoader.readBytes(streamBytes,0,0);
				_parser.appendData(streamBytes);
			}
			// Close loader
			_streamLoader.close();
            try {
                //tags = _parseTS(tags);
                //_switched = false;
                _finishCallback();
                //_adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.FRAGMENT, getMetrics()));
            } catch (error:Error) {
                _adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.ERROR, error.toString()));
            }
        };
		
		
		/** Continue parsing already loaded data. **/
		public function parseMoreData():void {
			if( _streamLoader.connected ) {
				//trace("parseMoreData, bytesAvailable = "+_streamLoader.bytesAvailable+", = "+_streamLoader.bytesAvailable/188+" pkts");
				if( _streamLoader.bytesAvailable > 188*100 ) {
					// Calculate bandwidth, for first set of bytes only
					if( _started ) {
						var delay:Number = (new Date().valueOf() - _started) / 1000;
						_bandwidth = Math.round(_streamLoader.bytesAvailable * 8 / delay);
						_started = 0;
					}
					// Add new data to parsing buffer
					//trace("loaded data, # packets: " + _loader.data.length/188);
					var streamBytes:ByteArray = new ByteArray();
					_streamLoader.readBytes(streamBytes,0,0);
					_parser.appendData(streamBytes);
				}
			}
			// Extract tags.
			if( _loadFinished ) {
				_loadFinished = false;
				var tags:Vector.<Tag> = new Vector.<Tag>();
				try {
					tags = _parseTS(tags);
					if( tags.length > 0 ) {
						_switched = false;
						_callback(tags);
						_adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.FRAGMENT, getMetrics()));
					}
				} catch (error:Error) {
					_adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.ERROR, error.toString()));
				}
			}
		};


        /** Catch IO and security errors. **/
        private function _errorHandler(event:ErrorEvent):void {
            _adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.ERROR, event.toString()));
        };


        /** Get the quality level for the next fragment. **/
        public function getLevel():Number {
            return _level;
        };


        /** Get the current QOS metrics. **/
        public function getMetrics():Object {
            return { bandwidth:_bandwidth, level:_level, screenwidth:_width };
        };


        /** Load a fragment. **/
        public function load(fragment:Number, callback:Function, buffer:Number, finishCallback:Function):void {
            _fragment = fragment;
            _callback = callback;
			_finishCallback = finishCallback;
            if(buffer == 0) {
                _switched = true;
            }
            //if(_started) {
                //_loader.close();
			//	_streamLoader.close();
            //}
            _started = new Date().valueOf();
            _updateLevel();
            try {
				//trace("loading "+_levels[_level].fragments[_fragment].url);
                //_loader.load(new URLRequest(_levels[_level].fragments[_fragment].url));
				_streamLoader.load(new URLRequest(_levels[_level].fragments[_fragment].url));
            } catch (error:Error) {
                _adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.ERROR, error.message));
            }
        };


        /** Store the manifest data. **/
        private function _levelsHandler(event:AdaptiveEvent):void {
            _levels = event.levels;
        };


        /** Parse a TS fragment. **/
        private function _parseTS(tags:Vector.<Tag>):Vector.<Tag> {
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
        };


        /** Update the quality level for the next fragment load. **/
        private function _updateLevel():void {
            var level:Number = -1;
            // Select the lowest non-audio level.
            for(var i:Number = 0; i < _levels.length; i++) {
                if(!_levels[i].audio) {
                    level = i;
                    break;
                }
            }
            if(level == -1) {
                _adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.ERROR,
                    "None of the quality levels in this stream can be played."));
            }
            // Then update with highest possible level.
            for(var j:Number = _levels.length - 1; j > 0; j--) {
                if( _levels[j].bitrate <= _bandwidth * BITRATE_FACTOR &&
                    _levels[j].width <= _width * WIDTH_FACTOR) {
                    level = j;
                    break;
                }
            }
            // Next restrict upswitches to 1 level at a time.
            if(level != _level) {
                if(level > _level) {
                    _level++;
                } else {
                    _level = level;
                }
                _switched = true;
                _adaptive.dispatchEvent(new AdaptiveEvent(AdaptiveEvent.SWITCH,_level));
            }
        };


        /** Provide the loader with screen width information. **/
        public function setWidth(width:Number):void {
            _width = width;
        }


    }


}