package net.digitalprimates.dash.parsers
{
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import net.digitalprimates.dash.DashManifest;
	import net.digitalprimates.dash.utils.TimeUtil;
	import net.digitalprimates.dash.valueObjects.AdaptationSet;
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.dash.valueObjects.Segment;
	import net.digitalprimates.dash.valueObjects.SegmentTemplate;
	import net.digitalprimates.dash.valueObjects.SegmentTimeline;
	import net.digitalprimates.dash.valueObjects.TimelineFragment;
	
	import org.osmf.events.ParseEvent;
	import org.osmf.net.StreamType;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashParser extends EventDispatcher implements IParser
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		/**
		 * The manifest object being built by the parser.
		 */		
		protected var manifest:DashManifest;
		
		private var internal_namespace:Namespace;

		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		/**
		 * @copy net.digitalprimates.dash.parsers.IParser#parse()
		 */		
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
				manifest.adaptations = parseAdaptationSets(items, baseURL);
				
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
		
		/**
		 * Parses the top level manifest items.
		 *  
		 * @param value
		 * @param baseURL
		 * @return 
		 */		
		protected function parseTopManifest(value:XML, baseURL:String):DashManifest {
			var man:DashManifest = new DashManifest();
			
			man.streamType = value.@type;
			if (man.streamType != StreamType.LIVE) man.streamType = StreamType.RECORDED; // TODO : getting static for some reason
			
			man.minBufferTime = TimeUtil.convertTimeToSeconds(value.@minBufferTime);
			man.duration = TimeUtil.convertTimeToSeconds(value.@mediaPresentationDuration);
			man.baseURL = baseURL;
			
			return man;
		}
		
		/**
		 * Parses adaptation sets.
		 *  
		 * @param items
		 * @param baseURL
		 * @return 
		 */		
		protected function parseAdaptationSets(items:XMLList, baseURL:String):Vector.<AdaptationSet> {
			var sets:Vector.<AdaptationSet> = new Vector.<AdaptationSet>();
			var item:AdaptationSet;
			
			for each (var xml:XML in items) {
				item = new AdaptationSet();
				item.baseURL = (xml.internal_namespace::BaseURL.length() > 0) ? xml.internal_namespace::BaseURL[0].toString() : baseURL;
				item.mimeType = xml.@mimeType;
				
				// get contentType from one level in
				if (xml.internal_namespace::ContentComponent.length() > 0) {
					item.id = xml.internal_namespace::ContentComponent[0].@id;
					item.contentType = xml.internal_namespace::ContentComponent[0].@contentType;
				}
				
				if (xml.internal_namespace::SegmentTemplate.length() > 0) {
					var templateXML:XML = xml.internal_namespace::SegmentTemplate[0];
					var st:SegmentTemplate = parseSegmentTemplate(templateXML);
					
					var initURL:String;
					// get the initialization to put in each representation
					if (templateXML.attribute('initialization').length() > 0)
						initURL = templateXML.@initialization;
				}
				
				item.medias = parseRepresentations(xml..internal_namespace::Representation, item.baseURL, initURL, item.mimeType, st);
				
				sets.push(item);
			}
			
			return sets;
		}
		
		/**
		 * Parses representations.
		 *  
		 * @param items
		 * @param baseURL
		 * @param initializationURL
		 * @param baseSegmentTemplate
		 * @return 
		 */		
		protected function parseRepresentations(items:XMLList, baseURL:String, initializationURL:String, baseMimeType:String, baseSegmentTemplate:SegmentTemplate):Vector.<Representation> {
			var sets:Vector.<Representation> = new Vector.<Representation>();
			var item:Representation;
			
			for each (var xml:XML in items) {
				item = new Representation();
				item.baseURL = (xml.internal_namespace::BaseURL.length() > 0) ? xml.internal_namespace::BaseURL[0].toString() : baseURL;
				item.id = xml.@id;
				item.mimeType = xml.@mimeType;
				if (item.mimeType == null || item.mimeType.length == 0) {
					item.mimeType = baseMimeType;
				}
				
				var codecList:String = String(xml.@codecs);
				item.codecs = codecList.split(",");
				
				item.width = Number(xml.@width);
				item.height = Number(xml.@height);
				item.bitrate = Number(xml.@bandwidth);
				
				var segmentList:XML = xml.internal_namespace::SegmentList[0];
				
				if (segmentList) {
					if (segmentList.internal_namespace::Initialization.length() > 0) {
						var initialization:XML = segmentList.internal_namespace::Initialization[0];
						initializationURL = initialization.@sourceURL;
						
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
				}
				
				if (xml.internal_namespace::SegmentTemplate.length() > 0) {
					var templateXML:XML = xml.internal_namespace::SegmentTemplate[0];
					item.segmentTemplate = parseSegmentTemplate(templateXML, baseSegmentTemplate);
					
					if (templateXML.attribute('initialization').length() > 0)
						initializationURL = templateXML.@initialization;
					
					item.segmentTimescale = item.segmentTemplate.timescale;
					item.segmentDuration = item.segmentTemplate.duration;
				}
				// the template may only be defined in the adpatation set, so pass it down
				else if (baseSegmentTemplate != null) {
					item.segmentTemplate = baseSegmentTemplate;
				}
				
				item.initialization = initializationURL;
				
				sets.push(item);
			}
			
			return sets;
		}
		
		/**
		 * Parses segments from a SegmentList.
		 *  
		 * @param items
		 * @param timescale
		 * @param duration
		 * @return 
		 */		
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
		
		/**
		 * Parses range values (100-200) from a node.
		 *  
		 * @param value
		 * @return 
		 */		
		protected function parseRangeValues(value:String):Point {
			var point:Point;
			
			if (value != null && value.length > 0 && value.indexOf('-') > 0) {
				point = new Point();
				point.x = Number(value.split('-')[0]);
				point.y = Number(value.split('-')[1]);
			}
			
			return point;
		}
		
		/**
		 * Parses a SegmentTemplate node.
		 *  
		 * @param xml
		 * @param base The template from a parent node.
		 * @return 
		 */		
		protected function parseSegmentTemplate(xml:XML, base:SegmentTemplate=null):SegmentTemplate {
			if (!xml)
				return null;
			
			var item:SegmentTemplate = new SegmentTemplate(base);
			
			if (xml.attribute('timescale').length() > 0)
				item.timescale = Number(xml.@timescale);
			
			if (xml.attribute('duration').length() > 0)
				item.duration = Number(xml.@duration);
			
			if (xml.attribute('media').length() > 0)
				item.mediaURL = xml.@media;
			
			if (xml.attribute('startNumber').length() > 0)
				item.startNumber = xml.@startNumber;
			
			if (xml.internal_namespace::SegmentTimeline.length() > 0) {
				var t:XML = xml.internal_namespace::SegmentTimeline[0];
				var timeline:SegmentTimeline = new SegmentTimeline();
				var collection:Vector.<TimelineFragment> = new Vector.<TimelineFragment>();
				var frag:TimelineFragment;
				for each (var f:XML in t..internal_namespace::S) {
					frag = new TimelineFragment;
					
					if (f.attribute('t').length() > 0)
						frag.time = f.@t;
					
					if (f.attribute('d').length() > 0)
						frag.duration = f.@d;
					
					if (f.attribute('r').length() > 0)
						frag.repeat = f.@r;
					
					collection.push(frag);
				}
				timeline.fragments = collection;
				item.timeline = timeline;
			}
			
			return item;
		}
		
		/**
		 * Called when the manifest has finished loading. 
		 */		
		protected function finishLoad():void {
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, manifest));
		}

		/**
		 * Called when there was an error while parsing the manifest. 
		 */		
		protected function error():void {
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_ERROR, false, false, null));
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		/**
		 * Constructor. 
		 */		
		public function DashParser() {

		}
	}
}
