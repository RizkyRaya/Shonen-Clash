package net.play5d.game.bvn.utils
{
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.data.EffectModel;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.views.effects.BuffEffectView;
   import net.play5d.game.bvn.views.effects.EffectView;
   import net.play5d.game.bvn.views.effects.ShineEffectView;
   import net.play5d.game.bvn.views.effects.SpecialEffectView;
   import net.play5d.game.bvn.views.effects.SteelHitEffect;
   
   public class EffectManager
   {
      
      private static const MAX_POOL_PER_EFFECT:int = 64;
      
      private static const PREALLOCATE_POOL:int = 2;
      
      private static const MAINTENANCE_INTERVAL:int = 300;
      
      private static const MAX_IDLE_FRAME:int = 1800;
      
      private var _maintenanceCounter:int = 0;
      
      private var _cleanFrame:int = 0;
      
      private var _viewCache:Dictionary = new Dictionary();
      
      private var _hitCache:Dictionary = new Dictionary(true);
      
      private var _defCache:Dictionary = new Dictionary(true);
      
      private var _peakPoolSize:int = 0;
      
      private var _peakActiveCount:int = 0;
      
      private var _highWatermark:int = 0;
      
      private var _lowWatermark:int = 0;
      
      private var _reuseCount:int = 0;
      
      private var _createCount:int = 0;
      
      private var _shineCache:Vector.<ShineEffectView> = new Vector.<ShineEffectView>();
      
      public function EffectManager()
      {
         super();
      }
      
      public function destory() : void
      {
         for each(var _loc1_ in _viewCache)
         {
            for each(var _loc2_ in _loc1_)
            {
               _loc2_.destory();
            }
         }
         var len:int = int(_shineCache.length);
         var i:int = 0;
         while(i < len)
         {
            _shineCache[i].destory();
            i++;
         }
         _viewCache = null;
         _hitCache = null;
         _defCache = null;
         _shineCache.length = 0;
         _shineCache = null;
      }
      
      public function getHitEffectVOByHitVO(param1:HitVO, param2:IGameSprite = null) : EffectVO
      {
         var _loc4_:FighterMain = null;
         var _loc6_:EffectCacheVO = _hitCache[param1];
         var _loc3_:Boolean = false;
         if(param2 && param2 is FighterMain)
         {
            _loc4_ = param2 as FighterMain;
            _loc3_ = _loc4_.isMosouEnemy();
         }
         if(_loc6_)
         {
            if(_loc3_ && _loc6_.mosouEnemy)
            {
               return _loc6_.mosouEnemy;
            }
            if(!_loc3_ && _loc6_.normal)
            {
               return _loc6_.normal;
            }
         }
         var _loc5_:EffectVO = _loc3_ ? EffectModel.I.getMosouEnemyHitEffect(param1.hitType) : EffectModel.I.getHitEffect(param1.hitType);
         if(!_loc5_)
         {
            _hitCache[param1] = null;
            return null;
         }
         _loc5_ = _loc5_.clone();
         if(_loc5_.shake)
         {
            if(_loc5_.shake.pow != undefined && _loc5_.shake.pow != 0)
            {
               _loc5_.shake.y = _loc5_.shake.pow;
            }
            if(_loc5_.shake.x == 0 && _loc5_.shake.y == 0)
            {
               _loc5_.shake.x = 3;
            }
         }
         if(!_loc6_)
         {
            _loc6_ = new EffectCacheVO();
         }
         if(_loc3_)
         {
            _loc6_.mosouEnemy = _loc5_;
         }
         else
         {
            _loc6_.normal = _loc5_;
         }
         _hitCache[param1] = _loc6_;
         return _loc5_;
      }
      
      private function getPool(vo:EffectVO) : EffectPool
      {
         var pool:EffectPool = _viewCache[vo];
         if(pool == null)
         {
            pool = new EffectPool();
            _viewCache[vo] = pool;
            preAllocate(pool,vo);
         }
         return pool;
      }
      
      public function getDefenseEffectVOByHitVO(param1:HitVO, param2:int, param3:IGameSprite = null) : EffectVO
      {
         var _loc5_:FighterMain = null;
         var _loc7_:EffectCacheVO = _defCache[param1];
         var _loc4_:Boolean = false;
         if(param3 && param3 is FighterMain)
         {
            _loc5_ = param3 as FighterMain;
            _loc4_ = _loc5_.isMosouEnemy();
         }
         if(_loc7_)
         {
            if(_loc4_ && _loc7_.mosouEnemy)
            {
               return _loc7_.mosouEnemy;
            }
            if(!_loc4_ && _loc7_.normal)
            {
               return _loc7_.normal;
            }
         }
         var _loc6_:EffectVO = _loc4_ ? EffectModel.I.getMosouEnemyDefenseEffect(param1.hitType,param2) : EffectModel.I.getDefenseEffect(param1.hitType,param2);
         if(!_loc6_)
         {
            _defCache[param1] = null;
            return null;
         }
         _loc6_ = _loc6_.clone();
         if(!_loc7_)
         {
            _loc7_ = new EffectCacheVO();
         }
         if(_loc4_)
         {
            _loc7_.mosouEnemy = _loc6_;
         }
         else
         {
            _loc7_.normal = _loc6_;
         }
         _defCache[param1] = _loc7_;
         return _loc6_;
      }
      
      private function preAllocate(pool:EffectPool, vo:EffectVO) : void
      {
         var i:int = 0;
         while(i < PREALLOCATE_POOL)
         {
            var effect:EffectView = createEffectView(vo);
            effect.isActive = false;
            effect.poolIndex = pool.views.length;
            effect.ownerPool = pool;
            pool.views.push(effect);
            pool.pushFree(effect.poolIndex);
            ++_createCount;
            i++;
         }
         updatePeakPool();
      }
      
      public function getEffectView(vo:EffectVO) : EffectView
      {
         var pool:EffectPool = getPool(vo);
         if(pool.hasFree())
         {
            var index:int = pool.popFree();
            var effect:EffectView = pool.views[index];
            ++pool.activeCount;
            ++_reuseCount;
            return effect;
         }
         if(pool.totalCount >= MAX_POOL_PER_EFFECT)
         {
            return null;
         }
         var newEffect:EffectView = createEffectView(vo);
         newEffect.poolIndex = pool.views.length;
         newEffect.ownerPool = pool;
         pool.views.push(newEffect);
         ++pool.activeCount;
         ++_createCount;
         updatePeakPool();
         return newEffect;
      }
      
      public function updatePool() : void
      {
         ++_cleanFrame;
         if(_cleanFrame < 120)
         {
            return;
         }
         _cleanFrame = 0;
         cleanPool();
      }
      
      public function releaseEffect(effect:EffectView) : void
      {
         var pool:EffectPool = effect.ownerPool;
         if(pool == null)
         {
            return;
         }
         if(pool.activeCount > 0)
         {
            --pool.activeCount;
         }
         pool.pushFree(effect.poolIndex);
      }
      
      public function updateMaintenance() : void
      {
         ++_maintenanceCounter;
         if(_maintenanceCounter < MAINTENANCE_INTERVAL)
         {
            return;
         }
         _maintenanceCounter = 0;
         maintenance();
      }
      
      private function cleanPool() : void
      {
         for each(var pool in _viewCache)
         {
            var views:Vector.<EffectView> = pool.views;
            var i:int = views.length - 1;
            while(i >= 0)
            {
               var effect:EffectView = views[i];
               if(!effect.isActive)
               {
                  effect.idleFrame += 120;
                  if(effect.idleFrame > MAX_IDLE_FRAME)
                  {
                     if(views.length > PREALLOCATE_POOL)
                     {
                        effect.destory();
                        views.splice(i,1);
                        var j:int = i;
                        while(j < views.length)
                        {
                           views[j].poolIndex = j;
                           j++;
                        }
                        pool.rebuildFreeList();
                     }
                  }
               }
               i--;
            }
         }
      }
      
      private function createEffectView(vo:EffectVO) : EffectView
      {
         if(vo.isSpecial)
         {
            return new SpecialEffectView(vo);
         }
         if(vo.isBuff)
         {
            return new BuffEffectView(vo);
         }
         if(vo.isSteelHit)
         {
            return new SteelHitEffect(vo);
         }
         return new EffectView(vo);
      }
      
      public function getActiveCount(vo:EffectVO) : int
      {
         var pool:EffectPool = _viewCache[vo];
         return pool == null ? 0 : pool.activeCount;
      }
      
      public function getIdleCount(vo:EffectVO) : int
      {
         var pool:EffectPool = _viewCache[vo];
         return pool == null ? 0 : pool.idleCount;
      }
      
      public function getTotalPoolSize() : int
      {
         var total:int = 0;
         for each(var pool in _viewCache)
         {
            total += pool.totalCount;
         }
         return total;
      }
      
      public function getTotalActiveCount() : int
      {
         var total:int = 0;
         for each(var pool in _viewCache)
         {
            total += pool.activeCount;
         }
         return total;
      }
      
      public function get reuseCount() : int
      {
         return _reuseCount;
      }
      
      public function get createCount() : int
      {
         return _createCount;
      }
      
      public function get reuseRate() : Number
      {
         var total:int = _reuseCount + _createCount;
         return total == 0 ? 0 : _reuseCount / total;
      }
      
      public function getTotalIdleCount() : int
      {
         var total:int = 0;
         for each(var pool in _viewCache)
         {
            total += pool.idleCount;
         }
         return total;
      }
      
      private function updatePeakPool() : void
      {
         var totalPool:int = getTotalPoolSize();
         if(totalPool > _peakPoolSize)
         {
            _peakPoolSize = totalPool;
         }
         var totalActive:int = getTotalActiveCount();
         if(totalActive > _peakActiveCount)
         {
            _peakActiveCount = totalActive;
         }
         updateWatermark();
      }
      
      private function updateWatermark() : void
      {
         _highWatermark = _peakPoolSize;
         if(_peakActiveCount > _lowWatermark)
         {
            _lowWatermark = _peakActiveCount;
         }
      }
      
      public function getShine() : ShineEffectView
      {
         var _loc3_:int = int(_shineCache.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc3_)
         {
            if(!_shineCache[_loc2_].isActive)
            {
               return _shineCache[_loc2_];
            }
            _loc2_++;
         }
         var _loc1_:ShineEffectView = new ShineEffectView();
         _shineCache.push(_loc1_);
         return _loc1_;
      }
      
      public function get lowWatermark() : int
      {
         return _lowWatermark;
      }
      
      public function get highWatermark() : int
      {
         return _highWatermark;
      }
      
      public function get peakActiveCount() : int
      {
         return _peakActiveCount;
      }
      
      public function get peakPoolSize() : int
      {
         return _peakPoolSize;
      }
      
      public function maintenance() : void
      {
         for each(var pool in _viewCache)
         {
            PoolMaintenance.shrinkEffectPool(pool);
         }
         PoolMaintenance.shrinkShinePool(_shineCache);
      }
   }
}

