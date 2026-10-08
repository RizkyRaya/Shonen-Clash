package net.play5d.game.bvn.mob.views
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.ctrls.ControllerHudManager;
   import net.play5d.game.bvn.mob.data.ScreenPadConfigVO;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class SetScreenBtnView extends Sprite
   {
      
      private var _btnGroup:SetBtnGroup;
      
      public function SetScreenBtnView()
      {
         super();
         this.graphics.beginFill(0,0.8);
         this.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         this.graphics.endFill();
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 30;
         _btnGroup.endY = 550;
         _btnGroup.gap = 70;
         var _loc1_:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
         var currentAlpha:Number = _loc1_.hasOwnProperty("padAlpha") ? Number(_loc1_["padAlpha"]) : 1;
         _btnGroup.setBtnData([{
            "label":"SCREENPAD TYPE",
            "cn":"Preinstall",
            "options":[{
               "label":"CLASSIC",
               "cn":"Tipe 1",
               "value":0
            },{
               "label":"JOYPAD",
               "cn":"Tipe 2",
               "value":1
            }],
            "optoinKey":"joyMode",
            "optionValue":_loc1_.joyMode
         },{
            "label":"OPACITY",
            "cn":"Transparansi",
            "options":[{
               "label":"100%",
               "cn":"100%",
               "value":1
            },{
               "label":"75%",
               "cn":"75%",
               "value":0.75
            },{
               "label":"50%",
               "cn":"50%",
               "value":0.5
            },{
               "label":"25%",
               "cn":"25%",
               "value":0.25
            },{
               "label":"0%",
               "cn":"0%",
               "value":0
            }],
            "optoinKey":"padAlpha",
            "optionValue":currentAlpha
         },{
            "label":"SP SKILL",
            "cn":"SP Skill",
            "options":[{
               "label":"AUTO",
               "cn":"Otomatis",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"Selalu",
               "value":false
            }],
            "optoinKey":"superSkillAutoHide",
            "optionValue":_loc1_.superSkillAutoHide
         },{
            "label":"WANKAI",
            "cn":"Transform",
            "options":[{
               "label":"AUTO",
               "cn":"Otomatis",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"Selalu",
               "value":false
            }],
            "optoinKey":"wankaiAutoHide",
            "optionValue":_loc1_.wankaiAutoHide
         },{
            "label":"SPECIAL",
            "cn":"Ultimate",
            "options":[{
               "label":"AUTO",
               "cn":"Otomatis",
               "value":true
            },{
               "label":"ALWAYS",
               "cn":"Selalu",
               "value":false
            }],
            "optoinKey":"specialAutoHide",
            "optionValue":_loc1_.specialAutoHide
         },{
            "label":"CUSTOM",
            "cn":"Kustom"
         },{
            "label":"APPLY",
            "cn":"Selesai"
         }]);
         _btnGroup.initScroll(RootSprite.FULL_SCREEN_SIZE.x,RootSprite.FULL_SCREEN_SIZE.y);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptionChange);
         this.addChild(_btnGroup);
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         var _loc2_:CustomScreenBtnView = null;
         switch(param1.selectedLabel)
         {
            case "CUSTOM":
               _loc2_ = new CustomScreenBtnView();
               RootSprite.I.addChild(_loc2_.getDisplay());
               break;
            case "APPLY":
               closeSelf();
         }
      }
      
      private function onOptionChange(param1:SetBtnEvent) : void
      {
         var config:ScreenPadConfigVO;
         var e:SetBtnEvent = param1;
         if(e.optionKey == "joyMode")
         {
            if(GameInterfaceManager.config.screenPadConfig.joySet)
            {
               GameUI.confrim("Custom already set, are you sure ?","Kustomisai seleai,apakah kamu ingin simpan？",function():void
               {
                  GameInterfaceManager.config.screenPadConfig.joySet = null;
                  var _loc1_:ScreenPadConfigVO = GameInterfaceManager.config.screenPadConfig;
                  _loc1_.setValueByKey(e.optionKey,e.optionValue);
               });
               return;
            }
         }
         config = GameInterfaceManager.config.screenPadConfig;
         config.setValueByKey(e.optionKey,e.optionValue);
         if(e.optionKey == "padAlpha")
         {
            ControllerHudManager.forceRefresh();
         }
      }
      
      private function closeSelf() : void
      {
         if(_btnGroup)
         {
            try
            {
               _btnGroup.destory();
               this.removeChild(_btnGroup);
               _btnGroup = null;
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         try
         {
            this.parent.removeChild(this);
         }
         catch(e:Error)
         {
            trace(e);
         }
      }
   }
}

