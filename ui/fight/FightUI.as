package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   import net.play5d.game.bvn.ui.ContinueBtn;
   import net.play5d.game.bvn.ui.IGameUI;
   import net.play5d.game.bvn.ui.PauseDialog;
   import net.play5d.game.bvn.utils.ResUtils;
   
   public class FightUI implements IGameUI
   {
      
      public static var QI_BAR_MODE:int;
      
      public var ui:ui_fight;
      
      private var _fightbar:FightBar;
      
      private var _qibar1:QiBar;
      
      private var _qibar2:QiBar;
      
      private var _hits1:HitsUI;
      
      private var _hits2:HitsUI;
      
      private var _endParam:Object;
      
      private var _renderEnd:Boolean;
      
      private var _playOver:Boolean;
      
      private var _showWinnerDelay:int;
      
      private var _drawGame:Boolean;
      
      private var _isSlowDown:Boolean;
      
      private var _pauseDialog:PauseDialog;
      
      private var _flyTimer:Number = 0;
      
      private var _p1PosUI:player_pos_p1;
      
      private var _p2PosUI:player_pos_p2;
      
      private var _isUiHidden:Boolean = false;
      
      private var _isPaused:Boolean = false;
      
      private var _isBgmTriggered:Boolean = false;
      
      private var _bloodOverlay:Shape;
      
      private var _targetMasterVolume:Number = 1;
      
      private var _currentMasterVolume:Number = 1;
      
      private var _p1FighterCache:FighterMain;
      
      private var _p2FighterCache:FighterMain;
      
      private var _globalSoundTransform:SoundTransform = new SoundTransform(1);
      
      public function FightUI()
      {
         super();
         ui = ResUtils.I.createDisplayObject(ResUtils.I.fight,"ui_fight");
         if(ui.fzqi2 && ui.fzqi1)
         {
            ui.fzqi2.x = 1066 - ui.fzqi1.x;
         }
         ui.scaleX = GameConfig.GAME_SIZE.x / 1066;
         ui.scaleY = GameConfig.GAME_SIZE.y / 600;
         _fightbar = new FightBar(ui.hpbarmc);
         _qibar1 = new QiBar(ui.fzqi1);
         _qibar2 = new QiBar(ui.fzqi2);
         _hits1 = new HitsUI(ui.hits1);
         _hits2 = new HitsUI(ui.hits2);
         _qibar2.setDirect(-1);
         _p1PosUI = ResUtils.I.createDisplayObject(ResUtils.I.fight,"player_pos_p1");
         _p2PosUI = ResUtils.I.createDisplayObject(ResUtils.I.fight,"player_pos_p2");
         _p1PosUI.visible = false;
         _p2PosUI.visible = false;
         ui.addChild(_p1PosUI);
         ui.addChild(_p2PosUI);
         _bloodOverlay = new Shape();
         _bloodOverlay.graphics.beginFill(16711680,1);
         _bloodOverlay.graphics.drawRect(0,0,1066,600);
         _bloodOverlay.graphics.endFill();
         _bloodOverlay.alpha = 0;
         _bloodOverlay.visible = false;
         ui.addChildAt(_bloodOverlay,0);
         if(GameMode.isAcrade())
         {
            _fightbar.initScore();
            GameEvent.addEventListener("SCORE_UPDATE",updateScore);
         }
      }
      
      public function initlize(param1:GameRunFighterGroup, param2:GameRunFighterGroup) : void
      {
         _fightbar.setFighter(param1,param2);
         _qibar1.setFighter(param1.currentFighter,param1.currentAssister);
         _qibar2.setFighter(param2.currentFighter,param2.currentAssister);
         updateScore(null);
      }
      
      public function setVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = ui.soundTransform;
         _loc2_.volume = param1;
         ui.soundTransform = _loc2_;
      }
      
      public function showWins(param1:FighterMain, param2:int) : void
      {
         _fightbar.showWin(param1,param2);
      }
      
      private function updateScore(param1:GameEvent) : void
      {
         _fightbar.setScore(GameData.I.score);
      }
      
      public function destory() : void
      {
         GameEvent.removeEventListener("SCORE_UPDATE",updateScore);
         SoundMixer.soundTransform = new SoundTransform(1);
         _currentMasterVolume = 1;
         _targetMasterVolume = 1;
         if(_bloodOverlay)
         {
            _bloodOverlay.graphics.clear();
            if(_bloodOverlay.parent)
            {
               _bloodOverlay.parent.removeChild(_bloodOverlay);
            }
            _bloodOverlay = null;
         }
         if(_pauseDialog)
         {
            _pauseDialog.destory();
            _pauseDialog = null;
         }
         if(_fightbar)
         {
            _fightbar.destory();
            _fightbar = null;
         }
         if(_qibar1)
         {
            _qibar1.destory();
            _qibar1 = null;
         }
         if(_qibar2)
         {
            _qibar2.destory();
            _qibar2 = null;
         }
         if(_hits1)
         {
            _hits1.destory();
            _hits1 = null;
         }
         if(_hits2)
         {
            _hits2.destory();
            _hits2 = null;
         }
         if(ui)
         {
            try
            {
               ui.removeChildren();
               ui.stopAllMovieClips();
            }
            catch(e:Error)
            {
               trace(e);
            }
            ui = null;
         }
         _p1FighterCache = null;
         _p2FighterCache = null;
         _globalSoundTransform = null;
      }
      
      public function getUI() : DisplayObject
      {
         return ui;
      }
      
      public function render() : void
      {
         _fightbar.render();
         _qibar1.render();
         _qibar2.render();
         if(!GameCtrl.I || !GameCtrl.I.gameState || !GameCtrl.I.gameRunData)
         {
            return;
         }
         var _loc1_:Number = GameCtrl.I.gameState.camera.getZoom();
         renderPlayerPosUI(_loc1_);
         if(_renderEnd)
         {
            renderEnd();
         }
         checkLowHpBGM();
         checkRestoreUI();
         checkBloodFilter();
      }
      
      private function checkBloodFilter() : void
      {
         if(_isPaused || _playOver || _renderEnd || !_bloodOverlay)
         {
            if(_bloodOverlay && _bloodOverlay.visible)
            {
               _bloodOverlay.visible = false;
            }
            if(_currentMasterVolume < 1)
            {
               _currentMasterVolume = 1;
               if(_globalSoundTransform)
               {
                  _globalSoundTransform.volume = 1;
                  SoundMixer.soundTransform = _globalSoundTransform;
               }
            }
            return;
         }
         if(!GameCtrl.I.gameRunData.p1FighterGroup)
         {
            return;
         }
         var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         var isLowHp:Boolean = false;
         if(p1 && p1.hpMax > 0 && p1.hp > 0 && p1.hp / p1.hpMax <= 0.3)
         {
            isLowHp = true;
         }
         if(isLowHp)
         {
            if(!_bloodOverlay.visible)
            {
               _bloodOverlay.visible = true;
            }
            var pulse:Number = (Math.sin(getTimer() / 150) + 1) / 2;
            _bloodOverlay.alpha = 0.1 + pulse * 0.25;
            _targetMasterVolume = 0.2;
         }
         else
         {
            if(_bloodOverlay.visible)
            {
               _bloodOverlay.visible = false;
               _bloodOverlay.alpha = 0;
            }
            _targetMasterVolume = 1;
         }
         if(Math.abs(_currentMasterVolume - _targetMasterVolume) > 0.01)
         {
            _currentMasterVolume += (_targetMasterVolume - _currentMasterVolume) * 0.05;
            if(_globalSoundTransform)
            {
               _globalSoundTransform.volume = _currentMasterVolume;
               SoundMixer.soundTransform = _globalSoundTransform;
            }
         }
      }
      
      private function checkRestoreUI() : void
      {
         if(_playOver || _renderEnd)
         {
            return;
         }
         if(!GameCtrl.I.gameRunData.p1FighterGroup || !GameCtrl.I.gameRunData.p2FighterGroup)
         {
            return;
         }
         var group1:* = GameCtrl.I.gameRunData.p1FighterGroup;
         var group2:* = GameCtrl.I.gameRunData.p2FighterGroup;
         var p1:FighterMain = group1 ? group1.currentFighter : null;
         var p2:FighterMain = group2 ? group2.currentFighter : null;
         var isP1Casting:Boolean = p1 != null && (p1.actionState == 12 || p1.actionState == 13 || p1.actionState == 50);
         var isP2Casting:Boolean = p2 != null && (p2.actionState == 12 || p2.actionState == 13 || p2.actionState == 50);
         if(!isP1Casting && !isP2Casting)
         {
            if(_isUiHidden)
            {
               fadIn(true);
            }
            if(ui)
            {
               if(ui.alpha < 1 || !ui.visible)
               {
                  ui.alpha = 1;
                  ui.visible = true;
               }
            }
         }
      }
      
      private function checkLowHpBGM() : void
      {
         if(_isPaused)
         {
            return;
         }
         if(!GameCtrl.I.gameRunData.p1FighterGroup || !GameCtrl.I.gameRunData.p2FighterGroup)
         {
            return;
         }
         var p1:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         var p2:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
         if(!p1 || !p2 || p1.hpMax <= 0 || p2.hpMax <= 0)
         {
            return;
         }
         if(_p1FighterCache != p1 || _p2FighterCache != p2)
         {
            _p1FighterCache = p1;
            _p2FighterCache = p2;
            _isBgmTriggered = false;
            _playOver = false;
            SoundCtrl.I.playStartGameBGM();
         }
         if(_isBgmTriggered)
         {
            return;
         }
         var p1HpRate:Number = p1.hp / p1.hpMax;
         var p2HpRate:Number = p2.hp / p2.hpMax;
         var p1Low:Boolean = p1HpRate <= 0.4 && p1.hp > 0;
         var p2Low:Boolean = p2HpRate <= 0.4 && p2.hp > 0;
         if(p2Low || p1Low)
         {
            var p1Id:String = "null";
            var p2Id:String = "null";
            if(p1.hasOwnProperty("data") && p1["data"])
            {
               p1Id = p1["data"].id;
            }
            else if(p1.hasOwnProperty("id"))
            {
               p1Id = p1["id"];
            }
            if(p2.hasOwnProperty("data") && p2["data"])
            {
               p2Id = p2["data"].id;
            }
            else if(p2.hasOwnProperty("id"))
            {
               p2Id = p2["id"];
            }
            if(p2Low)
            {
               SoundCtrl.I.checkFighterHpBGM(p2HpRate,p1Id);
            }
            else
            {
               SoundCtrl.I.checkFighterHpBGM(p1HpRate,p2Id);
            }
            _isBgmTriggered = true;
         }
      }
      
      private function renderQibarPos(param1:Number) : void
      {
         if(QI_BAR_MODE != 0)
         {
            return;
         }
         if(param1 < 1.5)
         {
            _qibar1.moveTo(120,60,0.8);
            _qibar2.moveTo(946,60,0.8);
         }
         else
         {
            _qibar1.moveResume();
            _qibar2.moveResume();
         }
      }
      
      public function renderAnimate() : void
      {
         _fightbar.renderAnimate();
         _qibar1.renderAnimate();
         _qibar2.renderAnimate();
         renderStartAndKO();
      }
      
      private function renderStartAndKO() : void
      {
         var _loc2_:MovieClip = ui.startKOmc;
         if(!_loc2_)
         {
            return;
         }
         var _loc1_:String = _loc2_.currentFrameLabel;
         if(_loc1_)
         {
            if(_loc1_ == "stop")
            {
               return;
            }
            if(_loc1_.indexOf("go:") != -1)
            {
               _loc2_.gotoAndStop(_loc1_.split("go:")[1]);
               return;
            }
         }
         _loc2_.nextFrame();
      }
      
      public function fadIn(param1:Boolean = true) : void
      {
         _isUiHidden = false;
         _fightbar.fadIn(param1);
         if(QI_BAR_MODE == 1)
         {
            _qibar1.fadIn(false);
            _qibar2.fadIn(false);
            _qibar1.setPosAndScale(120,60,0.8);
            _qibar2.setPosAndScale(946,60,0.8);
         }
         else
         {
            _qibar1.fadIn(param1);
            _qibar2.fadIn(param1);
         }
      }
      
      public function fadOut(param1:Boolean = true) : void
      {
         _isUiHidden = true;
         _fightbar.fadOut(param1);
         _qibar1.fadOut(param1);
         _qibar2.fadOut(param1);
      }
      
      public function showHits(param1:int, param2:int) : void
      {
         var _loc3_:HitsUI = param2 == 1 ? _hits1 : _hits2;
         _loc3_.show(param1);
      }
      
      public function hideHits(param1:int) : void
      {
         var _loc2_:HitsUI = param1 == 1 ? _hits1 : _hits2;
         _loc2_.hide();
      }
      
      public function showStart(param1:Function = null, param2:Object = null) : void
      {
         var round:int;
         var finishBack:Function;
         var params:Object;
         var onFight:*;
         var startComplete:*;
         if(GameCtrl.I && GameCtrl.I.gameRunData)
         {
            initlize(GameCtrl.I.gameRunData.p1FighterGroup,GameCtrl.I.gameRunData.p2FighterGroup);
         }
         _isBgmTriggered = false;
         _playOver = false;
         _renderEnd = false;
         finishBack = param1;
         params = param2;
         onFight = function(param1:Event):void
         {
            ui.startKOmc.removeEventListener("fight",onFight);
         };
         startComplete = function(param1:Event):void
         {
            ui.startKOmc.removeEventListener("complete",startComplete);
            if(finishBack != null)
            {
               finishBack();
            }
         };
         if(ui)
         {
            ui.visible = true;
            ui.alpha = 1;
         }
         fadIn(true);
         round = GameCtrl.I.gameRunData.round;
         ui.startKOmc.y = -50;
         ui.startKOmc.$round = round;
         ui.startKOmc.gotoAndStop(round < 5 ? "start" : "start_final");
         ui.startKOmc.addEventListener("fight",onFight);
         if(finishBack != null)
         {
            ui.startKOmc.addEventListener("complete",startComplete);
         }
      }
      
      public function showEnd(param1:Function = null, param2:Object = null) : void
      {
         var _loc3_:FighterMain = null;
         _endParam = param2;
         if(!_endParam)
         {
            _endParam = {};
         }
         _endParam.finishBack = param1;
         _drawGame = param2 ? param2.drawGame : false;
         _renderEnd = true;
         _playOver = false;
         if(GameCtrl.I.gameRunData.isTimerOver)
         {
            playTimeOver();
         }
         else
         {
            _loc3_ = param2 ? param2.loser : null;
            playKO(_loc3_);
         }
      }
      
      public function showContinue(param1:Function) : void
      {
         var btn:ContinueBtn;
         var onClick:Function = param1;
         var onBtnClick:* = function(param1:ContinueBtn):void
         {
            onClick();
            param1.destory();
            try
            {
               ui.removeChild(param1);
            }
            catch(e:Error)
            {
            }
         };
         if(!ui)
         {
            return;
         }
         btn = new ContinueBtn();
         btn.x = 300;
         btn.y = 500;
         btn.onClick(onBtnClick);
         ui.addChild(btn);
      }
      
      private function playKO(param1:FighterMain = null) : void
      {
         var bsKO:Boolean;
         var p1:FighterMain;
         var p2:FighterMain;
         var playKO2:*;
         var bwMatrix:Array;
         var bwFilter:ColorMatrixFilter;
         var loser:FighterMain = param1;
         _isUiHidden = true;
         if(_fightbar)
         {
            _fightbar.fadOut(true);
         }
         if(_qibar1)
         {
            _qibar1.fadOut(true);
         }
         if(_qibar2)
         {
            _qibar2.fadOut(true);
         }
         if(_hits1)
         {
            _hits1.hide();
         }
         if(_hits2)
         {
            _hits2.hide();
         }
         if(_p1PosUI)
         {
            _p1PosUI.visible = false;
         }
         if(_p2PosUI)
         {
            _p2PosUI.visible = false;
         }
         playKO2 = function():void
         {
            ui.startKOmc.y = 0;
            ui.startKOmc.gotoAndStop("ko");
            ui.startKOmc.addEventListener("complete",koBack);
            SoundCtrl.I.playSwcSound(bsKO ? snd_ko_bs : snd_ko);
         };
         _showWinnerDelay = 0;
         EffectCtrl.I.freezeEnabled = false;
         _isSlowDown = false;
         if(loser)
         {
            EffectCtrl.I.doEffectById("hit_end",loser.x,loser.y);
            EffectCtrl.I.shine(16777215,0.85);
            GameCtrl.I.gameState.cameraFocusOne(loser.getDisplay());
            try
            {
               if(GameCtrl.I.gameState.camera.hasOwnProperty("setZoom"))
               {
                  GameCtrl.I.gameState.camera["setZoom"](1.8);
               }
               else if(GameCtrl.I.gameState.camera.hasOwnProperty("zoom"))
               {
                  GameCtrl.I.gameState.camera["zoom"] = 1.8;
               }
            }
            catch(e:Error)
            {
            }
         }
         bsKO = false;
         p1 = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         p2 = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
         if(p1 && p2)
         {
            if(p1.actionState == 12 || p1.actionState == 13 || p2.actionState == 12 || p2.actionState == 13)
            {
               bsKO = true;
               EffectCtrl.I.BGEffect("kobg",2);
            }
         }
         if(!bsKO)
         {
            EffectCtrl.I.bgBlurEnabled = true;
            EffectCtrl.I.bgBlur(8,0,4000);
         }
         else
         {
            EffectCtrl.I.bgBlurEnabled = false;
         }
         EffectCtrl.I.shake(12,12,1.5);
         SoundCtrl.I.playSwcSound(snd_over_hit);
         if(GameCtrl.I)
         {
            GameCtrl.I.pause();
            try
            {
               bwMatrix = [0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0,0,0,1,0];
               bwFilter = new ColorMatrixFilter(bwMatrix);
               GameCtrl.I.gameState.getDisplay().filters = [bwFilter];
            }
            catch(e:Error)
            {
            }
         }
         setTimeout(function():void
         {
            try
            {
               GameCtrl.I.gameState.getDisplay().filters = [];
            }
            catch(e:Error)
            {
            }
            if(GameCtrl.I)
            {
               GameCtrl.I.resume();
               GameCtrl.I.slowRate = 0.25;
               EffectCtrl.I.slowDown(0.25,4000);
            }
            playKO2();
         },2000);
      }
      
      private function koBack(param1:Event) : void
      {
         EffectCtrl.I.freezeEnabled = false;
         EffectCtrl.I.bgBlurEnabled = true;
         EffectCtrl.I.cancelBgBlur();
         ui.startKOmc.removeEventListener("complete",koBack);
         _playOver = true;
         GameCtrl.I.resume();
         GameCtrl.I.slowRate = 1;
         EffectCtrl.I.slowDownResume();
      }
      
      private function playTimeOver() : void
      {
         ui.startKOmc.y = 0;
         ui.startKOmc.gotoAndStop("timeover");
         ui.startKOmc.addEventListener("complete",timeoverBack);
         _qibar1.fadOut(false);
         _qibar2.fadOut(false);
      }
      
      private function timeoverBack(param1:Event) : void
      {
         EffectCtrl.I.freezeEnabled = false;
         ui.startKOmc.removeEventListener("complete",timeoverBack);
         if(_drawGame)
         {
            playDrawGame();
            _showWinnerDelay = 0;
         }
         else
         {
            _playOver = true;
            _showWinnerDelay = 0.5 * GameConfig.FPS_GAME;
         }
      }
      
      private function playDrawGame() : void
      {
         ui.startKOmc.gotoAndStop("drawgame");
         ui.startKOmc.addEventListener("complete",drawGameBack);
      }
      
      private function drawGameBack(param1:Event) : void
      {
         ui.startKOmc.removeEventListener("complete",drawGameBack);
         if(_endParam.finishBack != null)
         {
            _endParam.finishBack();
         }
      }
      
      private function renderEnd() : void
      {
         var _loc1_:FighterMain = null;
         if(!_playOver)
         {
            return;
         }
         if(!_endParam)
         {
            return;
         }
         if(_showWinnerDelay > 0)
         {
            _showWinnerDelay -= 1;
            if(_showWinnerDelay <= 0)
            {
               _loc1_ = _endParam.winner;
               if(_loc1_)
               {
                  if(GameData.I && GameData.I.config && GameData.I.config.dynamicCamera)
                  {
                     EffectCtrl.I.playCinematicOutro(_loc1_);
                  }
                  else
                  {
                     GameCtrl.I.gameState.cameraFocusOne(_loc1_.getDisplay());
                  }
                  showWinner(_loc1_);
                  if(GameMode.isSingleMode())
                  {
                     showWins(_loc1_,GameCtrl.I.gameRunData.getWins(_loc1_));
                  }
                  if(_endParam)
                  {
                     _endParam.finishBack();
                  }
               }
               _renderEnd = false;
               _endParam = null;
            }
            return;
         }
         var _loc2_:FighterMain = _endParam.loser;
         if(_loc2_)
         {
            if(_loc2_.actionState == 22)
            {
               if(!_isSlowDown)
               {
                  _isSlowDown = true;
                  _flyTimer = getTimer();
               }
            }
            if(_loc2_.actionState == 30)
            {
               if(_isSlowDown)
               {
                  if(getTimer() - _flyTimer < 1200)
                  {
                     _showWinnerDelay = 1 * GameConfig.FPS_GAME;
                  }
                  else
                  {
                     _showWinnerDelay = 0.5 * GameConfig.FPS_GAME;
                  }
                  EffectCtrl.I.slowDownResume();
               }
               else
               {
                  _showWinnerDelay = 1 * GameConfig.FPS_GAME;
                  EffectCtrl.I.slowDownResume();
               }
            }
         }
      }
      
      public function clearStartAndEnd() : void
      {
         ui.startKOmc.gotoAndStop(1);
      }
      
      public function pause() : void
      {
         _isPaused = true;
         if(!_pauseDialog)
         {
            _pauseDialog = new PauseDialog();
            _pauseDialog.graphics.clear();
            _pauseDialog.graphics.beginFill(0,0.6);
            _pauseDialog.graphics.drawRect(0,0,1066,600);
            _pauseDialog.graphics.endFill();
            ui.addChild(_pauseDialog);
         }
         _pauseDialog.show();
      }
      
      public function resume() : Boolean
      {
         _isPaused = false;
         if(!_pauseDialog)
         {
            return true;
         }
         return _pauseDialog.hide();
      }
      
      private function showWinner(param1:FighterMain, param2:Function = null) : void
      {
         var teamid:int;
         var winner:FighterMain = param1;
         var back:Function = param2;
         var winnerBack:* = function(param1:Event):void
         {
            ui.startKOmc.removeEventListener("complete",winnerBack);
            if(back != null)
            {
               back();
            }
         };
         ui.startKOmc.y = 30;
         teamid = winner && winner.team ? winner.team.id : 1;
         if(GameConfig.SHOW_UI_STATUS == 1)
         {
            ui.startKOmc.$winnerScale = 0.8;
            switch(teamid - 1)
            {
               case 0:
                  ui.startKOmc.$winnerX = 30;
                  break;
               case 1:
                  ui.startKOmc.$winnerX = 586;
            }
         }
         else
         {
            switch(teamid - 1)
            {
               case 0:
                  ui.startKOmc.$winnerX = 30;
                  break;
               case 1:
                  ui.startKOmc.$winnerX = 546;
            }
         }
         ui.startKOmc.$perfect = winner.hp >= winner.hpMax;
         ui.startKOmc.gotoAndStop("winner");
         if(back != null)
         {
            ui.startKOmc.addEventListener("complete",winnerBack);
         }
      }
      
      private function renderPlayerPosUI(param1:Number) : void
      {
         var _loc4_:Point = null;
         if(param1 > 1.8)
         {
            _p1PosUI.visible = _p2PosUI.visible = false;
            return;
         }
         if(!GameCtrl.I.gameRunData.p1FighterGroup || !GameCtrl.I.gameRunData.p2FighterGroup)
         {
            return;
         }
         var _loc2_:FighterMain = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
         var _loc3_:FighterMain = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
         if(_loc2_)
         {
            _loc4_ = getPlayerPos(_loc2_);
            _p1PosUI.x = _loc4_.x / ui.scaleX;
            _p1PosUI.y = _loc4_.y / ui.scaleY;
            _p1PosUI.visible = true;
         }
         if(_loc3_)
         {
            _loc4_ = getPlayerPos(_loc3_);
            _p2PosUI.x = _loc4_.x / ui.scaleX;
            _p2PosUI.y = _loc4_.y / ui.scaleY;
            _p2PosUI.visible = true;
         }
      }
      
      private function getPlayerPos(param1:IGameSprite) : Point
      {
         var _loc2_:Point = GameCtrl.I.gameState.getGameSpriteGlobalPosition(param1,0,-50);
         if(_loc2_.x < 20)
         {
            _loc2_.x = 20;
         }
         if(_loc2_.x > GameConfig.GAME_SIZE.x - 20)
         {
            _loc2_.x = GameConfig.GAME_SIZE.x - 20;
         }
         if(_loc2_.y < 60)
         {
            _loc2_.y = 60;
         }
         if(_loc2_.y > GameConfig.GAME_SIZE.y - 5)
         {
            _loc2_.x = GameConfig.GAME_SIZE.x - 5;
         }
         return _loc2_;
      }
   }
}

