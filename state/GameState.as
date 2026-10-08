package net.play5d.game.bvn.state
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.GameLogic;
   import net.play5d.game.bvn.ctrl.ShadowCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.mob.AssetLoader;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.kyo.stage.Istage;
   
   public class GameState extends Sprite implements Istage
   {
      
      private var _gameLayer:Sprite = new Sprite();
      
      private var _playerLayer:Sprite = new Sprite();
      
      private var _gameSprites:Vector.<IGameSprite> = new Vector.<IGameSprite>();
      
      private var _map:MapMain;
      
      private var _shadowLayer:Sprite = new Sprite();
      
      public var camera:GameCamera;
      
      private var _cameraFocus:Array;
      
      public var gameUI:GameUI;
      
      private var _isDynamicZooming:Boolean = false;
      
      private var _zoomedFighter:FighterMain = null;
      
      public function GameState()
      {
         super();
         _gameLayer.mouseChildren = false;
         _gameLayer.mouseEnabled = false;
         _shadowLayer.mouseChildren = false;
         _shadowLayer.mouseEnabled = false;
         _playerLayer.mouseChildren = false;
         _playerLayer.mouseEnabled = false;
      }
      
      public function get gameLayer() : Sprite
      {
         return _gameLayer;
      }
      
      public function getMap() : MapMain
      {
         return _map;
      }
      
      public function setVisibleByClass(param1:Class, param2:Boolean) : void
      {
         for each(var sprite in _gameSprites)
         {
            if(sprite is param1)
            {
               sprite.getDisplay().visible = param2;
            }
         }
      }
      
      public function getFighterByData(param1:FighterVO) : FighterMain
      {
         for each(var sprite in _gameSprites)
         {
            if(sprite is FighterMain && (sprite as FighterMain).data == param1)
            {
               return sprite as FighterMain;
            }
         }
         return null;
      }
      
      public function get display() : DisplayObject
      {
         return this;
      }
      
      public function getGameSpriteGlobalPosition(param1:IGameSprite, param2:Number = 0, param3:Number = 0) : Point
      {
         var zoom:Number = camera.getZoom(true);
         var screenRect:Rectangle = camera.getScreenRect(true);
         return new Point((-screenRect.x + param1.x + param2) * zoom,(-screenRect.y + param1.y + param3) * zoom);
      }
      
      public function getGameSprites() : Vector.<IGameSprite>
      {
         return _gameSprites;
      }
      
      public function addGameSprite(param1:IGameSprite) : void
      {
         param1.setActive(true);
         if(_gameSprites.indexOf(param1) != -1)
         {
            return;
         }
         _gameSprites.push(param1);
         _playerLayer.addChild(param1.getDisplay());
         ShadowCtrl.register(param1);
         param1.setVolume(GameData.I.config.soundVolume);
      }
      
      public function addGameSpriteAt(param1:IGameSprite, param2:int) : void
      {
         param1.setActive(true);
         if(_gameSprites.indexOf(param1) != -1)
         {
            return;
         }
         _gameSprites.push(param1);
         _playerLayer.addChildAt(param1.getDisplay(),param2);
         ShadowCtrl.register(param1);
         param1.setVolume(GameData.I.config.soundVolume);
      }
      
      public function removeGameSprite(param1:IGameSprite, param2:Boolean = false) : void
      {
         var index:int;
         if(param2)
         {
            param1.destory(true);
         }
         else
         {
            param1.setActive(false);
         }
         index = int(_gameSprites.indexOf(param1));
         if(index == -1)
         {
            return;
         }
         _gameSprites.splice(index,1);
         try
         {
            ShadowCtrl.unregister(param1);
            if(param1.getDisplay() && param1.getDisplay().parent)
            {
               param1.getDisplay().parent.removeChild(param1.getDisplay());
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function build() : void
      {
         GameCtrl.I.initlize(this);
         EffectCtrl.I.initlize(this,_playerLayer);
         ShadowCtrl.init(_shadowLayer);
         gameUI = new GameUI();
         GameEvent.dispatchEvent("FIGHT_START");
      }
      
      public function initFight(param1:GameRunFighterGroup, param2:GameRunFighterGroup, param3:MapMain) : void
      {
         _map = param3;
         _map.gameState = this;
         if(_map.bgLayer)
         {
            addChild(_map.bgLayer);
         }
         addChild(_gameLayer);
         if(_map.mapLayer)
         {
            _gameLayer.addChild(_map.mapLayer);
         }
         _gameLayer.addChild(_shadowLayer);
         _gameLayer.addChild(_playerLayer);
         if(_map.frontFixLayer)
         {
            _gameLayer.addChild(_map.frontFixLayer);
         }
         if(_map.frontLayer)
         {
            _gameLayer.addChild(_map.frontLayer);
         }
         _cameraFocus = [];
         var p1:FighterMain = param1.currentFighter;
         var p2:FighterMain = param2.currentFighter;
         var nextP1:FighterMain = null;
         var nextP2:FighterMain = null;
         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            nextP2 = param2.nextFighter2;
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            nextP1 = param1.nextFighter1;
            nextP2 = param2.nextFighter2;
         }
         if(p1)
         {
            GameLogic.resetFighterHP(p1);
            p1.x = _map.p1pos.x + 40;
            p1.y = _map.p1pos.y;
            p1.direct = 1;
            p1.updatePosition();
            _cameraFocus.push(p1.getDisplay());
         }
         if(p2)
         {
            GameLogic.resetFighterHP(p2);
            if(GameMode.isAcrade())
            {
               GameLogic.setMessionEnemyAttack(p2);
            }
            p2.x = _map.p2pos.x;
            p2.y = _map.p2pos.y;
            p2.direct = -1;
            p2.updatePosition();
            _cameraFocus.push(p2.getDisplay());
         }
         if(nextP1)
         {
            GameLogic.resetFighterHP(nextP1);
            nextP1.x = _map.p1pos.x;
            nextP1.y = _map.p1pos.y;
            nextP1.direct = -1;
            nextP1.idle();
            nextP1.updatePosition();
         }
         if(nextP2)
         {
            GameLogic.resetFighterHP(nextP2);
            nextP2.x = _map.p2pos.x + 40;
            nextP2.y = _map.p2pos.y;
            nextP2.direct = 1;
            nextP2.updatePosition();
         }
         if(_map.mapLayer)
         {
            initCamera();
            camera.focus(_cameraFocus);
            gameUI.initFight(param1,param2);
            addChild(gameUI.getUIDisplay());
            return;
         }
         throw new Error("map is error! :: mapLayer is null!");
      }
      
      public function resetFight(param1:GameRunFighterGroup, param2:GameRunFighterGroup) : void
      {
         var p1:FighterMain = param1.currentFighter;
         var p2:FighterMain = param2.currentFighter;
         var nextP1:FighterMain = null;
         var nextP2:FighterMain = null;
         _cameraFocus = [];
         if(GameMode.currentMode == 24 || GameMode.currentMode == 25)
         {
            nextP2 = param2.nextFighter2;
         }
         if(GameMode.currentMode == 14 || GameMode.currentMode == 15)
         {
            nextP1 = param1.nextFighter1;
            nextP2 = param2.nextFighter2;
         }
         if(p1)
         {
            GameLogic.resetFighterHP(p1);
            p1.x = _map.p1pos.x + 40;
            p1.y = _map.p1pos.y;
            p1.direct = 1;
            p1.idle();
            p1.updatePosition();
            _cameraFocus.push(p1.getDisplay());
         }
         if(p2)
         {
            GameLogic.resetFighterHP(p2);
            if(GameMode.isAcrade())
            {
               GameLogic.setMessionEnemyAttack(p2);
            }
            p2.x = _map.p2pos.x;
            p2.y = _map.p2pos.y;
            p2.direct = -1;
            p2.idle();
            p2.updatePosition();
            _cameraFocus.push(p2.getDisplay());
         }
         if(nextP1)
         {
            GameLogic.resetFighterHP(nextP1);
            nextP1.x = _map.p1pos.x;
            nextP1.y = _map.p1pos.y;
            nextP1.direct = -1;
            nextP1.idle();
            nextP1.updatePosition();
         }
         if(nextP2)
         {
            GameLogic.resetFighterHP(nextP2);
            nextP2.x = _map.p2pos.x + 40;
            nextP2.y = _map.p2pos.y;
            nextP2.direct = -1;
            nextP2.idle();
            nextP2.updatePosition();
         }
         gameUI.initFight(param1,param2);
         cameraResume();
      }
      
      public function cameraFocusOne(param1:DisplayObject) : void
      {
         camera.focus([param1]);
         camera.setZoom(3.5);
         camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
      }
      
      public function updateCameraFocus(param1:Array) : void
      {
         _cameraFocus = param1;
         camera.focus(param1);
         camera.setZoom(2);
         camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
      }
      
      public function cameraResume() : void
      {
         camera.focus(_cameraFocus);
         if(_cameraFocus.length < 2)
         {
            camera.setZoom(2);
         }
         camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
      }
      
      private function initCamera() : void
      {
         if(camera)
         {
            throw new Error("camera inited!");
         }
         var stageSize:Point = _map.getStageSize();
         camera = new GameCamera(_gameLayer,GameConfig.GAME_SIZE,stageSize,true);
         camera.focusX = true;
         camera.focusY = true;
         camera.offsetY = _map.getMapBottomDistance();
         camera.setStageBounds(new Rectangle(0,-1000,stageSize.x,stageSize.y));
         camera.autoZoom = true;
         camera.autoZoomMin = int(1 / GameData.I.config.cameraZoomRate * 100) / 100;
         camera.autoZoomMax = GameData.I.config.cameraDistance;
         camera.tweenSpd = 2.5 / GameConfig.SPEED_PLUS_DEFAULT;
         var zoomVal:Number = 2;
         var camX:Number = stageSize.x / 2 * zoomVal - 360;
         var camY:Number = _map.bottom - 200;
         camera.setZoom(zoomVal);
         camera.setX(-camX);
         camera.setY(-camY);
         camera.updateNow();
      }
      
      public function render() : void
      {
         checkWallKnockbackCamera();
         if(camera)
         {
            camera.render();
         }
         if(gameUI)
         {
            gameUI.render();
         }
         if(_map && camera)
         {
            var screenRect:Rectangle = camera.getScreenRect(true);
            _map.render(-screenRect.x,-screenRect.y,camera.getZoom(true));
         }
      }
      
      private function checkWallKnockbackCamera() : void
      {
         if(!_cameraFocus || _cameraFocus.length == 0 || !_map)
         {
            return;
         }
         var isDynamicCamEnabled:Boolean = GameData.I && GameData.I.config ? GameData.I.config.dynamicCamera : true;
         if(!isDynamicCamEnabled)
         {
            if(_isDynamicZooming)
            {
               cameraResume();
               _isDynamicZooming = false;
               _zoomedFighter = null;
            }
            return;
         }
         if(!_isDynamicZooming)
         {
            for each(var sprite in _gameSprites)
            {
               var fighter:FighterMain = sprite as FighterMain;
               if(fighter && fighter.isAlive && fighter.actionState == 22)
               {
                  if(_cameraFocus.indexOf(fighter.getDisplay()) != -1)
                  {
                     cameraFocusOne(fighter.getDisplay());
                     _isDynamicZooming = true;
                     _zoomedFighter = fighter;
                     break;
                  }
               }
            }
         }
         else if(_zoomedFighter)
         {
            if(!_zoomedFighter.isAlive || _zoomedFighter.actionState != 22)
            {
               cameraResume();
               _isDynamicZooming = false;
               _zoomedFighter = null;
            }
         }
      }
      
      public function drawGameRect(param1:Rectangle, param2:uint = 16711680, param3:Number = 0.5, param4:Boolean = false) : void
      {
         if(param4)
         {
            _gameLayer.graphics.clear();
         }
         _gameLayer.graphics.beginFill(param2,param3);
         _gameLayer.graphics.drawRect(param1.x,param1.y,param1.width,param1.height);
         _gameLayer.graphics.endFill();
      }
      
      public function clearDrawGameRect() : void
      {
         _gameLayer.graphics.clear();
      }
      
      public function afterBuild() : void
      {
      }
      
      public function destory(param1:Function = null) : void
      {
         var gs:IGameSprite;
         if(_gameSprites)
         {
            while(_gameSprites.length > 0)
            {
               gs = _gameSprites.pop();
               try
               {
                  if(gs)
                  {
                     gs.destory(true);
                  }
               }
               catch(e:Error)
               {
               }
               try
               {
                  if(gs && gs.getDisplay() && gs.getDisplay().parent)
                  {
                     gs.getDisplay().parent.removeChild(gs.getDisplay());
                  }
               }
               catch(e:Error)
               {
               }
            }
            _gameSprites.length = 0;
            _gameSprites = null;
         }
         if(gameUI)
         {
            try
            {
               gameUI.destory();
            }
            catch(e:Error)
            {
            }
            gameUI = null;
         }
         camera = null;
         _cameraFocus = null;
         try
         {
            EffectCtrl.I.destory();
         }
         catch(e:Error)
         {
         }
         try
         {
            ShadowCtrl.clear();
            GameCtrl.I.destory();
            AssetLoader.clearCache();
         }
         catch(e:Error)
         {
         }
         if(_map)
         {
            try
            {
               _map.destory();
            }
            catch(e:Error)
            {
            }
            _map.gameState = null;
            _map = null;
         }
         if(_playerLayer)
         {
            try
            {
               while(_playerLayer.numChildren > 0)
               {
                  _playerLayer.removeChildAt(0);
               }
            }
            catch(e:Error)
            {
            }
            _playerLayer = null;
         }
         if(_gameLayer)
         {
            try
            {
               _gameLayer.graphics.clear();
               while(_gameLayer.numChildren > 0)
               {
                  _gameLayer.removeChildAt(0);
               }
            }
            catch(e:Error)
            {
            }
            _gameLayer = null;
         }
         try
         {
            graphics.clear();
            while(numChildren > 0)
            {
               removeChildAt(0);
            }
         }
         catch(e:Error)
         {
         }
         if(param1 != null)
         {
            try
            {
               param1();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function initMosouFight(param1:GameRunFighterGroup, param2:MapMain) : void
      {
         _map = param2;
         _map.gameState = this;
         if(_map.bgLayer)
         {
            addChild(_map.bgLayer);
         }
         addChild(_gameLayer);
         if(_map.mapLayer)
         {
            _gameLayer.addChild(_map.mapLayer);
         }
         _gameLayer.addChild(_shadowLayer);
         _gameLayer.addChild(_playerLayer);
         if(_map.frontFixLayer)
         {
            _gameLayer.addChild(_map.frontFixLayer);
         }
         if(_map.frontLayer)
         {
            _gameLayer.addChild(_map.frontLayer);
         }
         _cameraFocus = [];
         var p1:FighterMain = param1.currentFighter;
         if(p1)
         {
            p1.x = _map.p1pos.x;
            p1.y = _map.p1pos.y;
            p1.direct = 1;
            p1.updatePosition();
            _cameraFocus.push(p1.getDisplay());
         }
         if(_map.mapLayer)
         {
            initCamera();
            camera.focus(_cameraFocus);
            gameUI.initMission(param1);
            addChild(gameUI.getUIDisplay());
            return;
         }
         throw new Error("map is error! :: mapLayer is null!");
      }
   }
}

