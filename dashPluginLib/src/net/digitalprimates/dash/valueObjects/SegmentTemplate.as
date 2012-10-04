package net.digitalprimates.dash.valueObjects
{
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class SegmentTemplate
	{
		//----------------------------------------
		//
		// Static
		//
		//----------------------------------------
		
		public static function replacements(source:String, media:Representation, index:int = -1, time:Number = 0):String {
			var newSource:String = source;
			
			newSource = SegmentTemplate.replaceBandwidth(newSource, media);
			newSource = SegmentTemplate.replaceRepresentationID(newSource, media);
			newSource = SegmentTemplate.replaceSegmentID(newSource, index);
			newSource = SegmentTemplate.replaceTime(newSource, time);
			
			return newSource;
		}
		
		public static function replaceBandwidth(source:String, media:Representation):String {
			return source.replace(/\$Bandwidth\$/g, media.bitrate);
		}
		
		public static function replaceRepresentationID(source:String, media:Representation):String {
			return source.replace(/\$RepresentationID\$/g, media.id);
		}
		
		public static function replaceSegmentID(source:String, index:int):String {
			return source.replace(/\$Number\$/g, index);
		}
		
		public static function replaceTime(source:String, time:Number):String {
			return source.replace(/\$Time\$/g, time);
		}
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var timescale:Number = 0;
		public var duration:Number = 0;
		public var mediaURL:String;
		public var startNumber:Number = 0;
		public var segments:Array;
		public var baseURL:String;
		public var timeline:SegmentTimeline;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function SegmentTemplate(base:SegmentTemplate) {
			if (base) {
				this.timescale = base.timescale;
				this.duration = base.duration;
				this.mediaURL = base.mediaURL;
				this.startNumber = base.startNumber;
				this.segments = base.segments;
				this.baseURL = base.baseURL;
				this.timeline = base.timeline;
			}
		}
	}
}