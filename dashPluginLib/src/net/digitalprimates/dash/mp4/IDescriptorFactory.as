package net.digitalprimates.dash.mp4
{
	import net.digitalprimates.dash.mp4.descriptors.Descriptor;
	import net.digitalprimates.dash.valueObjects.BitStream;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public interface IDescriptorFactory
	{
		function getInstance(data:BitStream, objectTypeIndication:uint = 0):Descriptor;
	}
}