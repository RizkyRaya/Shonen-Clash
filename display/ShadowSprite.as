package net.play5d.game.bvn.display
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class ShadowSprite extends Bitmap
   {
      
      private static var _drawMatrix:Matrix = new Matrix();
      
      private static var _colorTransform:ColorTransform = new ColorTransform(0,0,0,1,0,0,0,0);
      
      private var _bmd:BitmapData;
      
      public var boundsX:Number = 0;
      
      public var boundsY:Number = 0;
      
      public var res:Number = 0.35;
      
      public function ShadowSprite()
      {
         super(null,"auto",false);
      }
      
      public function updateShape(source:DisplayObject) : void
      {
         if(!source)
         {
            return;
         }
         var bounds:Rectangle = source.getBounds(source);
         if(bounds.width <= 1 || bounds.height <= 1)
         {
            return;
         }
         var w:int = Math.ceil(bounds.width * res);
         var h:int = Math.ceil(bounds.height * res);
         if(w <= 0 || h <= 0)
         {
            return;
         }
         boundsX = bounds.x;
         boundsY = bounds.y;
         if(!_bmd || _bmd.width < w || _bmd.height < h)
         {
            if(_bmd)
            {
               _bmd.dispose();
            }
            _bmd = new BitmapData(w + 50,h + 50,true,0);
            this.bitmapData = _bmd;
         }
         else
         {
            _bmd.fillRect(_bmd.rect,0);
         }
         _drawMatrix.identity();
         _drawMatrix.translate(-bounds.x,-bounds.y);
         _drawMatrix.scale(res,res);
         _bmd.draw(source,_drawMatrix,_colorTransform,null,null,false);
      }
      
      public function reset() : void
      {
         visible = true;
         alpha = 0.5;
         x = 0;
         y = 0;
         if(_bmd)
         {
            _bmd.fillRect(_bmd.rect,0);
         }
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(_bmd)
         {
            _bmd.dispose();
            _bmd = null;
         }
         this.bitmapData = null;
      }
   }
}

