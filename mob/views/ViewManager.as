package net.play5d.game.bvn.mob.views
{
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.game.bvn.state.SettingState;
   import net.play5d.game.bvn.utils.URL;
   import net.play5d.game.bvn.utils.UpdateURL;
   import net.play5d.kyo.stage.Istage;
   
   public class ViewManager
   {
      
      private static var _i:ViewManager;
      
      public function ViewManager()
      {
         super();
      }
      
      public static function get I() : ViewManager
      {
         if(!_i)
         {
            _i = new ViewManager();
         }
         return _i;
      }
      
      public function goP1JoyStickSet() : void
      {
         goJoyStickSet(1,GameInterfaceManager.config.joy1Config);
      }
      
      public function goP2JoyStickSet() : void
      {
         goJoyStickSet(2,GameInterfaceManager.config.joy2Config);
      }
      
      public function goGamePadSet() : void
      {
         goGamePadSetInner(1,GameInterfaceManager.config.joy1Config);
      }
      
      public function goP2GamePadSet() : void
      {
         goGamePadSetInner(2,GameInterfaceManager.config.joy2Config);
      }
      
      private function goJoyStickSet(param1:int, param2:JoyStickConfigVO) : void
      {
         var _loc3_:Istage = MainGame.stageCtrl.currentStage;
         if(!_loc3_ is SettingState)
         {
            return;
         }
         var _loc4_:SettingState = _loc3_ as SettingState;
         var _loc5_:JoyStickSetUI = new JoyStickSetUI();
         _loc5_.setConfig(param1,param2);
         _loc4_.goInnerSetPage(_loc5_);
      }
      
      public function checkUpdate() : void
      {
         URL.go(UpdateURL.getURL(),false);
      }
      
      private function goGamePadSetInner(param1:int, param2:JoyStickConfigVO) : void
      {
         var _loc3_:Istage = MainGame.stageCtrl.currentStage;
         if(!_loc3_ is SettingState)
         {
            return;
         }
         var _loc4_:SettingState = _loc3_ as SettingState;
         var _loc5_:GamePadSetUI = new GamePadSetUI();
         _loc5_.setConfig(param1,param2);
         _loc4_.goInnerSetPage(_loc5_);
      }
      
      public function setScreenBtns() : void
      {
         var _loc1_:SetScreenBtnView = new SetScreenBtnView();
         RootSprite.I.addChildToGameSprite(_loc1_);
      }
      
      public function setGraphicsBtns() : void
      {
         var _loc1_:SetGraphicsView = new SetGraphicsView();
         RootSprite.I.addChildToGameSprite(_loc1_);
      }
      
      public function setGameplayBtns() : void
      {
         var _loc1_:SetGameplayView = new SetGameplayView();
         RootSprite.I.addChildToGameSprite(_loc1_);
      }
      
      public function setAudioBtns() : void
      {
         var _loc1_:SetAudioView = new SetAudioView();
         RootSprite.I.addChildToGameSprite(_loc1_);
      }
   }
}

