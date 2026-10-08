package net.play5d.game.bvn.mob.views
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class SetGameplayView extends Sprite
   {
      
      private var _btnGroup:SetBtnGroup;
      
      public function SetGameplayView()
      {
         super();
         this.graphics.beginFill(0,0.8);
         this.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,GameConfig.GAME_SIZE.y);
         this.graphics.endFill();
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 30;
         _btnGroup.endY = 550;
         _btnGroup.gap = 70;
         var cfg:ConfigVO = GameData.I.config;
         _btnGroup.setBtnData([{
            "label":"COM LEVEL",
            "cn":"",
            "options":[{
               "label":"EASY",
               "cn":"",
               "value":1
            },{
               "label":"NORMAL",
               "cn":"",
               "value":2
            },{
               "label":"HARD",
               "cn":"",
               "value":3
            },{
               "label":"SUPER HARD",
               "cn":"",
               "value":4
            },{
               "label":"NO HOPE",
               "cn":"",
               "value":5
            }],
            "optoinKey":"AI_level",
            "optionValue":cfg.AI_level
         },{
            "label":"HP",
            "cn":"",
            "options":[{
               "label":"HALF",
               "cn":"",
               "value":1
            },{
               "label":"NORMAL",
               "cn":"",
               "value":2
            },{
               "label":"DOUBLE",
               "cn":"",
               "value":3
            }],
            "optoinKey":"fighterHP",
            "optionValue":cfg.fighterHP
         },{
            "label":"TIME",
            "cn":"",
            "options":[{
               "label":"30s",
               "cn":"",
               "value":30
            },{
               "label":"60s",
               "cn":"",
               "value":60
            },{
               "label":"90s",
               "cn":"",
               "value":90
            },{
               "label":"120s",
               "cn":"",
               "value":120
            },{
               "label":"180s",
               "cn":"",
               "value":180
            },{
               "label":"∞",
               "cn":"",
               "value":-1
            }],
            "optoinKey":"fightTime",
            "optionValue":cfg.fightTime
         },{
            "label":"ROUNDS",
            "cn":"",
            "options":[{
               "label":"1 ROUND",
               "cn":"",
               "value":1
            },{
               "label":"3 ROUNDS",
               "cn":"",
               "value":2
            },{
               "label":"5 ROUNDS",
               "cn":"",
               "value":3
            }],
            "optoinKey":"maxWinRound",
            "optionValue":cfg.maxWinRound
         },{
            "label":"SCREEN MODE",
            "cn":"",
            "options":[{
               "label":"FULLSCREEN",
               "cn":"",
               "value":0
            },{
               "label":"PS2",
               "cn":"",
               "value":1
            }],
            "optoinKey":"screenMode",
            "optionValue":cfg.extendConfig.screenMode
         },{
            "label":"APPLY",
            "cn":""
         }]);
         _btnGroup.initScroll(RootSprite.FULL_SCREEN_SIZE.x,RootSprite.FULL_SCREEN_SIZE.y);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptionChange);
         this.addChild(_btnGroup);
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "APPLY":
               GameData.I.saveData();
               GameData.I.config.applyConfig();
               closeSelf();
         }
      }
      
      private function onOptionChange(param1:SetBtnEvent) : void
      {
         var config:ConfigVO = GameData.I.config;
         config.setValueByKey(param1.optionKey,param1.optionValue);
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

