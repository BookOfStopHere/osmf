package net.digitalprimates.dash.net
{
	import flash.utils.getTimer;
	
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.dash.valueObjects.Segment;
	import net.digitalprimates.dash.valueObjects.SegmentTemplate;
	import net.digitalprimates.dash.valueObjects.SegmentTimeline;
	import net.digitalprimates.dash.valueObjects.TimelineFragment;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamRequestKind;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataMode;
	import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
	import org.osmf.utils.URL;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashIndexHandler extends HTTPStreamingIndexHandlerBase
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		private var fileHandler:DashFileHandler;
		
		private var currentQuality:int = -1;
		private var currentSegmentIndex:int = -1;

		private var streamIndexInfo:DashStreamingIndexInfo;
		private var streamNames:Array = null;
		private var streamQualityRates:Array = null;

		private var _duration:Number = 0;

		protected function get duration():Number {
			return _duration;
		}

		protected function set duration(value:Number):void {
			if (_duration == value)
				return;
			
			_duration = value;
			
			if (!isNaN(_duration))
				notifyTotalDuration(_duration);
		}
		
		private var _fragmentDuration:Number = 0;
		
		protected function get fragmentDuration():Number {
			return _fragmentDuration;
		}
		
		protected function set fragmentDuration(value:Number):void {
			if (_fragmentDuration == value)
				return;
			
			_fragmentDuration = value;
			
			if (!isNaN(_fragmentDuration))
				notifyFragmentDuration(_fragmentDuration);
		}
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		override public function initialize(indexInfo:Object):void {
			streamIndexInfo = (indexInfo as DashStreamingIndexInfo);
			if (streamIndexInfo == null) {
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;
			}
			
			this.duration = streamIndexInfo.duration;

			var streamCount:int = streamIndexInfo.streamInfos.length;
			streamQualityRates = [];
			streamNames = [];

			for (var quality:int = 0; quality < streamCount; quality++) {
				var streamInfo:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
				if (streamInfo == null)
					continue;

				streamQualityRates[quality] = streamInfo.bitrate;
				streamNames[quality] = streamInfo.streamName;
			}

			// Nothing else to load, start now!
			notifyRatesReady();
			notifyIndexReady(0);
		}

		override public function dispose():void {
			// do something?
		}

		override public function processIndexData(data:*, indexContext:Object):void {
			// TODO : Parse manifest...
		}

		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest {
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			
			fileHandler.currentMimeType = media.mimeType;
			fileHandler.currentCodecs = media.codecs;
			
			var segmentRequest:HTTPStreamRequest;
			
			// see if we get a request because of a quality change
			segmentRequest = processQualityChange(quality);
			
			if (!segmentRequest) {
				// if not, calculate which segment to load
				var index:int = -1;
				var fragmentTime:Number;
				
				if (media.segmentTemplate) {
					if (media.segmentTemplate.timescale > 0 && media.segmentTemplate.duration > 0) {
						fragmentDuration = (media.segmentDuration / media.segmentTimescale);
						index = time / fragmentDuration;
						fragmentTime = time * fragmentDuration;
					}
					else {
						index = 0;
						var ft:Number = 0;
						var frag:Segment
						
						while (ft < time && index < media.segmentTemplate.segments.length) {
							index++;
							frag = media.segmentTemplate.segments[index];
							ft += frag.duration;
						}
						
						frag = media.segmentTemplate.segments[index];
						fragmentTime = frag.startTime;
						fragmentDuration = frag.duration;
					}
				}
					// just use the segmentDuration value to figure out the index
				else {
					fragmentDuration = (media.segmentDuration / media.segmentTimescale);
					index = time / fragmentDuration;
				}
				
				if (index == -1)
					throw new Error("Fragment could not be calculated!");
				
				currentSegmentIndex = index;
				
				if (validateMediaDone(media)) {
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}
				
				if (media.segments) {
					var segment:Segment = media.segments[currentSegmentIndex];
					segmentRequest = getRequestForSegment(segment, media);
				}
				else {
					throw new Error("Missing segment information.");
				}
			}
			
			CONFIG::LOGGING
			{
				Log.log(segmentRequest.url);
			}
			return segmentRequest;
		}

		override public function getNextFile(quality:int):HTTPStreamRequest {
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			var done:Boolean = false;
			
			// see if we get a request because of a quality change
			segmentRequest = processQualityChange(quality);
			
			// if not, use the segment cursor
			if (!segmentRequest) {
				currentSegmentIndex++;
				
				if (validateMediaDone(media)) {
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}
				
				var segmentRequest:HTTPStreamRequest;
				
				if (media.segments) {
					var segment:Segment = media.segments[currentSegmentIndex];
					segmentRequest = getRequestForSegment(segment, media);
					fragmentDuration = segment.duration / segment.timescale;
				}
				else {
					throw new Error("Missing segment information.");
				}
			}
			
			CONFIG::LOGGING
			{
				Log.log(segmentRequest.url);
			}
			return segmentRequest;
		}
		
		override public function dvrGetStreamInfo(indexInfo:Object):void {
			
		}

		override public function get isBestEffortFetchEnabled():Boolean {
			return false;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function validateMediaDone(media:Representation):Boolean {
			return (currentSegmentIndex >= media.segments.length);
		}
		
		protected function processQualityChange(quality:int):HTTPStreamRequest {
			if (currentQuality != quality) {
				currentQuality = quality;
				return getInitializationRequest(quality);
			}
			
			return null;
		}
		
		protected function getInitializationRequest(quality:int):HTTPStreamRequest {
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			
			if (media.initialization != null && media.initialization.length > 0) {
				var requestURL:String = buildRequestUrl(media.initialization, media.baseURL);
				requestURL = SegmentTemplate.mediaReplacements(requestURL, media);
				return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
			}
			
			return null;
		}
		
		protected function getRequestForSegment(segment:Segment, media:Representation):HTTPStreamRequest {
			var requestURL:String = buildRequestUrl(segment.media, media.baseURL);
			requestURL = SegmentTemplate.mediaReplacements(requestURL, media);
			return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
		}
		
		protected function buildRequestUrl(destination:String, baseURL:String):String {
			var requestURL:String;
			var url:URL = new URL(destination);
			
			if (url.absolute) {
				requestURL = destination;
			}
			else {
				requestURL = baseURL;
				
				if (requestURL.charAt(requestURL.length - 1) != "/" && destination.charAt(0) != "/") {
					requestURL += "/";
				}
				
				requestURL += destination;
			}
			
			return requestURL;
		}
		
		private function notifyRatesReady():void {
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent(
					HTTPStreamingIndexHandlerEvent.RATES_READY,
					false,
					false,
					false,
					NaN,
					streamNames,
					streamQualityRates
				)
			);
		}

		private function notifyIndexReady(quality:int):void {
			dispatchEvent(
				new HTTPStreamingIndexHandlerEvent(
					HTTPStreamingIndexHandlerEvent.INDEX_READY,
					false,
					false,
					false, // TODO : LIVE
					NaN // TODO : LIVE
				)
			);
		}

		private function notifyFragmentDuration(duration:Number):void {
			CONFIG::LOGGING
			{
				Log.log(duration);
			}
			dispatchEvent(
				new HTTPStreamingEvent(
					HTTPStreamingEvent.FRAGMENT_DURATION,
					false,
					false,
					duration,
					null,
					null
				)
			);
		}
		
		private function notifyTotalDuration(duration:Number):void {
			CONFIG::LOGGING
			{
				Log.log(duration);
			}
			var metadata:Object = new Object();
			metadata.duration = duration;
			var tag:FLVTagScriptDataObject = new FLVTagScriptDataObject();
			tag.objects = ["onMetaData", metadata];
			dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.SCRIPT_DATA, false, false, 0, tag, FLVTagScriptDataMode.IMMEDIATE));
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashIndexHandler(fileHandler:DashFileHandler) {
			super();
			
			this.fileHandler = fileHandler;
		}
	}
}
