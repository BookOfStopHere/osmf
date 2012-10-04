package net.digitalprimates.dash.utils
{
	import net.digitalprimates.dash.valueObjects.BitStream;
	import net.digitalprimates.dash.valueObjects.Descriptor;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public interface IDescriptorFactory
	{
		function getInstance(bs:BitStream, objectTypeIndication:uint = 0):Descriptor;
	}
}