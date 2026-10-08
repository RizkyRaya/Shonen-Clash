package net.play5d.game.bvn.fighter.ctrler
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.BaseGameSprite;
   
   public class FighterEffectCtrl
   {
      
      private var _target:BaseGameSprite;
      
      private var _targetDisplay:DisplayObject;
      
      private var _inGhostStep:Boolean;
      
      private var _faceObj:Object = {};
      
      private var _isShakeIng:Boolean;
      
      private var _isShadowIng:Boolean;
      
      private var _isGlowIng:Boolean;
      
      public function FighterEffectCtrl(param1:BaseGameSprite)
      {
         super();
         _target = param1;
         _targetDisplay = param1.getDisplay();
      }
      
      public function destory() : void
      {
         _target = null;
         _targetDisplay = null;
         _faceObj = null;
      }
      
      public function setBishaFace(param1:String, param2:Class) : void
      {
         _faceObj[param1] = param2;
      }
      
      private function getFace(param1:String) : DisplayObject
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:Class = _faceObj[param1];
         if(!_loc2_)
         {
            Debugger.errorMsg("未定义必杀特写:" + param1);
            return null;
         }
         var _loc3_:BitmapData = new _loc2_();
         var _loc4_:Bitmap = new Bitmap(_loc3_);
         _loc4_.smoothing = false;
         return _loc4_;
      }
      
      public function shine(param1:uint = 16777215) : void
      {
      }
      
      public function shake(param1:Number = 0, param2:Number = 3, param3:Number = 0) : void
      {
      }
      
      public function startShake(param1:Number = 0, param2:Number = 3) : void
      {
      }
      
      public function endShake() : void
      {
      }
      
      public function shadow(param1:int = 0, param2:int = 0, param3:int = 0) : void
      {
      }
      
      public function endShadow() : void
      {
      }
      
      public function dash(param1:Boolean = true) : void
      {
         if(_target.isInAir)
         {
            EffectCtrl.I.doEffectById("dash_air",_target.x,_target.y,_target.direct,null,param1);
         }
         else
         {
            EffectCtrl.I.doEffectById("dash",_target.x,_target.y,_target.direct,null,param1);
         }
      }
      
      public function bisha(param1:Boolean = false, param2:String = null) : void
      {
         var _loc3_:DisplayObject = getFace(param2);
         EffectCtrl.I.bisha(_target,param1,_loc3_);
      }
      
      public function endBisha() : void
      {
         EffectCtrl.I.endBisha(_target);
      }
      
      public function startWanKai(param1:String = null) : void
      {
         var _loc2_:DisplayObject = param1 ? getFace(param1) : null;
         EffectCtrl.I.wanKai(_target as FighterMain,_loc2_);
      }
      
      public function endWanKai() : void
      {
         if((_target as FighterMain).actionState == 50)
         {
            EffectCtrl.I.endWanKai(_target as FighterMain);
         }
      }
      
      public function walk() : void
      {
         if(_inGhostStep)
         {
            EffectCtrl.I.doEffectById("ghost_step",_target.x,_target.y,_target.direct);
         }
         else
         {
            SoundCtrl.I.playAssetSoundRandom("step1","step2","step3");
         }
      }
      
      public function jump() : void
      {
         EffectCtrl.I.jumpEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function jumpAir() : void
      {
         EffectCtrl.I.jumpAirEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function touchFloor() : void
      {
         EffectCtrl.I.touchFloorEffect(_targetDisplay.x,_targetDisplay.y);
      }
      
      public function hitFloor(param1:int, param2:Number = 0) : void
      {
         EffectCtrl.I.hitFloorEffect(param1,_targetDisplay.x,_targetDisplay.y);
      }
      
      public function slowDown(param1:Number) : void
      {
         EffectCtrl.I.slowDown(1.5,param1 * 1000);
      }
      
      public function energyExplode() : void
      {
         EffectCtrl.I.energyExplode(_target);
      }
      
      public function replaceSkill() : void
      {
         EffectCtrl.I.replaceSkill(_target);
      }
      
      public function ghostStep() : void
      {
         _inGhostStep = true;
         EffectCtrl.I.ghostStep(_target);
      }
      
      public function endGhostStep() : void
      {
         _inGhostStep = false;
         EffectCtrl.I.endGhostStep(_target);
      }
      
      public function startGlow(param1:uint = 16777215) : void
      {
      }
      
      public function endGlow() : void
      {
      }
      
      public function clean() : void
      {
         endGhostStep();
      }
   }
}

