package net.digitalprimates.mfex.player.mediators
{
	import net.digitalprimates.mfex.Media;
	import net.digitalprimates.mfex.player.IPlayerController;
	import net.digitalprimates.mfex.player.views.VideoPlayer;
	
	import org.robotlegs.mvcs.Mediator;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class VideoPlayerMediator extends Mediator
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		[Inject]
		public var view:VideoPlayer;
		
		[Inject]
		public var controller:IPlayerController;
		
		[Inject]
		public var media:Media;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		override public function onRegister():void {
			/*if (media.autoPlay) {
				controller.play();
			}*/
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Lifecycle
		//
		//----------------------------------------
		
		
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function VideoPlayerMediator() {
			super();
		}
	}
}