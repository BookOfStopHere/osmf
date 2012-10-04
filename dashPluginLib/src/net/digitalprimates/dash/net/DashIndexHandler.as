package net.digitalprimates.dash.net
{
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
			
			var fragmentDuration:Number = 0;
			
			// if not, calculate which segment to load
			if (!segmentRequest) {
				var index:int = -1;
				var fragmentTime:Number;
				
				if (media.segmentTemplate && media.segmentTemplate.timeline) {
					index = getIndexForTimeFromTemplate(time, media.segmentTemplate);
					fragmentTime = getTimeForIndexFromTemplate(index, media.segmentTemplate);
					fragmentDuration = getDurationForIndexFromTemplate(index, media.segmentTemplate);
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
				else if (media.segmentTemplate) {
					var absoluteIdx:int = currentSegmentIndex + media.segmentTemplate.startNumber;
					segmentRequest = getRequestForTemplate(absoluteIdx, media.segmentTemplate, media, fragmentTime);
				}
				else {
					throw new Error("Missing segment information.");
				}
			}

			Log.log(segmentRequest.url);
			notifyFragmentDuration(fragmentDuration);
			return segmentRequest;
		}

		override public function getNextFile(quality:int):HTTPStreamRequest {
			var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
			var media:Representation = info.media;
			var done:Boolean = false;
			
			notifyTotalDuration(this.duration);
			
			// see if we get a request because of a quality change
			segmentRequest = processQualityChange(quality);
			
			var fragmentDuration:Number = 0;
			
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
					fragmentDuration = media.segmentDuration / media.segmentTimescale;
				}
				else if (media.segmentTemplate) {
					var fragmentTime:Number = -1;
					
					if (media.segmentTemplate && media.segmentTemplate.timeline) {
						fragmentTime = getTimeForIndexFromTemplate(currentSegmentIndex, media.segmentTemplate);
					}
					
					fragmentDuration = getDurationForIndexFromTemplate(currentSegmentIndex, media.segmentTemplate);
					
					var absoluteIdx:int = currentSegmentIndex + media.segmentTemplate.startNumber;
					segmentRequest = getRequestForTemplate(absoluteIdx, media.segmentTemplate, media, fragmentTime);
				}
				else {
					throw new Error("Missing segment information.");
				}
			}
			
			Log.log(segmentRequest.url);
			notifyFragmentDuration(fragmentDuration);
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
			var segmentCount:int = -1;
			if (media.segments) {
				segmentCount = media.segments.length;
			}
			else if (media.segmentTemplate.timeline && media.segmentTemplate.timeline.fragments) {
				// TODO : Move to parsing step.. Just calculate the total number of fragments there.
				// TODO : live?
				segmentCount = 0;
				for (var i:int = 0; i < media.segmentTemplate.timeline.fragments.length; i++) {
					var frag:TimelineFragment = media.segmentTemplate.timeline.fragments[i];
					segmentCount += (1 + frag.repeat);
				}
			}
			
			if (segmentCount != -1) {
				if (currentSegmentIndex >= segmentCount) {
					return true;
				}
			}
			
			// TODO : What if SegmentTemplate and no SegmentTimeline?
			return false;
		}
		
		private function getIndexForTimeFromTemplate(time:Number, template:SegmentTemplate):int {
			if (!template || !template.timeline || !template.timeline.fragments || template.timeline.fragments.length == 0)
				throw new Error("Missing template information.");
			
			var timeline:Vector.<TimelineFragment> = template.timeline.fragments;
			
			var t:Number = timeline[0].time;
			var count:int = 0;
			var k:int = 0;
			var i:int;
			
			while (k < timeline.length) {
				if (timeline[k].repeat > 0) {
					for (i = 0; i < timeline[k].repeat; i++) {
						if ((t + timeline[k].duration) >= time) return count;
						count++;
						t += timeline[k].duration;
					}
				}
				else {
					if ((t + timeline[k].duration) >= time) return count;
					count++;
					t += timeline[k].duration;
				}
				k++;
			}
			
			return count;
		}
		
		private function getTimeForIndexFromTemplate(index:int, template:SegmentTemplate):Number {
			if (!template || !template.timeline || !template.timeline.fragments || template.timeline.fragments.length == 0)
				throw new Error("Missing template information.");
			
			// TODO : Create a map for indexes to TimelineFragments....
			// Need some sort of map because of repeat values.
			
			var timeline:Vector.<TimelineFragment> = template.timeline.fragments;
			
			var time:Number = timeline[0].time;
			var count:int = 0;
			var k:int = 0;
			var i:int;
			
			while (true) {
				if (timeline[k].repeat > 0) {
					for (i = 0; i < timeline[k].repeat; i++) {
						count++;
						if (count > index) return time;
						time += timeline[k].duration;
					}
				}
				else {
					count++;
					if (count > index) return time;
					time += timeline[k].duration;
				}
				k++;
			}
			
			return time;
		}
		
		private function getDurationForIndexFromTemplate(index:int, template:SegmentTemplate):Number {
			if (template.duration != 0) {
				return template.duration / template.timescale;
			}
			else {
				if (!template || !template.timeline || !template.timeline.fragments || template.timeline.fragments.length == 0)
					throw new Error("Missing template information.");
				
				var timeline:Vector.<TimelineFragment> = template.timeline.fragments;
				
				var count:int = 0;
				var k:int = 0;
				
				while (true) {
					count += timeline[k].repeat;
					if (count >= index)
						return timeline[k].duration;
					
					count++;
					k++;
				}
			}
			
			return NaN;
		}
		
		protected function processQualityChange(quality:int):HTTPStreamRequest {
			if (currentQuality != quality) {
				currentQuality = quality;
				
				var info:DashStreamingInfo = streamIndexInfo.streamInfos[quality];
				var media:Representation = info.media;
				
				if (media.initialization != null && media.initialization.length > 0) {
					var requestURL:String = buildRequestUrl(media.initialization, media.baseURL);
					// might have some wildcards in here to replace
					requestURL = SegmentTemplate.replacements(requestURL, media);
					return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
				}
			}
			
			return null;
		}
		
		protected function getRequestForSegment(segment:Segment, media:Representation):HTTPStreamRequest {
			var requestURL:String = buildRequestUrl(segment.media, media.baseURL);
			return new HTTPStreamRequest(HTTPStreamRequestKind.DOWNLOAD, requestURL);
		}
		
		protected function getRequestForTemplate(index:int, template:SegmentTemplate, media:Representation, time:Number):HTTPStreamRequest {
			var mediaURL:String = media.segmentTemplate.mediaURL;
			mediaURL = SegmentTemplate.replacements(mediaURL, media, index, time);
			
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
