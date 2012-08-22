package net.digitalprimates.dash.parsers
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import net.digitalprimates.dash.DashManifest;
	import net.digitalprimates.dash.utils.TimeUtil;
	import net.digitalprimates.dash.valueObjects.AdaptationSet;
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.dash.valueObjects.Segment;
	
	import org.osmf.events.ParseEvent;
	import org.osmf.net.StreamType;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashParser extends EventDispatcher
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		protected var manifest:DashManifest;
		private var internal_namespace:Namespace;

		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		public function parse(value:String, baseURL:String):void {
			if (!value || value.length == 0)
				error();

			var xml:XML = new XML(value);

			if (!xml)
				error();

			try {
				internal_namespace = new Namespace(xml.namespace());
				use namespace internal_namespace;
				
				manifest = parseTopManifest(xml, baseURL);
				
				// TODO : Assume only one period for now...
				var period:XML = xml.internal_namespace::Period[0];
				var items:XMLList = period..internal_namespace::AdaptationSet;
				manifest.adaptation = parseAdaptationSets(items, baseURL);
				
				finishLoad();
			}
			catch (err:Error) {
				error();
			}
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		protected function parseTopManifest(value:XML, baseURL:String):DashManifest {
			var man:DashManifest = new DashManifest();
			
			man.streamType = value.@type;
			if (man.streamType != StreamType.LIVE) man.streamType = StreamType.RECORDED; // TODO : getting static for some reason
			
			man.minBufferTime = TimeUtil.convertTimeToSeconds(value.@minBufferTime);
			man.duration = TimeUtil.convertTimeToSeconds(value.@mediaPresentationDuration);
			man.baseURL = baseURL;
			
			return man;
		}
		
		protected function parseAdaptationSets(items:XMLList, baseURL:String):Vector.<AdaptationSet> {
			var sets:Vector.<AdaptationSet> = new Vector.<AdaptationSet>();
			var item:AdaptationSet;
			
			for each (var xml:XML in items) {
				item = new AdaptationSet();
				item.baseURL = (xml.internal_namespace::BaseURL.length() > 0) ? xml.internal_namespace::BaseURL[0].toString() : baseURL;
				item.medias = parseRepresentations(xml..internal_namespace::Representation, item.baseURL);
				
				sets.push(item);
			}
			
			return sets;
		}
		
		protected function parseRepresentations(items:XMLList, baseURL:String):Vector.<Representation> {
			var sets:Vector.<Representation> = new Vector.<Representation>();
			var item:Representation;
			
			for each (var xml:XML in items) {
				item = new Representation();
				item.baseURL = (xml.internal_namespace::BaseURL.length() > 0) ? xml.internal_namespace::BaseURL[0].toString() : baseURL;
				item.id = xml.@id;
				item.mimeType = xml.@mimeType;
				
				var codecList:String = String(xml.@codecs);
				item.codecs = codecList.split(",");
				
				item.width = Number(xml.@width);
				item.height = Number(xml.@height);
				item.bitrate = Number(xml.@bandwidth);
				
				// get contentType from one level in
				if (xml.internal_namespace::ContentComponent.length() > 0) {
					item.contentType = xml.internal_namespace::ContentComponent[0].@contentType;
				}
				
				var segmentList:XML = xml.internal_namespace::SegmentList[0];
				
				if (segmentList.internal_namespace::Initialization.length() > 0) {
					var initialization:XML = segmentList.internal_namespace::Initialization[0];
					item.segmentSourceURL = initialization.@sourceURL;
					
					var range:Point = parseRangeValues(initialization.@range);
					if (range) {
						item.segmentRangeStart = range.x;
						item.segmentRangeEnd = range.y;
					}
				}
				
				var timescale:Number = Number(segmentList.@timescale);
				var duration:Number = Number(segmentList.@duration);
				
				item.segmentTimescale = timescale;
				item.segmentDuration = duration;
				
				item.segments = parseSegments(segmentList..internal_namespace::SegmentURL, timescale, duration);
				
				sets.push(item);
			}
			
			return sets;
		}
		
		protected function parseSegments(items:XMLList, timescale:Number, duration:Number):Vector.<Segment> {
			var sets:Vector.<Segment> = new Vector.<Segment>();
			var item:Segment;
			var range:Point;
			
			for each (var xml:XML in items) {
				item = new Segment();
				item.media = xml.@media;
				item.timescale = timescale;
				item.duration = duration;
				
				range = parseRangeValues(xml.SegmentList.Initialization.@range);
				if (range) {
					item.mediaRangeStart = range.x;
					item.mediaRangeEnd = range.y;
				}
				
				range = parseRangeValues(xml.SegmentList.Initialization.@range);
				if (range) {
					item.indexRangeStart = range.x;
					item.indexRangeEnd = range.y;
				}
				
				sets.push(item);
			}
			
			return sets;
		}
		
		protected function parseRangeValues(value:String):Point {
			var point:Point;
			
			if (value != null && value.length > 0 && value.indexOf('-') > 0) {
				point = new Point();
				point.x = Number(value.split('-')[0]);
				point.y = Number(value.split('-')[1]);
			}
			
			return point;
		}
		
		protected function finishLoad():void {
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, manifest));
		}

		protected function error():void {
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR, false, false, null));
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashParser() {

		}
	}
}
