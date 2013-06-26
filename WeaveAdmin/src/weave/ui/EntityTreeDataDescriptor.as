package weave.ui
{
    import mx.collections.ICollectionView;
    import mx.controls.treeClasses.ITreeDataDescriptor;
    
	/**
	 * @author adufilie
	 */
    public class EntityTreeDataDescriptor implements ITreeDataDescriptor
    {
        public function addChildAt(parent:Object, newChild:Object, index:int, model:Object = null):Boolean
        {
			if (newChild is EntityNode)
			{
				EntityNode.addChildAt(parent as EntityNode, newChild as EntityNode, index);
				return true;
			}
			return false;
        }
        public function removeChildAt(parent:Object, child:Object, index:int, model:Object = null):Boolean
        {
			if (child is EntityNode)
				EntityNode.removeChild(parent as EntityNode, child as EntityNode);
			return true;
        }
        public function getChildren(node:Object, model:Object = null):ICollectionView
        {
			return (node as EntityNode).children;
        }
        public function hasChildren(node:Object, model:Object = null):Boolean
        {
			var children:ICollectionView = getChildren(node, model);
			return children != null;
        }
        public function getData(node:Object, model:Object = null):Object
        {
			return node as EntityNode;
        }
        public function isBranch(node:Object, model:Object = null):Boolean
        {
			return (node as EntityNode).isBranch();
        }
    }
}
