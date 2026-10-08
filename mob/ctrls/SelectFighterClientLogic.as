package net.play5d.game.bvn.mob.ctrls
{
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.state.LoadingState;
   import net.play5d.game.bvn.state.SelectFighterStage;
   
   public class SelectFighterClientLogic
   {
      
      public function SelectFighterClientLogic()
      {
         super();
      }
      
      public function init() : void
      {
         SelectFighterStage.AUTO_FINISH = false;
         LoadingState.AUTO_START_GAME = false;
         GameEvent.addEventListener("SELECT_FIGHTER_STEP",onSelectStep);
         GameEvent.addEventListener("SELECT_FIGHTER_INDEX",onSelectIndex);
      }
      
      public function dispose() : void
      {
         GameEvent.removeEventListener("SELECT_FIGHTER_STEP",onSelectStep);
         GameEvent.removeEventListener("SELECT_FIGHTER_INDEX",onSelectIndex);
      }
      
      public function receiveSelect(param1:Object) : Boolean
      {
         var _loc4_:int;
         var _loc2_:SelectFighterStage = null;
         var _loc3_:Array = param1 as Array;
         if(!_loc3_ || _loc3_[0] != "SELECT")
         {
            return false;
         }
         switch((_loc4_ = int(_loc3_[1])) - 1)
         {
            case 0:
               try
               {
                  _loc2_ = MainGame.stageCtrl.currentStage as SelectFighterStage;
                  _loc2_.setSelect(1,_loc3_[2]);
               }
               catch(e:Error)
               {
               }
               break;
            case 1:
               try
               {
                  _loc2_ = MainGame.stageCtrl.currentStage as SelectFighterStage;
                  _loc2_.nextStep();
               }
               catch(e:Error)
               {
               }
               break;
            case 2:
               onSelectFighter(_loc3_);
               break;
            case 3:
               receiveSelectIndex(_loc3_);
               break;
            case 4:
               onSelectFighterIndexFinish(_loc3_);
         }
         return true;
      }
      
      private function onSelectFighter(param1:Array) : void
      {
         if(MainGame.stageCtrl.currentStage is SelectFighterStage)
         {
            GameData.I.p1Select.fighter1 = param1[2];
            GameData.I.p1Select.fighter2 = param1[3];
            GameData.I.p1Select.fighter3 = param1[4];
            GameData.I.p1Select.fuzhu = param1[5];
            GameData.I.p2Select.fighter1 = param1[6];
            GameData.I.p2Select.fighter2 = param1[7];
            GameData.I.p2Select.fighter3 = param1[8];
            GameData.I.p2Select.fuzhu = param1[9];
            GameData.I.selectMap = param1[10];
            (MainGame.stageCtrl.currentStage as SelectFighterStage).goLoadGame();
         }
      }
      
      private function onSelectStep(param1:GameEvent) : void
      {
         var _loc2_:Array = ["SELECT",1,param1.param];
         LANClientCtrl.I.sendTCP(_loc2_);
      }
      
      private function onSelectIndex(param1:GameEvent) : void
      {
         var _loc2_:Array = ["SELECT",4,param1.param];
         LANClientCtrl.I.sendTCP(_loc2_);
      }
      
      private function receiveSelectIndex(param1:Array) : void
      {
         var _loc2_:LoadingState = MainGame.stageCtrl.currentStage as LoadingState;
         if(_loc2_)
         {
            _loc2_.setOrder(1,param1[2]);
         }
      }
      
      private function onSelectFighterIndexFinish(param1:Array) : void
      {
         if(MainGame.stageCtrl.currentStage is LoadingState)
         {
            (MainGame.stageCtrl.currentStage as LoadingState).gotoGame(param1[2],param1[3]);
         }
      }
   }
}

