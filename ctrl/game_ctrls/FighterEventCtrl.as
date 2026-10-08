package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.events.FighterEvent;
   import net.play5d.game.bvn.fighter.events.FighterEventDispatcher;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterEventCtrl extends BaseFighterEventCtrl
   {
      
      public function FighterEventCtrl()
      {
         super();
      }
      
      override public function initlize() : void
      {
         super.initlize();
         FighterEventDispatcher.addEventListener("DO_SPECIAL",addAssister);
         FighterEventDispatcher.addEventListener("HIT_TARGET",onHitTarget);
         FighterEventDispatcher.addEventListener("HURT_RESUME",onHurtResume);
         FighterEventDispatcher.addEventListener("DEAD",onDead);
         FighterEventDispatcher.addEventListener("IDLE",onIdle);
         FighterEventDispatcher.addEventListener("DIE",onDie);
      }
      
      private function addAssister(param1:FighterEvent) : void
      {
         var _loc3_:FighterMain = param1.fighter as FighterMain;
         if(_loc3_.actionState != 0 && _loc3_.actionState != 20)
         {
            return;
         }
         if(_loc3_.fzqi < 100)
         {
            return;
         }
         _loc3_.fzqi = 0;
         var _loc4_:GameRunFighterGroup = _loc3_.team.id == 1 ? GameCtrl.I.gameRunData.p1FighterGroup : GameCtrl.I.gameRunData.p2FighterGroup;
         var _loc2_:Assister = _loc4_.currentAssister;
         _loc2_.setOwner(_loc3_);
         _loc2_.direct = _loc3_.direct;
         _loc2_.x = _loc3_.x - 30 * _loc2_.direct;
         _loc2_.y = _loc3_.y;
         _loc2_.onRemove = removeAssister;
         GameCtrl.I.addGameSprite(param1.fighter.team.id,_loc2_);
         EffectCtrl.I.assisterEffect(_loc2_);
         _loc2_.goFight();
      }
      
      private function removeAssister(param1:Assister) : void
      {
         GameCtrl.I.removeGameSprite(param1);
      }
      
      private function onHitTarget(param1:FighterEvent) : void
      {
         addHits(param1.fighter as FighterMain,param1.params.target);
         if(GameMode.isAcrade() && param1.fighter.team.id == 1)
         {
            GameLogic.addScoreByHitTarget(param1.params.hitvo);
         }
      }
      
      private function onHurtResume(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function onDead(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function onIdle(param1:FighterEvent) : void
      {
         removeHits(param1.fighter.id);
      }
      
      private function addHits(param1:FighterMain, param2:IGameSprite) : void
      {
         var _loc4_:String = param2 && param2 is BaseGameSprite ? (param2 as BaseGameSprite).id : null;
         var _loc5_:int = 1;
         switch(param1.team.id - 1)
         {
            case 0:
               _loc5_ = 1;
               break;
            case 1:
               _loc5_ = 2;
         }
         var _loc3_:int = GameLogic.addHits(param1.id,_loc4_,_loc5_);
         if(_loc3_ > 1)
         {
            GameCtrl.I.gameState.gameUI.getUI().showHits(_loc3_,_loc5_);
         }
      }
      
      private function removeHits(param1:String) : void
      {
         var _loc2_:Object = GameLogic.getHitsObjByTargetId(param1);
         if(_loc2_)
         {
            GameCtrl.I.gameState.gameUI.getUI().hideHits(_loc2_.uiID);
         }
         GameLogic.clearHitsByTargetId(param1);
      }
      
      private function onDie(param1:FighterEvent) : void
      {
         GameCtrl.I.onFighterDie(param1.fighter as FighterMain);
      }
   }
}

