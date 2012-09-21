package net.digitalprimates.dash.net
{
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.dash.valueObjects.Segment;
	import net.digitalprimates.dash.valueObjects.SegmentTemplate;
	
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

		private var duration:Number = 0;
		
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
			
			duration = streamIndexInfo.duration;

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
			var quality:int = indexContext as int;
		}

		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest {
			Log.log(time);
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			
			notifyTotalDuration(this.duration);

			fileHandler.currentMimeType = media.mimeType;
			fileHandler.currentCodecs = media.codecs;
			
			var segmentRequest:HTTPStreamRequest;
			
			// see if we get a request because of a quality change
			segmentRequest = processQualityChange(quality);
			
			// if not, calculate which segment to load
			if (!segmentRequest) {
				var index:int = time / (media.segmentDuration / media.segmentTimescale);
				
				currentSegmentIndex = index;
				
				// TODO : How to know when done using a segment template?
				/*if (currentSegmentIndex >= media.segments.length) {
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}*/
				
				if (media.segments) {
					var segment:Segment = media.segments[currentSegmentIndex];
					segmentRequest = getRequestForSegment(segment, media);
				}
				else if (media.segmentTemplate) {
					var absoluteIdx:int = currentSegmentIndex + media.segmentTemplate.startNumber;
					segmentRequest = getRequestForTemplate(absoluteIdx, media.segmentTemplate, media);
				}
				else {
					throw new Error("Missing segment information.");
				}
			}

			Log.log(segmentRequest.url);
			notifyFragmentDuration(media.segmentDuration / media.segmentTimescale);
			return segmentRequest;
		}

		override public function getNextFile(quality:int):HTTPStreamRequest {
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;

			notifyTotalDuration(this.duration);
			
			// see if we get a request because of a quality change
			segmentRequest = processQualityChange(quality);
			
			// if not, use the segment cursor
			if (!segmentRequest) {
				currentSegmentIndex++;
				Log.log(currentSegmentIndex);
				
				// TODO : How to know when done using a segment template?
				/*if (currentSegmentIndex >= media.segments.length) {
					return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
				}*/
				
				var segmentRequest:HTTPStreamRequest;
				
				if (media.segments) {
					var segment:Segment = media.segments[currentSegmentIndex];
					segmentRequest = getRequestForSegment(segment, media);
				}
				else if (media.segmentTemplate) {
					var absoluteIdx:int = currentSegmentIndex + media.segmentTemplate.startNumber;
					segmentRequest = getRequestForTemplate(absoluteIdx, media.segmentTemplate, media);
				}
				else {
					throw new Error("Missing segment information.");
				}
			}
			
			Log.log(segmentRequest.url);
			notifyFragmentDuration(media.segmentDuration / media.segmentTimescale);
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

		protected function processQualityChange(quality:int):HTTPStreamRequest {
			if (currentQuality != quality) {
				currentQuality = quality;
				
				var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
				var media:Representation = info.media;
				
				if (media.initialization != null && media.initialization.length > 0) {
					var requestURL:String = buildRequestUrl(media.initialization, media.baseURL);
					// might have some wildcards in here to replace
					requestURL = SegmentTemplate.replaceRepresentationID(requestURL, media);					
					return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
				}
			}
			
			return null;
		}
		
		protected function getRequestForSegment(segment:Segment, media:Representation):HTTPStreamRequest {
			var requestURL:String = buildRequestUrl(segment.media, media.baseURL);
			return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
		}
		
		protected function getRequestForTemplate(index:int, template:SegmentTemplate, media:Representation):HTTPStreamRequest {
			var mediaURL:String = media.segmentTemplate.mediaURL;
			mediaURL = SegmentTemplate.replaceRepresentationID(mediaURL, media);
			mediaURL = SegmentTemplate.replaceSegmentID(mediaURL, index);
			
			var requestURL:String = buildRequestUrl(mediaURL, media.baseURL);
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
