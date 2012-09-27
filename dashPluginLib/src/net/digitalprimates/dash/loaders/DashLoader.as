package net.digitalprimates.dash.loaders
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import net.digitalprimates.dash.DashManifest;
	import net.digitalprimates.dash.DashMetadataNamespaces;
	import net.digitalprimates.dash.InternalDashPluginInfo;
	import net.digitalprimates.dash.builders.BaseDashBuilder;
	import net.digitalprimates.dash.builders.IDashBuilder;
	import net.digitalprimates.dash.parsers.IParser;
	import net.digitalprimates.dash.utils.Log;
	import net.digitalprimates.dash.valueObjects.AdaptationSet;
	import net.digitalprimates.dash.valueObjects.Representation;
	import net.digitalprimates.osmf.utils.PluginLoader;
	import net.digitalprimates.osmf.utils.events.PluginLoaderEvent;
	
	import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingItem;
	import org.osmf.net.StreamingItemType;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.URL;

	/**
	 * Handles the initial loading of the Dash manifest file.
	 * <p>This class loads the manifest and builds the <code>DynamicStreamingResource</code>
	 * used to represent the actual video stream.</code>
	 *
	 * @author Nathan Weber
	 */
	public class DashLoader extends LoaderBase
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		private var pluginsLoaded:Boolean = false;

		private var pluginLoader:PluginLoader;

		private var pendingResource:MediaResourceBase;

		private var loadTrait:LoadTrait;

		private var manifestLoader:URLLoader;

		private var builders:Vector.<IDashBuilder>;

		private var parser:IParser;

		protected var factory:MediaFactory;

		private var _plugins:Vector.<PluginInfoResource>;

		/**
		 * The set of plugins used internally. 
		 * 
		 * @return 
		 */		
		protected function get plugins():Vector.<PluginInfoResource> {
			if (!_plugins) {
				_plugins = new Vector.<PluginInfoResource>();
				_plugins.push(new PluginInfoResource(new InternalDashPluginInfo()));
			}

			return _plugins;
		}

		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		/**
		 * @private 
		 */		
		override public function canHandleResource(resource:MediaResourceBase):Boolean {
			if (resource is URLResource) {
				var url:URL = new URL((resource as URLResource).url);
				if (url.extension == "mpd") {
					return true;
				}
			}

			return false;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		/**
		 * Builds a factory to use when creating the internal MediaElement.
		 *  
		 * @return 
		 */		
		protected function createDefaultFactory():MediaFactory {
			return new DefaultMediaFactory();
		}

		/**
		 * @private 
		 */		
		override protected function executeLoad(loadTrait:LoadTrait):void {
			this.loadTrait = loadTrait;

			updateLoadTrait(loadTrait, LoadState.LOADING);

			var url:String = URLResource(loadTrait.resource).url;
			manifestLoader = new URLLoader(new URLRequest(url));
			manifestLoader.addEventListener(Event.COMPLETE, onComplete);
			manifestLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			manifestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}

		/**
		 * Called when then manifest is done being loaded.
		 *  
		 * @param resource
		 */		
		protected function finishLoad(resource:MediaResourceBase):void {
			var loadedElem:MediaElement = factory.createMediaElement(resource);

			LoadFromDocumentLoadTrait(loadTrait).mediaElement = loadedElem;
			updateLoadTrait(loadTrait, LoadState.READY);
		}

		/**
		 * Returns a set of <code>IDashBuilder</code> objects that can be used
		 * to parse a Dash manifest.
		 *  
		 * @return 
		 */		
		protected function getBuilders():Vector.<IDashBuilder> {
			var b:Vector.<IDashBuilder> = new Vector.<IDashBuilder>();

			b.push(new BaseDashBuilder());

			return b;
		}

		private function getParser(resourceData:String):IParser {
			var parser:IParser;

			for each (var b:IDashBuilder in builders) {
				if (b.canParse(resourceData)) {
					parser = b.build(resourceData);
					break;
				}
			}

			return parser;
		}

		/**
		 * Builds the resource used to represent the actual video stream.
		 *  
		 * @param manifest
		 * @return 
		 */		
		protected function makeStreamingResource(manifest:DashManifest):MediaResourceBase {
			var resource:DynamicStreamingResource = new DynamicStreamingResource((loadTrait.resource as URLResource).url, manifest.streamType);
			
			var primaryStreamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			var alternativeStreamItems:Vector.<StreamingItem> = new Vector.<StreamingItem>();
			
			var httpMetadata:Metadata = new Metadata();
			resource.addMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
			httpMetadata.addValue(DashMetadataNamespaces.HTTP_STREAMING_PERIOD_DURATION_KEY, manifest.duration);
			httpMetadata.addValue(DashMetadataNamespaces.HTTP_STREAMING_MIN_BUFFER_TIME_KEY, manifest.minBufferTime);
			
			var adaptation:AdaptationSet;
			var media:Representation;
			
			var streamName:String;
			var streamBitrate:Number;
			var streamWidth:int;
			var streamHeight:int;
			
			var firstAudioStream:Boolean = true;
			
			for each (adaptation in manifest.adaptations) {
				// use the video adaptation set as the variable bitrates OSMF expects
				if (adaptation.isVideo) {
					for each (media in adaptation.medias) {
						streamName = media.id;
						streamBitrate = media.bitrate / 1000;
						streamWidth = media.width;
						streamHeight = media.height;
						
						var streamItem:DynamicStreamingItem =
							new DynamicStreamingItem(streamName,
													 streamBitrate,
													 streamWidth,
													 streamHeight);
						
						primaryStreamItems.push(streamItem);
						httpMetadata.addValue(
							DashMetadataNamespaces.HTTP_STREAMING_REPRESENTATION_KEY + streamItem.streamName,
							media);
					}
				}
				// external audio tracks as set as 'alternative audio tracks' in osmf
				// is Dash the external audio track may be the default
				// osmf doesn't support that, so it's been 'hacked' in
				// see DashHTTPNetStream
				else if (adaptation.isAudio) {
					for each (media in adaptation.medias) {
						streamName = media.id;
						streamBitrate = media.bitrate / 1000;
						
						var audioItem:StreamingItem =
							new StreamingItem(StreamingItemType.AUDIO,
											  streamName,
											  streamBitrate);
						
						alternativeStreamItems.push(audioItem);
						httpMetadata.addValue(
							DashMetadataNamespaces.HTTP_STREAMING_REPRESENTATION_KEY + audioItem.streamName,
							media);
						
						// if this is the first external audio, assume it's also the default audio track
						// set this metadata so that we can force OSMF into using it later
						// TODO : This might be a bad assumption!  What if there are external audio tracks and the
						// video track has audio?  Is that allowed in the Dash spec?
						if (firstAudioStream) {
							firstAudioStream = false;
							httpMetadata.addValue(
								DashMetadataNamespaces.DEFAULT_AUDIO_TRACK,
								audioItem.streamName);
						}
					}
				}
				else {
					Log.log("unexpected adaptation set");
				}
			}
			
			resource.streamItems = primaryStreamItems;
			resource.alternativeAudioStreamItems = alternativeStreamItems;
			
			// Add metadata to the created resource specifying the resource from
			// which it was derived.  This allows interested clients to determine
			// the origins of the resource.
			resource.addMetadataValue(MetadataNamespaces.DERIVED_RESOURCE_METADATA, loadTrait.resource);

			// Add some metadata to indicate that this is a fully loaded m3u8 resource.
			// Important, because if we're just proxying a single stream we don't want to parse it again.
			// We also don't want HTTPNetLoader to try to play a DynamicStreamingResource
			resource.addMetadataValue(DashMetadataNamespaces.PLAYABLE_RESOURCE_METADATA, true);

			return resource;
		}

		private function finishManifestLoad(manifest:DashManifest):void {
			try {
				var resource:MediaResourceBase = makeStreamingResource(manifest);

				if (pluginsLoaded) {
					finishLoad(resource);
				}
				else {
					pendingResource = resource;
				}
			}
			catch (error:Error)
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, "Invalid mpd file.")));
			}
		}

		//----------------------------------------
		//
		// Handlers
		//
		//----------------------------------------

		private function onPluginsLoaded(event:PluginLoaderEvent):void {
			pluginLoader.removeEventListener(PluginLoaderEvent.LOAD_COMPLETE, onPluginsLoaded);
			pluginLoader.removeEventListener(PluginLoaderEvent.LOAD_ERROR, onPluginsLoadError);
			pluginLoader = null;

			pluginsLoaded = true;

			if (pendingResource) {
				finishLoad(pendingResource);
				pendingResource = null;
			}
		}

		private function onPluginsLoadError(event:PluginLoaderEvent):void {
			pluginLoader.removeEventListener(PluginLoaderEvent.LOAD_COMPLETE, onPluginsLoaded);
			pluginLoader.removeEventListener(PluginLoaderEvent.LOAD_ERROR, onPluginsLoadError);
			pluginLoader = null;
		}

		private function onComplete(event:Event):void {
			manifestLoader.removeEventListener(Event.COMPLETE, onComplete);
			manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			try {
				var resourceData:String = String((event.target as URLLoader).data);

				parser = getParser(resourceData);

				// Begin parsing.
				parser.addEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
				parser.addEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

				parser.parse(resourceData, URL.normalizePathForURL(URLResource(loadTrait.resource).url, true));
			}
			catch (parseError:Error)
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
			}
		}

		private function onError(event:ErrorEvent):void {
			manifestLoader.removeEventListener(Event.COMPLETE, onComplete);
			manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, event.text)));
		}

		private function onParserLoadComplete(event:ParseEvent):void {
			parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
			parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

			var manifest:DashManifest = event.data as DashManifest;
			finishManifestLoad(manifest);
		}

		private function onParserLoadError(event:ParseEvent):void {
			parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
			parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

			updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, "Invalid mpd file.")));
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		/**
		 * Constructor.
		 * 
		 * @param factory
		 */		
		public function DashLoader(factory:MediaFactory = null) {
			super();

			if (factory == null) {
				factory = createDefaultFactory();
				pluginLoader = new PluginLoader(factory, plugins);
				pluginLoader.addEventListener(PluginLoaderEvent.LOAD_COMPLETE, onPluginsLoaded);
				pluginLoader.addEventListener(PluginLoaderEvent.LOAD_ERROR, onPluginsLoadError);

				// Nothing to load.
				if (!pluginLoader.load()) {
					pluginsLoaded = true;
				}
			}

			this.factory = factory;
			this.builders = getBuilders();
		}
	}
}
