package net.digitalprimates.dash.net
{
	import flash.net.NetConnection;
	
	import net.digitalprimates.dash.DashMetadataNamespaces;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingItem;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPStreamMixer;
	import org.osmf.net.httpstreaming.HTTPStreamSource;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	
	/**
	 * Handles the loading of Dash streams.
	 * <p>The only purpose of this class is to force OSMF to use an alternativeAudioTrack as the default
	 * audio track for a stream.  Dash allows for this situation but OSMF does not.</p>
	 * <p>Every variable is private in OSMF so I had to modify HTTPNetStream and add several hook to make this work. :(</p>
	 * 
	 * @author Nathan Weber
	 */
	public class DashHTTPNetStream extends HTTPNetStream
	{
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		/**
		 * @private 
		 * If we have an external audio track built a mixer and force the alternative audio tracks to be used.
		 * Otherwise just let HTTPNetStream do it's thing.
		 */		
		override protected function createSource(resource:URLResource):void {
			var handled:Boolean = false;
			
			var httpMetadata:Metadata = resource.getMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			if (httpMetadata) {
				var hasDefaultAudio:Boolean = (httpMetadata.keys.indexOf(DashMetadataNamespaces.DEFAULT_AUDIO_TRACK) != -1);
				if (hasDefaultAudio) {
					var mixer:HTTPStreamMixer = new HTTPStreamMixer(this);
					mixer.video = new HTTPStreamSource(factory, resource, mixer);
					
					setMixer(mixer);
					setSource(mixer);
					setVideoHandler(mixer.video);
					
					var defaultTrackName:String = httpMetadata.getValue(DashMetadataNamespaces.DEFAULT_AUDIO_TRACK) as String;
					changeAudioStreamTo(defaultTrackName);
					
					handled = true;
				}
			}
			
			if (!handled) {
				super.createSource(resource);
			}
		}
		
		/**
		 * @private 
		 * HTTPNetStream used to directly call a static method on a utils class to get this resource.
		 * That's dumb.
		 * This is a hook I added so that we can build a resource without having to modify that static method.
		 * This method returns a resource for the alternative audio track.
		 */		
		override protected function createAudioResource(resource:MediaResourceBase, streamName:String):MediaResourceBase {
			var source:DynamicStreamingResource = (resource as DynamicStreamingResource);
			var audioResource:DynamicStreamingResource = new DynamicStreamingResource(source.host, source.streamType);
			
			var items:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
			for each (var audioItem:StreamingItem in source.alternativeAudioStreamItems) {
				items.push(new DynamicStreamingItem(audioItem.streamName, audioItem.bitrate));
			}
			
			audioResource.streamItems = items;
			
			var httpMetadata:Metadata = source.getMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			audioResource.addMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
			
			return audioResource;
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function DashHTTPNetStream(connection:NetConnection, factory:HTTPStreamingFactory, resource:URLResource=null) {
			super(connection, factory, resource);
		}
	}
}