package net.digitalprimates.mfex.contexts
{
	import flash.display.DisplayObjectContainer;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.digitalprimates.mfex.Media;
	import net.digitalprimates.mfex.player.IPlayerController;
	import net.digitalprimates.mfex.player.PlayerController;
	import net.digitalprimates.mfex.player.mediators.VideoDisplayMediator;
	import net.digitalprimates.mfex.player.mediators.VideoPlayerMediator;
	import net.digitalprimates.mfex.player.views.VideoDisplay;
	import net.digitalprimates.mfex.player.views.VideoPlayer;
	
	import org.robotlegs.mvcs.Context;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DefaultMediaContext extends Context implements IPlayerContext
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		protected var started:Boolean = false;
		
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------
		
		private var _media:Media;

		public function get media():Media {
			return _media;
		}

		public function set media(value:Media):void {
			if (_media == value)
				return;
			
			_media = value;
			mapMedia();
		}
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		override public function startup():void {
			started = true;
			
			mapMedia();
			
			mapVideoPlayerInternals();
			mapVideoPlayer();
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		protected function mapMedia():void {
			if (!started) {
				return;
			}
			
			if (media)
				injector.mapValue(Media, media);
		}
		
		protected function mapVideoPlayerInternals():void {
			
		}
		
		protected function mapVideoPlayer():void {
			injector.mapSingletonOf(IPlayerController, PlayerController);
			mediatorMap.mapView(VideoDisplay, VideoDisplayMediator);
			mediatorMap.mapView(VideoPlayer, VideoPlayerMediator);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DefaultMediaContext(contextView:DisplayObjectContainer=null, media:Media=null) {
			super(contextView, true);
		}
	}
}
