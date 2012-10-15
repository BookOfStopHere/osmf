package net.digitalprimates.dash.mp4
{
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.mp4.boxes.BoxInfo;

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