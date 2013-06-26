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

package weave.services.wms
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import weave.api.WeaveAPI;
	import weave.api.core.IDisposableObject;
	import weave.api.getCallbackCollection;
	import weave.api.objectWasDisposed;
	import weave.api.primitives.IBounds2D;
	import weave.api.reportError;
	import weave.api.services.IWMSService;
	import weave.core.CallbackCollection;
	import weave.primitives.Bounds2D;

	/**
	 * This is an abstract class containing all the implementation details relevant
	 * to each Service object for WMS.
	 * 
	 * @author kmonico
	 */
	public class AbstractWMS implements IWMSService, IDisposableObject
	{
		public function AbstractWMS() 
		{
		}

		/**
		 * This is the tiling index which contains the KDTree of the tiles
		 * and associated images.
		 */
		protected var _currentTileIndex:WMSTileIndex;
		
		// parameters common to all tiling services
		protected var _tiledName:String; // displayed on maptool settings
		protected var _srs:String = null; // mercator for ModestMaps, lat/lon for nasa
		
		// dictionary mapping request strings to WMSTile objects
		protected var _urlToTile:Dictionary = new Dictionary(true);
				
		// reusable objects
		protected const _tempPoint:Point = new Point();
		protected const _tempBounds:Bounds2D = new Bounds2D();
		
		/**
		 * The bounds allowed for requests.
		 */
		protected const _allowedRequestedBounds:IBounds2D = new Bounds2D(-180, -90, 180, 90);

		/**
		 * This is an array of tiles whose images are downloading.
		 */
		protected var _pendingTiles:Array = [];
		
		/**
		 * This function will cancel all pending requests.
		 * @see weave.api.core.IWMSService#cancelPendingRequests
		 */
		public function cancelPendingRequests():void
		{
			for each (var tile:WMSTile in _pendingTiles)
			{
				tile.cancelDownload();
				delete _urlToTile[tile.request.url];
			}			
			_pendingTiles.length = 0;
		}
		
		/**
		 * This function will determine if a tile with identical bounds as key was already
		 * downloaded.
 		 * @param key The bounds object to check.
		 * @param array An array of WMSTile objects.
		 * @return True if there is a tile with bounds identical to key.
		 */
		protected function tileContainingBoundsDownloaded(key:IBounds2D, array:Array):Boolean
		{
			for each (var obj:Object in array)
			{
				var tempTile:WMSTile = obj as WMSTile;
				
				// if bounds are the same, they're the same tile
				if (tempTile.bounds.equals(key))
					return true;
			}
			return false;
		}
		
		/**
		 * This function will remove an image from _pendingImages and trigger callbacks.
		 */
		protected function handleTileDownload(tile:WMSTile):void
		{
			if (objectWasDisposed(this))
				return;
			
			_currentTileIndex.addTile(tile);
			
			// remove from pending list if necessary
			var index:int = _pendingTiles.indexOf(tile);
			if (index >= 0)
				_pendingTiles.splice(index, 1);
			
			WeaveAPI.StageUtils.callLater(this, getCallbackCollection(this).triggerCallbacks);
		}
		
		/**
		 * Return the number of pending requests.
		 * @see weave.api.core.IWMSService#getNumPendingRequests
		 */
		public function getNumPendingRequests():int
		{
			return _pendingTiles.length;
		}
		
		/**
		 * Return the srs code.
		 * @see weave.api.core.IWMSService#getProjectionSRS
		 */
		public function getProjectionSRS():String
		{
			return _srs;
		}
		
		/**
		 * Request the images.
		 * @see weave.api.core.IWMSService#requestImages
		 */		 
		/* abstract */ public function requestImages(dataBounds:IBounds2D, screenBounds:IBounds2D, lowerQuality:Boolean = false):Array 
		{
			return null;
		}
		
		/**
		 * Return the allowed bounds.
		 * @see weave.api.core.IWMSService#getAllowedBounds
		 */ 
		public function getAllowedBounds(output:IBounds2D):void
		{
			output.reset();
		}
		
		/* abstract */ public function setProvider(provider:String):void
		{
			reportError("Attempt to set the provider of AbstractWMS.");
		}
		
		/* abstract */ public function getProvider():*
		{
			reportError("Attempt to get the provider of AbstractWMS.");
			return null;
		}
		
		/**
		 * This will cancel pending requests when this object is disposed.
		 */		
		public function dispose():void
		{
			cancelPendingRequests();
		}
		
		/* abstract */ public function getCreditInfo():String
		{
			reportError("Attempt to get copyright information of AbstractWMS.");
			return null;
		}
	}
}