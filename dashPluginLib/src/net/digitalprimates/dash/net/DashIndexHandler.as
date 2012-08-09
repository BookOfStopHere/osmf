package net.digitalprimates.dash.net
{
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.dash.valueObjects.Segment;
	
	import org.osmf.events.HTTPStreamingEvent;
	import org.osmf.events.HTTPStreamingIndexHandlerEvent;
	import org.osmf.net.httpstreaming.HTTPStreamRequest;
	import org.osmf.net.httpstreaming.HTTPStreamRequestKind;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
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
		// Constants
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var currentSegmentIndex:int = -1;
		
		private var streamIndexInfo:DashStreamingIndexInfo;
		private var streamNames:Array = null;
		private var streamQualityRates:Array = null;
		
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
		
		override public function initialize(indexInfo:Object):void
		{	
			streamIndexInfo = (indexInfo as DashStreamingIndexInfo);
			if (streamIndexInfo == null) {
				dispatchEvent(new HTTPStreamingEvent(HTTPStreamingEvent.INDEX_ERROR));
				return;
			}
			
			var streamCount:int = streamIndexInfo.streamInfos.length;
			streamQualityRates = [];
			streamNames = [];
			
			for (var quality:int = 0; quality < streamCount; quality++) {
				var streamInfo:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
				if (streamInfo == null)
					continue;
				
				streamQualityRates[quality]	= streamInfo.bitrate;
				streamNames[quality] = streamInfo.streamName;
			}
			
			// Nothing else to load, start now!
			notifyRatesReady();
			notifyIndexReady(0);
		}
		
		override public function dispose():void
		{	
			// do something?
		}
		
		override public function processIndexData(data:*, indexContext:Object):void
		{
			var quality:int = indexContext as int;
			
			
			
			// everything is loaded up front, so just go with it?
			notifyRatesReady();
			notifyIndexReady(quality);
		}
		
		override public function getFileForTime(time:Number, quality:int):HTTPStreamRequest
		{
			trace("getFileForTime |", time);
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			
			var index:int = time / (media.segmentDuration / media.segmentTimescale);
			
			currentSegmentIndex = index;
			
			if (currentSegmentIndex >= media.segments.length) {
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			var segment:Segment = media.segments[currentSegmentIndex];
			return getRequestForSegment(segment, media);
		}
		
		override public function getNextFile(quality:int):HTTPStreamRequest
		{
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			
			currentSegmentIndex++;
			trace("getNextFile |", currentSegmentIndex);
			
			if (currentSegmentIndex >= media.segments.length) {
				return new HTTPStreamRequest(HTTPStreamRequestKind.DONE);
			}
			
			var segment:Segment = media.segments[currentSegmentIndex];
			return getRequestForSegment(segment, media);
		}
		
		override public function dvrGetStreamInfo(indexInfo:Object):void
		{
			
		}
		
		override public function get isBestEffortFetchEnabled():Boolean
		{
			return false;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function getRequestForSegment(segment:Segment, media:Representation):HTTPStreamRequest {
			// assume using media url for now
			// TODO : byte range
			
			var requestURL:String = null;
			
			var url:URL = new URL(segment.media);
			if (url.absolute) {
				requestURL = segment.media;
			}
			else {
				requestURL = media.baseURL;
				
				if (requestURL.charAt(requestURL.length-1) != "/" && segment.media.charAt(0) != "/") {
					requestURL += "/";
				}
				
				requestURL += segment.media;
			}
			
			trace("getRequestForSegment |", requestURL);
			return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
		}

		private function notifyRatesReady():void {
			dispatchEvent(new HTTPStreamingIndexHandlerEvent(
				HTTPStreamingIndexHandlerEvent.RATES_READY,
				false,
				false,
				false,
				NaN,
				streamNames,
				streamQualityRates
			));
		}

		private function notifyIndexReady(quality:int):void {
			dispatchEvent(new HTTPStreamingIndexHandlerEvent(
				HTTPStreamingIndexHandlerEvent.INDEX_READY,
				false,
				false,
				false, // TODO : LIVE
				NaN // TODO : LIVE
			));
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
		
		public function DashIndexHandler() {
			super();
		}
	}
}