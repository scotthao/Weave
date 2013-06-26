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

package weave.visualization.plotters
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import weave.Weave;
	import weave.api.data.IQualifiedKey;
	import weave.api.linkSessionState;
	import weave.api.newLinkableChild;
	import weave.api.primitives.IBounds2D;
	import weave.api.registerLinkableChild;
	import weave.api.setSessionState;
	import weave.api.ui.IPlotTask;
	import weave.core.LinkableBoolean;
	import weave.data.AttributeColumns.BinnedColumn;
	import weave.data.AttributeColumns.ColorColumn;
	import weave.data.AttributeColumns.DynamicColumn;
	import weave.data.AttributeColumns.FilteredColumn;
	import weave.primitives.Bounds2D;
	import weave.visualization.plotters.styles.SolidFillStyle;
	import weave.visualization.plotters.styles.SolidLineStyle;
	
	/**
	 * This plotter displays a histogram with optional colors.
	 * 
	 * @author adufilie
	 */
	public class HistogramPlotter extends AbstractPlotter
	{
		public function HistogramPlotter()
		{
			clipDrawing = true;
			
			// don't lock the ColorColumn, so linking to global ColorColumn is possible
			var _colorColumn:ColorColumn = fillStyle.color.internalDynamicColumn.requestLocalObject(ColorColumn, false);
			_colorColumn.ramp.value = "0x808080";

			var _binnedColumn:BinnedColumn = _colorColumn.internalDynamicColumn.requestLocalObject(BinnedColumn, true);
			
			// the data inside the binned column needs to be filtered by the subset
			var filteredColumn:FilteredColumn = _binnedColumn.internalDynamicColumn.requestLocalObject(FilteredColumn, true);
			
			linkSessionState(filteredKeySet.keyFilter, filteredColumn.filter);
			
			// make the colors spatial properties because the binned column is inside
			registerSpatialProperty(dynamicColorColumn);

			setSingleKeySource(fillStyle.color.internalDynamicColumn); // use record keys, not bin keys!
		}
		
		/**
		 * This column object may change and it may be null, depending on the session state.
		 * This function is provided for convenience.
		 */		
		public function get internalBinnedColumn():BinnedColumn
		{
			var cc:ColorColumn = internalColorColumn;
			if (cc)
				return cc.getInternalColumn() as BinnedColumn
			return null;
		}
		/**
		 * This column object may change and it may be null, depending on the session state.
		 * This function is provided for convenience.
		 */
		public function get internalColorColumn():ColorColumn
		{
			return fillStyle.color.getInternalColumn() as ColorColumn;
		}
		/**
		 * This column object will always remain for the life of the plotter.
		 * This function is provided for convenience.
		 */		
		public function get dynamicColorColumn():DynamicColumn
		{
			return fillStyle.color.internalDynamicColumn;
		}
		public const lineStyle:SolidLineStyle = newLinkableChild(this, SolidLineStyle);
		public const fillStyle:SolidFillStyle = newLinkableChild(this, SolidFillStyle);
		public const drawPartialBins:LinkableBoolean = registerLinkableChild(this, new LinkableBoolean(true));
		
		/**
		 * This function returns the collective bounds of all the bins.
		 */
		override public function getBackgroundDataBounds(output:IBounds2D):void
		{
			var binCol:BinnedColumn = internalBinnedColumn;
			if (binCol != null)
				output.setBounds(-0.5, 0, Math.max(1, binCol.numberOfBins) - 0.5, Math.max(1, binCol.largestBinSize));
			else
				output.reset();
		}
		
		/**
		 * This gets the data bounds of the histogram bin that a record key falls into.
		 */
		override public function getDataBoundsFromRecordKey(recordKey:IQualifiedKey, output:Array):void
		{
			var binCol:BinnedColumn = internalBinnedColumn;
			if (binCol == null)
			{
				initBoundsArray(output, 0);
				return;
			}
			
			var binIndex:Number = binCol.getValueFromKey(recordKey, Number);
			if (isNaN(binIndex))
			{
				initBoundsArray(output, 0);
				return;
			}
			
			var binHeight:int = binCol.getKeysFromBinIndex(binIndex).length;
			initBoundsArray(output);
			(output[0] as IBounds2D).setBounds(binIndex - 0.5, 0, binIndex + 0.5, binHeight);
		}
		
		/**
		 * This draws the histogram bins that a list of record keys fall into.
		 */
		override public function drawPlotAsyncIteration(task:IPlotTask):Number
		{
			drawAll(task.recordKeys, task.dataBounds, task.screenBounds, task.buffer);
			return 1;
		}
		private function drawAll(recordKeys:Array, dataBounds:IBounds2D, screenBounds:IBounds2D, destination:BitmapData):void

		{
			var i:int;
			var binCol:BinnedColumn = internalBinnedColumn;
			if (binCol == null)
				return;
			
			// convert record keys to bin keys
			// save a mapping of each bin key found to a value of true
			var binName:String;
			var _tempBinKeyToSingleRecordKeyMap:Object = new Object();
			for (i = 0; i < recordKeys.length; i++)
			{
				binName = binCol.getValueFromKey(recordKeys[i], String);
				var array:Array = _tempBinKeyToSingleRecordKeyMap[binName] as Array
				if (!array)
					array = _tempBinKeyToSingleRecordKeyMap[binName] = [];
				array.push(recordKeys[i]);
			}

			var binNames:Array = [];
			for (binName in _tempBinKeyToSingleRecordKeyMap)
				binNames.push(binName);
			var allBinNames:Array = binCol.binningDefinition.getBinNames();
			
			// draw the bins
			// BEGIN template code for defining a drawPlot() function.
			//---------------------------------------------------------
			
			var graphics:Graphics = tempShape.graphics;
			for (i = 0; i < binNames.length; i++)
			{
				binName = binNames[i];
				var keys:Array = _tempBinKeyToSingleRecordKeyMap[binName] as Array;
				var binHeight:int = drawPartialBins.value ? keys.length : (binCol.getKeysFromBinName(binName) as Array).length;
				var binIndex:int = allBinNames.indexOf(binName);
	
				// project data coords to screen coords
				tempPoint.x = binIndex - 0.5; // center of rectangle will be binIndex, width 1
				tempPoint.y = 0;
				dataBounds.projectPointTo(tempPoint, screenBounds);
				tempBounds.setMinPoint(tempPoint);
				tempPoint.x = binIndex + 0.5; // center of rectangle will be binIndex, width 1
				tempPoint.y = binHeight;
				dataBounds.projectPointTo(tempPoint, screenBounds);
				tempBounds.setMaxPoint(tempPoint);
	
				// draw rectangle for bin
				graphics.clear();
				lineStyle.beginLineStyle(keys[0], graphics);
				fillStyle.beginFillStyle(keys[0], graphics);
				graphics.drawRect(tempBounds.getXMin(), tempBounds.getYMin(), tempBounds.getWidth(), tempBounds.getHeight());
				graphics.endFill();
				// flush the tempShape "buffer" onto the destination BitmapData.
				destination.draw(tempShape);
			}
			
			//---------------------------------------------------------
			// END template code
		}
		
		private const tempPoint:Point = new Point();
		private const tempBounds:IBounds2D = new Bounds2D(); // reusable temporary object

		//------------------------
		// backwards compatibility
		[Deprecated(replacement="internalBinnedColumn")] public function set binnedColumn(value:Object):void
		{
			fillStyle.color.internalDynamicColumn.globalName = Weave.DEFAULT_COLOR_COLUMN;
			setSessionState(internalBinnedColumn, value);
		}
	}
}
