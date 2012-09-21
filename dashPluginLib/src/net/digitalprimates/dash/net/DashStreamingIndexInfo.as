package net.digitalprimates.dash.net
{
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashStreamingIndexInfo extends HTTPStreamingIndexInfoBase
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		public var url:String;
		public var streamInfos:Vector.<DashStreamingInfo>;
		public var duration:Number;

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashStreamingIndexInfo(url:String, streamInfos:Vector.<DashStreamingInfo>, duration:Number) {
			this.url = url;
			this.streamInfos = streamInfos;
			this.duration = duration;
		}
	}
}
