/* ***** BEGIN LICENSE BLOCK *****
 *
 * This file is part of the Weave API.
 *
 * The Initial Developer of the Weave API is the Institute for Visualization
 * and Perception Research at the University of Massachusetts Lowell.
 * Portions created by the Initial Developer are Copyright (C) 2008-2012
 * the Initial Developer. All Rights Reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * ***** END LICENSE BLOCK ***** */

package weave.api
{
	/**
	 * Shortcut for WeaveAPI.SessionManager.registerDisposableChild()
	 * @copy weave.api.core.ISessionManager#registerDisposableChild()
	 */
	public function registerDisposableChild(disposableParent:Object, disposableChild:Object):*
	{
		return WeaveAPI.SessionManager.registerDisposableChild(disposableParent, disposableChild);
	}
}
