package net.digitalprimates.mfex
{
	import net.digitalprimates.mfex.contexts.DashMediaContext;
	import net.digitalprimates.mfex.contexts.DefaultMediaContext;
	import net.digitalprimates.mfex.contexts.HDSMediaContext;
	import net.digitalprimates.mfex.contexts.HLSMediaContext;
	import net.digitalprimates.mfex.contexts.IPlayerContext;
	import net.digitalprimates.mfex.player.views.VideoPlayer;
	import net.digitalprimates.mfex.utils.URL;
	
	import org.robotlegs.mvcs.Context;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class Media
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------

		private static const HLS_EXTENSION:String = "m3u8";
		private static const HDS_EXTENSION:String = "f4m";
		private static const DASH_EXTENSION:String = "mpd";

		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _source:Object;

		public function get source():Object {
			return _source;
		}

		public function set source(value:Object):void {
			if (_source == value)
				return;
			
			_source = value;
			initContext();
		}

		private var _player:VideoPlayer;

		public function get player():VideoPlayer {
			return _player;
		}

		public function set player(value:VideoPlayer):void {
			if (_player == value)
				return;
			
			_player = value;
			initContext();
		}
		
		private var _autoPlay:Boolean;

		public function get autoPlay():Boolean {
			return _autoPlay;
		}

		public function set autoPlay(value:Boolean):void {
			_autoPlay = value;
		}
		
		private var _context:IPlayerContext;

		public function get context():IPlayerContext {
			return _context;
		}

		public function set context(value:IPlayerContext):void {
			if (_context == value)
				return;
			
			_context = value;
			initContext();
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		protected function createDefaultContextForSource(source:Object):IPlayerContext {
			var sourceURL:String = (source as String);
			
			if (!sourceURL) {
				// we don't know how to handle this
				throw new Error("URL expected!");
			}
			
			var url:URL = new URL(sourceURL);
			
			switch (url.extension) {
				case HLS_EXTENSION:
					return new HLSMediaContext();
				case HDS_EXTENSION:
					return new HDSMediaContext();
				case DASH_EXTENSION:
					return new DashMediaContext();
				default:
					return new DefaultMediaContext();
			}
		}
		
		protected function initContext():void {
			if (!source || !player)
				return;
			
			if (!context)
				context = createDefaultContextForSource(source);
			
			context.media = this;
			context.contextView = player;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function Media(source:Object, player:VideoPlayer, autoPlay:Boolean=true, context:IPlayerContext=null) {
			this.autoPlay = autoPlay;
			this.context = context;
			this.source = source;
			this.player = player;
		}
	}
}
