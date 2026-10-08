package net.play5d.game.bvn.mob.views
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.events.ScreenPadEvent;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadGame;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadUtils;
   import net.play5d.game.bvn.mob.utils.UIAssetUtil;
   
   public class CustomScreenBtnView
   {
      
      private var _ui:Sprite;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _scale:Number = 1;
      
      private var _btns:Array;
      
      private var _btnPos:Dictionary = new Dictionary();
      
      private var _btnItemSetUI:CustomSetBtnItemUI;
      
      private var _screenPad:ScreenPadGame;
      
      private var _screenBtns:Vector.<ScreenPadBtnBase>;
      
      private var _moveStep:Point;
      
      public function CustomScreenBtnView()
      {
         super();
         _ui = UIAssetUtil.I.createDisplayObject("screen_pad_set_ui_mc");
         _ui.graphics.beginFill(0,0.8);
         _ui.graphics.drawRect(0,0,RootSprite.FULL_SCREEN_SIZE.x,RootSprite.FULL_SCREEN_SIZE.y);
         _ui.graphics.endFill();
         _width = RootSprite.FULL_SCREEN_SIZE.x;
         _height = ScreenPadUtils.cm2pixel(0.8);
         _scale = _height / 55;
         _btnItemSetUI = new CustomSetBtnItemUI(_scale);
         _ui.addChild(_btnItemSetUI.getUI());
         initBtns("close","up","down","left","right","center","side","zoomin","zoomout","ok");
         initView();
         initPad();
      }
      
      public function getDisplay() : Sprite
      {
         return _ui;
      }
      
      private function initView() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc5_:int = 0;
         var _loc6_:DisplayObject = _ui.getChildByName("btnbg");
         if(_loc6_)
         {
            _loc6_.width = _width;
            _loc6_.height = _height;
         }
         var _loc8_:DisplayObject = _ui.getChildByName("up");
         var _loc7_:int = _loc8_.width * 0.15;
         var _loc1_:Number = 0;
         _loc5_ = 0;
         while(_loc5_ < _btns.length)
         {
            _loc2_ = _btns[_loc5_];
            _loc2_.x = _loc1_;
            _loc1_ += _loc7_ + _loc2_.width;
            if(_loc5_ == 0 || _loc5_ == _btns.length - 2)
            {
               _loc1_ += _loc7_;
            }
            _loc5_++;
         }
         var _loc9_:Number = _loc1_;
         var _loc10_:int = _btns.length - 2;
         var _loc3_:Number = RootSprite.FULL_SCREEN_SIZE.x;
         var _loc4_:Number = (_loc3_ - _loc9_) / 2;
         _loc5_ = 0;
         while(_loc5_ < _btns.length)
         {
            _loc2_ = _btns[_loc5_];
            _loc2_.x += _loc4_;
            _loc5_++;
         }
      }
      
      private function initBtns(... rest) : void
      {
         var _loc2_:DisplayObject = null;
         _btns = [];
         for each(var _loc3_ in rest)
         {
            _loc2_ = _ui.getChildByName(_loc3_);
            if(_loc2_)
            {
               _btnPos[_loc2_] = new Point(_loc2_.x,_loc2_.y);
               _btns.push(_loc2_);
               _loc2_.scaleX = _loc2_.scaleY = _scale;
               _loc2_.addEventListener("touchTap",btnTouchHandler);
            }
         }
      }
      
      private function btnTouchHandler(param1:TouchEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:DisplayObject = param1.currentTarget as DisplayObject;
         if(!_loc4_)
         {
            return;
         }
         var _loc3_:Point = _btnPos[_loc4_];
         if(!_loc3_)
         {
            _loc4_.alpha = 0.5;
            TweenLite.to(_loc4_,0.2,{"alpha":1});
         }
         else
         {
            _loc2_ = _loc3_.y;
            _loc4_.y += 5 * _scale;
            _loc4_.alpha = 0.5;
            TweenLite.to(_loc4_,0.2,{
               "alpha":1,
               "y":_loc2_
            });
         }
         switch(_loc4_.name)
         {
            case "close":
               removeSelf();
               break;
            case "up":
               moveAllBtns(0,-_moveStep.x);
               break;
            case "down":
               moveAllBtns(0,_moveStep.x);
               break;
            case "left":
               moveAllBtns(-_moveStep.x,0);
               break;
            case "right":
               moveAllBtns(_moveStep.x,0);
               break;
            case "center":
               moveLRBtns(_moveStep.x);
               break;
            case "side":
               moveLRBtns(-_moveStep.x);
               break;
            case "zoomin":
               zoomBtns(0.1);
               break;
            case "zoomout":
               zoomBtns(-0.1);
               break;
            case "ok":
               doOK();
         }
         if(_loc4_.name == "ok")
         {
            SoundCtrl.I.sndConfrim();
         }
         else
         {
            SoundCtrl.I.sndSelect();
         }
      }
      
      private function removeSelf() : void
      {
         if(_screenPad)
         {
            _screenPad.destory();
            _screenPad = null;
         }
         if(_btns)
         {
            for each(var _loc1_ in _btns)
            {
               _loc1_.removeEventListener("touchTap",btnTouchHandler);
            }
            _btns = null;
         }
         if(_ui)
         {
            try
            {
               _ui.parent.removeChild(_ui);
            }
            catch(e:Error)
            {
               trace(e);
            }
            _ui = null;
         }
      }
      
      private function doOK() : void
      {
         GameInterfaceManager.config.screenPadConfig.joySet = _screenPad.getBtnPosData();
         ScreenPadManager.reBuild();
         removeSelf();
      }
      
      private function initPad() : void
      {
         _screenPad = new ScreenPadGame(RootSprite.STAGE);
         _screenPad.showEditMode();
         _screenPad.addEventListener("ScreenPadEvent_CUSTOM_MOVING",screenPadCustomHandler);
         _screenPad.addEventListener("ScreenPadEvent_CUSTOM_SELECT",screenPadCustomHandler);
         _screenBtns = _screenPad.getBtns();
         _moveStep = new Point();
         _moveStep.x = RootSprite.FULL_SCREEN_SIZE.x * 0.01;
         _moveStep.y = RootSprite.FULL_SCREEN_SIZE.y * 0.01;
      }
      
      private function screenPadCustomHandler(param1:ScreenPadEvent) : void
      {
         switch(param1.type)
         {
            case "ScreenPadEvent_CUSTOM_MOVING":
               _btnItemSetUI.show(param1.screenPadBtn);
               break;
            case "ScreenPadEvent_CUSTOM_SELECT":
               _btnItemSetUI.show(param1.screenPadBtn);
         }
      }
      
      private function moveAllBtns(param1:Number = 0, param2:Number = 0) : void
      {
         for each(var _loc3_ in _screenBtns)
         {
            _loc3_.display.x += param1;
            _loc3_.display.y += param2;
         }
      }
      
      private function moveLRBtns(param1:Number = 0) : void
      {
         var _loc2_:Number = RootSprite.FULL_SCREEN_SIZE.x / 2;
         for each(var _loc3_ in _screenBtns)
         {
            if(_loc3_.display.x < _loc2_)
            {
               _loc3_.display.x += param1;
            }
            else
            {
               _loc3_.display.x -= param1;
            }
         }
      }
      
      private function zoomBtns(param1:Number) : void
      {
         for each(var _loc2_ in _screenBtns)
         {
            zoomBtn(_loc2_,param1);
         }
      }
      
      private function zoomBtn(param1:ScreenPadBtnBase, param2:Number) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:Number = param1.display.scaleX;
         _loc3_ += param2;
         param1.display.scaleX = param1.display.scaleY = _loc3_;
      }
   }
}

