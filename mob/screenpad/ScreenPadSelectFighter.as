package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.Stage;
   import flash.events.TouchEvent;
   import flash.geom.Point;
   import net.play5d.game.bvn.mob.RootSprite;
   import net.play5d.game.bvn.mob.input.ScreenPadInput;
   
   public class ScreenPadSelectFighter
   {
      
      public var inputers:Vector.<ScreenPadInput>;
      
      private var _stage:Stage;
      
      private var _touchEnabled:Boolean = true;
      
      private var _listened:Boolean;
      
      private var _downCache:Object = {};
      
      private var _btns:Vector.<ScreenPadBtnBase>;
      
      private var W:Number;
      
      private var H:Number;
      
      public function ScreenPadSelectFighter(param1:Stage)
      {
         super();
         _stage = param1;
         build();
      }
      
      public function reBuild() : void
      {
         var _loc1_:int = 0;
         try
         {
            while(_loc1_ < _btns.length)
            {
               _stage.removeChild(_btns[_loc1_].display);
               _btns[_loc1_].onRemove();
               _loc1_++;
            }
         }
         catch(e:Error)
         {
         }
         build();
      }
      
      private function build() : void
      {
         W = RootSprite.FULL_SCREEN_SIZE.x;
         H = RootSprite.FULL_SCREEN_SIZE.y;
         _btns = new Vector.<ScreenPadBtnBase>();
         addBtn("back",ScreenPadAsset.cancel,0,0,0,0,0);
         initBtns();
      }
      
      private function addBtn(param1:String, param2:Class, param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:Number = 0, param8:Number = 0) : ScreenPadBtn
      {
         var _loc9_:Point = new Point();
         _loc9_.x = ScreenPadUtils.cm2pixel(param8);
         var _loc10_:ScreenPadBtn = ScreenPadUtils.getButton(param2,_loc9_);
         _loc10_.moveAble = false;
         _loc10_.keyId = param1;
         _loc10_.areaAdd = ScreenPadUtils.cm2pixel(param7);
         if(param3 != 0)
         {
            _loc10_.display.x = ScreenPadUtils.cm2pixel(param3);
         }
         if(param4 != 0)
         {
            _loc10_.display.y = ScreenPadUtils.cm2pixel(param4);
         }
         if(param5 != 0)
         {
            _loc10_.display.x = W - _loc10_.display.width - ScreenPadUtils.cm2pixel(param5);
         }
         if(param6 != 0)
         {
            _loc10_.display.y = H - _loc10_.display.height - ScreenPadUtils.cm2pixel(param6);
         }
         _btns.push(_loc10_);
         return _loc10_;
      }
      
      private function initBtns() : void
      {
         for each(var _loc1_ in _btns)
         {
            _loc1_.initArea();
         }
      }
      
      public function setTouchEnabled(value:Boolean) : void
      {
         _touchEnabled = value;
      }
      
      public function show() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _btns.length)
         {
            _stage.addChild(_btns[_loc1_].display);
            _btns[_loc1_].onAdd();
            _loc1_++;
         }
      }
      
      public function hide() : void
      {
         var _loc1_:*;
         var _loc2_:int = 0;
         try
         {
            while(_loc2_ < _btns.length)
            {
               _stage.removeChild(_btns[_loc2_].display);
               _btns[_loc2_].onRemove();
               _loc2_++;
            }
         }
         catch(e:Error)
         {
         }
         for each(_loc1_ in inputers)
         {
            _loc1_.clear();
         }
      }
      
      public function setHudAlpha(value:Number) : void
      {
         for each(var btn in _btns)
         {
            btn.setAlpha(value);
         }
      }
      
      public function touchHandler(param1:TouchEvent) : void
      {
         if(!_touchEnabled)
         {
            return;
         }
         var _loc2_:ScreenPadBtnBase = null;
         var _loc4_:int = 0;
         var _loc3_:int = param1.touchPointID;
         var _loc5_:Number = param1.stageX;
         var _loc6_:Number = param1.stageY;
         if(param1.type == "touchEnd")
         {
            if(_downCache[_loc3_])
            {
               _loc2_ = _downCache[_loc3_].btn;
               _loc2_.touchUP();
               setInputerDown(_downCache[_loc3_].key,false);
               delete _downCache[_loc3_];
            }
            return;
         }
         while(_loc4_ < _btns.length)
         {
            _loc2_ = _btns[_loc4_];
            var _loc7_:String = param1.type;
            if("touchBegin" === _loc7_)
            {
               if(_loc2_.checkArea(_loc5_,_loc6_))
               {
                  _loc2_.touchDown(_loc5_,_loc6_);
                  _downCache[_loc3_] = {
                     "btn":_loc2_,
                     "key":_loc2_.keyId
                  };
                  setInputerDown(_loc2_.keyId,true);
               }
            }
            _loc4_++;
         }
      }
      
      private function setInputerDown(param1:Object, param2:Boolean) : void
      {
         var _loc5_:ScreenPadInput = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:Array = null;
         var _loc9_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1 == null)
         {
            return;
         }
         _loc4_ = int(inputers.length);
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            _loc5_ = inputers[_loc7_];
            if(param1 is String)
            {
               _loc5_.setDown(param1 as String,param2);
            }
            if(param1 is Array)
            {
               _loc6_ = param1 as Array;
               _loc3_ = int(_loc6_.length);
               _loc8_ = 0;
               while(_loc8_ < _loc3_)
               {
                  _loc9_ = _loc6_[_loc8_];
                  _loc5_.setDown(_loc9_,param2);
                  _loc8_++;
               }
            }
            _loc7_++;
         }
      }
   }
}

