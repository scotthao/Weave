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

package weave.api.core
{
	/**
	 * This is a collection of static core functions for Weave.
	 * 
	 * @author adufilie
	 */
	public interface ISessionManager
	{
		/**
		 * This function gets the ICallbackCollection associated with an ILinkableObject.
		 * If there is no ICallbackCollection defined for the object, one will be created.
		 * This ICallbackCollection is used for reporting changes in the session state
		 * @param linkableObject An ILinkableObject to get the associated ICallbackCollection for.
		 * @return The ICallbackCollection associated with the given object.
		 */
		function getCallbackCollection(linkableObject:ILinkableObject):ICallbackCollection;
		
		/**
		 * This function will create a new instance of the specified child class and register it as a child of the parent.
		 * If a callback function is given, the callback will be added to the child and cleaned up when the parent is disposed of.
		 * 
		 * Example usage:   public const foo:LinkableNumber = newLinkableChild(this, LinkableNumber, handleFooChange);
		 * 
		 * @param linkableParent A parent ILinkableObject to create a new child for.
		 * @param linkableChildType The class definition that implements ILinkableObject used to create the new child.
		 * @param callback A callback with no parameters that will be added to the child that will run before the parent callbacks are triggered, or during the next ENTER_FRAME event if a grouped callback is used.
		 * @param useGroupedCallback If this is true, addGroupedCallback() will be used instead of addImmediateCallback().
		 * @return The new child object.
		 */
		function newLinkableChild(linkableParent:Object, linkableChildType:Class, callback:Function = null, useGroupedCallback:Boolean = false):*;
		
		/**
		 * This function tells the SessionManager that the session state of the specified child should appear in the
		 * session state of the specified parent, and the child should be disposed of when the parent is disposed.
		 * 
		 * There is one other requirement for the child session state to appear in the parent session state -- the child
		 * must be accessible through a public variable of the parent or through an accessor function of the parent.
		 * 
		 * This function will add callbacks to the sessioned children that cause the parent callbacks to run.
		 * 
		 * If a callback function is given, the callback will be added to the child and cleaned up when the parent is disposed of.
		 * 
		 * Example usage:   public const foo:LinkableNumber = registerLinkableChild(this, someLinkableNumber, handleFooChange);
		 * 
		 * @param linkableParent A parent ILinkableObject that the child will be registered with.
		 * @param linkableChild The child ILinkableObject to register as a child.
		 * @param callback A callback with no parameters that will be added to the child that will run before the parent callbacks are triggered, or during the next ENTER_FRAME event if a grouped callback is used.
		 * @param useGroupedCallback If this is true, addGroupedCallback() will be used instead of addImmediateCallback().
		 * @param linkParentCallbacks Normally this parameter is true.  If it is false, the callbacks of the child will not trigger the parent callbacks.
		 * @return The linkableChild object that was passed to the function.
		 */
		function registerLinkableChild(linkableParent:Object, linkableChild:ILinkableObject, callback:Function = null, useGroupedCallback:Boolean = false):*;

		/**
		 * This function will create a new instance of the specified child class and register it as a child of the parent.
		 * Use this function when a child object can be disposed of but you do not want to link the callbacks.
		 * The child will be disposed when the parent is disposed.
		 * 
		 * Example usage:   public const foo:LinkableNumber = newDisposableChild(this, LinkableNumber);
		 * 
		 * @param disposableParent A parent ILinkableObject to create a new child for.
		 * @param disposableChildType The class definition that implements ILinkableObject used to create the new child.
		 * @return The new child object.
		 */
		function newDisposableChild(disposableParent:Object, disposableChildType:Class):*;
		
		/**
		 * This will register a child of a parent and cause the child to be disposed when the parent is disposed.
		 * Use this function when a child object can be disposed of but you do not want to link the callbacks.
		 * The child will be disposed when the parent is disposed.
		 * 
		 * Example usage:   public const foo:LinkableNumber = registerDisposableChild(this, someLinkableNumber);
		 * 
		 * @param disposableParent A parent disposable object that the child will be registered with.
		 * @param disposableChild The disposable object to register as a child of the parent.
		 * @return The linkableChild object that was passed to the function.
		 */
		function registerDisposableChild(disposableParent:Object, disposableChild:Object):*;

		/**
		 * This function gets the owner of a linkable object.  The owner of an object is defined as its first registered parent.
		 * @param child An ILinkableObject that was registered as a child of another ILinkableObject.
		 * @return The owner of the child object (the first parent that was registered with the child), or null if the child has no owner.
		 */
		function getLinkableOwner(child:ILinkableObject):ILinkableObject;
		
		/**
		 * This function will return all the descendant objects that implement ILinkableObject.
		 * If the filter parameter is specified, the results will contain only those objects that extend or implement the filter class.
		 * @param root A root object to get the descendants of.
		 * @param filter An optional Class definition which will be used to filter the results.
		 * @return An Array containing a list of descendant objects.
		 */
		function getLinkableDescendants(root:ILinkableObject, flter:Class = null):Array;
		
		/**
		 * This will assign an asynchronous task to a linkable object so that <code>linkableObjectIsBusy(busyObject)</code>
		 * will return true until all assigned tasks are unassigned using <code>unassignBusyTask(taskToken)</code>.
		 * This will not add the task to WeaveAPI.ProgressIndicator.
		 * @param taskToken A token representing an asynchronous task.  If this is an AsyncToken, a responder will be added that will automatically call unassignBusyTask(taskToken) on success or failure.
		 * @param busyObject The object that is busy waiting for the task to complete.
		 * @see weave.api.core.IProgressIndicator#addTask()
		 */
		function assignBusyTask(taskToken:Object, busyObject:ILinkableObject):void;
		
		/**
		 * This will unassign an asynchronous task from all linkable objects it has been previously assigned to.
		 * If the task was previously registered with WeaveAPI.ProgressManager, this will call WeaveAPI.ProgressManager.removeTask().
		 * @param taskToken A token representing an asynchronous task.
		 * @see weave.api.core.IProgressIndicator#removeTask()
		 */
		function unassignBusyTask(taskToken:Object):void;
		
		/**
		 * This checks if any asynchronous tasks have been assigned to a linkable object or any of its registered descendants.
		 * @param linkableObject The object to check.
		 * @return A value of true if any asynchronous tasks have been assigned to the object.
		 */
		function linkableObjectIsBusy(linkableObject:ILinkableObject):Boolean;

		/**
		 * @param linkableObject An object containing sessioned properties (sessioned objects may be nested).
		 * @param newState An object containing the new values for sessioned properties in the sessioned object.
		 * @param removeMissingDynamicObjects If true, this will remove any properties from an ILinkableCompositeObject that do not appear in the session state.
		 */
		function setSessionState(linkableObject:ILinkableObject, newState:Object, removeMissingDynamicObjects:Boolean = true):void;
		
		/**
		 * @param linkableObject An object containing sessioned properties (sessioned objects may be nested).
		 * @return An object containing the values from the sessioned properties.
		 */
		function getSessionState(linkableObject:ILinkableObject):Object;
		
		/**
		 * This function computes the diff of two session states.
		 * @param oldState The source session state.
		 * @param newState The destination session state.
		 * @return A patch that generates the destination session state when applied to the source session state, or undefined if the two states are equivalent.
		 */
		function computeDiff(oldState:Object, newState:Object):*;
		
		/**
		 * This modifies an existing diff to include an additional diff.
		 * @param baseDiff The base diff which will be modified to include an additional diff.
		 * @param diffToAdd The diff to add to the base diff.  This diff will not be modified.
		 * @return The modified baseDiff, or a new diff object if baseDiff is a primitive value.
		 */
		function combineDiff(baseDiff:Object, diffToAdd:Object):Object;

		/**
		 * This function will copy the session state from one sessioned object to another.
		 * If the two objects are of different types, the behavior of this function is undefined.
		 * @param source A sessioned object to copy the session state from.
		 * @param destination A sessioned object to copy the session state to.
		 */
		function copySessionState(source:ILinkableObject, destination:ILinkableObject):void;

		/**
		 * This will link the session state of two ILinkableObjects.
		 * The session state of 'primary' will be copied over to 'secondary' after linking them.
		 * @param primary An ILinkableObject to give authority over the initial shared value.
		 * @param secondary The ILinkableObject to link with 'primary' via session state.
		 */
		function linkSessionState(primary:ILinkableObject, secondary:ILinkableObject):void;

		/**
		 * This will unlink the session state of two ILinkableObjects that were previously linked with linkSessionState().
		 * @param first The ILinkableObject to unlink from 'second'
		 * @param second The ILinkableObject to unlink from 'first'
		 */
		function unlinkSessionState(first:ILinkableObject, second:ILinkableObject):void;

		/**
		 * This function will link the session state of an ILinkableVariable to a bindable property of an object.
		 * Prior to linking, the value of the ILinkableVariable will be copied over to the bindable property.
		 * @param linkableVariable An ILinkableVariable to link to a bindable property.
		 * @param bindableParent An object with a bindable property.
		 * @param bindablePropertyName The variable name of the bindable property.
		 * @param delay The delay to use before setting the linkable variable to reflect a change in the bindable property while the bindableParent has focus.
		 * @param onlyWhenFocused If this is set to true and the bindableParent is a UIComponent, the bindable value will only be copied to the linkableVariable when the component has focus.
		 */
		function linkBindableProperty(linkableVariable:ILinkableVariable, bindableParent:Object, bindablePropertyName:String, delay:uint = 0, onlyWhenFocused:Boolean = false):void;

		/**
		 * This function will unlink an ILinkableVariable from a bindable property that has been previously linked with linkBindableProperty().
		 * @param linkableVariable An ILinkableVariable to unlink from a bindable property.
		 * @param bindableParent An object with a bindable property.
		 * @param bindablePropertyName The variable name of the bindable property.
		 */
		function unlinkBindableProperty(linkableVariable:ILinkableVariable, bindableParent:Object, bindablePropertyName:String):void;
		
		/**
		 * This function should be called when an ILinkableObject or IDisposableObject is no longer needed.
		 * @param object An ILinkableObject or an IDisposableObject to clean up.
		 * @param moreObjects More objects to clean up.
		 */
		function disposeObjects(object:Object, ...moreObjects):void;

		/**
		 * This function checks if an object has been disposed of by the ISessionManager.
		 * @param object An object to check.
		 * @return A value of true if disposeObjects() was called for the specified object.
		 */
		function objectWasDisposed(object:Object):Boolean;
	}
}
