package net.digitalprimates.mfex.events
{
	import flash.events.Event;
	import flash.net.NetStream;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class NetStreamEvent extends Event
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		public static const STARTED:String = "netStreamStarted";
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		public var netStream:NetStream;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		override public function clone():Event {
			return new NetStreamEvent(this.type, this.netStream);
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function NetStreamEvent(type:String, netStream:NetStream) {
			super(type, false, false);
		}
	}
}