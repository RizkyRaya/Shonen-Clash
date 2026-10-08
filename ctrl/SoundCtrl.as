package net.play5d.game.bvn.ctrl
{
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   import net.play5d.game.bvn.data.BgmVO;
   import net.play5d.kyo.loader.KyoSoundLoader;
   import net.play5d.kyo.sound.KyoBGSounder;
   import net.play5d.kyo.utils.KyoRandom;
   
   public class SoundCtrl
   {
      
      private static var _i:SoundCtrl;
      
      private var _bgmCache:Object = {};
      
      private var _fightBgmLoaded:Object = {};
      
      private var _bgSound:KyoBGSounder;
      
      private var _soundLoader:KyoSoundLoader;
      
      private var _bgmObj:Object;
      
      private var _bgmPaused:Boolean = false;
      
      private var _waitingSound:Object;
      
      private var _sndTransform:SoundTransform = new SoundTransform();
      
      private var _lastSndTime:int;
      
      private var _isLowHpBgmPlaying:Boolean = false;
      
      public function SoundCtrl()
      {
         super();
      }
      
      public static function get I() : SoundCtrl
      {
         if(!_i)
         {
            _i = new SoundCtrl();
         }
         return _i;
      }
      
      public function setSoundVolumn(param1:Number) : void
      {
         _sndTransform.volume = param1;
      }
      
      public function setBgmVolumn(param1:Number) : void
      {
         if(!_bgSound)
         {
            _bgSound = new KyoBGSounder();
         }
         _bgSound.volume = param1;
      }
      
      public function playAssetSound(param1:String, param2:Number = 1) : void
      {
         var _loc3_:SoundTransform = null;
         if(param1 == null)
         {
            return;
         }
         var _loc4_:Sound = AssetManager.I.getSound(param1);
         if(_loc4_)
         {
            _loc3_ = _sndTransform;
            if(param2 != 1)
            {
               _loc3_ = new SoundTransform(param2 * _sndTransform.volume);
            }
            _loc4_.play(0,0,_loc3_);
            _lastSndTime = getTimer();
         }
      }
      
      public function playEffectSound(param1:String, param2:Number = 1) : void
      {
         var _loc3_:SoundTransform = null;
         if(param1 == null)
         {
            return;
         }
         if(keepSoundNoise())
         {
            return;
         }
         var _loc4_:Sound = AssetManager.I.getEffect(param1);
         if(_loc4_)
         {
            _loc3_ = _sndTransform;
            if(param2 != 1)
            {
               _loc3_ = new SoundTransform(param2 * _sndTransform.volume);
            }
            _loc4_.play(0,0,_loc3_);
            _lastSndTime = getTimer();
         }
      }
      
      public function playAssetSoundRandom(... rest) : void
      {
         if(keepSoundNoise())
         {
            return;
         }
         var _loc2_:String = KyoRandom.getRandomInArray(rest);
         playAssetSound(_loc2_);
      }
      
      public function playSwcSound(param1:Class) : void
      {
         if(keepSoundNoise())
         {
            return;
         }
         var _loc2_:Sound = new param1();
         _loc2_.play(0,0,_sndTransform);
         _lastSndTime = getTimer();
      }
      
      private function keepSoundNoise() : Boolean
      {
         return getTimer() - _lastSndTime < 20;
      }
      
      public function BGM(param1:Object, param2:Boolean = true) : void
      {
         if(_bgmPaused)
         {
            _waitingSound = param1;
            return;
         }
         if(!_bgSound)
         {
            _bgSound = new KyoBGSounder();
         }
         if(_bgSound.sound == param1)
         {
            return;
         }
         if(_bgSound.playing)
         {
            _bgSound.stop();
         }
         if(param1)
         {
            _bgSound.play(param1,param2);
         }
      }
      
      public function pauseBGM() : void
      {
         if(_bgmPaused)
         {
            return;
         }
         _bgmPaused = true;
         if(_bgSound)
         {
            _bgSound.pause();
         }
      }
      
      public function resumeBGM() : void
      {
         if(!_bgmPaused)
         {
            return;
         }
         _bgmPaused = false;
         if(_waitingSound)
         {
            BGM(_waitingSound);
            _waitingSound = null;
            return;
         }
         if(_bgSound)
         {
            _bgSound.resume();
         }
      }
      
      public function loadFightBGM(arr:Vector.<BgmVO>, success:Function, fail:Function = null, process:Function = null) : void
      {
         var o:Object;
         var curUrl:String;
         var sndLen:int;
         var urls:Array;
         var loadNext:Function;
         var loadBack:Function;
         var loadFail:Function;
         var loadProcess:Function;
         _isLowHpBgmPlaying = false;
         if(!_soundLoader)
         {
            _soundLoader = new KyoSoundLoader();
         }
         urls = [];
         _bgmObj = {};
         for each(o in arr)
         {
            _bgmObj[o.id] = o;
            if(!_fightBgmLoaded[o.url])
            {
               urls.push(o.url);
            }
         }
         if(urls.length == 0)
         {
            if(success != null)
            {
               success();
            }
            return;
         }
         sndLen = urls.length;
         loadNext = function():void
         {
            if(urls.length < 1)
            {
               if(success != null)
               {
                  success();
               }
               loadNext = null;
               loadBack = null;
               loadFail = null;
               loadProcess = null;
               return;
            }
            curUrl = urls.shift();
            AssetManager.I.loadSound(curUrl,loadBack,loadFail,loadProcess);
         };
         loadBack = function(snd:Sound):void
         {
            _soundLoader.addSound(curUrl,snd);
            _fightBgmLoaded[curUrl] = true;
            if(loadNext != null)
            {
               loadNext();
            }
         };
         loadFail = function():void
         {
            trace("SoundCtrl.loadFightBGM fail!",curUrl);
            if(loadNext != null)
            {
               loadNext();
            }
         };
         loadProcess = function(v:Number):void
         {
            if(process != null)
            {
               process(v);
            }
         };
         loadNext();
      }
      
      public function playBossBGM(param1:Boolean) : void
      {
         playFighterBGM(param1 ? "boss_naruto" : "boss_bleach");
      }
      
      public function playFighterBGM(id:String) : Boolean
      {
         var vo:Object = _bgmObj[id];
         if(!vo || !_soundLoader)
         {
            return true;
         }
         var snd:Sound = _soundLoader.getSound(vo.url);
         if(!snd)
         {
            return true;
         }
         BGM(snd);
         return false;
      }
      
      public function playStartGameBGM() : void
      {
         _isLowHpBgmPlaying = false;
         playFighterBGM("map");
      }
      
      public function checkFighterHpBGM(enemyHpRate:Number, enemyFighterId:String) : void
      {
         if(_isLowHpBgmPlaying)
         {
            return;
         }
         if(enemyHpRate <= 0.4)
         {
            playFighterBGM(enemyFighterId);
            _isLowHpBgmPlaying = true;
         }
      }
      
      public function smartPlayGameBGM(id:String) : void
      {
         playStartGameBGM();
      }
      
      public function unloadFightBGM() : void
      {
         BGM(null);
         _bgmObj = {};
         _isLowHpBgmPlaying = false;
      }
      
      public function clearFightBGMCache() : void
      {
         if(_soundLoader)
         {
            _soundLoader.unload();
            _soundLoader = null;
         }
         _fightBgmLoaded = {};
         _bgmObj = {};
         _isLowHpBgmPlaying = false;
      }
      
      public function sndSelect() : void
      {
         playSwcSound(snd_menu1);
      }
      
      public function sndConfrim() : void
      {
         playSwcSound(snd_menu2);
      }
   }
}

