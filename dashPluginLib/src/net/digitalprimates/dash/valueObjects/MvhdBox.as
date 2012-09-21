package net.digitalprimates.dash.valueObjects
{
	import flash.utils.ByteArray;

	/**
	 *
	 *
	 * @author Nathan Weber
	 */
	public class MvhdBox extends BoxInfo
	{
		//----------------------------------------
		//
		// Properties
		//
		//----------------------------------------

		private var _creationTime:Number;

		public function get creationTime():Number {
			return _creationTime;
		}

		public function set creationTime(value:Number):void {
			_creationTime = value;
		}

		private var _modificationTime:Number;

		public function get modificationTime():Number {
			return _modificationTime;
		}

		public function set modificationTime(value:Number):void {
			_modificationTime = value;
		}

		private var _timescale:Number;

		public function get timescale():Number {
			return _timescale;
		}

		public function set timescale(value:Number):void {
			_timescale = value;
		}

		private var _duration:Number;

		public function get duration():Number {
			return _duration;
		}

		public function set duration(value:Number):void {
			_duration = value;
		}

		private var _preferredRate:int;

		public function get preferredRate():int {
			return _preferredRate;
		}

		public function set preferredRate(value:int):void {
			_preferredRate = value;
		}

		private var _preferredVolume:int;

		public function get preferredVolume():int {
			return _preferredVolume;
		}

		public function set preferredVolume(value:int):void {
			_preferredVolume = value;
		}

		private var _matrixA:int;

		public function get matrixA():int {
			return _matrixA;
		}

		public function set matrixA(value:int):void {
			_matrixA = value;
		}

		private var _matrixB:int;

		public function get matrixB():int {
			return _matrixB;
		}

		public function set matrixB(value:int):void {
			_matrixB = value;
		}

		private var _matrixU:int;

		public function get matrixU():int {
			return _matrixU;
		}

		public function set matrixU(value:int):void {
			_matrixU = value;
		}

		private var _matrixC:int;

		public function get matrixC():int {
			return _matrixC;
		}

		public function set matrixC(value:int):void {
			_matrixC = value;
		}

		private var _matrixD:int;

		public function get matrixD():int {
			return _matrixD;
		}

		public function set matrixD(value:int):void {
			_matrixD = value;
		}

		private var _matrixV:int;

		public function get matrixV():int {
			return _matrixV;
		}

		public function set matrixV(value:int):void {
			_matrixV = value;
		}

		private var _matrixX:int;

		public function get matrixX():int {
			return _matrixX;
		}

		public function set matrixX(value:int):void {
			_matrixX = value;
		}

		private var _matrixY:int;

		public function get matrixY():int {
			return _matrixY;
		}

		public function set matrixY(value:int):void {
			_matrixY = value;
		}

		private var _matrixW:int;

		public function get matrixW():int {
			return _matrixW;
		}

		public function set matrixW(value:int):void {
			_matrixW = value;
		}

		private var _previewTime:int;

		public function get previewTime():int {
			return _previewTime;
		}

		public function set previewTime(value:int):void {
			_previewTime = value;
		}

		private var _previewDuration:int;

		public function get previewDuration():int {
			return _previewDuration;
		}

		public function set previewDuration(value:int):void {
			_previewDuration = value;
		}

		private var _posterTime:int;

		public function get posterTime():int {
			return _posterTime;
		}

		public function set posterTime(value:int):void {
			_posterTime = value;
		}

		private var _selectionTime:int;

		public function get selectionTime():int {
			return _selectionTime;
		}

		public function set selectionTime(value:int):void {
			_selectionTime = value;
		}

		private var _selectionDuration:int;

		public function get selectionDuration():int {
			return _selectionDuration;
		}

		public function set selectionDuration(value:int):void {
			_selectionDuration = value;
		}

		private var _currentTime:int;

		public function get currentTime():int {
			return _currentTime;
		}

		public function set currentTime(value:int):void {
			_currentTime = value;
		}

		private var _nextTrackID:int;

		public function get nextTrackID():int {
			return _nextTrackID;
		}

		public function set nextTrackID(value:int):void {
			_nextTrackID = value;
		}

		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------

		override protected function parse():void {
			readFullBox(bitStream, this);

			if (version == 1) {
				creationTime = data.readDouble();
				modificationTime = data.readDouble();
				timescale = data.readUnsignedInt();
				duration = data.readDouble();
			}
			else {
				creationTime = data.readUnsignedInt();
				modificationTime = data.readUnsignedInt();
				timescale = data.readUnsignedInt();
				duration = data.readUnsignedInt();
			}

			preferredRate = data.readUnsignedInt();
			preferredVolume = data.readUnsignedShort();

			data.position += 10; // reserved

			matrixA = data.readUnsignedInt();
			matrixB = data.readUnsignedInt();
			matrixU = data.readUnsignedInt();
			matrixC = data.readUnsignedInt();
			matrixD = data.readUnsignedInt();
			matrixV = data.readUnsignedInt();
			matrixX = data.readUnsignedInt();
			matrixY = data.readUnsignedInt();
			matrixW = data.readUnsignedInt();
			previewTime = data.readUnsignedInt();
			previewDuration = data.readUnsignedInt();
			posterTime = data.readUnsignedInt();
			selectionTime = data.readUnsignedInt();
			selectionDuration = data.readUnsignedInt();
			currentTime = data.readUnsignedInt();
			nextTrackID = data.readUnsignedInt();

			data.position = 0;
		}

		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------

		public function MvhdBox(size:int, data:ByteArray = null) {
			super(size, BOX_TYPE_MVHD, data);
		}
	}
}
