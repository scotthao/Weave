/*
    Weave (Web-based Analysis and Visualization Environment)
    Copyright (C) 2008-2011 University of Massachusetts Lowell

    This file is a part of Weave.

    Weave is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License, Version 3,
    as published by the Free Software Foundation.

    Weave is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Weave.  If not, see <http://www.gnu.org/licenses/>.
*/

package weave.core
{
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.Capabilities;
	
	import mx.events.DynamicEvent;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	import weave.api.core.IErrorManager;
	import weave.api.getCallbackCollection;
	import weave.compiler.StandardLib;
	import weave.utils.DebugUtils;
	import weave.utils.fixErrorMessage;
	
	/**
	 * This class is a central location for reporting and detecting errors.
	 * The callbacks for this object get called when an error is reported.
	 * 
	 * @author adufilie
	 */
	public class ErrorManager implements IErrorManager
	{
		private var _errors:Array = [];
		
		/**
		 * This is the list of all previously reported errors.
		 */
		public function get errors():Array
		{
			return _errors;
		}
		
		/**
		 * This function is intended to be the global error reporting mechanism for Weave.
		 * @param error An Error or a String describing the error.
		 * @param faultMessage A message associated with the error, if any.  If specified, the error will be wrapped in a Fault object.
		 * @param faultCessage Content associated with the error, if any.  If specified, the error will be wrapped in a Fault object.
		 */
		public function reportError(error:Object, faultMessage:String = null, faultContent:Object = null):void
		{
			if (error is DynamicEvent && error.error)
				error = error.error;
			if (error is FaultEvent)
			{
				// pull out the fault from the event
				var faultEvent:FaultEvent = error as FaultEvent;
				if (!faultMessage && faultEvent.message)
					faultMessage = StandardLib.asString(faultEvent.message.body);
				error = faultEvent.fault;
			}
			if (error is ErrorEvent)
				error = (error as ErrorEvent).text;
			if (error is String)
				error = new Error(error);
			if (error != null && !(error is Error))
				faultContent = faultContent == null ? error : [error, faultContent];
			if (!(error is Error) || faultMessage || faultContent != null)
			{
				// wrap the error in a Fault object
				if (!faultMessage && error is Error)
				{
					fixErrorMessage(error as Error);
					faultMessage = StandardLib.asString((error as Error).message);
				}
				var fault:Fault = new Fault('Error', faultMessage);
				fault.content = faultContent;
				fault.rootCause = error;
				error = fault;
			}
			
			var _error:Error = error as Error;
			if (!_error)
				throw new Error("Assertion failed");
			
			fixErrorMessage(_error);
			
			if (Capabilities.isDebugger)
			{
				trace('\n' + _error.getStackTrace() + '\n');
				//enterDebugger();
			}
			
			errors.push(_error);
			getCallbackCollection(this).triggerCallbacks();
		}
		
		public static function errorToString(error:Error):String
		{
			if (error is Fault)
			{
				var f:Fault = error as Fault;
				var errorString:String = '';
				if (f.faultDetail && (f.faultCode == IOErrorEvent.IO_ERROR || f.faultCode == SecurityErrorEvent.SECURITY_ERROR))
				{
					errorString = f.faultDetail;
				}
				else
				{
					errorString = f.faultCode;
					if (f.faultString)
						errorString += ': ' + f.faultString;
					if (f.faultDetail)
						errorString += ': ' + f.faultDetail;
					if (errorString == 'Error')
						errorString = "Communication error";
				}
				
				return errorString;
			}
			else if (Capabilities.isDebugger)
			{
				// get partial stack trace
				return error.message + '\rStack trace: ' + DebugUtils.getCompactStackTrace(error).join('; ');
			}
			else
			{
				return error.toString();
			}
		}
	}
}
