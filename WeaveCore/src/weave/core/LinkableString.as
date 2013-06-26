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
	/**
	 * This is a LinkableVariable which limits its session state to String values.
	 * @author adufilie
	 * @see weave.core.LinkableVariable
	 */
	public class LinkableString extends LinkableVariable
	{
		public function LinkableString(defaultValue:String = null, verifier:Function = null, defaultValueTriggersCallbacks:Boolean = true)
		{
			super(String, verifier, defaultValue, defaultValueTriggersCallbacks);
		}

		public function get value():String
		{
			return _sessionState;
		}
		public function set value(value:String):void
		{
			setSessionState(value);
		}
		
		override public function setSessionState(value:Object):void
		{
			if (value != null)
				value = String(value);
			super.setSessionState(value);
		}
	}
}
