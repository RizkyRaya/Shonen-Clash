package net.play5d.game.bvn.mob.data
{
   import net.play5d.game.bvn.interfaces.IExtendConfig;
   import net.play5d.game.bvn.mob.input.JoyStickConfigVO;
   import net.play5d.game.bvn.mob.input.JoySticker;
   
   public class ExtendConfig implements IExtendConfig
   {
      
      public var joyMenuConfig:JoyStickConfigVO = new JoyStickConfigVO();
      
      public var joy1Config:JoyStickConfigVO = new JoyStickConfigVO();
      
      public var joy2Config:JoyStickConfigVO = new JoyStickConfigVO();
      
      public var screenMode:int = 0;
      
      public var screenPadConfig:ScreenPadConfigVO = new ScreenPadConfigVO();
      
      private var _isInitDefaultJoystick:Boolean;
      
      public function ExtendConfig()
      {
         super();
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_.joy_menu = joyMenuConfig.toObj();
         _loc1_.joy_p1 = joy1Config.toObj();
         _loc1_.joy_p2 = joy2Config.toObj();
         _loc1_.screenMode = screenMode;
         _loc1_.screenPadConfig = screenPadConfig.toObj();
         return _loc1_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1.joy_menu != undefined)
         {
            joyMenuConfig.readObj(param1.joy_menu);
         }
         if(param1.joy_p1 != undefined)
         {
            joy1Config.readObj(param1.joy_p1);
         }
         if(param1.joy_p2 != undefined)
         {
            joy2Config.readObj(param1.joy_p2);
         }
         if(param1.screenMode != undefined)
         {
            screenMode = param1.screenMode;
         }
         if(param1.screenPadConfig != undefined)
         {
            screenPadConfig.readObj(param1.screenPadConfig);
         }
         updateJoyConfig();
      }
      
      public function updateJoyConfig() : void
      {
         initDefaultDevices();
         joyMenuConfig.deviceId = joy1Config.deviceId;
         joyMenuConfig.deviceIsSet = joy1Config.deviceIsSet;
         joyMenuConfig.up2.readObj(joy1Config.up2.toObj());
         joyMenuConfig.down2.readObj(joy1Config.down2.toObj());
         joyMenuConfig.left2.readObj(joy1Config.left2.toObj());
         joyMenuConfig.right2.readObj(joy1Config.right2.toObj());
         joyMenuConfig.up.readObj(joy1Config.up.toObj());
         joyMenuConfig.down.readObj(joy1Config.down.toObj());
         joyMenuConfig.left.readObj(joy1Config.left.toObj());
         joyMenuConfig.right.readObj(joy1Config.right.toObj());
         joyMenuConfig.jump.readObj(joy1Config.jump.toObj());
         joyMenuConfig.back.readObj(joy1Config.back.toObj());
      }
      
      private function initDefaultDevices() : void
      {
         if(_isInitDefaultJoystick)
         {
            return;
         }
         trace("initDefaultDevices");
         _isInitDefaultJoystick = true;
         setDefaultDevice(joy1Config,0);
         setDefaultDevice(joy2Config,1);
      }
      
      private function setDefaultDevice(param1:JoyStickConfigVO, param2:int) : void
      {
         if(!param1.deviceIsSet && param1.deviceId == null)
         {
            param1.deviceId = JoySticker.getDeviceId(param2);
         }
      }
   }
}

