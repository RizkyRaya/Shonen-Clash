package net.play5d.game.bvn.ctrl
{
   import flash.display.DisplayObjectContainer;
   import flash.geom.Matrix;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.display.ShadowData;
   import net.play5d.game.bvn.display.ShadowSprite;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class ShadowCtrl
   {
      
      private static var _layer:DisplayObjectContainer;
      
      private static const SCALE_RATE:Number = 0.0012;
      
      private static const ALPHA_RATE:Number = 0.0015;
      
      private static const MIN_SCALE:Number = 0.45;
      
      private static const MIN_ALPHA:Number = 0.05;
      
      private static const GROUND_ALPHA:Number = 0.55;
      
      private static const SHAPE_SKIP_FRAME:int = 6;
      
      private static var _datas:Vector.<ShadowData> = new Vector.<ShadowData>();
      
      private static var _shadowPool:Vector.<ShadowSprite> = new Vector.<ShadowSprite>();
      
      private static var _dataPool:Vector.<ShadowData> = new Vector.<ShadowData>();
      
      private static var _frame:int = 0;
      
      private static var _lastEnabledState:Boolean = true;
      
      private static var _helperMatrix:Matrix = new Matrix();
      
      public function ShadowCtrl()
      {
         super();
      }
      
      public static function init(layer:DisplayObjectContainer) : void
      {
         _layer = layer;
      }
      
      public static function register(sprite:IGameSprite) : void
      {
         if(!_layer)
         {
            return;
         }
         var fighter:FighterMain = sprite as FighterMain;
         if(!fighter)
         {
            return;
         }
         unregister(sprite);
         var data:ShadowData = _dataPool.length > 0 ? _dataPool.pop() : new ShadowData();
         var shadow:ShadowSprite = _shadowPool.length > 0 ? _shadowPool.pop() : new ShadowSprite();
         shadow.reset();
         data.owner = fighter;
         data.shadow = shadow;
         data.groundY = fighter.y;
         _layer.addChildAt(shadow,0);
         _datas.push(data);
      }
      
      public static function unregister(sprite:IGameSprite) : void
      {
         var fighter:FighterMain = sprite as FighterMain;
         if(!fighter)
         {
            return;
         }
         var len:int = int(_datas.length);
         var i:int = len - 1;
         while(i >= 0)
         {
            var data:ShadowData = _datas[i];
            if(data.owner == fighter)
            {
               recycleData(data);
               _datas.splice(i,1);
               break;
            }
            i--;
         }
      }
      
      public static function update() : void
      {
         var enabled:Boolean = GameConfig.SHADOW_ENABLED;
         if(!enabled)
         {
            if(_lastEnabledState)
            {
               hideAllShadows();
               _lastEnabledState = false;
            }
            return;
         }
         _lastEnabledState = true;
         ++_frame;
         var needShapeUpdate:Boolean = false;
         if(_frame >= SHAPE_SKIP_FRAME)
         {
            needShapeUpdate = true;
            _frame = 0;
         }
         var len:int = int(_datas.length);
         var i:int = len - 1;
         while(i >= 0)
         {
            updateShadow(_datas[i],needShapeUpdate);
            i--;
         }
      }
      
      private static function updateShadow(data:ShadowData, needShapeUpdate:Boolean = true) : void
      {
         if(!data)
         {
            return;
         }
         var fighter:FighterMain = data.owner;
         var shadow:ShadowSprite = data.shadow;
         if(!fighter || !shadow)
         {
            return;
         }
         if(!fighter.isAlive || !fighter.getActive())
         {
            shadow.visible = false;
            return;
         }
         shadow.visible = true;
         if(fighter.isTouchBottom)
         {
            data.groundY = fighter.y;
         }
         if(needShapeUpdate && fighter.getBodySpriteOnly())
         {
            shadow.updateShape(fighter.getBodySpriteOnly());
         }
         var scaleMod:Number = 1;
         var alphaMod:Number = GROUND_ALPHA;
         if(fighter.isInAir)
         {
            var airHeight:Number = data.groundY - fighter.y;
            if(airHeight < 0)
            {
               airHeight = 0;
            }
            scaleMod = 1 - airHeight * SCALE_RATE;
            if(scaleMod < MIN_SCALE)
            {
               scaleMod = MIN_SCALE;
            }
            alphaMod = GROUND_ALPHA - airHeight * ALPHA_RATE;
            if(alphaMod < MIN_ALPHA)
            {
               alphaMod = MIN_ALPHA;
            }
         }
         var mat:Matrix = _helperMatrix;
         mat.identity();
         mat.translate(shadow.boundsX * shadow.res,shadow.boundsY * shadow.res);
         mat.scale(1 / shadow.res,1 / shadow.res);
         mat.scale(fighter.direct * scaleMod,0.35 * scaleMod);
         mat.c = -0.5;
         mat.translate(fighter.x + 12,data.groundY);
         shadow.transform.matrix = mat;
         shadow.alpha = alphaMod;
      }
      
      public static function getShadow(sprite:IGameSprite) : ShadowSprite
      {
         var fighter:FighterMain = sprite as FighterMain;
         if(!fighter)
         {
            return null;
         }
         var len:int = int(_datas.length);
         var i:int = 0;
         while(i < len)
         {
            if(_datas[i].owner == fighter)
            {
               return _datas[i].shadow;
            }
            i++;
         }
         return null;
      }
      
      private static function hideAllShadows() : void
      {
         var len:int = int(_datas.length);
         var i:int = 0;
         while(i < len)
         {
            if(_datas[i] && _datas[i].shadow)
            {
               _datas[i].shadow.visible = false;
            }
            i++;
         }
      }
      
      private static function recycleData(data:ShadowData) : void
      {
         if(!data)
         {
            return;
         }
         if(data.shadow)
         {
            data.shadow.visible = false;
            if(data.shadow.parent)
            {
               data.shadow.parent.removeChild(data.shadow);
            }
            _shadowPool.push(data.shadow);
         }
         data.reset();
         _dataPool.push(data);
      }
      
      public static function updateTargetShadow(fighter:FighterMain) : void
      {
         if(!GameConfig.SHADOW_ENABLED)
         {
            return;
         }
         var len:int = int(_datas.length);
         var i:int = 0;
         while(i < len)
         {
            if(_datas[i].owner == fighter)
            {
               updateShadow(_datas[i],true);
               return;
            }
            i++;
         }
      }
      
      public static function clear() : void
      {
         var len:int = int(_datas.length);
         var i:int = len - 1;
         while(i >= 0)
         {
            recycleData(_datas[i]);
            i--;
         }
         _datas.length = 0;
         _shadowPool.length = 0;
         _dataPool.length = 0;
         _frame = 0;
      }
   }
}

