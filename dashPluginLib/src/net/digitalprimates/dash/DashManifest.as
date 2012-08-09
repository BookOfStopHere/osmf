package net.digitalprimates.dash
{
	import net.digitalprimates.dash.valueObjects.AdaptationSet;

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DashManifest
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		/**
		 * "Live" or "Recorded" 
		 */		
		public var streamType:String;
		
		/**
		 * In seconds. 
		 */		
		public var minBufferTime:Number;
		
		/**
		 * In seconds. 
		 */		
		public var duration:Number;
		
		public var baseURL:String;
		
		public var adaptation:Vector.<AdaptationSet>;
	}
}