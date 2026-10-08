package net.play5d.game.bvn.ctrl.game_ctrls
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.ctrl.StateCtrl;
   import net.play5d.game.bvn.data.GameData;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.game.bvn.ui.GameUI;
   
   public class GameStartCtrl
   {
      
      private var _state:GameState;
      
      private var _p1:FighterMain;
      
      private var _p2:FighterMain;
      
      private var _p1_1:FighterMain;
      
      private var _p2_2:FighterMain;
      
      private var _isStart1v1:Boolean;
      
      private var _isStart2v2:Boolean;
      
      private var _isStartNextRound:Boolean;
      
      private var _isStartMosou:Boolean;
      
      private var _step:int;
      
      private var _holdFrame:int;
      
      private var _uiPlaying:Boolean;
      
      private var _introTeamId:int = -1;
      
      private var _mousouFinish:Boolean = false;
      
      public function GameStartCtrl(param1:GameState)
      {
         super();
         _state = param1;
      }
      
      public function destory() : void
      {
         _p1 = null;
         _p2 = null;
         _p1_1 = null;
         _p2_2 = null;
         _state = null;
      }
      
      public function render() : Boolean
      {
         if(_isStart1v1)
         {
            return renderStart1v1();
         }
         if(_isStart2v2)
         {
            return renderStart2v2();
         }
         if(_isStartNextRound)
         {
            return renderNextRound();
         }
         if(_isStartMosou)
         {
            return renderStartMosou();
         }
         return false;
      }
      
      private function renderStartMosou() : Boolean
      {
         return _mousouFinish;
      }
      
      public function start1v1(param1:FighterMain, param2:FighterMain, param3:int = -1) : void
      {
         _p1 = param1;
         _p2 = param2;
         _isStart1v1 = true;
         _introTeamId = param3;
         switch(param3 - 1)
         {
            case 0:
               SoundCtrl.I.smartPlayGameBGM(param1.data.id);
               break;
            case 1:
               SoundCtrl.I.smartPlayGameBGM(param2.data.id);
               break;
            default:
               SoundCtrl.I.smartPlayGameBGM(param2.data.id);
         }
         preRenderStart();
      }
      
      public function start2v2(param1:FighterMain, param2:FighterMain, param3:FighterMain, param4:FighterMain, param5:int = -1) : void
      {
         _p1 = param1;
         _p1_1 = param2;
         _p2 = param3;
         _p2_2 = param4;
         _isStart2v2 = true;
         _introTeamId = param5;
         switch(param5 - 1)
         {
            case 0:
               SoundCtrl.I.smartPlayGameBGM(param1.data.id);
               SoundCtrl.I.smartPlayGameBGM(param2.data.id);
               break;
            case 1:
               SoundCtrl.I.smartPlayGameBGM(param3.data.id);
               SoundCtrl.I.smartPlayGameBGM(param4.data.id);
               break;
            default:
               SoundCtrl.I.smartPlayGameBGM(param3.data.id);
               SoundCtrl.I.smartPlayGameBGM(param4.data.id);
         }
         preRenderStart();
      }
      
      public function startMosou() : void
      {
         _isStartMosou = true;
         _mousouFinish = false;
         GameUI.I.getUI().showStart(function():void
         {
            _mousouFinish = true;
         });
      }
      
      private function preRenderStart() : void
      {
         var initStep:int;
         EffectCtrl.I.clearCinematicAll();
         _step = -1;
         initStep = 0;
         switch(_introTeamId - -1)
         {
            case 0:
               initStep = 0;
               break;
            case 2:
               initStep = 1;
               break;
            case 3:
               initStep = 2;
         }
         StateCtrl.I.transOut(function():void
         {
            _step = initStep;
         },true);
      }
      
      private function renderStart1v1() : Boolean
      {
         if(_uiPlaying)
         {
            return false;
         }
         if(_holdFrame-- > 0)
         {
            return false;
         }
         switch(_step)
         {
            case 0:
               if(_introTeamId == -1 || _introTeamId == 1)
               {
                  _step = 1;
               }
               else
               {
                  _step = 2;
               }
               break;
            case 1:
               _p1.sayIntro();
               if(GameData.I.config.dynamicCamera)
               {
                  EffectCtrl.I.playCinematicIntro(_p1);
               }
               if(GameMode.currentMode == 22 || GameMode.currentMode == 23 || GameMode.currentMode == 12 || GameMode.isDuoMode())
               {
                  _p2.sayIntro();
                  _step = 4;
               }
               else
               {
                  _step = 2;
               }
               _holdFrame = 2 * GameConfig.FPS_GAME;
               break;
            case 2:
               if(_introTeamId == -1 || _introTeamId == 2)
               {
                  _step = 3;
                  _holdFrame = 0.1 * GameConfig.FPS_GAME;
               }
               else
               {
                  _step = 4;
               }
               break;
            case 3:
               _p2.sayIntro();
               if(GameData.I.config.dynamicCamera)
               {
                  EffectCtrl.I.playCinematicIntro(_p2);
               }
               _holdFrame = 2 * GameConfig.FPS_GAME;
               _step = 4;
               break;
            case 4:
               if(GameData.I.config.dynamicCamera)
               {
                  EffectCtrl.I.finishCinematicIntro();
               }
               else
               {
                  _state.cameraResume();
               }
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
               _step = 5;
               break;
            case 5:
               _uiPlaying = true;
               _state.gameUI.getUI().showStart(function():void
               {
                  _uiPlaying = false;
               });
               _step = 6;
               break;
            case 6:
               _p1 = null;
               _p2 = null;
               return true;
         }
         return false;
      }
      
      private function renderStart2v2() : Boolean
      {
         if(_uiPlaying)
         {
            return false;
         }
         if(_holdFrame-- > 0)
         {
            return false;
         }
         switch(_step)
         {
            case 0:
               if(_p1)
               {
                  _p1.sayIntro();
               }
               if(_p2)
               {
                  _p2.sayIntro();
               }
               if(_p1_1)
               {
                  _p1_1.sayIntro();
               }
               if(_p2_2)
               {
                  _p2_2.sayIntro();
               }
               if(GameData.I.config.dynamicCamera && _p1)
               {
                  EffectCtrl.I.playCinematicIntro(_p1);
               }
               _holdFrame = 2.2 * GameConfig.FPS_GAME;
               _step = 1;
               break;
            case 1:
               if(GameData.I.config.dynamicCamera)
               {
                  EffectCtrl.I.finishCinematicIntro();
               }
               else
               {
                  _state.cameraResume();
               }
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
               _step = 2;
               break;
            case 2:
               _uiPlaying = true;
               _state.gameUI.getUI().showStart(function():void
               {
                  _uiPlaying = false;
               });
               _step = 3;
               break;
            case 3:
               _p1 = null;
               _p1_1 = null;
               _p2 = null;
               _p2_2 = null;
               return true;
         }
         return false;
      }
      
      public function startNextRound() : void
      {
         EffectCtrl.I.clearCinematicAll();
         _isStartNextRound = true;
         _uiPlaying = true;
         StateCtrl.I.transOut(null,true);
         _state.gameUI.getUI().showStart(function():void
         {
            _uiPlaying = false;
         });
      }
      
      public function skip() : void
      {
         EffectCtrl.I.clearCinematicAll();
         if(_isStart1v1)
         {
            if(_step < 5)
            {
               StateCtrl.I.quickTrans();
               _state.cameraResume();
               _uiPlaying = false;
               _step = 6;
               _state.gameUI.getUI().fadIn(true);
               if(_p1)
               {
                  _p1.idle();
               }
               if(_p2)
               {
                  _p2.idle();
               }
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
            }
         }
         if(_isStart2v2)
         {
            if(_step < 2)
            {
               StateCtrl.I.quickTrans();
               _state.cameraResume();
               _uiPlaying = false;
               _step = 3;
               _state.gameUI.getUI().fadIn(true);
               if(_p1)
               {
                  _p1.idle();
               }
               if(_p1_1)
               {
                  _p1_1.idle();
               }
               if(_p2)
               {
                  _p2.idle();
               }
               if(_p2_2)
               {
                  _p2_2.idle();
               }
               _holdFrame = 0.5 * GameConfig.FPS_GAME;
            }
         }
      }
      
      private function renderNextRound() : Boolean
      {
         return _uiPlaying == false;
      }
   }
}

