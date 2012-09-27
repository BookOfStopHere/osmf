package net.digitalprimates.dash.elements
{
	import net.digitalprimates.dash.DashMetadataNamespaces;
	import net.digitalprimates.dash.loaders.DashLoader;
	import net.digitalprimates.dash.traits.DashBufferTrait;
	
	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitType;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashElement extends LoadFromDocumentElement
	{
		private var bufferTrait:DashBufferTrait;
		
		override public function set proxiedElement(value:MediaElement):void {
			setupBufferTrait(value);
			super.proxiedElement = value;
		}
		
		protected function setupBufferTrait(element:MediaElement):void {
			if (!element) {
				return;
			}
			
			var proxiedBufferTrait:BufferTrait = (element.getTrait(MediaTraitType.BUFFER) as BufferTrait);
			if (!proxiedBufferTrait) {
				element.addEventListener(MediaElementEvent.TRAIT_ADD, onBufferTraitAdd);
			}
			
			if (!bufferTrait) {
				var httpMetadata:Metadata = element.resource.getMetadataValue(DashMetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
				var hasMinBufferTime:Boolean = (httpMetadata.keys.indexOf(DashMetadataNamespaces.HTTP_STREAMING_MIN_BUFFER_TIME_KEY) != -1);
				if (hasMinBufferTime) {
					var defaultMinBufferTime:Number = httpMetadata.getValue(DashMetadataNamespaces.HTTP_STREAMING_MIN_BUFFER_TIME_KEY) as Number;
					bufferTrait = new DashBufferTrait(proxiedBufferTrait, defaultMinBufferTime);
				}
			}
			else {
				bufferTrait.proxiedBufferTrait = proxiedBufferTrait;
			}
		}
		
		private function onBufferTraitAdd(event:MediaElementEvent):void {
			if (event.traitType == MediaTraitType.BUFFER) {
				setupBufferTrait(proxiedElement);
				proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onBufferTraitAdd);
			}
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashElement(resource:MediaResourceBase = null, loader:DashLoader = null) {
			if (loader == null) {
				loader = new DashLoader();
			}
			
			super(resource, loader);
		}
	}
}
