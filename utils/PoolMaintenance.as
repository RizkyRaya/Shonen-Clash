package net.play5d.game.bvn.utils
{
   import net.play5d.game.bvn.views.effects.EffectView;
   import net.play5d.game.bvn.views.effects.ShineEffectView;
   
   public class PoolMaintenance
   {
      
      public static const MIN_POOL:int = 8;
      
      public static const SHRINK_PER_UPDATE:int = 4;
      
      public function PoolMaintenance()
      {
         super();
      }
      
      public static function shrinkShinePool(pool:Vector.<ShineEffectView>) : void
      {
         if(pool == null)
         {
            return;
         }
         if(pool.length <= MIN_POOL)
         {
            return;
         }
         var removed:int = 0;
         var i:int = pool.length - 1;
         while(i >= 0)
         {
            if(pool.length <= MIN_POOL)
            {
               break;
            }
            if(removed >= SHRINK_PER_UPDATE)
            {
               break;
            }
            if(!pool[i].isActive)
            {
               pool[i].destory();
               pool.splice(i,1);
               removed++;
            }
            i--;
         }
      }
      
      public static function shrinkEffectPool(pool:EffectPool) : void
      {
         if(pool == null)
         {
            return;
         }
         var views:Vector.<EffectView> = pool.views;
         if(pool.activeCount > 0)
         {
            return;
         }
         while(views.length > 2)
         {
            var effect:EffectView = views.pop();
            effect.destory();
         }
         pool.rebuildFreeList();
      }
   }
}

