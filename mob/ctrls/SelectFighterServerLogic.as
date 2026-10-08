package net.play5d.game.bvn.mob.ctrls
{
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.state.LoadingState;
   import net.play5d.game.bvn.state.SelectFighterStage;
   
   public class SelectFighterServerLogic
   {
      
      private var _timeout:int;
      
      public function SelectFighterServerLogic()
      {
         super();
      }
      
      public function init() : void
      {
         SelectFighterStage.AUTO_FINISH = false;
         LoadingState.AUTO_START_GAME = false;
         GameEvent.addEventListener("SELECT_FIGHTER_STEP",onSelectStep);
         GameEvent.addEventListener("SELECT_FIGHTER_FINISH",onSelectFinish);
         GameEvent.addEventListener("SELECT_FIGHTER_INDEX",onSelectFighterIndex);
      }
      
      public function dispose() : void
      {
         GameEvent.removeEventListener("SELECT_FIGHTER_STEP",onSelectStep);
         GameEvent.removeEventListener("SELECT_FIGHTER_FINISH",onSelectFinish);
         GameEvent.removeEventListener("SELECT_FIGHTER_INDEX",onSelectFighterIndex);
      }
      
      public function receiveSelect(param1:Object) : Boolean
      {
         var _loc4_:int;
         var _loc2_:SelectFighterStage = null;
         var _loc5_:LoadingState = null;
         var _loc3_:Array = param1 as Array;
         if(!_loc3_ || _loc3_[0] != "SELECT")
         {
            return false;
         }
         switch((_loc4_ = int(param1[1])) - 1)
         {
            case 0:
               try
               {
                  _loc2_ = MainGame.stageCtrl.currentStage as SelectFighterStage;
                  _loc2_.setSelect(2,_loc3_[2]);
                  checkSelectFinish();
               }
               catch(e:Error)
               {
               }
               break;
            case 3:
               try
               {
                  _loc5_ = MainGame.stageCtrl.currentStage as LoadingState;
                  _loc5_.setOrder(2,param1[2]);
                  checkSelectIndexFinish();
               }
               catch(e:Error)
               {
               }
         }
         return true;
      }
      
      private function onSelectStep(param1:GameEvent) : void
      {
         var _loc2_:Array = ["SELECT",1,param1.param];
         LANServerCtrl.I.sendTCP(_loc2_);
         checkSelectFinish();
      }
      
      private function checkSelectFinish() : void
      {
         var stg:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
         if(stg.p1SelectFinish && stg.p2SelectFinish)
         {
            clearTimeout(_timeout);
            _timeout = setTimeout(function():void
            {
               LANServerCtrl.I.sendTCP(["SELECT",2]);
               stg.nextStep();
            },1000);
         }
      }
      
      private function onSelectFinish(param1:GameEvent) : void
      {
         var _loc3_:Array = ["SELECT",3,GameData.I.p1Select.fighter1,GameData.I.p1Select.fighter2,GameData.I.p1Select.fighter3,GameData.I.p1Select.fuzhu,GameData.I.p2Select.fighter1,GameData.I.p2Select.fighter2,GameData.I.p2Select.fighter3,GameData.I.p2Select.fuzhu,GameData.I.selectMap];
         LANServerCtrl.I.sendTCP(_loc3_);
         var _loc2_:SelectFighterStage = MainGame.stageCtrl.currentStage as SelectFighterStage;
         _loc2_.goLoadGame();
      }
      
      private function onSelectFighterIndex(param1:GameEvent) : void
      {
         var _loc2_:Array = ["SELECT",4,param1.param];
         LANServerCtrl.I.sendTCP(_loc2_);
         checkSelectIndexFinish();
      }
      
      private function checkSelectIndexFinish() : void
      {
         var stg:LoadingState;
         try
         {
            stg = MainGame.stageCtrl.currentStage as LoadingState;
            if(stg.selectFinish())
            {
               setTimeout(function():void
               {
                  var _loc1_:Array = stg.getSort();
                  LANServerCtrl.I.sendTCP(["SELECT",5,_loc1_[0],_loc1_[1]]);
                  stg.gotoGame(_loc1_[0],_loc1_[1]);
               },1000);
            }
         }
         catch(e:Error)
         {
         }
      }
   }
}

