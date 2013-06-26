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

package weave.utils;
import java.io.PrintStream;
import java.util.LinkedList;
import java.util.Observable;
import java.util.Observer;

/**
 * @author pkovac
 * @author adufilie
 */
public class ProgressManager extends Observable
{
	private final long ONE_SECOND = 1000000000;
	
	private String step_desc;
	private long current_steps;
	private long total_steps;
	
	LinkedList<Long> ticks = new LinkedList<Long>();
	private long min_dur_for_est = ONE_SECOND * 10; // time from start before estimating begins
	private long duration_for_estimate = ONE_SECOND * 10; // duration of ticks to use for estimate
	private long current_items;
	private long total_items;
	private long paused_time;
	private long offset_duration = 0;
    
    public ProgressManager()
    {
    	duration_for_estimate = Long.MAX_VALUE;
    }
    
    public ProgressManager(long durationForEstimate)
    {
    	duration_for_estimate = durationForEstimate;
    }
    
    public String getStepDescription() { return step_desc; }
    public long getStepNumber() { return current_steps; }
    public long getStepTotal() { return total_steps; }
    public long getTickNumber() { return current_items; }
    public long getTickTotal() { return total_items; }
    public long getStepTimeRemaining()
    {
    	double tick_duration = ticks.peekLast() - ticks.peekFirst();
    	if (ticks.size() <= 1 || tick_duration < min_dur_for_est)
    		return Long.MAX_VALUE;
    	double rate_est = (tick_duration) / (ticks.size() - 1);
    	double time_rem = (total_items - current_items) * rate_est;
    	return (long)Math.ceil(time_rem / ONE_SECOND);
    }
    
    public void beginStep(String description, int stepNumber, int stepTotal, int tickTotal)
    {
    	this.step_desc = description;
    	
    	this.current_steps = stepNumber;
    	this.total_steps = stepTotal;
    	
    	this.current_items = 0;
    	this.total_items = tickTotal;
    	
    	ticks.clear();
    	tick();
    }
    
    public void pause()
    {
    	paused_time = System.nanoTime();
    }
    public void resume()
    {
    	offset_duration += System.nanoTime() - paused_time;
    }
    
    public void tick()
    {
    	// add new tick
    	ticks.add(System.nanoTime() - offset_duration);
    	// drop the ticks that are outside our estimate duration
    	long firstTick;
    	do {
    		firstTick = ticks.pollFirst();
    	} while (ticks.size() > 0 && ticks.peekLast() - ticks.peekFirst() > duration_for_estimate);
    	ticks.addFirst(firstTick); // add back the tick we just removed to make the condition true again
    	
    	current_items++;
    	
    	setChanged();
    	notifyObservers();
    }
    
    public static class ProgressPrinter implements Observer
    {
    	private ProgressManager p;
    	private PrintStream out;
    	private long lastPrintMillisec;
    	private long printIntervalMillisec = 1000; 
    	
    	public ProgressPrinter(PrintStream out)
    	{
    		this.p = new ProgressManager();
    		this.out = out;
    		p.addObserver(this);
    	}
    	
    	public ProgressManager getProgressManager()
    	{
    		return p;
    	}

		public void update(Observable o, Object arg)
		{
			long curTime = System.currentTimeMillis();
			if (curTime - lastPrintMillisec < printIntervalMillisec)
				return;
			lastPrintMillisec = curTime;
			
			String step = "";
			if (p.getStepTotal() > 0)
			{
				step = String.format(
					"Step %s of %s: ",
					p.getStepNumber(),
					p.getStepTotal()
				);
			}
			
			String ticks = "";
			if (p.getTickTotal() > 0)
			{
				ticks = String.format(
					"%s/%s items",
					p.getTickNumber(),
					p.getTickTotal(),
					p.getStepTimeRemaining()
				);
			}
			
			String remain = "";
			double time = p.getStepTimeRemaining();
			if (time != Long.MAX_VALUE)
			{
				long s = (long)Math.ceil(time % 60);
				long m = (long)(time/60) % 60;
				long h = (long)(time/60/60);
				StringBuilder timeStr = new StringBuilder();
				if (h > 0)
					timeStr.append(h).append('h');
				if (h > 0 || m > 0)
					timeStr.append(m).append('m');
				if (h == 0 && s > 0)
					timeStr.append(s).append('s');
					
				remain = String.format("; %s remaining", timeStr);
			}
			
			String desc = p.getStepDescription();
			String par = ticks + remain;
			if (par.length() > 0)
				par = " (" + par + ")";
			
			out.println(step + desc + par);
            out.flush();
    	}
    }
}
