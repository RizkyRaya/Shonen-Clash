package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.game.bvn.interfaces.IExtendConfig;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class ConfigVO implements ISaveData
   {
      
      public var select_config:SelectStageConfigVO = new SelectStageConfigVO();
      
      public var AI_level:int = 4;
      
      public var fighterHP:Number = 2;
      
      public var fightTime:int = -1;
      
      public var quality:String = "low";
      
      public var gameFps:int = 60;
      
      public var shadow:Boolean = false;
      
      public var blur:Boolean = true;
      
      public var shake:Boolean = true;
      
      public var smoothing:Boolean = false;
      
      public var shine:String = "standard";
      
      public var soundVolume:Number = 0.7;
      
      public var bgmVolume:Number = 0.8;
      
      public var keyInputMode:int = 1;
      
      public var cameraZoomRate:Number = 0.7;
      
      public var cameraDistance:Number = 2.5;
      
      public var dynamicCamera:Boolean = true;
      
      public var performanceMode:Boolean = false;
      
      public var maxWinRound:int = 2;
      
      public var extendConfig:IExtendConfig;
      
      public var key_menu:KeyConfigVO;
      
      public var key_p1:KeyConfigVO;
      
      public var key_p2:KeyConfigVO;
      
      public function ConfigVO()
      {
         super();
         key_menu = new KeyConfigVO(0);
         key_p1 = new KeyConfigVO(1);
         key_p2 = new KeyConfigVO(2);
         extendConfig = GameInterface.instance.getConfigExtend();
         setDefaultConfig(key_menu);
         setDefaultConfig(key_p1);
         setDefaultConfig(key_p2);
      }
      
      public function setDefaultConfig(param1:KeyConfigVO) : void
      {
         switch(param1.id)
         {
            case 0:
               param1.setKeys(87,83,65,68,74,75,76,85,73,79);
               param1.selects = [74,75,76,85,73,79];
               break;
            case 1:
               param1.setKeys(87,83,65,68,74,75,76,85,73,79);
               break;
            case 2:
               param1.setKeys(38,40,37,39,97,98,99,100,101,102);
         }
      }
      
      public function toSaveObj() : Object
      {
         var _loc1_:Object = {};
         _loc1_.key_p1 = key_p1.toSaveObj();
         _loc1_.key_p2 = key_p2.toSaveObj();
         _loc1_.AI_level = AI_level;
         _loc1_.fighterHP = fighterHP;
         _loc1_.fightTime = fightTime;
         _loc1_.quality = quality;
         _loc1_.gameFps = gameFps;
         _loc1_.shadow = shadow;
         _loc1_.blur = blur;
         _loc1_.shake = shake;
         _loc1_.smoothing = smoothing;
         _loc1_.shine = shine;
         _loc1_.keyInputMode = keyInputMode;
         _loc1_.soundVolume = soundVolume;
         _loc1_.bgmVolume = bgmVolume;
         _loc1_.cameraZoomRate = cameraZoomRate;
         _loc1_.cameraDistance = cameraDistance;
         _loc1_.dynamicCamera = dynamicCamera;
         _loc1_.performanceMode = performanceMode;
         _loc1_.maxWinRound = maxWinRound;
         if(extendConfig)
         {
            _loc1_.extend_config = extendConfig.toSaveObj();
         }
         return _loc1_;
      }
      
      public function readSaveObj(param1:Object) : void
      {
         if(param1.key_p1)
         {
            key_p1.readSaveObj(param1.key_p1);
         }
         if(param1.key_p2)
         {
            key_p2.readSaveObj(param1.key_p2);
         }
         if(param1.extend_config && extendConfig)
         {
            extendConfig.readSaveObj(param1.extend_config);
         }
         delete param1["key_p1"];
         delete param1["key_p2"];
         KyoUtils.setValueByObject(this,param1);
      }
      
      public function getValueByKey(param1:String) : *
      {
         if(this.hasOwnProperty(param1))
         {
            return this[param1];
         }
         if(extendConfig)
         {
            try
            {
               return extendConfig[param1];
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
         return null;
      }
      
      public function setValueByKey(param1:String, param2:*) : void
      {
         if(this.hasOwnProperty(param1))
         {
            this[param1] = param2;
            switch(param1)
            {
               case "bgmVolume":
                  SoundCtrl.I.setBgmVolumn(bgmVolume);
                  break;
               case "soundVolume":
                  SoundCtrl.I.setSoundVolumn(soundVolume);
            }
            return;
         }
         if(extendConfig)
         {
            try
            {
               extendConfig[param1] = param2;
            }
            catch(e:Error)
            {
               trace(e);
            }
         }
      }
      
      public function applyConfig() : void
      {
         switch(quality)
         {
            case "low":
            case "medium":
               GameConfig.QUALITY_GAME = "low";
               break;
            case "high":
               GameConfig.QUALITY_GAME = "medium";
               break;
            case "higher":
            case "best":
               GameConfig.QUALITY_GAME = "high";
         }
         switch(shine)
         {
            case "off":
               GameConfig.FPS_SHINE_EFFECT = 0;
               break;
            case "low":
               GameConfig.FPS_SHINE_EFFECT = 5;
               break;
            case "standard":
               GameConfig.FPS_SHINE_EFFECT = 15;
               break;
            case "high":
               GameConfig.FPS_SHINE_EFFECT = 30;
               break;
            default:
               GameConfig.FPS_SHINE_EFFECT = 0;
         }
         GameConfig.setGameFps(gameFps);
         EffectCtrl.EFFECT_SMOOTHING = smoothing;
         GameConfig.SHADOW_ENABLED = shadow;
         EffectCtrl.BG_BULR_ENABLED = blur;
         EffectCtrl.SHAKE_ENABLED = shake;
         EffectCtrl.PERFORMANCE_MODE = performanceMode;
         SoundCtrl.I.setBgmVolumn(bgmVolume);
         SoundCtrl.I.setSoundVolumn(soundVolume);
         GameConfig.MAX_WIN_ROUND = maxWinRound;
         GameInterface.instance.applyConfig(this);
      }
   }
}

