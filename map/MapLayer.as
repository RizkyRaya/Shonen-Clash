package net.play5d.game.bvn.map
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.BlurFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class MapLayer extends Sprite
   {
      
      public var enabled:Boolean = false;
      
      private var _view:DisplayObject;
      
      private var _blurBitmaps:Object = {};
      
      private var _smoothing:Boolean;
      
      private var _currentShow:DisplayObject;
      
      public function MapLayer(param1:DisplayObject)
      {
         super();
         if(!param1)
         {
            return;
         }
         enabled = true;
         initView(param1);
      }
      
      private function initView(param1:DisplayObject) : void
      {
         _view = param1;
         show(_view);
         this.x = param1.x;
         this.y = param1.y;
         param1.x = param1.y = 0;
      }
      
      private function getBlurBitmap(param1:int = 5, param2:int = 0) : Bitmap
      {
         var _loc4_:String = param1 + "|" + param2;
         if(_blurBitmaps[_loc4_])
         {
            return _blurBitmaps[_loc4_];
         }
         var _loc5_:Bitmap = drawBitmap(true,0);
         trace("addBlurBitmap",_loc4_);
         var _loc3_:BlurFilter = new BlurFilter(param1,param2,1);
         _loc5_.bitmapData.applyFilter(_loc5_.bitmapData,_loc5_.bitmapData.rect,new Point(),_loc3_);
         _blurBitmaps[_loc4_] = _loc5_;
         return _loc5_;
      }
      
      public function normalize() : void
      {
         var _loc5_:Sprite = null;
         var _loc4_:int = 0;
         var _loc3_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         var _loc1_:DisplayObject = null;
         if(!_view)
         {
            return;
         }
         if(_view is Bitmap)
         {
            (_view as Bitmap).smoothing = GameData.I.config.quality == "best";
         }
         if(_view is Sprite)
         {
            _loc5_ = _view as Sprite;
            while(_loc4_ < _loc5_.numChildren)
            {
               _loc3_ = _loc5_.getChildAt(_loc4_);
               if(_loc3_ is Bitmap)
               {
                  (_loc3_ as Bitmap).smoothing = GameData.I.config.quality == "best";
               }
               _loc4_++;
            }
            _loc2_ = _loc5_.getChildByName("logo4399");
            _loc1_ = _loc5_.getChildByName("logo_mine");
            trace("logos",_loc2_,_loc1_);
            if(_loc2_)
            {
               _loc2_.visible = false;
            }
            if(_loc1_)
            {
               _loc1_.visible = false;
            }
            switch(GameConfig.MAP_LOGO_STATE - 1)
            {
               case 0:
                  if(_loc2_)
                  {
                     _loc2_.visible = true;
                  }
                  break;
               case 1:
                  if(_loc1_)
                  {
                     _loc1_.visible = true;
                  }
            }
         }
      }
      
      public function renderOptical(param1:Vector.<IGameSprite>) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:DisplayObject = null;
         var _loc5_:int = 0;
         if(!_view)
         {
            return;
         }
         if(_smoothing)
         {
            return;
         }
         var _loc6_:Sprite = _view as Sprite;
         if(!_loc6_)
         {
            return;
         }
         var _loc4_:int = _loc6_.numChildren;
         if(_loc4_ < 1)
         {
            return;
         }
         while(_loc5_ < _loc4_)
         {
            _loc3_ = _loc6_.getChildAt(_loc5_);
            if(_loc3_ is MovieClip != false)
            {
               _loc2_ = _loc3_.getBounds(_loc6_);
               _loc2_.x += _loc6_.x + this.x;
               _loc2_.y += _loc6_.y + this.y;
               _loc3_.alpha = checkHitGameSprite(_loc2_,param1) ? 0.5 : 1;
            }
            _loc5_++;
         }
      }
      
      private function show(param1:DisplayObject) : void
      {
         if(_currentShow == param1)
         {
            return;
         }
         if(_currentShow)
         {
            try
            {
               removeChild(_currentShow);
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         addChild(param1);
         _currentShow = param1;
      }
      
      private function checkHitGameSprite(param1:Rectangle, param2:Vector.<IGameSprite>) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:IGameSprite = null;
         var _loc3_:Boolean = false;
         var _loc6_:Rectangle = null;
         while(_loc5_ < param2.length)
         {
            _loc4_ = param2[_loc5_];
            if(_loc4_)
            {
               _loc6_ = _loc4_.getArea();
               if(_loc6_)
               {
                  _loc3_ = param1.intersects(_loc6_);
                  if(_loc3_)
                  {
                     return true;
                  }
               }
            }
            _loc5_++;
         }
         return false;
      }
      
      private function drawBitmap(param1:Boolean = true, param2:uint = 0) : Bitmap
      {
         var _loc5_:Bitmap = null;
         var _loc3_:Rectangle = null;
         var _loc4_:Matrix = null;
         if(_view)
         {
            _loc5_ = new Bitmap(new BitmapData(_view.width / 2,_view.height / 2,param1,param2));
            _loc3_ = _view.getBounds(_view);
            _loc4_ = new Matrix(1,0,0,1,-_loc3_.x,-_loc3_.y);
            _loc4_.scale(0.5,0.5);
            _loc5_.bitmapData.draw(_view,_loc4_);
            _loc5_.x = _loc3_.x;
            _loc5_.y = _loc3_.y;
            _loc5_.scaleX = _loc5_.scaleY = 2;
            return _loc5_;
         }
         return null;
      }
      
      public function destory() : void
      {
         if(_view is Bitmap)
         {
            (_view as Bitmap).bitmapData.dispose();
         }
      }
      
      public function setSmoothing(param1:Number = 0, param2:Number = 0) : void
      {
         var _loc3_:Bitmap = null;
         if(!_view)
         {
            return;
         }
         try
         {
            if(param1 <= 0 && param2 <= 0)
            {
               show(_view);
               return;
            }
            _loc3_ = getBlurBitmap(param1,param2);
            show(_loc3_);
         }
         catch(e:Error)
         {
            trace("MapLayer.setSmoothing error ::",e);
         }
      }
   }
}

