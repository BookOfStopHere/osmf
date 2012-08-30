package net.digitalprimates.mfex.player.views
{
	import flash.events.Event;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class VideoDisplay extends UIComponent
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var video:*;
		
		protected var stageVideoAvailable:Boolean = false;
		
		protected function get flashVideo():Video {
			return (video as Video);
		}
		
		protected function get stageVideo():StageVideo {
			return (video as StageVideo);
		}
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function attachNetStream(netStream:NetStream):void {
			video.attachNetStream(netStream);
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function configureVideo():void {
			if (stageVideoAvailable) {
				if (flashVideo) {
					removeChild(video);
					video = null;
				}
				
				video = stage.stageVideos[0];
			}
			else {
				if (!flashVideo) {
					video = new Video();
					addChild(video);
				}
			}
			
			invalidateDisplayList();
		}
		
		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------
		
		private function onAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if (stage.stageVideos && stage.stageVideos.length > 0) {
				stageVideoAvailable = true;
			}
			else {
				stageVideoAvailable = false;
				stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailabilityChange);
			}
			
			configureVideo();
		}
		
		private function onStageVideoAvailabilityChange(event:StageVideoAvailabilityEvent):void {
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailabilityChange);
			stageVideoAvailable = (event.availability == StageVideoAvailability.AVAILABLE);
			configureVideo();
		}
		
		//----------------------------------------
		//
		// Lifecycle
		//
		//----------------------------------------
		
		override protected function createChildren():void {
			super.createChildren();
			
			configureVideo();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (flashVideo) {
				flashVideo.width = unscaledWidth;
				flashVideo.height = unscaledHeight;
			}
			
			else if (stageVideo) {
				var topLeft:Point = new Point(0,0);
				var bottomRight:Point = new Point(unscaledWidth, unscaledHeight);
				
				var viewport:Rectangle = new Rectangle();
				viewport.topLeft = this.localToGlobal(topLeft);
				viewport.bottomRight = this.localToGlobal(bottomRight);
				
				stageVideo.viewPort = viewport;
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function VideoDisplay() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
}