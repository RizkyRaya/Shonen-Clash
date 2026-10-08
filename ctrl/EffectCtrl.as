package net.play5d.game.bvn.ctrl
{
   import com.greensock.TweenLite;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.EffectModel;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.state.GameCamera;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.utils.EffectManager;
   import net.play5d.game.bvn.views.effects.BitmapFilterView;
   import net.play5d.game.bvn.views.effects.BlackBackView;
   import net.play5d.game.bvn.views.effects.BuffEffectView;
   import net.play5d.game.bvn.views.effects.EffectView;
   import net.play5d.game.bvn.views.effects.ShadowEffectView;
   import net.play5d.game.bvn.views.effects.ShineEffectView;
   import net.play5d.game.bvn.views.effects.SpecialEffectView;
   
   public class EffectCtrl
   {
      
      private static var _i:EffectCtrl;
      
      public static var EFFECT_SMOOTHING:Boolean = true;
      
      public static var SHADOW_ENABLED:Boolean = false;
      
      public static var SHAKE_ENABLED:Boolean = true;
      
      public static var BG_BULR_ENABLED:Boolean = true;
      
      public static var PERFORMANCE_MODE:Boolean = false;
      
      private static const MAX_EFFECT_LOW:int = 45;
      
      private static const MAX_EFFECT_MEDIUM:int = 50;
      
      private static const MAX_EFFECT_HIGH:int = 55;
      
      private static const MAX_EFFECT_BEST:int = 60;
      
      public var shineMaxCount:int = 3;
      
      public var freezeEnabled:Boolean = false;
      
      public var bgBlurEnabled:Boolean = true;
      
      private var _gameStage:GameState;
      
      private var _effectLayer:Sprite;
      
      private var _manager:EffectManager;
      
      private const SHAKE_POW_MAX:int = 10;
      
      private var _freezeFrame:int = 0;
      
      private var _effects:Vector.<EffectView>;
      
      private var _justRenderAnimateTargets:Vector.<BaseGameSprite>;
      
      private var _justRenderTargets:Vector.<BaseGameSprite>;
      
      private var _shineEffects:Vector.<ShineEffectView>;
      
      private var _shadowEffects:Vector.<ShadowEffectView>;
      
      private var _filterEffects:Vector.<BitmapFilterView> = new Vector.<BitmapFilterView>();
      
      private var _blackBack:BlackBackView;
      
      private var _shakeHoldX:int = 0;
      
      private var _shakeHoldY:int = 0;
      
      private var _shakePowX:int = 0;
      
      private var _shakePowY:int = 0;
      
      private var _shakeXDirect:int = 1;
      
      private var _shakeYDirect:int = 1;
      
      private var _shakeFrameX:int = 0;
      
      private var _shakeFrameY:int = 0;
      
      private var _shakeLoseX:int = 0;
      
      private var _shakeLoseY:int = 0;
      
      private var _renderAnimateGap:int = 0;
      
      private var _renderAnimateFrame:int = 0;
      
      private var _renderAnimate:Boolean = true;
      
      private var _slowDownFrame:int;
      
      private var _blurFrame:int;
      
      private var _replaceSkillFrame:int;
      
      private var _replaceSkillFrameHold:int;
      
      private var _replaceSkillPos:Point;
      
      private var _explodeSkillFrame:int;
      
      private var _explodeEffectPos:Point;
      
      private var _onFreezeOver:Vector.<Function> = null;
      
      private var _hitFocusTarget:IGameSprite;
      
      private var _frameEffectKeys:Vector.<EffectVO>;
      
      private var _frameEffectCounts:Vector.<int>;
      
      private var _removeEnemies:Vector.<Object>;
      
      private var _bishaZoomObj:Object;
      
      private var _introZoomObj:Object;
      
      private var _outroDarkRect:Sprite;
      
      private var _outroWinner:FighterMain;
      
      private var _topLetterbox:Sprite;
      
      private var _bottomLetterbox:Sprite;
      
      private const LETTERBOX_HEIGHT:Number = 75;
      
      public function EffectCtrl()
      {
         super();
      }
      
      public static function get I() : EffectCtrl
      {
         if(!_i)
         {
            _i = new EffectCtrl();
         }
         return _i;
      }
      
      public function destory() : void
      {
         slowDownResume();
         clearCinematicAll();
         _outroWinner = null;
         _freezeFrame = 0;
         _slowDownFrame = 0;
         _blurFrame = 0;
         _replaceSkillFrame = 0;
         _replaceSkillFrameHold = 0;
         _explodeSkillFrame = 0;
         _hitFocusTarget = null;
         if(_effects)
         {
            var i:int = _effects.length - 1;
            while(i >= 0)
            {
               var effect:EffectView = _effects[i];
               if(effect)
               {
                  if(effect.display && effect.display.parent)
                  {
                     effect.display.parent.removeChild(effect.display);
                  }
                  effect.destory();
               }
               i--;
            }
            _effects.length = 0;
            _effects = null;
         }
         if(_shineEffects)
         {
            i = _shineEffects.length - 1;
            while(i >= 0)
            {
               var shine:ShineEffectView = _shineEffects[i];
               if(shine)
               {
                  if(shine.parent)
                  {
                     shine.parent.removeChild(shine);
                  }
                  shine.destory();
               }
               i--;
            }
            _shineEffects.length = 0;
            _shineEffects = null;
         }
         if(_shadowEffects)
         {
            i = _shadowEffects.length - 1;
            while(i >= 0)
            {
               if(_shadowEffects[i])
               {
                  _shadowEffects[i].destory();
               }
               i--;
            }
            _shadowEffects.length = 0;
            _shadowEffects = null;
         }
         if(_filterEffects)
         {
            i = _filterEffects.length - 1;
            while(i >= 0)
            {
               var filter:BitmapFilterView = _filterEffects[i];
               if(filter)
               {
                  filter.destory();
               }
               i--;
            }
            _filterEffects.length = 0;
            _filterEffects = null;
         }
         if(_justRenderTargets)
         {
            _justRenderTargets.length = 0;
            _justRenderTargets = null;
         }
         if(_justRenderAnimateTargets)
         {
            _justRenderAnimateTargets.length = 0;
            _justRenderAnimateTargets = null;
         }
         if(_onFreezeOver)
         {
            _onFreezeOver.length = 0;
            _onFreezeOver = null;
         }
         if(_removeEnemies)
         {
            i = _removeEnemies.length - 1;
            while(i >= 0)
            {
               if(_removeEnemies[i])
               {
                  _removeEnemies[i].fighter = null;
                  _removeEnemies[i].callback = null;
               }
               i--;
            }
            _removeEnemies.length = 0;
            _removeEnemies = null;
         }
         if(_frameEffectKeys)
         {
            _frameEffectKeys.length = 0;
            _frameEffectKeys = null;
            _frameEffectCounts.length = 0;
            _frameEffectCounts = null;
         }
         _replaceSkillPos = null;
         _explodeEffectPos = null;
         if(_blackBack)
         {
            if(_blackBack.parent)
            {
               _blackBack.parent.removeChild(_blackBack);
            }
            _blackBack.destory();
            _blackBack = null;
         }
         if(_manager)
         {
            _manager.destory();
            _manager = null;
         }
         _gameStage = null;
         _effectLayer = null;
         _shakeHoldX = 0;
         _shakeHoldY = 0;
         _shakePowX = 0;
         _shakePowY = 0;
         _shakeFrameX = 0;
         _shakeFrameY = 0;
         _shakeLoseX = 0;
         _shakeLoseY = 0;
      }
      
      public function initlize(param1:GameState, param2:Sprite) : void
      {
         _manager = new EffectManager();
         _gameStage = param1;
         _effectLayer = param2;
         _effects = new Vector.<EffectView>();
         _justRenderAnimateTargets = new Vector.<BaseGameSprite>();
         _justRenderTargets = new Vector.<BaseGameSprite>();
         _shineEffects = new Vector.<ShineEffectView>();
         _shadowEffects = new Vector.<ShadowEffectView>();
         _frameEffectKeys = new Vector.<EffectVO>();
         _frameEffectCounts = new Vector.<int>();
         _removeEnemies = new Vector.<Object>();
         _blackBack = new BlackBackView();
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
         _topLetterbox = new Sprite();
         _topLetterbox.graphics.beginFill(0,1);
         _topLetterbox.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,LETTERBOX_HEIGHT);
         _topLetterbox.graphics.endFill();
         _topLetterbox.y = -LETTERBOX_HEIGHT;
         _bottomLetterbox = new Sprite();
         _bottomLetterbox.graphics.beginFill(0,1);
         _bottomLetterbox.graphics.drawRect(0,0,GameConfig.GAME_SIZE.x,LETTERBOX_HEIGHT);
         _bottomLetterbox.graphics.endFill();
         _bottomLetterbox.y = GameConfig.GAME_SIZE.y;
      }
      
      public function playCinematicIntro(fighter:FighterMain) : void
      {
         var cam:GameCamera;
         if(!_gameStage || !_gameStage.camera)
         {
            return;
         }
         cam = _gameStage.camera;
         showCinematicLetterbox();
         bgBlur(5,0,3000);
         _gameStage.cameraFocusOne(fighter.getDisplay());
         if(_introZoomObj)
         {
            TweenLite.killTweensOf(_introZoomObj);
         }
         _introZoomObj = {"val":cam.getZoom()};
         TweenLite.to(_introZoomObj,0.5,{
            "val":7.5,
            "onUpdate":function():void
            {
               cam.setZoom(_introZoomObj.val);
               cam.updateNow();
            }
         });
      }
      
      public function finishCinematicIntro() : void
      {
         var cam:GameCamera;
         if(!_gameStage || !_gameStage.camera)
         {
            return;
         }
         cam = _gameStage.camera;
         hideCinematicLetterbox();
         cancelBgBlur();
         if(_introZoomObj)
         {
            TweenLite.killTweensOf(_introZoomObj);
         }
         _introZoomObj = {"val":cam.getZoom()};
         TweenLite.to(_introZoomObj,0.6,{
            "val":2.5,
            "onUpdate":function():void
            {
               cam.setZoom(_introZoomObj.val);
               cam.updateNow();
            },
            "onComplete":function():void
            {
               if(_gameStage)
               {
                  _gameStage.cameraResume();
               }
            }
         });
      }
      
      public function clearCinematicAll() : void
      {
         if(_introZoomObj)
         {
            TweenLite.killTweensOf(_introZoomObj);
         }
         if(_bishaZoomObj)
         {
            TweenLite.killTweensOf(_bishaZoomObj);
            if(_bishaZoomObj.isMap1 && _gameStage && _gameStage.camera && _gameStage.camera.hasOwnProperty("offsetY"))
            {
               _gameStage.camera["offsetY"] = _bishaZoomObj.origOffsetY;
            }
            _bishaZoomObj = null;
         }
         TweenLite.killDelayedCallsTo(showOutroCinematic);
         if(_topLetterbox)
         {
            TweenLite.killTweensOf(_topLetterbox);
            _topLetterbox.y = -LETTERBOX_HEIGHT;
            if(_topLetterbox.parent)
            {
               _topLetterbox.parent.removeChild(_topLetterbox);
            }
         }
         if(_bottomLetterbox)
         {
            TweenLite.killTweensOf(_bottomLetterbox);
            _bottomLetterbox.y = GameConfig.GAME_SIZE.y;
            if(_bottomLetterbox.parent)
            {
               _bottomLetterbox.parent.removeChild(_bottomLetterbox);
            }
         }
         if(_outroDarkRect)
         {
            TweenLite.killTweensOf(_outroDarkRect);
            if(_outroDarkRect.parent)
            {
               _outroDarkRect.parent.removeChild(_outroDarkRect);
            }
            _outroDarkRect = null;
         }
         cancelBgBlur();
         clearImpactFrame();
         if(_gameStage && _gameStage.camera)
         {
            _gameStage.camera.setZoom(1);
            _gameStage.camera.updateNow();
            _gameStage.cameraResume();
         }
      }
      
      public function playCinematicOutro(winner:FighterMain) : void
      {
         if(!_gameStage || !_gameStage.camera)
         {
            return;
         }
         slowDown(0.1,5000);
         showImpactFrame();
         _outroWinner = winner;
         TweenLite.killDelayedCallsTo(showOutroCinematic);
         showOutroCinematic();
      }
      
      private function showOutroCinematic() : void
      {
         var cam:GameCamera;
         if(!_gameStage || !_gameStage.camera || !_outroWinner)
         {
            return;
         }
         cam = _gameStage.camera;
         showCinematicLetterbox();
         bgBlur(6,0,5000);
         _gameStage.cameraFocusOne(_outroWinner.getDisplay());
         if(_introZoomObj)
         {
            TweenLite.killTweensOf(_introZoomObj);
         }
         _introZoomObj = {"val":cam.getZoom()};
         TweenLite.to(_introZoomObj,0.8,{
            "val":7.5,
            "onUpdate":function():void
            {
               cam.setZoom(_introZoomObj.val);
               cam.updateNow();
            }
         });
         if(_outroDarkRect && _outroDarkRect.parent)
         {
            _outroDarkRect.parent.removeChild(_outroDarkRect);
         }
         _outroDarkRect = new Sprite();
         _outroDarkRect.graphics.beginFill(0,0.45);
         _outroDarkRect.graphics.drawRect(0,-200,GameConfig.GAME_SIZE.x + 500,GameConfig.GAME_SIZE.y + 500);
         _outroDarkRect.graphics.endFill();
         _outroDarkRect.alpha = 0;
         _effectLayer.addChild(_outroDarkRect);
         TweenLite.to(_outroDarkRect,0.5,{"alpha":1});
      }
      
      private function showImpactFrame() : void
      {
         if(!_gameStage)
         {
            return;
         }
         var mangaMatrix:Array = [0.4,0.6,0.2,0,-20,0.4,0.6,0.2,0,-20,0.4,0.6,0.2,0,-20,0,0,0,1,0];
         var mangaFilter:ColorMatrixFilter = new ColorMatrixFilter(mangaMatrix);
         _gameStage.filters = [mangaFilter];
         TweenLite.killDelayedCallsTo(clearImpactFrame);
         TweenLite.delayedCall(0.15,clearImpactFrame);
      }
      
      private function clearImpactFrame() : void
      {
         if(_gameStage)
         {
            _gameStage.filters = [];
         }
      }
      
      private function showCinematicLetterbox() : void
      {
         if(!_gameStage)
         {
            return;
         }
         _gameStage.addChild(_topLetterbox);
         _gameStage.addChild(_bottomLetterbox);
         TweenLite.to(_topLetterbox,0.25,{"y":0});
         TweenLite.to(_bottomLetterbox,0.25,{"y":GameConfig.GAME_SIZE.y - LETTERBOX_HEIGHT});
      }
      
      private function hideCinematicLetterbox() : void
      {
         TweenLite.to(_topLetterbox,0.25,{
            "y":-LETTERBOX_HEIGHT,
            "onComplete":removeLetterboxTop
         });
         TweenLite.to(_bottomLetterbox,0.25,{
            "y":GameConfig.GAME_SIZE.y,
            "onComplete":removeLetterboxBottom
         });
      }
      
      private function removeLetterboxTop() : void
      {
         if(_topLetterbox && _topLetterbox.parent)
         {
            _topLetterbox.parent.removeChild(_topLetterbox);
         }
      }
      
      private function removeLetterboxBottom() : void
      {
         if(_bottomLetterbox && _bottomLetterbox.parent)
         {
            _bottomLetterbox.parent.removeChild(_bottomLetterbox);
         }
      }
      
      private function showEpicShockwave(targetX:Number, targetY:Number) : void
      {
         var flashRect:Sprite;
         var ringCore:Sprite;
         var ringOuter:Sprite;
         var ringDistortion:Sprite;
         if(!_gameStage)
         {
            return;
         }
         showImpactFrame();
         flashRect = new Sprite();
         flashRect.graphics.beginFill(16777215,1);
         flashRect.graphics.drawRect(0,-200,GameConfig.GAME_SIZE.x + 500,GameConfig.GAME_SIZE.y + 500);
         flashRect.graphics.endFill();
         flashRect.alpha = 0.85;
         _gameStage.addChild(flashRect);
         TweenLite.to(flashRect,0.35,{
            "alpha":0,
            "onComplete":function():void
            {
               if(flashRect.parent)
               {
                  flashRect.parent.removeChild(flashRect);
               }
            }
         });
         shake(12,12,400);
         ringCore = createRing(16777215,12,65535,0.7,40);
         ringOuter = createRing(16777215,3,49151,0,40);
         ringDistortion = createRing(0,6,0,0,40);
         ringCore.x = ringOuter.x = ringDistortion.x = targetX;
         ringCore.y = ringOuter.y = ringDistortion.y = targetY - 40;
         ringCore.blendMode = BlendMode.ADD;
         ringOuter.blendMode = BlendMode.ADD;
         _effectLayer.addChild(ringDistortion);
         _effectLayer.addChild(ringOuter);
         _effectLayer.addChild(ringCore);
         ringCore.scaleX = ringCore.scaleY = 0.1;
         TweenLite.to(ringCore,0.25,{
            "scaleX":8,
            "scaleY":8,
            "alpha":0,
            "onComplete":function():void
            {
               if(ringCore.parent)
               {
                  ringCore.parent.removeChild(ringCore);
               }
            }
         });
         ringOuter.scaleX = ringOuter.scaleY = 0.5;
         TweenLite.to(ringOuter,0.5,{
            "scaleX":25,
            "scaleY":25,
            "alpha":0,
            "onComplete":function():void
            {
               if(ringOuter.parent)
               {
                  ringOuter.parent.removeChild(ringOuter);
               }
            }
         });
         ringDistortion.scaleX = ringDistortion.scaleY = 0.2;
         TweenLite.to(ringDistortion,0.4,{
            "scaleX":15,
            "scaleY":15,
            "alpha":0,
            "onComplete":function():void
            {
               if(ringDistortion.parent)
               {
                  ringDistortion.parent.removeChild(ringDistortion);
               }
            }
         });
      }
      
      private function createRing(lineColor:uint, lineThick:Number, fillColor:uint, fillAlpha:Number, radius:Number) : Sprite
      {
         var sp:Sprite = new Sprite();
         sp.graphics.lineStyle(lineThick,lineColor,1);
         if(fillAlpha > 0)
         {
            sp.graphics.beginFill(fillColor,fillAlpha);
         }
         sp.graphics.drawCircle(0,0,radius);
         if(fillAlpha > 0)
         {
            sp.graphics.endFill();
         }
         return sp;
      }
      
      public function render() : void
      {
         renderSlowDown();
         if(!AdaptiveEngine.I.isHeavy)
         {
            renderShine();
         }
         _frameEffectKeys.length = 0;
         _frameEffectCounts.length = 0;
         var len:int = int(_effects.length);
         var i:int = 0;
         while(i < len)
         {
            _effects[i].render();
            i++;
         }
         if(isRenderAnimate())
         {
            renderAnimate();
         }
         if(_replaceSkillFrameHold > 0)
         {
            renderReplaceSkill();
         }
         if(_explodeSkillFrame > 0)
         {
            renderEnergyExplode();
         }
         var targetLen:int = int(_justRenderTargets.length);
         if(targetLen > 0)
         {
            i = 0;
            while(i < targetLen)
            {
               var target:BaseGameSprite = _justRenderTargets[i];
               target.render();
               GameLogic.fixGameSpritePosition(target);
               i++;
            }
         }
      }
      
      private function renderShine() : void
      {
         var len:int = int(_shineEffects.length);
         var i:int = 0;
         while(i < len)
         {
            _shineEffects[i].render();
            i++;
         }
      }
      
      private function renderAnimate() : void
      {
         var i:int = _effects.length - 1;
         while(i >= 0)
         {
            var effect:EffectView = _effects[i];
            effect.renderAnimate();
            i--;
         }
         if(!AdaptiveEngine.I.isHeavy)
         {
            var shadowLen:int = int(_shadowEffects.length);
            var s:int = 0;
            while(s < shadowLen)
            {
               if(_shadowEffects[s])
               {
                  _shadowEffects[s].render();
               }
               s++;
            }
         }
         var animLen:int = int(_justRenderAnimateTargets.length);
         if(animLen > 0)
         {
            i = 0;
            while(i < animLen)
            {
               _justRenderAnimateTargets[i].renderAnimate();
               i++;
            }
         }
         if(_blackBack)
         {
            _blackBack.renderAnimate();
         }
         if(!AdaptiveEngine.I.isHeavy)
         {
            renderShakeX();
            renderShakeY();
         }
         renderRemoveEnemy();
         renderBgBlur();
      }
      
      private function isRenderAnimate() : Boolean
      {
         if(_renderAnimateGap > 0)
         {
            if(_renderAnimateFrame++ >= _renderAnimateGap)
            {
               _renderAnimateFrame = 0;
               return true;
            }
            return false;
         }
         return true;
      }
      
      private function renderFreeze() : void
      {
         if(_freezeFrame > 0)
         {
            _freezeFrame -= 1;
            if(_freezeFrame <= 0)
            {
               if(_onFreezeOver)
               {
                  var len:int = int(_onFreezeOver.length);
                  var i:int = 0;
                  while(i < len)
                  {
                     _onFreezeOver[i]();
                     i++;
                  }
                  _onFreezeOver = null;
               }
               if(_hitFocusTarget)
               {
                  _hitFocusTarget = null;
                  GameCtrl.I.gameState.cameraResume();
               }
               GameCtrl.I.resume();
            }
         }
      }
      
      private function renderShakeX() : void
      {
         var _loc1_:Number = _shakeHoldX + _shakePowX;
         if(_loc1_ > 0)
         {
            _gameStage.x = _loc1_ * _shakeXDirect;
            if(_shakePowX > 0 && _shakeFrameX % 2 == 0)
            {
               _shakePowX -= _shakeLoseX;
               if(_shakePowX < _shakeLoseX)
               {
                  _shakePowX = 0;
                  _gameStage.x = 0;
                  _shakeFrameX = 0;
                  _shakeLoseX = 0;
                  return;
               }
            }
            _shakeFrameX += 1;
            _shakeXDirect *= -1;
         }
      }
      
      private function renderShakeY() : void
      {
         var _loc1_:Number = _shakeHoldY + _shakePowY;
         if(_loc1_ > 0)
         {
            _gameStage.y = _loc1_ * _shakeYDirect;
            if(_shakePowY > 0 && _shakeFrameY % 2 == 0)
            {
               _shakePowY -= _shakeLoseY;
               if(_shakePowY < _shakeLoseY)
               {
                  _shakePowY = 0;
                  _gameStage.y = 0;
                  _shakeFrameY = 0;
                  _shakeLoseY = 0;
                  return;
               }
            }
            _shakeYDirect *= -1;
            _shakeFrameY += 1;
         }
      }
      
      public function doHitEffect(param1:HitVO, param2:Rectangle, param3:IGameSprite = null) : void
      {
         var _loc6_:EffectVO = _manager.getHitEffectVOByHitVO(param1,param3);
         if(!_loc6_)
         {
            return;
         }
         var _loc4_:Number = param2.x + param2.width / 2;
         var _loc5_:Number = param2.y + param2.height / 2;
         var _loc7_:int = 1;
         if(_loc6_.followDirect && param1.owner && param1.owner is IGameSprite)
         {
            _loc7_ = (param1.owner as IGameSprite).direct;
         }
         var isDynamicCamEnabled:Boolean = true;
         if(GameData.I && GameData.I.config)
         {
            isDynamicCamEnabled = GameData.I.config.dynamicCamera;
         }
         if(param1.slowDown > 0)
         {
            slowDown(1.5,param1.slowDown * 1000);
            if(isDynamicCamEnabled)
            {
               showImpactFrame();
            }
         }
         if(param1.focusTarget)
         {
            _hitFocusTarget = param3;
            GameCtrl.I.gameState.cameraFocusOne(param3.getDisplay());
         }
         else if(_hitFocusTarget && _hitFocusTarget == param3)
         {
            _hitFocusTarget = null;
         }
         doEffectVO(_loc6_,_loc4_,_loc5_,_loc7_,param3);
      }
      
      public function doDefenseEffect(param1:HitVO, param2:Rectangle, param3:int, param4:IGameSprite = null) : void
      {
         var _loc7_:EffectVO = _manager.getDefenseEffectVOByHitVO(param1,param3,param4);
         if(!_loc7_)
         {
            return;
         }
         var _loc5_:Number = param2.x + param2.width / 2;
         var _loc6_:Number = param2.y + param2.height / 2;
         if(_loc7_.shake)
         {
            if(_loc7_.shake.pow != undefined && _loc7_.shake.pow != 0)
            {
               _loc7_.shake.x = 0;
               _loc7_.shake.y = _loc7_.shake.pow;
            }
         }
         var _loc8_:int = 1;
         if(_loc7_.followDirect && param1.owner && param1.owner is IGameSprite)
         {
            _loc8_ = (param1.owner as IGameSprite).direct;
         }
         doEffectVO(_loc7_,_loc5_,_loc6_,_loc8_,param4);
      }
      
      public function doSteelHitEffect(param1:HitVO, param2:Rectangle, param3:IGameSprite) : void
      {
         var _loc6_:EffectVO = null;
         switch(param1.hitType)
         {
            case 0:
               return;
            case 1:
            case 6:
               _loc6_ = EffectModel.I.getEffect("steel_hit_kan");
               break;
            case 2:
            case 3:
               _loc6_ = EffectModel.I.getEffect("steel_hit_qdj");
               break;
            default:
               _loc6_ = EffectModel.I.getEffect("steel_hit_mfdj");
         }
         if(!_loc6_)
         {
            return;
         }
         var _loc4_:Number = param2.x + param2.width / 2;
         var _loc5_:Number = param2.y + param2.height / 2;
         var _loc7_:int = 1;
         if(_loc6_.followDirect && param1.owner && param1.owner is IGameSprite)
         {
            _loc7_ = (param1.owner as IGameSprite).direct;
         }
         doEffectVO(_loc6_,_loc4_,_loc5_,_loc7_,param3);
      }
      
      public function doEffectById(param1:String, param2:Number, param3:Number, param4:int = 1, param5:IGameSprite = null, param6:Boolean = true) : void
      {
         var _loc7_:EffectVO = EffectModel.I.getEffect(param1);
         if(_loc7_)
         {
            doEffectVO(_loc7_,param2,param3,param4,param5,param6);
         }
      }
      
      public function assisterEffect(param1:Assister) : void
      {
         var _loc2_:Boolean = param1.data.comicType == 1;
         if(_loc2_)
         {
            doEffectById("fz_naruto",param1.x,param1.y);
         }
         else
         {
            doEffectById("fz_bleach",param1.x,param1.y);
         }
      }
      
      public function doEffectVO(param1:EffectVO, param2:Number, param3:Number, param4:int = 1, param5:IGameSprite = null, param6:Boolean = true) : void
      {
         var _loc14_:Number = Number(NaN);
         var _loc11_:Number = Number(NaN);
         var _loc12_:Number = Number(NaN);
         var _loc7_:* = 0;
         var _loc13_:Number = Number(NaN);
         var _loc10_:Number = Number(NaN);
         var _loc8_:int = 0;
         var effectIndex:int = _frameEffectKeys.indexOf(param1);
         if(effectIndex == -1)
         {
            _frameEffectKeys.push(param1);
            _frameEffectCounts.push(1);
         }
         else if(++_frameEffectCounts[effectIndex] > 3)
         {
            return;
         }
         var _loc9_:EffectView = addEffect(param1,param2,param3,param4,param6);
         if(_loc9_)
         {
            _effectLayer.addChild(_loc9_.display);
         }
         if(param1.freeze > 0)
         {
            freeze(param1.freeze);
         }
         if(param1.shake)
         {
            _loc14_ = Number(param1.shake.time != undefined ? param1.shake.time : 0);
            _loc11_ = Number(param1.shake.x != undefined ? param1.shake.x : 0);
            _loc12_ = Number(param1.shake.y != undefined ? param1.shake.y : 0);
            shake(_loc11_,_loc12_,_loc14_);
         }
         if(param1.shine)
         {
            _loc7_ = uint(param1.shine.color != undefined ? param1.shine.color : 16777215);
            _loc13_ = Number(param1.shine.alpha != undefined ? param1.shine.alpha : 0.2);
            shine(_loc7_,_loc13_);
         }
         if(param1.slowDown)
         {
            _loc10_ = Number(param1.slowDown.rate != undefined ? param1.slowDown.rate : 1.5);
            _loc8_ = int(param1.slowDown.time != undefined ? param1.slowDown.time : 1000);
            slowDown(_loc10_,_loc8_);
         }
         if(param5 && _loc9_)
         {
            _loc9_.setTarget(param5);
         }
         if(param1.specialEffectId && param5 && param5 is FighterMain)
         {
            doSpecialEffect(param1.specialEffectId,param5 as FighterMain);
         }
      }
      
      public function doSpecialEffect(param1:String, param2:FighterMain) : void
      {
         var _loc3_:EffectVO = EffectModel.I.getEffect(param1);
         var _loc4_:SpecialEffectView = addEffect(_loc3_,param2.x,param2.y,param2.direct) as SpecialEffectView;
         if(_loc4_)
         {
            _loc4_.setTarget(param2);
            _effectLayer.addChild(_loc4_.display);
         }
      }
      
      public function doBuffEffect(param1:String, param2:FighterMain, param3:FighterBuffVO) : void
      {
         var _loc4_:EffectVO = EffectModel.I.getEffect(param1);
         var _loc5_:BuffEffectView = addEffect(_loc4_,param2.x,param2.y,param2.direct) as BuffEffectView;
         if(_loc5_)
         {
            _loc5_.setTarget(param2);
            _loc5_.setBuff(param3);
            _effectLayer.addChild(_loc5_.display);
         }
      }
      
      private function addEffect(param1:EffectVO, param2:Number, param3:Number, param4:int = 1, param5:Boolean = true) : EffectView
      {
         if(PERFORMANCE_MODE)
         {
            return null;
         }
         switch(GameData.I.config.quality)
         {
            case "low":
               var maxEffect:int = MAX_EFFECT_LOW;
               break;
            case "medium":
               maxEffect = MAX_EFFECT_MEDIUM;
               break;
            case "high":
               maxEffect = MAX_EFFECT_HIGH;
               break;
            default:
               maxEffect = MAX_EFFECT_BEST;
         }
         maxEffect = AdaptiveEngine.I.getEffectBudget(maxEffect);
         if(_effects.length >= maxEffect)
         {
            return null;
         }
         if(!AdaptiveEngine.I.canSpawnEffect())
         {
            return null;
         }
         AdaptiveEngine.I.notifySpawn();
         var effect:EffectView = _manager.getEffectView(param1);
         if(!effect)
         {
            return null;
         }
         effect.start(param2,param3,param4,param5);
         effect.setFinishCallback(removeEffect);
         effect.addRemoveBack(removeEffect);
         _effects.push(effect);
         return effect;
      }
      
      private function removeEffect(effect:EffectView) : void
      {
         var index:int = _effects.indexOf(effect);
         if(index >= 0)
         {
            _effects.splice(index,1);
         }
         if(_manager)
         {
            _manager.releaseEffect(effect);
         }
      }
      
      public function freeze(param1:int) : void
      {
      }
      
      private function justRender(param1:BaseGameSprite) : void
      {
         if(_justRenderTargets.indexOf(param1) == -1)
         {
            _justRenderTargets.push(param1);
         }
      }
      
      private function justRenderAnimate(param1:BaseGameSprite) : void
      {
         if(_justRenderAnimateTargets.indexOf(param1) == -1)
         {
            _justRenderAnimateTargets.push(param1);
         }
      }
      
      private function cancelJustRender(param1:BaseGameSprite) : Boolean
      {
         var _loc2_:int = _justRenderTargets.indexOf(param1);
         if(_loc2_ != -1)
         {
            _justRenderTargets.splice(_loc2_,1);
         }
         return _justRenderTargets.length < 1;
      }
      
      private function cancelJustRenderAnimate(param1:BaseGameSprite) : Boolean
      {
         var _loc2_:int = _justRenderAnimateTargets.indexOf(param1);
         if(_loc2_ != -1)
         {
            _justRenderAnimateTargets.splice(_loc2_,1);
         }
         return _justRenderAnimateTargets.length < 1;
      }
      
      public function shine(param1:uint = 16777215, param2:Number = 0.2) : void
      {
         if(GameConfig.FPS_SHINE_EFFECT == 0 || AdaptiveEngine.I.isHeavy)
         {
            return;
         }
         if(_shineEffects.length > shineMaxCount)
         {
            _shineEffects[0].removeSelf();
         }
         var _loc3_:ShineEffectView = _manager.getShine();
         _loc3_.init(param1,param2);
         _loc3_.onRemove = removeShine;
         _shineEffects.push(_loc3_);
         _gameStage.addChild(_loc3_);
      }
      
      private function removeShine(param1:ShineEffectView) : void
      {
         var _loc2_:int = _shineEffects.indexOf(param1);
         if(_loc2_ != -1)
         {
            _shineEffects.splice(_loc2_,1);
         }
      }
      
      public function startShake(param1:Number, param2:Number) : void
      {
         _shakeHoldX = param1;
         _shakeHoldY = param2;
      }
      
      public function endShake() : void
      {
         _shakeHoldX = 0;
         _shakeHoldY = 0;
         if(_gameStage)
         {
            _gameStage.x = 0;
            _gameStage.y = 0;
         }
      }
      
      public function shake(param1:Number = 0, param2:Number = 3, param3:int = 500) : void
      {
         if(!SHAKE_ENABLED || isNaN(param1) || isNaN(param2) || AdaptiveEngine.I.isHeavy)
         {
            return;
         }
         if(Math.abs(_shakePowX) > Math.abs(param1) || Math.abs(_shakePowY) > Math.abs(param2))
         {
            return;
         }
         if(param1 != 0)
         {
            if(_shakePowX == 0)
            {
               _shakeXDirect = param1 > 0 ? 1 : -1;
               _shakePowX = Math.abs(param1);
            }
            else
            {
               _shakePowX += Math.abs(param1) / 2;
            }
            if(_shakePowX > 10)
            {
               _shakePowX = 10;
            }
         }
         if(param2 != 0)
         {
            if(_shakePowY == 0)
            {
               _shakeYDirect = param2 > 0 ? 1 : -1;
               _shakePowY = Math.abs(param2);
            }
            else
            {
               _shakePowY += Math.abs(param2) / 2;
            }
            if(_shakePowY > 10)
            {
               _shakePowY = 10;
            }
         }
         if(param3 <= 0)
         {
            param3 = 500;
         }
         _shakeLoseX = Math.ceil(_shakePowX / (param3 / 1000 * 30));
         _shakeLoseY = Math.ceil(_shakePowY / (param3 / 1000 * 30));
         if(_shakeLoseX < 1)
         {
            _shakeLoseX = 1;
         }
         if(_shakeLoseY < 1)
         {
            _shakeLoseY = 1;
         }
      }
      
      public function startShadow(param1:DisplayObject, param2:int = 0, param3:int = 0, param4:int = 0) : void
      {
         if(!SHADOW_ENABLED || !_shadowEffects || AdaptiveEngine.I.isHeavy || AdaptiveEngine.I.isMedium)
         {
            return;
         }
         var _loc5_:ShadowEffectView = null;
         var len:int = int(_shadowEffects.length);
         var i:int = 0;
         while(i < len)
         {
            if(_shadowEffects[i].target == param1)
            {
               _loc5_ = _shadowEffects[i];
               break;
            }
            i++;
         }
         if(_loc5_)
         {
            _loc5_.r = param2;
            _loc5_.g = param3;
            _loc5_.b = param4;
            _loc5_.stopShadow = false;
            return;
         }
         _loc5_ = new ShadowEffectView(param1,param2,param3,param4);
         _loc5_.onRemove = removeShadow;
         _loc5_.container = _effectLayer;
         _shadowEffects.push(_loc5_);
      }
      
      public function endShadow(param1:DisplayObject) : void
      {
         if(!SHADOW_ENABLED || !_shadowEffects)
         {
            return;
         }
         var len:int = int(_shadowEffects.length);
         var i:int = 0;
         while(i < len)
         {
            if(_shadowEffects[i].target == param1)
            {
               _shadowEffects[i].stopShadow = true;
               break;
            }
            i++;
         }
      }
      
      private function removeShadow(param1:ShadowEffectView) : void
      {
         if(!_shadowEffects)
         {
            return;
         }
         var index:int = _shadowEffects.indexOf(param1);
         if(index != -1)
         {
            _shadowEffects.splice(index,1);
         }
      }
      
      public function bisha(param1:BaseGameSprite, param2:Boolean = false, param3:DisplayObject = null) : void
      {
         var isFighter:Boolean;
         var isMainFighter:Boolean;
         var isDynamicCamEnabled:Boolean;
         var isExcluded:Boolean;
         var fighter:FighterMain;
         var fighterId:String;
         var cam:GameCamera;
         var targetZoom:Number;
         var currentZoom:Number;
         var p1Main:*;
         var p2Main:*;
         var isMap1:Boolean;
         var origOffset:Number;
         justRenderAnimate(param1);
         GameCtrl.I.pause();
         GameCtrl.I.setRenderHit(false);
         _gameStage.addChildAt(_blackBack,0);
         _blackBack.fadIn();
         isFighter = param1 is FighterMain;
         isDynamicCamEnabled = true;
         if(GameData.I && GameData.I.config)
         {
            isDynamicCamEnabled = GameData.I.config.dynamicCamera;
         }
         if(isDynamicCamEnabled)
         {
            showCinematicLetterbox();
            showEpicShockwave(param1.x,param1.y);
         }
         if(param3 && isFighter)
         {
            showFace(param1 as FighterMain,param3);
         }
         isMainFighter = false;
         if(GameCtrl.I && GameCtrl.I.gameRunData)
         {
            p1Main = GameCtrl.I.gameRunData.p1FighterGroup ? GameCtrl.I.gameRunData.p1FighterGroup.currentFighter : null;
            p2Main = GameCtrl.I.gameRunData.p2FighterGroup ? GameCtrl.I.gameRunData.p2FighterGroup.currentFighter : null;
            if(param1 == p1Main || param1 == p2Main)
            {
               isMainFighter = true;
            }
         }
         isExcluded = false;
         if(isMainFighter)
         {
            fighter = param1 as FighterMain;
            if(fighter && fighter.data && fighter.data.id)
            {
               fighterId = fighter.data.id.toLowerCase();
               if(fighterId.indexOf("gogeta") != -1)
               {
                  isExcluded = true;
               }
            }
         }
         if(isDynamicCamEnabled && !isExcluded && GameCtrl.I.gameState && GameCtrl.I.gameState.camera)
         {
            cam = GameCtrl.I.gameState.camera;
            GameCtrl.I.gameState.cameraFocusOne(param1.getDisplay());
            isMap1 = false;
            if(GameCtrl.I && GameCtrl.I.gameRunData && GameCtrl.I.gameRunData.map && GameCtrl.I.gameRunData.map.id == "map_1")
            {
               isMap1 = true;
            }
            else if(_gameStage && _gameStage.getMap() && _gameStage.getMap().data && _gameStage.getMap().data.id == "map_1")
            {
               isMap1 = true;
            }
            if(isMainFighter)
            {
               targetZoom = param2 ? 10 : 8;
            }
            else
            {
               targetZoom = param2 ? 5.5 : 4.5;
            }
            currentZoom = cam.getZoom();
            origOffset = 0;
            if(cam.hasOwnProperty("offsetY"))
            {
               origOffset = Number(cam["offsetY"]);
            }
            if(_bishaZoomObj)
            {
               TweenLite.killTweensOf(_bishaZoomObj);
            }
            _bishaZoomObj = {
               "val":currentZoom,
               "origOffsetY":origOffset,
               "isMap1":isMap1
            };
            TweenLite.to(_bishaZoomObj,0.5,{
               "val":targetZoom,
               "onUpdate":function():void
               {
                  cam.setZoom(_bishaZoomObj.val);
                  if(_bishaZoomObj.isMap1 && cam.hasOwnProperty("offsetY"))
                  {
                     cam["offsetY"] = 35;
                  }
                  cam.updateNow();
               }
            });
         }
         if(param2)
         {
            doEffectById("bisha_super",param1.x,param1.y - 50);
         }
         else
         {
            doEffectById("bisha",param1.x,param1.y - 50);
         }
      }
      
      public function endBisha(param1:BaseGameSprite) : void
      {
         if(cancelJustRenderAnimate(param1))
         {
            if(_bishaZoomObj)
            {
               TweenLite.killTweensOf(_bishaZoomObj);
               if(_bishaZoomObj.isMap1 && GameCtrl.I.gameState && GameCtrl.I.gameState.camera && GameCtrl.I.gameState.camera.hasOwnProperty("offsetY"))
               {
                  GameCtrl.I.gameState.camera["offsetY"] = _bishaZoomObj.origOffsetY;
               }
               _bishaZoomObj = null;
            }
            var isDynamicCamEnabled:Boolean = true;
            if(GameData.I && GameData.I.config)
            {
               isDynamicCamEnabled = GameData.I.config.dynamicCamera;
            }
            if(isDynamicCamEnabled)
            {
               hideCinematicLetterbox();
            }
            GameCtrl.I.resume();
            GameCtrl.I.gameState.cameraResume();
            GameCtrl.I.setRenderHit(true);
            _blackBack.fadOut();
            _gameStage.getMap().setVisible(true);
         }
      }
      
      private function showFace(param1:FighterMain, param2:DisplayObject) : void
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:int = 1;
         var _loc5_:IGameSprite = param1.getCurrentTarget();
         if(_loc5_)
         {
            _loc3_ = _loc5_.getDisplay();
            if(_loc3_)
            {
               _loc4_ = param1.getDisplay().x > _loc3_.x ? 2 : 1;
            }
         }
         _blackBack.showBishaFace(_loc4_,param2);
      }
      
      public function wanKai(param1:FighterMain, param2:DisplayObject = null) : void
      {
         justRenderAnimate(param1);
         GameCtrl.I.pause();
         GameCtrl.I.setRenderHit(false);
         _gameStage.addChildAt(_blackBack,0);
         _blackBack.fadIn();
         var isDynamicCamEnabled:Boolean = true;
         if(GameData.I && GameData.I.config)
         {
            isDynamicCamEnabled = GameData.I.config.dynamicCamera;
         }
         if(isDynamicCamEnabled)
         {
            showCinematicLetterbox();
            showEpicShockwave(param1.x,param1.y);
         }
         if(param2)
         {
            showFace(param1,param2);
         }
         GameCtrl.I.gameState.cameraFocusOne(param1.getDisplay());
         doEffectById("bisha_super",param1.x,param1.y - 50);
         _gameStage.getMap().setVisible(false);
      }
      
      public function endWanKai(param1:FighterMain) : void
      {
         if(cancelJustRenderAnimate(param1))
         {
            var isDynamicCamEnabled:Boolean = true;
            if(GameData.I && GameData.I.config)
            {
               isDynamicCamEnabled = GameData.I.config.dynamicCamera;
            }
            if(isDynamicCamEnabled)
            {
               hideCinematicLetterbox();
            }
            GameCtrl.I.resume();
            GameCtrl.I.gameState.cameraResume();
            _blackBack.fadOut();
            GameCtrl.I.setRenderHit(true);
            _gameStage.getMap().setVisible(true);
         }
      }
      
      public function jumpEffect(param1:Number, param2:Number) : void
      {
         doEffectById("jump",param1,param2);
      }
      
      public function jumpAirEffect(param1:Number, param2:Number) : void
      {
         doEffectById("jump_air",param1,param2);
      }
      
      public function touchFloorEffect(param1:Number, param2:Number) : void
      {
         doEffectById("touch_floor",param1,param2);
      }
      
      public function hitFloorEffect(param1:int, param2:Number, param3:Number) : void
      {
         switch(param1)
         {
            case 0:
               doEffectById("hit_floor",param2,param3);
               break;
            case 1:
               doEffectById("hit_floor_low",param2,param3);
               break;
            case 2:
               doEffectById("hit_floor_heavy",param2,param3);
               doEffectById("hit_floor_yan",param2,param3);
         }
      }
      
      public function slowDown(param1:Number, param2:int = 1000) : void
      {
         if(GameCtrl.I.slowRate > param1)
         {
            return;
         }
         GameCtrl.I.slow(param1);
         bgBlur(param1 * 2,0,250);
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / (30 / param1)) - 1;
         if(param2 == 0)
         {
            _slowDownFrame = 0;
         }
         else
         {
            _slowDownFrame = param2 / 1000 * GameConfig.FPS_GAME;
         }
      }
      
      public function bgBlur(param1:Number, param2:Number, param3:int = 1000) : void
      {
         if(!BG_BULR_ENABLED || !bgBlurEnabled || !_gameStage || AdaptiveEngine.I.isHeavy)
         {
            return;
         }
         if(_gameStage.getMap().getSmoothing().x > param1 || _gameStage.getMap().getSmoothing().y > 0)
         {
            return;
         }
         _gameStage.getMap().setSmoothing(param1,param2);
         _blurFrame = param3 / 1000 * 30;
      }
      
      public function cancelBgBlur() : void
      {
         _blurFrame = 0;
         if(_gameStage && _gameStage.getMap())
         {
            _gameStage.getMap().setSmoothing(0,0);
         }
      }
      
      private function renderBgBlur() : void
      {
         if(_blurFrame > 0)
         {
            if(--_blurFrame <= 0)
            {
               cancelBgBlur();
            }
         }
      }
      
      private function renderSlowDown() : void
      {
         if(_slowDownFrame > 0)
         {
            _slowDownFrame -= 1;
            if(_slowDownFrame <= 0)
            {
               slowDownResume();
            }
         }
      }
      
      public function slowDownResume() : void
      {
         GameCtrl.I.slowResume();
         _renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
         _slowDownFrame = 0;
      }
      
      public function BGEffect(param1:String, param2:Number = -1) : void
      {
         var effect:EffectView;
         var id:String = param1;
         var hold:Number = param2;
         var data:EffectVO = EffectModel.I.getEffect(id);
         if(!data)
         {
            return;
         }
         effect = addEffect(data,0,0,1);
         if(hold != -1)
         {
            effect.holdFrame = hold * 30;
         }
         if(effect)
         {
            effect.addRemoveBack(function():void
            {
               _gameStage.getMap().setVisible(true);
            });
            _gameStage.getMap().setVisible(false);
            _gameStage.addChildAt(effect.display,0);
         }
      }
      
      private function onBGEffectRemove(effect:EffectView) : void
      {
         if(_gameStage && _gameStage.getMap())
         {
            _gameStage.getMap().setVisible(true);
         }
      }
      
      public function setOnFreezeOver(param1:Function) : void
      {
         if(!_onFreezeOver)
         {
            _onFreezeOver = new Vector.<Function>();
         }
         _onFreezeOver.push(param1);
      }
      
      public function replaceSkill(param1:BaseGameSprite) : void
      {
         GameCtrl.I.pause();
         _gameStage.addChildAt(_blackBack,0);
         _gameStage.getMap().setVisible(false);
         doEffectById("replaceSp",param1.x,param1.y);
         _replaceSkillPos = new Point(param1.x,param1.y);
         _replaceSkillFrame = 0;
         _replaceSkillFrameHold = GameConfig.FPS_GAME;
      }
      
      private function endReplaceSkill() : void
      {
         GameCtrl.I.resume();
         _blackBack.fadOut();
         _gameStage.getMap().setVisible(true);
         _replaceSkillFrameHold = 0;
      }
      
      private function renderReplaceSkill() : void
      {
         _replaceSkillFrame += 1;
         if(_replaceSkillFrame == 1)
         {
            doEffectById("replaceSp2",_replaceSkillPos.x,_replaceSkillPos.y);
         }
         if(_replaceSkillFrame > _replaceSkillFrameHold)
         {
            endReplaceSkill();
         }
      }
      
      public function energyExplode(param1:BaseGameSprite) : void
      {
         GameCtrl.I.pause();
         _gameStage.addChildAt(_blackBack,0);
         _gameStage.getMap().setVisible(false);
         doEffectById("explodeSp",param1.x,param1.y);
         _explodeEffectPos = new Point(param1.x,param1.y);
         _explodeSkillFrame = 0.7 * GameConfig.FPS_GAME;
      }
      
      private function endEnergyExplode() : void
      {
         doEffectById("explodeSp2",_explodeEffectPos.x,_explodeEffectPos.y);
         GameCtrl.I.resume();
         _blackBack.fadOut();
         _gameStage.getMap().setVisible(true);
         _explodeSkillFrame = 0;
      }
      
      private function renderEnergyExplode() : void
      {
         _explodeSkillFrame -= 1;
         if(_explodeSkillFrame <= 0)
         {
            endEnergyExplode();
         }
      }
      
      public function ghostStep(param1:BaseGameSprite) : void
      {
         justRender(param1);
         justRenderAnimate(param1);
         GameCtrl.I.pause();
         _gameStage.addChildAt(_blackBack,0);
         _blackBack.fadIn();
         _gameStage.getMap().setVisible(false);
         SoundCtrl.I.playSwcSound(snd_ghost_jump);
      }
      
      public function endGhostStep(param1:BaseGameSprite) : void
      {
         var _loc3_:Boolean = cancelJustRender(param1);
         var _loc2_:Boolean = cancelJustRenderAnimate(param1);
         if(_loc3_ && _loc2_)
         {
            GameCtrl.I.resume();
            _blackBack.fadOut();
            _gameStage.getMap().setVisible(true);
         }
      }
      
      public function startFilter(param1:BaseGameSprite, param2:BitmapFilter, param3:Point = null) : void
      {
      }
      
      public function endFilter(param1:BaseGameSprite) : void
      {
      }
      
      private function renderRemoveEnemy() : void
      {
         var i:int = _removeEnemies.length - 1;
         while(i >= 0)
         {
            var enemyObj:Object = _removeEnemies[i];
            if(enemyObj)
            {
               var fighter:FighterMain = enemyObj.fighter;
               var callback:Function = enemyObj.callback;
               if(!fighter || !fighter.getDisplay())
               {
                  _removeEnemies.splice(i,1);
               }
               else if(fighter.getDisplay().alpha > 0)
               {
                  fighter.getDisplay().alpha = fighter.getDisplay().alpha - 0.05;
               }
               else
               {
                  if(callback != null)
                  {
                     callback();
                  }
                  enemyObj.fighter = null;
                  enemyObj.callback = null;
                  _removeEnemies.splice(i,1);
               }
            }
            else
            {
               _removeEnemies.splice(i,1);
            }
            i--;
         }
      }
      
      public function enemyBirthEffect(param1:FighterMain) : void
      {
         param1.getDisplay().alpha = 1;
         if(param1.data.comicType == 0)
         {
            EffectCtrl.I.doEffectById("fz_bleach",param1.x,param1.y,param1.direct,null,false);
         }
         else
         {
            EffectCtrl.I.doEffectById("fz_naruto",param1.x,param1.y,param1.direct,null,false);
         }
      }
      
      public function removeEnemyEffect(param1:FighterMain, param2:Function = null) : void
      {
         _removeEnemies.push({
            "fighter":param1,
            "callback":param2
         });
      }
   }
}

