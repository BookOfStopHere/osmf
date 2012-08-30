package net.digitalprimates.mfex.player
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import net.digitalprimates.mfex.Media;
	import net.digitalprimates.mfex.NetClient;
	import net.digitalprimates.mfex.events.NetStreamEvent;
	
	import org.robotlegs.mvcs.Actor;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class PlayerController extends Actor implements IPlayerController
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
		
		private var started:Boolean = false;
		private var netConnection:NetConnection;
		private var netStream:NetStream;
		
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
		
		public function play():void {
			if (started) {
				netStream.resume();
			}
			else {
				startStream();
				streamStarted();
				started = true;
			}
		}
		
		public function pause():void {
			if (netStream)
				netStream.pause();
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		protected function createNetConnection():NetConnection {
			return new NetConnection();
		}
		
		protected function createNetStream(nc:NetConnection):NetStream {
			return new NetStream(nc);
		}
		
		protected function createNetClient():NetClient {
			return new NetClient();
		}
		
		protected function startStream():void {
			netConnection = createNetConnection();
			netConnection.connect(null);
			
			netStream = createNetStream(netConnection);
			netStream.client = createNetClient();
			netStream.play(media.source);
		}
		
		protected function streamStarted():void {
			if (!netStream)
				throw new Error("Stream did not start!");
			
			dispatch(new NetStreamEvent(NetStreamEvent.STARTED, netStream));
		}
		
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
		
		public function PlayerController() {
			
		}
	}
}