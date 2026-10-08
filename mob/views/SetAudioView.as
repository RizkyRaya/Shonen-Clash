package net.play5d.game.bvn.mob.views
{
   import flash.display.Sprite;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class SetAudioView extends Sprite
   {
      
      private var _btnGroup:SetBtnGroup;
      
      public function SetAudioView()
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
            "label":"SOUND",
            "cn":"",
            "options":[{
               "label":"0%",
               "cn":"",
               "value":0
            },{
               "label":"10%",
               "cn":"",
               "value":0.1
            },{
               "label":"30%",
               "cn":"",
               "value":0.3
            },{
               "label":"50%",
               "cn":"",
               "value":0.5
            },{
               "label":"70%",
               "cn":"",
               "value":0.7
            },{
               "label":"100%",
               "cn":"",
               "value":1
            }],
            "optoinKey":"soundVolume",
            "optionValue":cfg.soundVolume
         },{
            "label":"BGM",
            "cn":"",
            "options":[{
               "label":"0%",
               "cn":"",
               "value":0
            },{
               "label":"10%",
               "cn":"",
               "value":0.1
            },{
               "label":"30%",
               "cn":"",
               "value":0.3
            },{
               "label":"50%",
               "cn":"",
               "value":0.5
            },{
               "label":"70%",
               "cn":"",
               "value":0.8
            },{
               "label":"100%",
               "cn":"",
               "value":1
            }],
            "optoinKey":"bgmVolume",
            "optionValue":cfg.bgmVolume
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

