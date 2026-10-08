package net.play5d.game.bvn.data.mosou
{
   public class MosouWaveVO
   {
      
      public var id:int;
      
      public var enemies:Vector.<MosouEnemyVO>;
      
      public var repeats:Vector.<MosouWaveRepeatVO>;
      
      public var hold:int;
      
      public function MosouWaveVO()
      {
         super();
      }
      
      public static function createByJSON(param1:Object) : MosouWaveVO
      {
         var _loc5_:int = 0;
         var _loc2_:MosouWaveRepeatVO = null;
         var _loc3_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:MosouWaveVO = new MosouWaveVO();
         _loc7_.hold = int(param1.hold);
         var _loc4_:Array = param1.enemies;
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc7_.addEnemy(MosouEnemyVO.createByJSON(_loc4_[_loc5_]));
            _loc5_++;
         }
         if(param1.repeat)
         {
            _loc7_.repeats = new Vector.<MosouWaveRepeatVO>();
            _loc2_ = new MosouWaveRepeatVO();
            _loc2_.type = param1.repeat.type;
            _loc2_.hold = param1.repeat.hold;
            _loc3_ = param1.repeat.enemies;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc2_.addEnemy(MosouEnemyVO.createByJSON(_loc3_[_loc6_]));
               _loc6_++;
            }
            _loc7_.repeats.push(_loc2_);
         }
         return _loc7_;
      }
      
      public function getAllEnemies() : Vector.<MosouEnemyVO>
      {
         if(!repeats)
         {
            return enemies;
         }
         var _loc1_:Vector.<MosouEnemyVO> = enemies.concat();
         for each(var _loc2_ in repeats)
         {
            if(_loc2_.enemies)
            {
               _loc1_ = _loc1_.concat(_loc2_.enemies);
            }
         }
         return _loc1_;
      }
      
      public function getAllEnemieIds() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Vector.<MosouEnemyVO> = getAllEnemies();
         for each(var _loc3_ in _loc2_)
         {
            if(_loc1_.indexOf(_loc3_.fighterID) == -1)
            {
               _loc1_.push(_loc3_.fighterID);
            }
         }
         return _loc1_;
      }
      
      public function getBosses() : Vector.<MosouEnemyVO>
      {
         var _loc1_:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
         var _loc2_:Vector.<MosouEnemyVO> = getAllEnemies();
         for each(var _loc3_ in _loc2_)
         {
            if(_loc3_.isBoss)
            {
               if(_loc1_.indexOf(_loc3_) == -1)
               {
                  _loc1_.push(_loc3_);
               }
            }
         }
         return _loc1_;
      }
      
      public function addEnemy(param1:Vector.<MosouEnemyVO>) : void
      {
         if(!enemies)
         {
            enemies = new Vector.<MosouEnemyVO>();
         }
         for each(var _loc2_ in param1)
         {
            _loc2_.wave = this;
            enemies.push(_loc2_);
         }
      }
      
      public function addRepeat(param1:MosouWaveRepeatVO) : void
      {
         if(!repeats)
         {
            repeats = new Vector.<MosouWaveRepeatVO>();
         }
         param1.wave = this;
         repeats.push(param1);
      }
      
      public function bossCount() : int
      {
         var _loc1_:int = 0;
         for each(var _loc2_ in enemies)
         {
            if(_loc2_.isBoss)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
   }
}

