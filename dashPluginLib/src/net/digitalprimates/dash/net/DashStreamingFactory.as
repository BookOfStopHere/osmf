package net.digitalprimates.dash.net
{
	import net.digitalprimates.dash.DashMetadataNamespaces;
	import net.digitalprimates.dash.valueObjects.Representation;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingItem;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashStreamingFactory extends HTTPStreamingFactory
	{
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		public override function createFileHandler(resource:MediaResourceBase):HTTPStreamingFileHandlerBase {
			return new DashFileHandler();
		}

		public override function createIndexHandler(resource:MediaResourceBase, fileHandler:HTTPStreamingFileHandlerBase):HTTPStreamingIndexHandlerBase {
			return new DashIndexHandler(fileHandler as DashFileHandler);
		}

		override public function createIndexInfo(resource:MediaResourceBase):HTTPStreamingIndexInfoBase {
			var streamInfos:Vector.<DashStreamingInfo> = generateStreamInfos(resource);
			var url:String = (resource as URLResource).url;
			
			var httpMetadata:Metadata = resource.getMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			var duration:Number = httpMetadata.getValue(DashMetadataNamespaces.HTTP_STREAMING_PERIOD_DURATION_KEY);
			
			return new DashStreamingIndexInfo(url, streamInfos, duration);
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		private static function generateStreamInfos(resource:MediaResourceBase):Vector.<DashStreamingInfo> {
			if (!resource) {
				return null;
			}

			var httpMetadata:Metadata = resource.getMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
			var streamInfos:Vector.<DashStreamingInfo> = new Vector.<DashStreamingInfo>();
			var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;

			if (dsResource != null) {
				var media:Representation
				for each (var streamItem:DynamicStreamingItem in dsResource.streamItems) {
					media = httpMetadata.getValue(DashMetadataNamespaces.HTTP_STREAMING_REPRESENTATION_KEY + streamItem.streamName);
					streamInfos.push(new DashStreamingInfo(streamItem.streamName, streamItem.bitrate, media));
				}
			}

			return streamInfos;
		}
	}
}
