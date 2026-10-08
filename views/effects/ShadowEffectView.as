package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class ShadowEffectView
   {
      
      private static var _bmdPool:Vector.<BitmapData> = new Vector.<BitmapData>();
      
      private static var _bitmapPool:Vector.<Bitmap> = new Vector.<Bitmap>();
      
      private static const MAX_POOL_SIZE:int = 30;
      
      public var target:DisplayObject;
      
      public var r:int = 0;
      
      public var g:int = 0;
      
      public var b:int = 0;
      
      public var container:Sprite;
      
      public var stopShadow:Boolean;
      
      public var onRemove:Function;
      
      private var _bps:Vector.<Bitmap> = new Vector.<Bitmap>();
      
      private var _alphaLose:Number = 0.1;
      
      private var _alphaStart:Number = 0.8;
      
      private var _addBpGap:int = 1;
      
      private var _addBpFrame:int = 0;
      
      private var _colorTransform:ColorTransform;
      
      public function ShadowEffectView(param1:DisplayObject, param2:int = 0, param3:int = 0, param4:int = 0)
      {
         super();
         this.target = param1;
         this.r = param2;
         this.g = param3;
         this.b = param4;
         _addBpFrame = 0;
         if(this.r != 0 || this.g != 0 || this.b != 0)
         {
            _colorTransform = new ColorTransform();
            _colorTransform.redOffset = this.r;
            _colorTransform.greenOffset = this.g;
            _colorTransform.blueOffset = this.b;
         }
      }
      
      private static function getPooledBitmapData(width:int, height:int) : BitmapData
      {
         var len:int = int(_bmdPool.length);
         var i:int = 0;
         while(i < len)
         {
            var bmd:BitmapData = _bmdPool[i];
            if(bmd.width == width && bmd.height == height)
            {
               _bmdPool.splice(i,1);
               bmd.fillRect(bmd.rect,0);
               return bmd;
            }
            i++;
         }
         return new BitmapData(width,height,true,0);
      }
      
      private static function getPooledBitmap(bmd:BitmapData) : Bitmap
      {
         if(_bitmapPool.length > 0)
         {
            var bp:Bitmap = _bitmapPool.pop();
            bp.bitmapData = bmd;
         }
         else
         {
            bp = new Bitmap(bmd,"auto",false);
         }
         return bp;
      }
      
      private static function recycleBitmap(bp:Bitmap) : void
      {
         if(!bp)
         {
            return;
         }
         if(bp.bitmapData)
         {
            if(_bmdPool.length < MAX_POOL_SIZE)
            {
               _bmdPool.push(bp.bitmapData);
            }
            else
            {
               bp.bitmapData.dispose();
            }
            bp.bitmapData = null;
         }
         if(_bitmapPool.length < MAX_POOL_SIZE)
         {
            _bitmapPool.push(bp);
         }
      }
      
      public static function clearPool() : void
      {
         for each(var bmd in _bmdPool)
         {
            bmd.dispose();
         }
         _bmdPool.length = 0;
         _bitmapPool.length = 0;
      }
      
      public function destory() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Bitmap = null;
         target = null;
         while(_loc1_ < _bps.length)
         {
            _loc2_ = _bps[_loc1_];
            if(container && _loc2_.parent == container)
            {
               container.removeChild(_loc2_);
            }
            recycleBitmap(_loc2_);
            _loc1_++;
         }
         _bps.length = 0;
         _colorTransform = null;
      }
      
      public function render() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Bitmap = null;
         if(stopShadow)
         {
            if(_bps.length <= 0)
            {
               removeSelf();
               return;
            }
         }
         else if(_addBpFrame++ > _addBpGap)
         {
            addShadowBp();
            _addBpFrame = 0;
         }
         while(_loc1_ < _bps.length)
         {
            _loc2_ = _bps[_loc1_];
            _loc2_.alpha -= _alphaLose;
            if(_loc2_.alpha <= 0)
            {
               removeBitmap(_loc2_);
            }
            else
            {
               _loc1_++;
            }
         }
      }
      
      private function addShadowBp() : void
      {
         if(!target)
         {
            return;
         }
         var bounds:Rectangle = target.getBounds(target);
         var w:int = Math.ceil(bounds.width);
         var h:int = Math.ceil(bounds.height);
         if(w <= 0 || h <= 0)
         {
            return;
         }
         var bmd:BitmapData = getPooledBitmapData(w,h);
         var matrix:Matrix = new Matrix();
         matrix.translate(-bounds.x,-bounds.y);
         bmd.draw(target,matrix,_colorTransform);
         var bp:Bitmap = getPooledBitmap(bmd);
         bp.alpha = _alphaStart;
         bp.x = target.x + bounds.x * target.scaleX;
         bp.y = target.y + bounds.y;
         bp.scaleX = target.scaleX;
         bp.scaleY = target.scaleY;
         container.addChildAt(bp,0);
         _bps.push(bp);
      }
      
      private function removeBitmap(param1:Bitmap) : void
      {
         var _loc2_:int = _bps.indexOf(param1);
         if(_loc2_ != -1)
         {
            _bps.splice(_loc2_,1);
         }
         if(container && param1.parent == container)
         {
            container.removeChild(param1);
         }
         recycleBitmap(param1);
      }
      
      private function removeSelf() : void
      {
         if(onRemove != null)
         {
            onRemove(this);
         }
      }
   }
}

