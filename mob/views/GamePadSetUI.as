package net.play5d.game.bvn.mob.views
{
   import com.greensock.TweenLite;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.ui.GameInputDevice;
   import flash.utils.getTimer;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.events.SetBtnEvent;
   import net.play5d.game.bvn.interfaces.IInnerSetUI;
   import net.play5d.game.bvn.mob.GameInterfaceManager;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.game.bvn.mob.input.JoyStickSetVO;
   import net.play5d.game.bvn.mob.input.JoySticker;
   import net.play5d.game.bvn.ui.GameUI;
   import net.play5d.game.bvn.ui.SetBtnDialog;
   import net.play5d.game.bvn.ui.SetBtnGroup;
   
   public class GamePadSetUI extends EventDispatcher implements IInnerSetUI
   {
      
      private static const MAPPINGS:Array = [{
         "id":"up2",
         "name":"Up Analog",
         "cn":""
      },{
         "id":"down2",
         "name":"Down Analog",
         "cn":""
      },{
         "id":"left2",
         "name":"Left Analog",
         "cn":""
      },{
         "id":"right2",
         "name":"Right Analog",
         "cn":""
      },{
         "id":"up",
         "name":"Up Dpad",
         "cn":""
      },{
         "id":"down",
         "name":"Down Dpad",
         "cn":""
      },{
         "id":"left",
         "name":"Left Dpad",
         "cn":""
      },{
         "id":"right",
         "name":"Right Dpad",
         "cn":""
      },{
         "id":"attack",
         "name":"ATTACK",
         "cn":""
      },{
         "id":"jump",
         "name":"JUMP",
         "cn":""
      },{
         "id":"dash",
         "name":"DASH",
         "cn":""
      },{
         "id":"skill",
         "name":"SKILL",
         "cn":""
      },{
         "id":"superSkill",
         "name":"ULTIMATE SKILL",
         "cn":""
      },{
         "id":"special",
         "name":"ASSIST/SWITCH",
         "cn":""
      },{
         "id":"waikai",
         "name":"AWAKENING",
         "cn":""
      },{
         "id":"back",
         "name":"START",
         "cn":""
      },{
         "id":"select",
         "name":"SELECT",
         "cn":""
      }];
      
      private var _joybitmap:Class = §setting_joy_png$c33d2c1ee246601fc37f0ef734be9588-682700004§;
      
      private var _btnGroup:SetBtnGroup;
      
      private var _currentPlayer:int = 1;
      
      private var _ui:Sprite;
      
      private var _bp:Bitmap;
      
      private var _p1JoyConfig:JoyStickConfigVO;
      
      private var _p2JoyConfig:JoyStickConfigVO;
      
      private var _tmpJoy1Config:JoyStickConfigVO;
      
      private var _tmpJoy2Config:JoyStickConfigVO;
      
      private var _setIndex:int;
      
      private var _lastKey:String;
      
      private var _dialog:SetBtnDialog;
      
      private var _startSet:Boolean;
      
      private var _lastMapTime:int = 0;
      
      public function GamePadSetUI()
      {
         super();
         _ui = new Sprite();
         _bp = new _joybitmap();
         _bp.x = 170;
         _bp.y = 250;
         _ui.addChild(_bp);
         _tmpJoy1Config = new JoyStickConfigVO();
         _tmpJoy2Config = new JoyStickConfigVO();
      }
      
      private function get currentTmpConfig() : JoyStickConfigVO
      {
         return _currentPlayer == 2 ? _tmpJoy2Config : _tmpJoy1Config;
      }
      
      private function subString(param1:String, param2:int) : String
      {
         if(!param1)
         {
            return null;
         }
         if(param1.length < param2)
         {
            return param1;
         }
         return param1.substr(0,param2) + "...";
      }
      
      private function initBtns() : void
      {
         if(_btnGroup)
         {
            _btnGroup.removeEventListener("SELECT",onBtnSelect);
            _btnGroup.removeEventListener("OPTION_CHANGE",onOptoinChange);
            if(_ui.contains(_btnGroup))
            {
               _ui.removeChild(_btnGroup);
            }
            _btnGroup.destory();
         }
         var _loc3_:int = 0;
         var _loc1_:GameInputDevice = null;
         var _loc4_:Vector.<GameInputDevice> = JoySticker.getAllDeivces();
         var _deviceOptions:Array = [{
            "label":"NONE (SCREENPAD)",
            "cn":"",
            "value":null
         }];
         while(_loc3_ < _loc4_.length)
         {
            _loc1_ = _loc4_[_loc3_];
            _deviceOptions.push({
               "label":subString(_loc1_.name,15),
               "cn":subString(_loc1_.name,45),
               "value":_loc1_.id
            });
            _loc3_++;
         }
         var _playerOptions:Array = [{
            "label":"PLAYER 1",
            "cn":"",
            "value":1
         },{
            "label":"PLAYER 2",
            "cn":"",
            "value":2
         }];
         _btnGroup = new SetBtnGroup();
         _btnGroup.startY = 20;
         _btnGroup.setBtnData([{
            "label":"TARGET PLAYER",
            "cn":"",
            "options":_playerOptions,
            "optionKey":"player",
            "optionValue":_currentPlayer
         },{
            "label":"GAMEPAD NAME",
            "cn":"",
            "options":_deviceOptions,
            "optionKey":"deviceId",
            "optionValue":currentTmpConfig.deviceId
         },{
            "label":"SWITCH P1/P2",
            "cn":""
         },{
            "label":"SET ALL",
            "cn":""
         },{
            "label":"SET DEFAULT",
            "cn":""
         },{
            "label":"APPLY",
            "cn":""
         },{
            "label":"CANCEL",
            "cn":""
         }]);
         _btnGroup.addEventListener("SELECT",onBtnSelect);
         _btnGroup.addEventListener("OPTION_CHANGE",onOptoinChange);
         _ui.addChild(_btnGroup);
      }
      
      public function setConfig(param1:int, param2:JoyStickConfigVO) : void
      {
         _currentPlayer = param1 > 0 ? param1 : 1;
         _p1JoyConfig = GameInterfaceManager.config.joy1Config;
         _p2JoyConfig = GameInterfaceManager.config.joy2Config;
         if(_p1JoyConfig)
         {
            _tmpJoy1Config.readObj(_p1JoyConfig.toObj());
         }
         if(_p2JoyConfig)
         {
            _tmpJoy2Config.readObj(_p2JoyConfig.toObj());
         }
         if(!_tmpJoy1Config.deviceId && JoySticker.getDeviceId(0) && !_tmpJoy1Config.deviceIsSet)
         {
            _tmpJoy1Config.deviceId = JoySticker.getDeviceId(0);
         }
         if(!_tmpJoy2Config.deviceId && JoySticker.getDeviceId(1) && !_tmpJoy2Config.deviceIsSet)
         {
            _tmpJoy2Config.deviceId = JoySticker.getDeviceId(1);
         }
         initBtns();
      }
      
      private function onBtnSelect(param1:SetBtnEvent) : void
      {
         switch(param1.selectedLabel)
         {
            case "SWITCH P1/P2":
               _currentPlayer = _currentPlayer == 1 ? 2 : 1;
               initBtns();
               GameUI.alert("NOW SETTING PLAYER " + _currentPlayer,"");
               break;
            case "SET ALL":
               var targetDevice:String = currentTmpConfig.deviceId;
               if(!targetDevice)
               {
                  targetDevice = JoySticker.getDeviceId(0);
               }
               if(targetDevice)
               {
                  currentTmpConfig.deviceId = targetDevice;
                  currentTmpConfig.deviceIsSet = true;
                  if(_currentPlayer == 1 && _tmpJoy2Config.deviceId == targetDevice)
                  {
                     _tmpJoy2Config.deviceId = null;
                     _tmpJoy2Config.deviceIsSet = true;
                  }
                  else if(_currentPlayer == 2 && _tmpJoy1Config.deviceId == targetDevice)
                  {
                     _tmpJoy1Config.deviceId = null;
                     _tmpJoy1Config.deviceIsSet = true;
                  }
                  initBtns();
               }
               if(!JoySticker.isActive(currentTmpConfig.deviceId))
               {
                  GameUI.alert("NO JOYSTICK CONNECTED","");
                  return;
               }
               _setIndex = -1;
               _btnGroup.keyEnable = false;
               _startSet = false;
               _lastMapTime = 0;
               GameRender.add(renderSet);
               setNextKey();
               break;
            case "SET DEFAULT":
               var defDeviceId:String = JoySticker.getDeviceId(_currentPlayer - 1);
               if(_currentPlayer == 1)
               {
                  _tmpJoy1Config = new JoyStickConfigVO();
                  _tmpJoy1Config.deviceId = defDeviceId;
                  _tmpJoy1Config.deviceIsSet = true;
                  if(defDeviceId != null && _tmpJoy2Config.deviceId == defDeviceId)
                  {
                     _tmpJoy2Config.deviceId = null;
                     _tmpJoy2Config.deviceIsSet = true;
                  }
               }
               else
               {
                  _tmpJoy2Config = new JoyStickConfigVO();
                  _tmpJoy2Config.deviceId = defDeviceId;
                  _tmpJoy2Config.deviceIsSet = true;
                  if(defDeviceId != null && _tmpJoy1Config.deviceId == defDeviceId)
                  {
                     _tmpJoy1Config.deviceId = null;
                     _tmpJoy1Config.deviceIsSet = true;
                  }
               }
               initBtns();
               GameUI.alert("SET JOYSTICK P" + _currentPlayer + " DEFAULT SUCCESS","");
               break;
            case "APPLY":
               if(_p1JoyConfig)
               {
                  _p1JoyConfig.readObj(_tmpJoy1Config.toObj());
               }
               if(_p2JoyConfig)
               {
                  _p2JoyConfig.readObj(_tmpJoy2Config.toObj());
               }
               GameInterfaceManager.config.updateJoyConfig();
               dispatchEvent(new SetBtnEvent("APPLY_SET"));
               GameInterfaceManager.updateInputConfig();
               break;
            case "CANCEL":
               dispatchEvent(new SetBtnEvent("CANCEL_SET"));
         }
      }
      
      private function onOptoinChange(param1:SetBtnEvent) : void
      {
         if(param1.optionKey == "player")
         {
            _currentPlayer = param1.optionValue;
            initBtns();
         }
         else if(param1.optionKey == "deviceId")
         {
            var selectedDeviceId:String = param1.optionValue;
            currentTmpConfig.deviceId = selectedDeviceId;
            currentTmpConfig.deviceIsSet = true;
            if(selectedDeviceId != null)
            {
               if(_currentPlayer == 1)
               {
                  if(_tmpJoy2Config.deviceId == selectedDeviceId)
                  {
                     _tmpJoy2Config.deviceId = null;
                     _tmpJoy2Config.deviceIsSet = true;
                  }
               }
               else if(_currentPlayer == 2)
               {
                  if(_tmpJoy1Config.deviceId == selectedDeviceId)
                  {
                     _tmpJoy1Config.deviceId = null;
                     _tmpJoy1Config.deviceIsSet = true;
                  }
               }
            }
         }
      }
      
      private function renderSet() : void
      {
         if(waitRelease())
         {
            return;
         }
         if(getTimer() - _lastMapTime < 400)
         {
            return;
         }
         var _loc1_:JoyStickSetVO = waitNextKey();
         if(_loc1_)
         {
            saveCurrentKey(_loc1_);
            setNextKey();
            _startSet = false;
            _lastMapTime = getTimer();
         }
      }
      
      private function waitRelease() : Boolean
      {
         if(!_startSet)
         {
            if(!JoySticker.isDownAnyKey(currentTmpConfig.deviceId))
            {
               _startSet = true;
            }
            return true;
         }
         return false;
      }
      
      private function waitNextKey() : JoyStickSetVO
      {
         var _loc1_:JoyStickSetVO = JoySticker.getDownKey(currentTmpConfig.deviceId,true);
         if(!_loc1_)
         {
            _lastKey = null;
            return null;
         }
         if(isDuplicateKey(_loc1_))
         {
            return null;
         }
         return _loc1_;
      }
      
      private function saveCurrentKey(param1:JoyStickSetVO) : void
      {
         var _loc2_:Object = getCurrentMapping();
         if(_loc2_)
         {
            currentTmpConfig[_loc2_.id] = param1;
         }
      }
      
      private function isDuplicateKey(param1:JoyStickSetVO) : Boolean
      {
         if(!param1)
         {
            return true;
         }
         var _loc2_:String = param1.id + "_" + param1.value;
         if(_lastKey == _loc2_)
         {
            return true;
         }
         _lastKey = _loc2_;
         return false;
      }
      
      private function getCurrentMapping() : Object
      {
         if(_setIndex < 0 || _setIndex >= MAPPINGS.length)
         {
            return null;
         }
         return MAPPINGS[_setIndex];
      }
      
      private function showCurrentMapping(param1:Object) : void
      {
         if(!_dialog)
         {
            _dialog = new SetBtnDialog();
            _dialog.ui.x = 80;
            _dialog.ui.y = 20;
            _ui.addChild(_dialog.ui);
         }
         _dialog.show(param1.name,param1.name);
      }
      
      private function setNextKey() : void
      {
         var _loc1_:Object = nextMapping();
         if(_loc1_)
         {
            showCurrentMapping(_loc1_);
         }
         else
         {
            finishMapping();
         }
      }
      
      private function nextMapping() : Object
      {
         ++_setIndex;
         _lastKey = null;
         return getCurrentMapping();
      }
      
      private function finishMapping() : void
      {
         if(_dialog)
         {
            _dialog.hide();
         }
         _btnGroup.keyEnable = true;
         GameRender.remove(renderSet);
      }
      
      public function fadIn() : void
      {
         _ui.y = 600;
         TweenLite.to(_ui,0.3,{"y":0});
      }
      
      public function fadOut() : void
      {
         TweenLite.to(_ui,0.3,{"y":600});
      }
      
      public function getUI() : DisplayObject
      {
         return _ui;
      }
      
      public function destory() : void
      {
         GameRender.remove(renderSet);
         if(_btnGroup)
         {
            _btnGroup.removeEventListener("SELECT",onBtnSelect);
            _btnGroup.removeEventListener("OPTION_CHANGE",onOptoinChange);
            try
            {
               _ui.removeChild(_btnGroup);
            }
            catch(e:Error)
            {
            }
            _btnGroup.destory();
            _btnGroup = null;
         }
         if(_dialog)
         {
            try
            {
               _ui.removeChild(_dialog.ui);
            }
            catch(e:Error)
            {
            }
            if(_dialog.hasOwnProperty("destory"))
            {
               _dialog["destory"]();
            }
            _dialog = null;
         }
         if(_bp && _ui.contains(_bp))
         {
            _ui.removeChild(_bp);
         }
         _bp = null;
         _tmpJoy1Config = null;
         _tmpJoy2Config = null;
         _p1JoyConfig = null;
         _p2JoyConfig = null;
      }
   }
}

