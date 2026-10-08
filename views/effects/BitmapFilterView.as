package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class BitmapFilterView implements IGameSprite
   {
      
      private static var DRAW_COUNT:int = 0;
      
      private static var _bmdPool:Vector.<BitmapData> = new Vector.<BitmapData>();
      
      private static const MAX_POOL_SIZE:int = 30;
      
      private var _bitmap:Bitmap;
      
      private var _cacheBitmapData:BitmapData;
      
      private var _lastX:Number = Number.MAX_VALUE;
      
      private var _lastY:Number = Number.MAX_VALUE;
      
      private var _lastScaleX:Number = Number.MAX_VALUE;
      
      private var _lastScaleY:Number = Number.MAX_VALUE;
      
      public var target:BaseGameSprite;
      
      private var _filter:BitmapFilter;
      
      private var _filterOffset:Point;
      
      private var _isDestoryed:Boolean;
      
      private var _bitmapFrame:int = -1;
      
      private var _targetDisplay:DisplayObject;
      
      private var _targetBounds:Rectangle;
      
      private var _targetFighter:FighterMain;
      
      private var _isActive:Boolean = true;
      
      public function BitmapFilterView(param1:BaseGameSprite, param2:BitmapFilter, param3:Point = null)
      {
         super();
         _bitmap = new Bitmap(null,"auto",false);
         this.target = param1;
         if(param1 is FighterMain)
         {
            _targetFighter = param1 as FighterMain;
         }
         _targetDisplay = param1.getDisplay();
         _filter = param2;
         _filterOffset = param3;
         _isActive = true;
      }
      
      private static function getPooledBitmapData(w:int, h:int) : BitmapData
      {
         var len:int = int(_bmdPool.length);
         var i:int = 0;
         while(i < len)
         {
            var bmd:BitmapData = _bmdPool[i];
            if(bmd.width == w && bmd.height == h)
            {
               _bmdPool.splice(i,1);
               bmd.fillRect(bmd.rect,0);
               return bmd;
            }
            i++;
         }
         return null;
      }
      
      private static function recycleBitmapData(bmd:BitmapData) : void
      {
         if(!bmd)
         {
            return;
         }
         if(_bmdPool.length < MAX_POOL_SIZE)
         {
            _bmdPool.push(bmd);
         }
         else
         {
            bmd.dispose();
         }
      }
      
      public static function clearPool() : void
      {
         for each(var bmd in _bmdPool)
         {
            bmd.dispose();
         }
         _bmdPool.length = 0;
      }
      
      public function getActive() : Boolean
      {
         return _isActive;
      }
      
      public function setActive(param1:Boolean) : void
      {
         _isActive = param1;
         if(_bitmap)
         {
            _bitmap.visible = param1;
         }
      }
      
      public function setVolume(param1:Number) : void
      {
      }
      
      public function update(param1:BitmapFilter, param2:Point = null) : void
      {
         _filter = param1;
         _filterOffset = param2;
         _targetBounds = null;
         _bitmapFrame = -1;
         if(!_filter && _bitmap)
         {
            _bitmap.visible = false;
         }
      }
      
      public function renderAnimate() : void
      {
      }
      
      public function render() : void
      {
         if(!_isActive || _isDestoryed || !target || !_targetDisplay || !_filter)
         {
            if(_bitmap)
            {
               _bitmap.visible = false;
            }
            return;
         }
         _bitmap.visible = true;
         var needUpdate:Boolean = false;
         if(_targetDisplay.x != _lastX)
         {
            needUpdate = true;
            _lastX = _targetDisplay.x;
         }
         if(_targetDisplay.y != _lastY)
         {
            needUpdate = true;
            _lastY = _targetDisplay.y;
         }
         if(_targetDisplay.scaleX != _lastScaleX)
         {
            needUpdate = true;
            _lastScaleX = _targetDisplay.scaleX;
         }
         if(_targetDisplay.scaleY != _lastScaleY)
         {
            needUpdate = true;
            _lastScaleY = _targetDisplay.scaleY;
         }
         if(_targetFighter)
         {
            var currentFrame:int = _targetFighter.getMC().getCurrentFrameCount();
            if(currentFrame != _bitmapFrame)
            {
               needUpdate = true;
            }
         }
         else
         {
            needUpdate = true;
         }
         if(needUpdate)
         {
            renderBitmapData();
         }
         if(!_targetBounds)
         {
            _targetBounds = _targetDisplay.getBounds(_targetDisplay);
         }
         _bitmap.scaleX = _targetDisplay.scaleX;
         _bitmap.scaleY = _targetDisplay.scaleY;
         var offsetX:Number = _filterOffset ? _filterOffset.x : 0;
         var offsetY:Number = _filterOffset ? _filterOffset.y : 0;
         if(target.direct > 0)
         {
            _bitmap.x = _targetDisplay.x - offsetX + _targetBounds.x * _bitmap.scaleX;
         }
         else
         {
            _bitmap.x = _targetDisplay.x + offsetX + _targetBounds.x * _bitmap.scaleX;
         }
         _bitmap.y = _targetDisplay.y - offsetY + _targetBounds.y * _bitmap.scaleY;
      }
      
      private function renderBitmapData() : void
      {
         if(!_filter || !_targetDisplay)
         {
            return;
         }
         if(_targetFighter)
         {
            var frame:int = _targetFighter.getMC().getCurrentFrameCount();
            if(frame == _bitmapFrame && _cacheBitmapData != null)
            {
               return;
            }
            _bitmapFrame = frame;
         }
         var originalVisible:Boolean = _targetDisplay.visible;
         if(!originalVisible)
         {
            _targetDisplay.visible = true;
         }
         _targetBounds = _targetDisplay.getBounds(_targetDisplay);
         var bmpData:BitmapData = KyoUtils.drawBitmapFilter(_targetDisplay,_filter,true,_filterOffset);
         if(!originalVisible)
         {
            _targetDisplay.visible = false;
         }
         if(!bmpData)
         {
            return;
         }
         if(!_cacheBitmapData)
         {
            _cacheBitmapData = getPooledBitmapData(bmpData.width,bmpData.height);
            if(_cacheBitmapData)
            {
               _cacheBitmapData.copyPixels(bmpData,bmpData.rect,new Point(0,0));
               bmpData.dispose();
            }
            else
            {
               _cacheBitmapData = bmpData;
            }
            _bitmap.bitmapData = _cacheBitmapData;
         }
         else if(_cacheBitmapData.width != bmpData.width || _cacheBitmapData.height != bmpData.height)
         {
            recycleBitmapData(_cacheBitmapData);
            _cacheBitmapData = getPooledBitmapData(bmpData.width,bmpData.height);
            if(_cacheBitmapData)
            {
               _cacheBitmapData.copyPixels(bmpData,bmpData.rect,new Point(0,0));
               bmpData.dispose();
            }
            else
            {
               _cacheBitmapData = bmpData;
            }
            _bitmap.bitmapData = _cacheBitmapData;
         }
         else
         {
            _cacheBitmapData.lock();
            _cacheBitmapData.fillRect(_cacheBitmapData.rect,0);
            _cacheBitmapData.copyPixels(bmpData,bmpData.rect,new Point(0,0),null,null,true);
            _cacheBitmapData.unlock();
            bmpData.dispose();
         }
      }
      
      public function isDestoryed() : Boolean
      {
         return _isDestoryed;
      }
      
      public function getDisplay() : DisplayObject
      {
         return _bitmap;
      }
      
      public function get direct() : int
      {
         return target ? target.direct : 1;
      }
      
      public function set direct(param1:int) : void
      {
      }
      
      public function get x() : Number
      {
         return _bitmap.x;
      }
      
      public function set x(param1:Number) : void
      {
         _bitmap.x = param1;
      }
      
      public function get y() : Number
      {
         return _bitmap.y;
      }
      
      public function set y(param1:Number) : void
      {
         _bitmap.y = param1;
      }
      
      public function get team() : TeamVO
      {
         return null;
      }
      
      public function set team(param1:TeamVO) : void
      {
      }
      
      public function hit(param1:HitVO, param2:IGameSprite) : void
      {
      }
      
      public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
      }
      
      public function getArea() : Rectangle
      {
         return null;
      }
      
      public function getBodyArea() : Rectangle
      {
         return null;
      }
      
      public function getCurrentHits() : Array
      {
         return null;
      }
      
      public function allowCrossMapXY() : Boolean
      {
         return true;
      }
      
      public function allowCrossMapBottom() : Boolean
      {
         return true;
      }
      
      public function getIsTouchSide() : Boolean
      {
         return false;
      }
      
      public function setIsTouchSide(param1:Boolean) : void
      {
      }
      
      public function setSpeedRate(param1:Number) : void
      {
      }
      
      public function destory(param1:Boolean = true) : void
      {
         _isActive = false;
         if(_bitmap)
         {
            _bitmap.visible = false;
            if(_bitmap.parent)
            {
               _bitmap.parent.removeChild(_bitmap);
            }
            if(_bitmap.bitmapData)
            {
               recycleBitmapData(_bitmap.bitmapData);
               _bitmap.bitmapData = null;
            }
         }
         _cacheBitmapData = null;
         _isDestoryed = true;
         if(param1)
         {
            this.target = null;
            _filter = null;
            _filterOffset = null;
            _targetFighter = null;
            _targetBounds = null;
            _targetDisplay = null;
         }
      }
   }
}

