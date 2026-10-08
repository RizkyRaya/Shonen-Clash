package net.play5d.game.bvn.mob.screenpad
{
   import flash.display.Bitmap;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class ScreenPadBtnBase
   {
      
      public var moveAble:Boolean = false;
      
      public var display:Bitmap;
      
      public var touchPos:Point = new Point();
      
      public var keyId:Object;
      
      public var areaAdd:Number = 0;
      
      protected var _orgScale:Number = 1;
      
      protected var _orgBounds:Rectangle;
      
      protected var _area:Rectangle;
      
      protected var _isDown:Boolean;
      
      protected var _visible:Boolean = true;
      
      public function ScreenPadBtnBase()
      {
         super();
      }
      
      public function init(param1:Point = null) : void
      {
         if(param1)
         {
            if(param1.x > 0 && param1.y > 0)
            {
               display.width = param1.x;
               display.height = param1.y;
            }
            else if(param1.x > 0)
            {
               display.width = param1.x;
               display.scaleY = display.scaleX;
            }
            else
            {
               display.height = param1.y;
               display.scaleX = display.scaleY;
            }
         }
         _orgScale = display.scaleX;
      }
      
      public function setScale(param1:Number) : void
      {
         _orgScale = param1;
         display.scaleX = display.scaleY = param1;
      }
      
      public function isDown() : Boolean
      {
         return _isDown;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         _visible = param1;
         if(display)
         {
            display.visible = param1;
         }
      }
      
      public function onAdd() : void
      {
      }
      
      public function onRemove() : void
      {
      }
      
      public function initArea() : void
      {
         _orgBounds = new Rectangle();
         _orgBounds.x = display.x;
         _orgBounds.y = display.y;
         _orgBounds.width = display.width;
         _orgBounds.height = display.height;
         _area = _orgBounds.clone();
         if(areaAdd != 0)
         {
            _area.x -= areaAdd;
            _area.y -= areaAdd;
            _area.width += areaAdd * 2;
            _area.height += areaAdd * 2;
         }
      }
      
      public function updateBounds() : void
      {
         _orgBounds.x = display.x;
         _orgBounds.y = display.y;
         _orgBounds.width = display.width;
         _orgBounds.height = display.height;
      }
      
      public function checkArea(param1:Number, param2:Number) : Boolean
      {
         if(!_visible)
         {
            return false;
         }
         return _area.contains(param1,param2);
      }
      
      final public function touchDown(param1:Number, param2:Number) : void
      {
         if(_isDown)
         {
            return;
         }
         _isDown = true;
         onTouchDown(param1,param2);
         downState();
      }
      
      final public function touchMove(param1:Number, param2:Number) : void
      {
         onTouchMove(param1,param2);
         moveState();
      }
      
      final public function touchUP() : void
      {
         if(!_isDown)
         {
            return;
         }
         _isDown = false;
         onTouchUp();
         upState();
      }
      
      public function setPosData(param1:Object) : void
      {
         if(display)
         {
            display.x = param1.x;
            display.y = param1.y;
            display.scaleX = display.scaleY = param1.scale;
         }
      }
      
      public function getPosData() : Object
      {
         return {
            "x":display.x,
            "y":display.y,
            "scale":display.scaleX
         };
      }
      
      protected function onTouchDown(param1:Number, param2:Number) : void
      {
      }
      
      protected function onTouchUp() : void
      {
      }
      
      protected function downState() : void
      {
      }
      
      protected function upState() : void
      {
         display.scaleX = display.scaleY = _orgScale;
         display.x = _orgBounds.x;
         display.y = _orgBounds.y;
      }
      
      protected function onTouchMove(param1:Number, param2:Number) : void
      {
      }
      
      protected function moveState() : void
      {
      }
      
      public function setAlpha(value:Number) : void
      {
         if(display)
         {
            display.alpha = value;
         }
      }
   }
}

