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
		
		public static function mediaReplacements(source:String, media:Representation):String {
			var newSource:String = source;
			
			newSource = SegmentTemplate.replaceBandwidth(newSource, media);
			newSource = SegmentTemplate.replaceRepresentationID(newSource, media);
			
			return newSource;
		}
		
		public static function replaceBandwidth(source:String, media:Representation):String {
			return source.replace("$Bandwidth$", media.bitrate);
		}
		
		public static function replaceRepresentationID(source:String, media:Representation):String {
			return source.replace("$RepresentationID$", media.id);
		}
		
		public static function replaceSegmentIndex(source:String, index:int):String {
			return source.replace("$Number$", index);
		}
		
		public static function replaceTime(source:String, time:Number):String {
			return source.replace("$Time$", time);
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
		public var segments:Vector.<Segment>;
		public var baseURL:String;
		
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
			}
		}
	}
}