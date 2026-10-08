package net.play5d.game.bvn.ui.select
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.GlowFilter;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.UIUtils;
   import net.play5d.game.bvn.utils.ResUtils;
   import net.play5d.kyo.display.BitmapText;
   
   public class SelectedFighterUI extends EventDispatcher
   {
      
      public var ui:Sprite;
      
      public var trueY:Number = 0;
      
      private var _fighterIndex:int = -1;
      
      private var _face:DisplayObject;
      
      private var _fighter:FighterVO;
      
      private var _text:BitmapText;
      
      private var _uiWidth:Number;
      
      public function SelectedFighterUI(param1:Sprite)
      {
         super();
         this.ui = param1;
         param1.mouseChildren = false;
         if(GameUI.SHOW_CN_TEXT)
         {
            _text = new BitmapText(true,16777215,[new GlowFilter(0,1,3,3,3)]);
            if(param1 is selected_item_p1_mc)
            {
               UIUtils.formatText(_text.textfield,{
                  "color":16777215,
                  "size":14,
                  "align":"right"
               });
               _text.width = param1.width - 10;
            }
            else
            {
               UIUtils.formatText(_text.textfield,{
                  "color":16777215,
                  "size":14,
                  "align":"left"
               });
               _text.x = 40;
               _text.width = param1.width + 40;
            }
            _text.y = param1.height - 30;
            param1.addChild(_text);
         }
      }
      
      public function mouseEnabled(param1:Boolean) : void
      {
         if(param1)
         {
            if(GameConfig.TOUCH_MODE)
            {
               ui.addEventListener("touchTap",mouseHandler);
            }
            else
            {
               ui.buttonMode = true;
               ui.addEventListener("mouseOver",mouseHandler);
               ui.addEventListener("click",mouseHandler);
            }
         }
         else
         {
            ui.buttonMode = false;
            ui.removeEventListener("touchTap",mouseHandler);
            ui.removeEventListener("mouseOver",mouseHandler);
            ui.removeEventListener("click",mouseHandler);
         }
      }
      
      private function mouseHandler(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function destory() : void
      {
         if(ui)
         {
            ui.removeEventListener("touchTap",mouseHandler);
            ui.removeEventListener("mouseOver",mouseHandler);
            ui.removeEventListener("click",mouseHandler);
         }
         if(_text)
         {
            _text.destory();
            _text = null;
         }
      }
      
      public function setFighter(param1:FighterVO) : void
      {
         var _loc2_:*;
         var _loc4_:Sprite;
         var _loc3_:DisplayObject = null;
         if(!param1)
         {
            return;
         }
         _fighter = param1;
         if(_text)
         {
            _text.text = param1.name;
         }
         _loc2_ = ui.getChildByName("ct") as ctmc;
         if(_loc4_ = _loc2_ ? _loc2_.getChildByName("ct") as Sprite : null)
         {
            if(_face)
            {
               try
               {
                  _loc4_.removeChild(_face);
               }
               catch(e:Error)
               {
               }
            }
            _loc3_ = AssetManager.I.getFighterFaceBig(param1);
            if(_loc3_)
            {
               _face = _loc3_;
               _loc4_.addChild(_loc3_);
            }
         }
      }
      
      public function getFighter() : FighterVO
      {
         return _fighter;
      }
      
      public function getFighterIndex() : int
      {
         return _fighterIndex;
      }
      
      public function setFighterIndex(param1:int) : void
      {
         _fighterIndex = param1;
         var _loc2_:* = ResUtils.I.createDisplayObject(ResUtils.I.select,"seltwzmc");
         _loc2_.gotoAndStop(param1);
         ui.addChild(_loc2_);
         if(ui is selected_item_p1_mc)
         {
            _loc2_.x = -8;
         }
         else
         {
            _loc2_.x = 252 - _loc2_.width;
         }
         _loc2_.y = -5;
         mouseEnabled(false);
      }
      
      public function setAssister() : void
      {
         var _loc1_:* = ResUtils.I.createDisplayObject(ResUtils.I.select,"seltwzmc");
         _loc1_.gotoAndStop(4);
         ui.addChild(_loc1_);
         if(ui is selected_item_p1_mc)
         {
            _loc1_.x = -8;
         }
         else
         {
            _loc1_.x = 176;
         }
         _loc1_.y = -5;
      }
   }
}

