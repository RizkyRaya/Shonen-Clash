package net.play5d.game.bvn.utils
{
   import net.play5d.game.bvn.views.effects.EffectView;
   
   public class EffectPool
   {
      
      public var views:Vector.<EffectView>;
      
      public var freeStack:Vector.<int>;
      
      public var activeCount:int = 0;
      
      public var lastIndex:int = 0;
      
      public function EffectPool()
      {
         super();
         views = new Vector.<EffectView>();
         freeStack = new Vector.<int>();
      }
      
      public function get totalCount() : int
      {
         return views.length;
      }
      
      public function get idleCount() : int
      {
         return freeStack.length;
      }
      
      public function pushFree(index:int) : void
      {
         freeStack.push(index);
      }
      
      public function popFree() : int
      {
         if(freeStack.length == 0)
         {
            return -1;
         }
         return freeStack.pop();
      }
      
      public function hasFree() : Boolean
      {
         return freeStack.length > 0;
      }
      
      public function clear() : void
      {
         views.length = 0;
         freeStack.length = 0;
         activeCount = 0;
         lastIndex = 0;
      }
      
      public function rebuildFreeList() : void
      {
         freeStack.length = 0;
         activeCount = 0;
         var len:int = int(views.length);
         var i:int = 0;
         while(i < len)
         {
            if(!views[i].isActive)
            {
               freeStack.push(i);
            }
            else
            {
               ++activeCount;
            }
            i++;
         }
      }
   }
}

