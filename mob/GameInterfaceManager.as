package net.play5d.game.bvn.mob
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.ConfigVO;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.events.GameEvent;
   import net.play5d.game.bvn.input.IGameInput;
   import net.play5d.game.bvn.interfaces.IExtendConfig;
   import net.play5d.game.bvn.interfaces.IFighterActionCtrl;
   import net.play5d.game.bvn.interfaces.IGameInterface;
   import net.play5d.game.bvn.map.MapMain;
   import net.play5d.game.bvn.mob.ads.AdManager;
   import net.play5d.game.bvn.mob.data.ExtendConfig;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.game.bvn.mob.input.JoySticker;
   import net.play5d.game.bvn.mob.screenpad.ScreenPadManager;
   import net.play5d.game.bvn.mob.utils.FileUtils;
   import net.play5d.game.bvn.mob.views.ViewManager;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.utils.GameSafeKeeper;
   import net.play5d.game.bvn.utils.URL;
   
   public class GameInterfaceManager implements IGameInterface
   {
      
      private static var _extendsConfig:ExtendConfig = new ExtendConfig();
      
      public static var ENGLISH_VERSION:Boolean = false;
      
      public function GameInterfaceManager()
      {
         super();
      }
      
      public static function get config() : ExtendConfig
      {
         return _extendsConfig;
      }
      
      public function initTitleUI(param1:DisplayObject) : void
      {
      }
      
      public function moreGames() : void
      {
         URL.go("http://www.youtube.com/@NeXbvn",true);
      }
      
      public function submitScore(param1:int) : void
      {
      }
      
      public function showRank() : void
      {
      }
      
      public function saveGame(param1:Object) : void
      {
         var _loc3_:String = JSON.stringify(param1);
         var _loc2_:File = File.applicationStorageDirectory.resolvePath("bvnsave.sav");
         FileUtils.writeFile(_loc2_.nativePath,_loc3_);
         trace("saveData",_loc3_);
      }
      
      public function loadGame() : Object
      {
         var _loc1_:File = File.applicationStorageDirectory.resolvePath("bvnsave.sav");
         var _loc2_:String = FileUtils.readTextFile(_loc1_.nativePath);
         if(!_loc2_)
         {
            return null;
         }
         return JSON.parse(_loc2_);
      }
      
      public function getFighterCtrl(param1:int) : IFighterActionCtrl
      {
         return null;
      }
      
      public function getGameMenu() : Array
      {
         return [{
            "txt":"ARCADE MODE",
            "cn":"",
            "children":[{
               "txt":"SINGLE MODE",
               "cn":""
            },{
               "txt":"TEAM MODE",
               "cn":""
            }]
         },{
            "txt":"BATTLE MODE",
            "cn":"",
            "children":[{
               "txt":"1 VS 1",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 22;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"1 VS 2",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 24;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"2 VS 2",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 14;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"Team Mode",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 12;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_TEAM_STAGE");
               }
            }]
         },{
            "txt":"MULTIPLAYER",
            "cn":"",
            "children":[{
               "txt":"Local 1 VS 1",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 21;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"Local 3 VS 3",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 11;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_TEAM_STAGE");
               }
            }]
         },{
            "txt":"MUSOU",
            "cn":"",
            "children":[{
               "txt":"STORY MODE",
               "cn":""
            }]
         },{
            "txt":"WATCHMODE",
            "cn":"",
            "children":[{
               "txt":"1 VS 1",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 23;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"1 VS 2",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 25;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            },{
               "txt":"2 VS 2",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 15;
                  MainGame.I.goSelect();
                  GameEvent.dispatchEvent("ENTER_SINGLE_STAGE");
               }
            }]
         },{
            "txt":"ENDLESS MODE",
            "cn":""
         },{
            "txt":"TRAINING",
            "cn":""
         },{
            "txt":"OPTION",
            "cn":"",
            "children":[{
               "txt":"SETTINGS",
               "cn":"",
               "func":function():void
               {
                  GameMode.currentMode = 401;
                  MainGame.I.goOption();
               }
            },{
               "txt":"CHANGELOG",
               "cn":"",
               "func":function():void
               {
                  var tf:TextFormat;
                  var txt:TextField;
                  var closeHint:TextField;
                  var closeFunc:Function;
                  var msgTitle:String = "<p align=\'center\'><font face=\'Impact\' size=\'28\' color=\'#FFCC00\'>PATCH 1.0.3 UPDATE</font></p><br>";
                  var msgBody:String = "<font face=\'Arial\' size=\'18\' color=\'#FFFFFF\'>" + "• Fix Dynamic Camera in Mosou Mode\n\n" + "• New Revamped Shadow (Experimental)\n\n" + "• Improve Dynamic Camera and add Some Cinematic VFX\n\n" + "• Add Rounds Settigs in Gameplay Options \n\n" + "• New Cinematic Intro and Outro" + "</font>";
                  var popW:Number = 700;
                  var popH:Number = 420;
                  var pop:Sprite = new Sprite();
                  pop.graphics.beginFill(0,0.85);
                  pop.graphics.drawRoundRect(0,0,popW,popH,20,20);
                  pop.graphics.endFill();
                  pop.graphics.lineStyle(3,16763904,0.8);
                  pop.graphics.drawRoundRect(0,0,popW,popH,20,20);
                  tf = new TextFormat("Arial",18,16777215);
                  tf.leading = 5;
                  txt = new TextField();
                  txt.defaultTextFormat = tf;
                  txt.width = popW - 60;
                  txt.height = popH - 80;
                  txt.x = 30;
                  txt.y = 25;
                  txt.multiline = true;
                  txt.wordWrap = true;
                  txt.selectable = false;
                  txt.htmlText = msgTitle + msgBody;
                  pop.addChild(txt);
                  closeHint = new TextField();
                  closeHint.defaultTextFormat = new TextFormat("Impact",18,11184810,null,null,null,null,null,"center");
                  closeHint.width = popW;
                  closeHint.y = popH - 40;
                  closeHint.selectable = false;
                  closeHint.text = "[ Tap anywhere to close ]";
                  pop.addChild(closeHint);
                  if(MainGame.I && MainGame.I.stage)
                  {
                     pop.x = (MainGame.I.stage.stageWidth - popW) / 2;
                     pop.y = (MainGame.I.stage.stageHeight - popH) / 2;
                  }
                  else
                  {
                     pop.x = (800 - popW) / 2;
                     pop.y = 45;
                  }
                  pop.mouseChildren = false;
                  pop.buttonMode = true;
                  closeFunc = function(e:*):void
                  {
                     pop.removeEventListener(MouseEvent.CLICK,closeFunc);
                     if(pop.parent)
                     {
                        pop.parent.removeChild(pop);
                     }
                  };
                  pop.addEventListener(MouseEvent.CLICK,closeFunc);
                  if(MainGame.I && MainGame.I.stage)
                  {
                     MainGame.I.stage.addChild(pop);
                  }
                  else
                  {
                     MainGame.I.addChild(pop);
                  }
               }
            }]
         }];
      }
      
      private function createOption(txt:String, key:String, options:Array, cn:String = "") : Object
      {
         return {
            "txt":txt,
            "cn":cn,
            "options":options,
            "optoinKey":key
         };
      }
      
      private function createGroup(txt:String, children:Array, cn:String = "") : Object
      {
         return {
            "txt":txt,
            "cn":cn,
            "children":children
         };
      }
      
      public function getSettingMenu() : Array
      {
         return [{
            "txt":"HUD",
            "cn":"",
            "select":ViewManager.I.setScreenBtns
         },{
            "txt":"Gamepad",
            "cn":"",
            "select":ViewManager.I.goGamePadSet
         },{
            "txt":"Gameplay",
            "cn":"",
            "select":ViewManager.I.setGameplayBtns
         },{
            "txt":"Audio",
            "cn":"",
            "select":ViewManager.I.setAudioBtns
         },{
            "txt":"Graphics",
            "cn":"",
            "select":ViewManager.I.setGraphicsBtns
         },{
            "txt":"Check Update",
            "cn":"",
            "select":ViewManager.I.checkUpdate
         }];
      }
      
      public function getGameInput(param1:String) : Vector.<IGameInput>
      {
         var _loc2_:Vector.<IGameInput> = new Vector.<IGameInput>();
         switch(param1)
         {
            case "MENU":
               _loc2_.push(InputManager.I.screen_menu);
               _loc2_.push(InputManager.I.joy_menu);
               break;
            case "P1":
               _loc2_.push(InputManager.I.screen_p1);
               _loc2_.push(InputManager.I.joy_p1);
               _loc2_.push(InputManager.I.socket_input_p1);
               break;
            case "P2":
               if(InputManager.I.joy_p2)
               {
                  _loc2_.push(InputManager.I.joy_p2);
               }
               _loc2_.push(InputManager.I.socket_input_p2);
               break;
            default:
               return null;
         }
         return _loc2_;
      }
      
      public function getConfigExtend() : IExtendConfig
      {
         return _extendsConfig;
      }
      
      public function afterBuildGame() : void
      {
         var _loc1_:MapMain = GameCtrl.I.gameState.getMap();
         if(_loc1_.mapLayer)
         {
            _loc1_.mapLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.frontLayer)
         {
            _loc1_.frontLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.frontFixLayer)
         {
            _loc1_.frontFixLayer.cacheAsBitmapMatrix = new Matrix();
         }
         if(_loc1_.bgLayer)
         {
            _loc1_.bgLayer.cacheAsBitmap = true;
         }
      }
      
      public function updateInputConfig() : Boolean
      {
         var j1:JoyStickConfigVO = _extendsConfig.joy1Config;
         var j2:JoyStickConfigVO = _extendsConfig.joy2Config;
         if(j1 && !j1.deviceIsSet && !j1.deviceId && JoySticker.getDeviceId(0))
         {
            j1.deviceId = JoySticker.getDeviceId(0);
         }
         if(j2 && !j2.deviceIsSet && !j2.deviceId && JoySticker.getDeviceId(1))
         {
            j2.deviceId = JoySticker.getDeviceId(1);
         }
         if(j1 && j2 && j1.deviceId != null && j1.deviceId == j2.deviceId)
         {
            if(!j1.deviceIsSet && j2.deviceIsSet)
            {
               j1.deviceId = null;
            }
            else
            {
               j2.deviceId = null;
            }
         }
         InputManager.I.joy_menu.setConfig(_extendsConfig.joyMenuConfig);
         InputManager.I.joy_p1.setConfig(_extendsConfig.joy1Config);
         if(InputManager.I.joy_p2 && _extendsConfig.joy2Config)
         {
            InputManager.I.joy_p2.setConfig(_extendsConfig.joy2Config);
         }
         InputManager.I.socket_input_p1.enabled = false;
         InputManager.I.socket_input_p2.enabled = false;
         InputManager.I.joy_menu.enabled = true;
         InputManager.I.joy_p1.enabled = true;
         if(InputManager.I.joy_p2)
         {
            InputManager.I.joy_p2.enabled = true;
         }
         return true;
      }
      
      public function applyConfig(param1:ConfigVO) : void
      {
         RootSprite.I.updateSize();
         ScreenPadManager.reBuild();
      }
      
      public function getCreadits(param1:String) : Sprite
      {
         var _loc4_:Sprite = new Sprite();
         param1 += "Youtube  : <a href=\"" + URL.markURL("http://www.youtube.com/@NeXbvn") + "\" target=\"_blank\">NeXV</a>" + "<br/>";
         param1 += "游戏官网 : <a href=\"" + URL.markURL("http://www.1212321.com/") + "\" target=\"_blank\">www.1212321.com</a>" + "<br/>";
         param1 += "游戏论坛 : <a href=\"" + URL.markURL("http://bbs.1212321.com/") + "\" target=\"_blank\">bbs.1212321.com</a>" + "<br/>";
         var _loc2_:TextField = new TextField();
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.font = "Impact";
         _loc3_.size = 20;
         _loc3_.color = 16776960;
         _loc3_.leading = 15;
         _loc2_.defaultTextFormat = _loc3_;
         _loc2_.multiline = true;
         if(ENGLISH_VERSION)
         {
            _loc2_.htmlText = "website : <a href=\"" + URL.markURL("http://www.1212321.com/") + "\" target=\"_blank\">www.1212321.com</a>" + "<br/>" + "bbs : <a href=\"" + URL.markURL("http://bbs.1212321.com/") + "\" target=\"_blank\">bbs.1212321.com</a>" + "<br/>";
         }
         else
         {
            _loc2_.htmlText = param1;
         }
         _loc2_.autoSize = "left";
         _loc2_.x = 50;
         _loc2_.y = 30;
         _loc4_.addChild(_loc2_);
         return _loc4_;
      }
      
      public function checkFile(param1:String, param2:ByteArray) : Boolean
      {
         return GameSafeKeeper.I.checkFile(param1,param2);
      }
      
      public function addMosouMoney(param1:Function) : void
      {
         var back:Function = param1;
         var succ:* = function():void
         {
            back(addMoney);
         };
         var fail:* = function():void
         {
            GameUI.alert("FAIL","广告加载失败或正在加载");
         };
         var watchAD:* = function():void
         {
            AdManager.I.showRewardVideo("金币",addMoney,succ,fail);
         };
         var addMoney:int = 1000 + Math.random() * 2000;
         GameUI.confrim("ADD MONEY","观看广告获得 1000-3000 金币! \n (制作不易，跪求支持)",watchAD);
      }
   }
}

