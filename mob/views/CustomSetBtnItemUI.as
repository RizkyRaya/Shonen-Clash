package net.play5d.game.bvn.mob.views
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadBtnBase;
   import net.play5d.game.bvn.mob.utils.UIAssetUtil;
   
   public class CustomSetBtnItemUI
   {
      
      private var _ui:Sprite;
      
      private var _target:ScreenPadBtnBase;
      
      private var _btns:Array;
      
      private var _btnPos:Dictionary = new Dictionary();
      
      private var _scale:Number = 1;
      
      public function CustomSetBtnItemUI(param1:Number)
      {
         super();
         _ui = UIAssetUtil.I.createDisplayObject("item_set_btns_mc");
         _ui.scaleX = _ui.scaleY = param1;
         _ui.visible = false;
         initBtns("zoomin2","zoomout2");
      }
      
      public function getUI() : Sprite
      {
         return _ui;
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
            _loc4_.y += 5;
            _loc4_.alpha = 0.5;
            TweenLite.to(_loc4_,0.2,{
               "alpha":1,
               "y":_loc2_
            });
         }
         switch(_loc4_.name)
         {
            case "zoomin2":
               zoomBtn(0.1);
               break;
            case "zoomout2":
               zoomBtn(-0.1);
         }
      }
      
      private function zoomBtn(param1:Number) : void
      {
         if(!_target)
         {
            return;
         }
         var _loc2_:Number = _target.display.scaleX;
         _loc2_ += param1;
         _target.display.scaleX = _target.display.scaleY = _loc2_;
      }
      
      public function show(param1:ScreenPadBtnBase) : void
      {
         _target = param1;
         _ui.visible = true;
         _ui.x = _target.display.x + _target.display.width - _ui.width;
         _ui.y = _target.display.y;
      }
      
      public function hide() : void
      {
         _target = null;
         _ui.visible = false;
      }
   }
}

