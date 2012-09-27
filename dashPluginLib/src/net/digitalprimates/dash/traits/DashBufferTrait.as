package net.digitalprimates.dash.traits
{
	import flash.events.Event;
	import flash.net.NetStream;
	
	import org.osmf.events.BufferEvent;
	import org.osmf.media.videoClasses.VideoSurface;
	import org.osmf.net.NetStreamBufferTrait;
	import org.osmf.traits.BufferTrait;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class DashBufferTrait extends BufferTrait
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		private var _proxiedBufferTrait:BufferTrait;

		public function get proxiedBufferTrait():BufferTrait {
			return _proxiedBufferTrait;
		}

		public function set proxiedBufferTrait(value:BufferTrait):void {
			clear();
			
			_proxiedBufferTrait = value;
			
			init();
		}

		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var minBufferTime:Number = 4;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		override public function set bufferTime(value:Number):void {
			proxiedBufferTrait.bufferTime = Math.max(value, minBufferTime);
		}
		
		override public function get bufferTime():Number {
			return proxiedBufferTrait.bufferTime;
		}
		
		override public function get bufferLength():Number {
			return proxiedBufferTrait.bufferLength;
		}
		
		override public function get buffering():Boolean {
			return proxiedBufferTrait.buffering;
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function init():void  {
			if (!proxiedBufferTrait)
				return;
			
			bufferTime = proxiedBufferTrait.bufferTime;
			proxiedBufferTrait.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, eventForwarder);
			proxiedBufferTrait.addEventListener(BufferEvent.BUFFERING_CHANGE, eventForwarder);
		}
		
		private function clear():void {
			if (!proxiedBufferTrait)
				return;
			
			proxiedBufferTrait.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, eventForwarder);
			proxiedBufferTrait.removeEventListener(BufferEvent.BUFFERING_CHANGE, eventForwarder);
		}
		
		private function eventForwarder(event:Event):void {
			dispatchEvent(event.clone());
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DashBufferTrait(proxiedBufferTrait:BufferTrait=null, minBufferTime:Number = 4) {
			super();
			
			this.minBufferTime = minBufferTime;
			this.proxiedBufferTrait = proxiedBufferTrait;
			
			init();
		}
	}
}