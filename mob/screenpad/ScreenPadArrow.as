package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   public class ScreenPadArrow extends ScreenPadBtnBase
   {
      
      private var _keyUP:String;
      
      private var _keyDOWN:String;
      
      private var _keyLEFT:String;
      
      private var _keyRIGHT:String;
      
      private var _downV:String;
      
      private var _downH:String;
      
      private var _lightH:Bitmap;
      
      private var _lightV:Bitmap;
      
      private var _center:Rectangle;
      
      private var _upBitmap:BitmapData;
      
      private var _startTouchPoint:Point;
      
      private var _touchMoving:Boolean;
      
      private var _resetPoint:Point;
      
      private var _resetTimer:Timer;
      
      public function ScreenPadArrow()
      {
         super();
      }
      
      override public function initArea() : void
      {
         super.initArea();
         _center = new Rectangle(_orgBounds.x + _orgBounds.width * 0.3,_orgBounds.y + _orgBounds.height * 0.3,_orgBounds.x + _orgBounds.width * 0.7,_orgBounds.y + _orgBounds.height * 0.7);
         _resetPoint = new Point(_orgBounds.x,_orgBounds.y);
         _lightH = new ScreenPadAsset.light();
         _lightV = new ScreenPadAsset.light();
         _lightH.scaleX = _lightH.scaleY = _orgScale;
         _lightV.scaleX = _lightV.scaleY = _orgScale;
         _lightH.alpha = display.alpha;
         _lightV.alpha = display.alpha;
         _lightH.visible = false;
         _lightV.visible = false;
         if(moveAble)
         {
            _resetTimer = new Timer(1000,1);
            _resetTimer.addEventListener("timerComplete",resetTimeHandler);
         }
      }
      
      private function resetTimeHandler(param1:TimerEvent) : void
      {
         display.x = _resetPoint.x;
         display.y = _resetPoint.y;
         updateBounds();
      }
      
      override public function updateBounds() : void
      {
         super.updateBounds();
         _center.x = _orgBounds.x + _orgBounds.width * 0.4;
         _center.y = _orgBounds.y + _orgBounds.height * 0.3;
         _center.width = _orgBounds.x + _orgBounds.width * 0.6;
         _center.height = _orgBounds.y + _orgBounds.height * 0.7;
      }
      
      override public function onAdd() : void
      {
         super.onAdd();
         display.parent.addChild(_lightH);
         display.parent.addChild(_lightV);
      }
      
      override public function onRemove() : void
      {
         super.onRemove();
         try
         {
            _lightH.parent.removeChild(_lightH);
            _lightV.parent.removeChild(_lightV);
         }
         catch(e:Error)
         {
         }
         if(_resetTimer)
         {
            _resetTimer.stop();
         }
      }
      
      public function setKeyIds(param1:String, param2:String, param3:String, param4:String) : void
      {
         _keyUP = param1;
         _keyDOWN = param2;
         _keyLEFT = param3;
         _keyRIGHT = param4;
      }
      
      override protected function onTouchDown(param1:Number, param2:Number) : void
      {
         if(param2 < _center.y)
         {
            _downV = _keyUP;
         }
         if(param2 > _center.height)
         {
            _downV = _keyDOWN;
         }
         if(param1 < _center.x)
         {
            _downH = _keyLEFT;
         }
         if(param1 > _center.width)
         {
            _downH = _keyRIGHT;
         }
         updateKeyId();
      }
      
      override protected function onTouchUp() : void
      {
         super.touchUP();
         _downV = null;
         _downH = null;
         updateKeyId();
      }
      
      private function updateKeyId() : void
      {
         if(!_downV && !_downH)
         {
            keyId = null;
         }
         keyId = [_downV,_downH];
      }
      
      public function getAllKeyIds() : Array
      {
         return [_keyUP,_keyDOWN,_keyLEFT,_keyRIGHT];
      }
      
      public function clearKey() : void
      {
         _downV = null;
         _downH = null;
         _lightH.visible = false;
         _lightV.visible = false;
      }
      
      public function getNotDownKeyIds() : Array
      {
         var _loc1_:Array = [_keyUP,_keyDOWN,_keyLEFT,_keyRIGHT];
         var _loc2_:int = _loc1_.indexOf(_downV);
         if(_loc2_ != -1)
         {
            _loc1_.splice(_loc2_,1);
         }
         var _loc3_:int = _loc1_.indexOf(_downH);
         if(_loc3_ != -1)
         {
            _loc1_.splice(_loc3_,1);
         }
         return _loc1_;
      }
      
      override protected function downState() : void
      {
         if(_downH == _keyLEFT)
         {
            _lightH.visible = true;
            _lightH.x = _orgBounds.x - _lightH.width / 2;
            _lightH.y = _orgBounds.y - _lightH.height / 2 + _orgBounds.width / 2;
         }
         if(_downH == _keyRIGHT)
         {
            _lightH.visible = true;
            _lightH.x = _orgBounds.x - _lightH.width / 2 + _orgBounds.width;
            _lightH.y = _orgBounds.y - _lightH.height / 2 + _orgBounds.width / 2;
         }
         if(_downV == _keyUP)
         {
            _lightV.visible = true;
            _lightV.x = _orgBounds.x - _lightV.width / 2 + _orgBounds.width / 2;
            _lightV.y = _orgBounds.y - _lightV.height / 2;
         }
         if(_downV == _keyDOWN)
         {
            _lightV.visible = true;
            _lightV.x = _orgBounds.x - _lightV.width / 2 + _orgBounds.width / 2;
            _lightV.y = _orgBounds.y - _lightV.height / 2 + _orgBounds.height;
         }
         if(_resetTimer)
         {
            _resetTimer.stop();
         }
      }
      
      override protected function onTouchMove(param1:Number, param2:Number) : void
      {
         if(!_isDown)
         {
            return;
         }
         _downV = null;
         _downH = null;
         if(param2 < _center.y)
         {
            _downV = _keyUP;
         }
         if(param2 > _center.height)
         {
            _downV = _keyDOWN;
         }
         if(param1 < _center.x)
         {
            _downH = _keyLEFT;
         }
         if(param1 > _center.width)
         {
            _downH = _keyRIGHT;
         }
         updateKeyId();
         if(moveAble)
         {
            updateMovePosition(param1,param2);
         }
      }
      
      private function updateMovePosition(param1:Number, param2:Number) : void
      {
         var _loc3_:Boolean = false;
         if(!_touchMoving)
         {
            if(!_startTouchPoint)
            {
               _startTouchPoint = new Point(param1,param2);
            }
            if(Math.abs(param1 - _startTouchPoint.x) + Math.abs(param2 - _startTouchPoint.y) > ScreenPadUtils.cm2pixel(0.3))
            {
               _touchMoving = true;
            }
            return;
         }
         var _loc4_:Number = _orgBounds.x + _orgBounds.width;
         var _loc5_:Number = _orgBounds.y + _orgBounds.height;
         if(param1 > _loc4_)
         {
            _loc3_ = true;
            display.x = param1 - display.width;
         }
         if(param1 < _orgBounds.x)
         {
            _loc3_ = true;
            display.x = param1;
         }
         if(param2 > _loc5_)
         {
            _loc3_ = true;
            display.y = param2 - display.height;
         }
         if(param2 < _orgBounds.y)
         {
            _loc3_ = true;
            display.y = param2;
         }
         if(_loc3_)
         {
            updateBounds();
         }
      }
      
      override protected function moveState() : void
      {
         if(!_isDown)
         {
            return;
         }
         _lightH.visible = false;
         _lightV.visible = false;
         downState();
      }
      
      override protected function upState() : void
      {
         super.upState();
         _lightH.visible = false;
         _lightV.visible = false;
         _startTouchPoint = null;
         _touchMoving = false;
         if(_resetTimer)
         {
            _resetTimer.reset();
            _resetTimer.start();
         }
      }
      
      override public function setAlpha(value:Number) : void
      {
         super.setAlpha(value);
         if(_lightH)
         {
            _lightH.alpha = value;
         }
         if(_lightV)
         {
            _lightV.alpha = value;
         }
      }
   }
}

