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
		
		public static function replaceRepresentationID(source:String, media:Representation):String {
			return source.replace(/\$RepresentationID\$/g, media.id);
		}
		
		public static function replaceSegmentID(source:String, index:int):String {
			return source.replace(/\$Number\$/g, index);
		}
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var timescale:Number;
		public var duration:Number;
		public var mediaURL:String;
		public var startNumber:Number;
		public var segments:Array;
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