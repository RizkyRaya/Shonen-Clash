package net.play5d.game.bvn.data.mosou
{
   public class MosouWaveRepeatVO
   {
      
      public var type:int;
      
      public var hold:int;
      
      public var wave:MosouWaveVO;
      
      public var enemies:Vector.<MosouEnemyVO>;
      
      public var _holdFrame:int;
      
      public function MosouWaveRepeatVO()
      {
         super();
      }
      
      public function addEnemy(param1:Vector.<MosouEnemyVO>) : void
      {
         if(!enemies)
         {
            enemies = new Vector.<MosouEnemyVO>();
         }
         for each(var _loc2_ in param1)
         {
            _loc2_.wave = wave;
            _loc2_.repeat = this;
            enemies.push(_loc2_);
         }
      }
   }
}

