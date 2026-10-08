package net.play5d.game.bvn.mob.views
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class SetGraphicsView extends Sprite
   {
      
      private var _btnGroup:SetBtnGroup;
      
      public function SetGraphicsView()
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
            "label":"QUALITY",
            "cn":"",
            "options":[{
               "label":"STANDARD",
               "cn":"",
               "value":"low"
            },{
               "label":"HIGH",
               "cn":"",
               "value":"medium"
            }],
            "optoinKey":"quality",
            "optionValue":cfg.quality
         },{
            "label":"FPS",
            "cn":"",
            "options":[{
               "label":"24 FPS",
               "cn":"",
               "value":24
            },{
               "label":"30 FPS",
               "cn":"",
               "value":30
            },{
               "label":"45 FPS",
               "cn":"",
               "value":45
            },{
               "label":"60 FPS",
               "cn":"",
               "value":60
            }],
            "optoinKey":"gameFps",
            "optionValue":cfg.gameFps
         },{
            "label":"SHADOW",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"shadow",
            "optionValue":cfg.shadow
         },{
            "label":"MOTION BLUR",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"blur",
            "optionValue":cfg.blur
         },{
            "label":"SHAKE",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"shake",
            "optionValue":cfg.shake
         },{
            "label":"DYNAMIC CAMERA",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"dynamicCamera",
            "optionValue":cfg.dynamicCamera
         },{
            "label":"PERFORMANCE MODE",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"performanceMode",
            "optionValue":cfg.performanceMode
         },{
            "label":"SHINE",
            "cn":"",
            "options":[{
               "label":"OFF",
               "cn":"",
               "value":"off"
            },{
               "label":"LOW",
               "cn":"",
               "value":"low"
            },{
               "label":"MEDIUM",
               "cn":"",
               "value":"standard"
            },{
               "label":"HIGH",
               "cn":"",
               "value":"high"
            }],
            "optoinKey":"shine",
            "optionValue":cfg.shine
         },{
            "label":"FXAA",
            "cn":"",
            "options":[{
               "label":"ON",
               "cn":"",
               "value":true
            },{
               "label":"OFF",
               "cn":"",
               "value":false
            }],
            "optoinKey":"smoothing",
            "optionValue":cfg.smoothing
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
         var e:SetBtnEvent = param1;
         var config:ConfigVO = GameData.I.config;
         config.setValueByKey(e.optionKey,e.optionValue);
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

