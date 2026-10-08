package net.play5d.game.bvn.ctrl.mosou_ctrls
{
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.mosou.enemy.EnemyHpFollowUI;
   
   public class MosouEnemyBarCtrl
   {
      
      private var _barMap:Dictionary = new Dictionary();
      
      private var _gameLayer:Sprite;
      
      public function MosouEnemyBarCtrl()
      {
         super();
      }
      
      private function initalize() : void
      {
      }
      
      public function destory() : void
      {
         _barMap = null;
      }
      
      public function updateEnemyBar(param1:FighterMain) : void
      {
         if(param1.mosouEnemyData.isBoss)
         {
            return;
         }
         if(_barMap[param1])
         {
            (_barMap[param1] as EnemyHpFollowUI).active();
            return;
         }
         if(!_gameLayer)
         {
            _gameLayer = GameCtrl.I.gameState.gameLayer;
         }
         var _loc2_:EnemyHpFollowUI = new EnemyHpFollowUI(param1);
         _barMap[param1] = _loc2_;
         _gameLayer.addChild(_loc2_.getUI());
      }
      
      public function render() : void
      {
         var _loc1_:EnemyHpFollowUI = null;
         if(!_barMap)
         {
            return;
         }
         for(var _loc2_ in _barMap)
         {
            _loc1_ = _barMap[_loc2_];
            if(!_loc1_.render())
            {
               try
               {
                  _gameLayer.removeChild(_loc1_.getUI());
               }
               catch(e:Error)
               {
                  trace("remove bar error");
               }
               _loc1_.destory();
               delete _barMap[_loc2_];
            }
         }
      }
      
      public function renderAnimate() : void
      {
      }
   }
}

