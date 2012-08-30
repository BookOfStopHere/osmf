package net.digitalprimates.mfex
{
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class NetClient extends Proxy
	{
		//----------------------------------------
		//
		// Variables
		//
		//----------------------------------------
		
		private var handlers:Dictionary = new Dictionary();
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public function addHandler(name:String, handler:Function, priority:int=0):void {
			var item:InvokeItem = new InvokeItem(handler, priority);
			
			var handlersForName:Array = handlers[name];
			if (!handlersForName) {
				handlersForName = [];
				handlers[name] = handlersForName;
			}
			
			handlersForName.push(item);
			handlersForName.sortOn("priority", Array.NUMERIC);
		}
		
		public function removeHandler(name:String, handler:Function):void {
			var handlersForName:Array = handlers[name];
			if (!handlersForName) {
				return;
			}
			
			for (var i:int = 0; i < handlersForName.length; i++) {
				if (handlersForName[i].handler == handler) {
					handlersForName.splice(i, 1);
					break;
				}
			}
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		private function invokeHandlers(name:String, args:Array):* {
			var handlersForName:Array = handlers[name];
			
			if (handlersForName) {
				var results:Array = [];
				for each (var item:InvokeItem in handlersForName) {
					results.push(item.handler.apply(null, args));
				}
			}
			
			return null;
		}
		
		override flash_proxy function callProperty(methodName:*, ... args):* {
			return invokeHandlers(methodName, args);
		}
		
		override flash_proxy function getProperty(name:*):*  {
			var results:* = function():* {
								return invokeHandlers(arguments.callee.name, arguments);
							};
			results.name = name;
			return results;
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return (handlers[name] != null && handlers[name].length > 0);
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		public function NetClient() {
			super();
		}
	}
}

class InvokeItem {
	public var handler:Function;
	public var priority:int;
	
	public function InvokeItem(handler:Function, priority:int) {
		this.handler = handler;
		this.priority = priority;
	}
}