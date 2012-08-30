package net.digitalprimates.mfex.player.mediators
{
	import flash.net.NetStream;
	
	import net.digitalprimates.mfex.events.NetStreamEvent;
	import net.digitalprimates.mfex.player.views.VideoDisplay;
	
	import org.robotlegs.mvcs.Mediator;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class VideoDisplayMediator extends Mediator
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		[Inject]
		public var view:VideoDisplay;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		override public function onRegister():void {
			addContextListener(NetStreamEvent.STARTED, onNetStreamStarted);
		}
		
		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------
		
		private function onNetStreamStarted(event:NetStreamEvent):void {
			view.attachNetStream(event.netStream);
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function VideoDisplayMediator() {
			
		}
	}
}