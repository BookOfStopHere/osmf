package net.digitalprimates.dash.utils
{
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.valueObjects.BoxInfo;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public interface IBoxFactory
	{
		function getInstance(input:IDataInput, readData:Boolean = false):BoxInfo;
	}
}