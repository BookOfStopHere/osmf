package net.digitalprimates.dash.net
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	import net.digitalprimates.dash.decoders.DefaultDecoderFactory;
	import net.digitalprimates.dash.decoders.IDecoder;
	import net.digitalprimates.dash.decoders.IDecoderFactory;
	
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class DashFileHandler extends HTTPStreamingFileHandlerBase
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------

		private var _decoderFactory:IDecoderFactory;

		protected function get decoderFactory():IDecoderFactory {
			if (!_decoderFactory) {
				_decoderFactory = new DefaultDecoderFactory();
			}

			return _decoderFactory;
		}

		protected var currentDecoder:IDecoder;

		public var currentMimeType:String;

		public var currentCodecs:Array;

		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------

		override public function beginProcessFile(seek:Boolean, seekTime:Number):void {
			trace("beginProcessFile");
			initializeProcessing();
		}

		override public function get inputBytesNeeded():Number {
			return 0;
		}

		override public function processFileSegment(input:IDataInput):ByteArray {
			trace("processFileSegment", input.bytesAvailable);
			return processDataByFormat(input);
		}

		override public function endProcessFile(input:IDataInput):ByteArray {
			trace("endProcessFile");
			var rv:ByteArray = processDataByFormat(input);

			finishProcessing();

			return rv;
		}

		override public function flushFileSegment(input:IDataInput):ByteArray {
			trace("flushFileSegment");
			var rv:ByteArray = processDataByFormat(input || new ByteArray());

			finishProcessing();

			return rv;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		private function initializeProcessing():void {
			currentDecoder = decoderFactory.newInstance(currentMimeType, currentCodecs);
		}

		private function finishProcessing():void {
			currentDecoder = null;
			currentMimeType = null;
			currentCodecs = null;
		}

		private function processDataByFormat(input:IDataInput, limit:Number = 0):ByteArray {
			if (!currentDecoder)
				return null;

			return currentDecoder.processData(input, limit);
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function DashFileHandler() {
			super();
		}
	}
}
