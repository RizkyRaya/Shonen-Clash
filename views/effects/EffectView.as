package net.play5d.game.bvn.views.effects
{
   import flash.display.Bitmap;
   import flash.geom.Point;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.BitmapDataCacheVO;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.kyo.utils.KyoMath;
   
   public class EffectView
   {
      
      public static const LIFE_ACTIVE:int = 0;
      
      public static const LIFE_IDLE:int = 1;
      
      public static const LIFE_COOLING:int = 2;
      
      public var poolIndex:int = -1;
      
      public var ownerPool:* = null;
      
      public var display:Bitmap;
      
      public var autoRemove:Boolean = true;
      
      public var loopPlay:Boolean = false;
      
      public var holdFrame:int = -1;
      
      public var isActive:Boolean = true;
      
      public var idleFrame:int = 0;
      
      public var lifeState:int = LIFE_ACTIVE;
      
      public var lastUsedFrame:int = 0;
      
      public var reuseCount:int = 0;
      
      protected var _target:IGameSprite;
      
      protected var _data:EffectVO;
      
      private var _onFinish:Function;
      
      private var _onRemoveFuncs:Vector.<Function>;
      
      private var _isDestoryed:Boolean;
      
      private var _bitmapDatas:Vector.<BitmapDataCacheVO>;
      
      private var _frameLabels:Object;
      
      private var _orgX:Number = 0;
      
      private var _orgY:Number = 0;
      
      private var _curFrame:int;
      
      private var _rotation:int;
      
      private var _direct:int;
      
      public function EffectView(param1:EffectVO)
      {
         super();
         _data = param1;
         display = new Bitmap();
         display.blendMode = param1.blendMode;
         display.smoothing = EffectCtrl.EFFECT_SMOOTHING;
         _bitmapDatas = param1.bitmapDataCache;
         _frameLabels = param1.frameLabelCache;
      }
      
      private function resetRuntimeState() : void
      {
         _target = null;
         _rotation = 0;
         _direct = 1;
         _curFrame = 0;
         _orgX = 0;
         _orgY = 0;
         _isDestoryed = false;
         display.rotation = 0;
         display.scaleX = 1;
         display.scaleY = 1;
         display.bitmapData = null;
         display.visible = true;
      }
      
      public function setTarget(param1:IGameSprite) : void
      {
         _target = param1;
      }
      
      public function setPos(param1:Number, param2:Number) : void
      {
         _orgX = param1;
         _orgY = param2;
      }
      
      public function setFinishCallback(func:Function) : void
      {
         _onFinish = func;
      }
      
      public function start(param1:Number = 0, param2:Number = 0, param3:int = 1, param4:Boolean = true) : void
      {
         resetRuntimeState();
         _orgX = param1;
         _orgY = param2;
         _direct = param3;
         display.scaleX = _direct;
         if(_data.randRotate)
         {
            randRotate();
         }
         if(param4 && _data.sound)
         {
            SoundCtrl.I.playEffectSound(_data.sound);
         }
         isActive = true;
         idleFrame = 0;
         lifeState = LIFE_ACTIVE;
         ++reuseCount;
         lastUsedFrame = GameRender.frameCount;
         renderDisplay();
      }
      
      public function destory() : void
      {
         _isDestoryed = true;
         if(isActive)
         {
            removeSelf();
         }
         display = null;
         if(_onRemoveFuncs)
         {
            _onRemoveFuncs.length = 0;
            _onRemoveFuncs = null;
         }
      }
      
      public function gotoAndPlay(param1:Object) : void
      {
         if(param1 is int)
         {
            _curFrame = int(param1);
         }
         else if(param1 is String)
         {
            for(var _loc2_ in _frameLabels)
            {
               if(_frameLabels[_loc2_] == param1)
               {
                  _curFrame = _loc2_;
                  break;
               }
            }
         }
      }
      
      private function randRotate() : void
      {
         _rotation = Math.random() * 360;
         display.rotation = _rotation;
         display.scaleX = 1;
      }
      
      public function render() : void
      {
      }
      
      public function renderAnimate() : void
      {
         if(_isDestoryed)
         {
            return;
         }
         var removed:Boolean = false;
         if(loopPlay)
         {
            if(_curFrame == _bitmapDatas.length - 1)
            {
               _curFrame = 0;
            }
         }
         else if(autoRemove)
         {
            if(_curFrame == _bitmapDatas.length - 1)
            {
               if(holdFrame == -1)
               {
                  removeSelf();
                  removed = true;
               }
               else
               {
                  _curFrame = 0;
               }
            }
            if(holdFrame != -1)
            {
               if(holdFrame-- <= 0)
               {
                  removeSelf();
                  removed = true;
               }
            }
         }
         if(!removed)
         {
            renderFrameLabel();
            renderDisplay();
            ++_curFrame;
         }
      }
      
      private function renderDisplay() : void
      {
         var bmp:BitmapDataCacheVO = _bitmapDatas[_curFrame];
         if(bmp == null)
         {
            display.bitmapData = null;
         }
         else
         {
            display.bitmapData = bmp.bitmapData;
            if(_rotation != 0)
            {
               var rad:Number = KyoMath.asRadians(_rotation);
               var pt:Point = KyoMath.getPointByRadians(new Point(bmp.offsetX,bmp.offsetY),rad);
               display.x = _orgX + pt.x;
               display.y = _orgY + pt.y;
            }
            else
            {
               display.x = _orgX + bmp.offsetX * _direct;
               display.y = _orgY + bmp.offsetY;
            }
         }
      }
      
      private function renderFrameLabel() : void
      {
         var label:String = _frameLabels[_curFrame];
         if(label == "loop")
         {
            gotoAndPlay(1);
         }
      }
      
      public function remove() : void
      {
         removeSelf();
      }
      
      public function addRemoveBack(param1:Function) : void
      {
         if(_onRemoveFuncs == null)
         {
            _onRemoveFuncs = new Vector.<Function>();
         }
         if(_onRemoveFuncs.indexOf(param1) == -1)
         {
            _onRemoveFuncs.push(param1);
         }
      }
      
      private function removeSelf() : void
      {
         isActive = false;
         idleFrame = 0;
         lifeState = LIFE_IDLE;
         lastUsedFrame = GameRender.frameCount;
         display.bitmapData = null;
         display.rotation = 0;
         display.scaleX = 1;
         display.scaleY = 1;
         display.visible = false;
         if(_onRemoveFuncs)
         {
            var len:int = int(_onRemoveFuncs.length);
            var i:int = 0;
            while(i < len)
            {
               _onRemoveFuncs[i](this);
               i++;
            }
         }
         if(display && display.parent)
         {
            display.parent.removeChild(display);
         }
         if(_onFinish != null)
         {
            _onFinish(this);
         }
      }
      
      public function updateLife(frame:int) : void
      {
         if(isActive)
         {
            return;
         }
         var idle:int = frame - lastUsedFrame;
         if(idle > 180)
         {
            lifeState = LIFE_COOLING;
         }
      }
      
      public function canDestroy(frame:int) : Boolean
      {
         if(isActive || lifeState != LIFE_COOLING)
         {
            return false;
         }
         return frame - lastUsedFrame > 350;
      }
   }
}

