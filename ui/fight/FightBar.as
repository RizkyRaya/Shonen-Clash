package net.play5d.game.bvn.ui.fight
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import net.play5d.game.bvn.data.GameMode;
   import net.play5d.game.bvn.data.GameRunFighterGroup;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.ui.WinUI;
   
   public class FightBar
   {
      
      private var _ui:hpbar_mc;
      
      private var _faceGroup1:FightFaceGroup;
      
      private var _faceGroup2:FightFaceGroup;
      
      private var _hpBar1:FighterHpBar;
      
      private var _hpBar2:FighterHpBar;
      
      private var _energyBar1:EnergyBar;
      
      private var _energyBar2:EnergyBar;
      
      private var _score:FightScoreUI;
      
      private var _isFadIn:Boolean;
      
      private var _timerMc:FightTimeUI;
      
      private var _winUI1:WinUI;
      
      private var _winUI2:WinUI;
      
      private var _isRenderAnimate:Boolean = false;
      
      private var _miniUi1:DisplayObject;
      
      private var _miniUi2:DisplayObject;
      
      private var _p1Partner:FighterMain;
      
      private var _p2Partner:FighterMain;
      
      private var _miniInner1:DisplayObject;
      
      private var _miniInner2:DisplayObject;
      
      private var _p1HpCache:Number = -1;
      
      private var _p2HpCache:Number = -1;
      
      public function FightBar(param1:hpbar_mc)
      {
         var p3MC:*;
         var p4MC:*;
         var mcContainer1:DisplayObjectContainer;
         var mcContainer2:DisplayObjectContainer;
         super();
         _ui = param1;
         _faceGroup1 = new FightFaceGroup(_ui.face1);
         _faceGroup2 = new FightFaceGroup(_ui.face2);
         _faceGroup2.setDirect(-1);
         _hpBar1 = new FighterHpBar(_ui.bar1);
         _hpBar2 = new FighterHpBar(_ui.bar2);
         _hpBar2.setDirect(-1);
         _energyBar1 = new EnergyBar(_ui.energy1);
         _energyBar2 = new EnergyBar(_ui.energy2);
         _energyBar2.setDirect(-1);
         _winUI1 = new WinUI(_ui.win_p1,1);
         _winUI2 = new WinUI(_ui.win_p2,2);
         _timerMc = new FightTimeUI(_ui.timemc);
         try
         {
            p3MC = _ui.getChildByName("hpbar_p3_mc");
            if(p3MC)
            {
               _miniUi1 = p3MC as DisplayObject;
               if(_miniUi1)
               {
                  _miniUi1.visible = false;
                  fixMirroredText(_miniUi1);
                  mcContainer1 = _miniUi1 as DisplayObjectContainer;
                  if(mcContainer1)
                  {
                     _miniInner1 = mcContainer1.getChildByName("bar");
                     if(!_miniInner1)
                     {
                        _miniInner1 = mcContainer1.getChildByName("hp");
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            p4MC = _ui.getChildByName("hpbar_p4_mc");
            if(p4MC)
            {
               _miniUi2 = p4MC as DisplayObject;
               if(_miniUi2)
               {
                  _miniUi2.visible = false;
                  fixMirroredText(_miniUi2);
                  mcContainer2 = _miniUi2 as DisplayObjectContainer;
                  if(mcContainer2)
                  {
                     _miniInner2 = mcContainer2.getChildByName("bar");
                     if(!_miniInner2)
                     {
                        _miniInner2 = mcContainer2.getChildByName("hp");
                     }
                  }
               }
            }
         }
         catch(e:Error)
         {
         }
         _ui.addEventListener("complete",uiPlayComplete);
      }
      
      public function get ui() : DisplayObject
      {
         return _ui;
      }
      
      private function fixMirroredText(uiObj:DisplayObject) : void
      {
         if(!uiObj)
         {
            return;
         }
         var container:DisplayObjectContainer = uiObj as DisplayObjectContainer;
         if(container)
         {
            var i:int = 0;
            while(i < container.numChildren)
            {
               fixMirroredText(container.getChildAt(i));
               i++;
            }
         }
         if(uiObj is TextField)
         {
            var tf:TextField = uiObj as TextField;
            if(isNetMirrored(tf))
            {
               tf.scaleX = -tf.scaleX;
               tf.x += tf.width;
            }
         }
      }
      
      private function isNetMirrored(obj:DisplayObject) : Boolean
      {
         var mirrored:Boolean = false;
         var curr:DisplayObject = obj;
         while(curr)
         {
            if(curr.scaleX < 0)
            {
               mirrored = !mirrored;
            }
            curr = curr.parent;
         }
         return mirrored;
      }
      
      public function destory() : void
      {
         if(_ui)
         {
            _ui.removeEventListener("complete",uiPlayComplete);
            _ui.gotoAndStop("destory");
            _ui = null;
         }
         if(_hpBar1)
         {
            _hpBar1.destory();
            _hpBar1 = null;
         }
         if(_hpBar2)
         {
            _hpBar2.destory();
            _hpBar2 = null;
         }
         if(_energyBar1)
         {
            _energyBar1.destory();
            _energyBar1 = null;
         }
         if(_energyBar2)
         {
            _energyBar2.destory();
            _energyBar2 = null;
         }
         _miniUi1 = null;
         _miniUi2 = null;
         _miniInner1 = null;
         _miniInner2 = null;
         _p1Partner = null;
         _p2Partner = null;
      }
      
      private function uiPlayComplete(param1:Event) : void
      {
         _ui.visible = _isFadIn;
      }
      
      public function initScore() : void
      {
         if(_ui.scoremc)
         {
            _ui.scoremc.visible = true;
            _score = new FightScoreUI(_ui.scoremc);
         }
      }
      
      public function setScore(param1:int) : void
      {
         if(_score)
         {
            _score.setScore(param1);
         }
      }
      
      public function showWin(param1:FighterMain, param2:int) : void
      {
         var _loc3_:WinUI = null;
         if(!param1 || param2 < 0 || param2 > 2)
         {
            return;
         }
         switch(param1.team.id - 1)
         {
            case 0:
               _loc3_ = _winUI1;
               break;
            case 1:
               _loc3_ = _winUI2;
         }
         if(_loc3_)
         {
            _loc3_.show(param1.data,param2);
         }
      }
      
      public function setFighter(param1:GameRunFighterGroup = null, param2:GameRunFighterGroup = null) : void
      {
         var isTagMode:Boolean = GameMode.currentMode == 14 || GameMode.currentMode == 15 || GameMode.currentMode == 24 || GameMode.currentMode == 25;
         _p1HpCache = -1;
         _p2HpCache = -1;
         if(param1)
         {
            _faceGroup1.setFighter(param1);
            if(param1.currentFighter)
            {
               _hpBar1.setFighter(param1.currentFighter);
               _energyBar1.setFighter(param1.currentFighter);
            }
            _p1Partner = getSecondaryFighter(param1);
            if(_miniUi1)
            {
               _miniUi1.visible = _isFadIn && _p1Partner != null && isTagMode;
               _miniUi1.alpha = 1;
            }
         }
         if(param2)
         {
            _faceGroup2.setFighter(param2);
            if(param2.currentFighter)
            {
               _hpBar2.setFighter(param2.currentFighter);
               _energyBar2.setFighter(param2.currentFighter);
            }
            _p2Partner = getSecondaryFighter(param2);
            if(_miniUi2)
            {
               _miniUi2.visible = _isFadIn && _p2Partner != null && isTagMode;
               _miniUi2.alpha = 1;
            }
         }
      }
      
      private function getSecondaryFighter(group:GameRunFighterGroup) : FighterMain
      {
         var holds:Vector.<FighterMain>;
         try
         {
            if(group["nextFighter1"])
            {
               return group["nextFighter1"];
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            if(group["nextFighter2"])
            {
               return group["nextFighter2"];
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            if(group["fighter2"])
            {
               return group["fighter2"];
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            if(group["fiter2"])
            {
               return group["fiter2"];
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            if(group["nextFighter"])
            {
               return group["nextFighter"];
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            holds = group.getHoldFighters();
            if(holds && holds.length > 0)
            {
               return holds[0];
            }
         }
         catch(e:Error)
         {
         }
         return null;
      }
      
      public function render() : void
      {
         _hpBar1.render();
         _hpBar2.render();
         if(_miniUi1 && _miniUi1.visible && _p1Partner)
         {
            renderMiniBar(_miniUi1,_p1Partner,_miniInner1,true);
         }
         if(_miniUi2 && _miniUi2.visible && _p2Partner)
         {
            renderMiniBar(_miniUi2,_p2Partner,_miniInner2,false);
         }
         _energyBar1.render();
         _energyBar2.render();
         _timerMc.render();
      }
      
      private function renderMiniBar(uiObj:DisplayObject, fighter:FighterMain, innerBar:DisplayObject, isP1:Boolean) : void
      {
         if(!fighter || fighter.hpMax <= 0)
         {
            return;
         }
         var currentHp:Number = fighter.hp;
         var cachedHp:Number = isP1 ? _p1HpCache : _p2HpCache;
         if(currentHp == cachedHp)
         {
            return;
         }
         if(isP1)
         {
            _p1HpCache = currentHp;
         }
         else
         {
            _p2HpCache = currentHp;
         }
         var rate:Number = currentHp / fighter.hpMax;
         if(rate < 0)
         {
            rate = 0;
         }
         else if(rate > 1)
         {
            rate = 1;
         }
         if(innerBar)
         {
            innerBar.scaleX = rate;
         }
         else
         {
            var mc:MovieClip = uiObj as MovieClip;
            if(mc)
            {
               var frameRate:int = Math.round(rate * mc.totalFrames);
               if(frameRate < 1)
               {
                  frameRate = 1;
               }
               mc.gotoAndStop(frameRate);
            }
         }
      }
      
      public function fadIn(param1:Boolean) : void
      {
         if(_isFadIn)
         {
            return;
         }
         _isFadIn = true;
         _ui.visible = true;
         if(param1)
         {
            _ui.gotoAndStop("fadin");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.gotoAndStop("fadin_fin");
         }
         var isTagMode:Boolean = GameMode.currentMode == 14 || GameMode.currentMode == 15 || GameMode.currentMode == 24 || GameMode.currentMode == 25;
         if(_miniUi1)
         {
            _miniUi1.visible = _p1Partner != null && isTagMode;
         }
         if(_miniUi2)
         {
            _miniUi2.visible = _p2Partner != null && isTagMode;
         }
      }
      
      public function fadOut(param1:Boolean) : void
      {
         if(!_isFadIn)
         {
            return;
         }
         _isFadIn = false;
         if(param1)
         {
            _ui.gotoAndStop("fadout");
            _isRenderAnimate = true;
         }
         else
         {
            _ui.visible = false;
         }
         if(_miniUi1)
         {
            _miniUi1.visible = false;
         }
         if(_miniUi2)
         {
            _miniUi2.visible = false;
         }
      }
      
      public function renderAnimate() : void
      {
         if(!_isRenderAnimate)
         {
            return;
         }
         var _loc1_:String = _ui.currentFrameLabel;
         if(_loc1_ == "fadin_fin" || _loc1_ == "fadout_fin")
         {
            _isRenderAnimate = false;
            return;
         }
         _ui.nextFrame();
      }
   }
}

