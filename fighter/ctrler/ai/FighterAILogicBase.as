package net.play5d.game.bvn.fighter.ctrler.ai
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import net.play5d.game.bvn.fighter.FighterAction;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class FighterAILogicBase
   {
      
      protected var AILevel:int;
      
      protected var _fighter:FighterMain;
      
      protected var _fighterAction:FighterAction;
      
      protected var _target:IGameSprite;
      
      protected var _targetFighter:FighterMain;
      
      protected var _isConting:Boolean;
      
      private var _breakActCache:Object = {};
      
      private var _hitDownActCache:Object = {};
      
      private var _contOrder:Array = [];
      
      public function FighterAILogicBase(param1:int, param2:FighterMain)
      {
         super();
         this.AILevel = param1;
         _fighter = param2;
      }
      
      public function destory() : void
      {
         _fighter = null;
         _fighterAction = null;
         _target = null;
         _targetFighter = null;
         _breakActCache = null;
         _hitDownActCache = null;
      }
      
      protected function addContOrder(param1:String, param2:int) : void
      {
         var _loc3_:int = _contOrder.indexOf(param1);
         if(_loc3_ != -1)
         {
            _contOrder[_loc3_].order = param2;
         }
         else
         {
            _contOrder.push({
               "id":param1,
               "order":param2
            });
         }
      }
      
      protected function updateConting() : void
      {
         _isConting = _fighter.actionState == 10 || _fighter.actionState == 11 || _fighter.actionState == 12 || _fighter.actionState == 13;
      }
      
      public function render() : void
      {
         _target = _fighter.getCurrentTarget();
         _targetFighter = _target as FighterMain;
         updateConting();
         if(!_fighterAction)
         {
            _fighterAction = _fighter.getCtrler().getMcCtrl().getAction();
         }
         updateActionAI();
         updateContOrder();
      }
      
      private function updateContOrder() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         if(_contOrder.length < 1)
         {
            return;
         }
         _contOrder.sortOn("order",2);
         _loc1_ = 1;
         while(_loc1_ < _contOrder.length)
         {
            _loc2_ = _contOrder[_loc1_].id;
            this[_loc2_] = false;
            _loc1_++;
         }
         _contOrder = [];
      }
      
      protected function updateActionAI() : void
      {
      }
      
      protected function getAIByFighterState(param1:Object) : Boolean
      {
         var _loc2_:Array = null;
         var _loc4_:Array = param1.defult;
         var _loc3_:int = int(_targetFighter ? _targetFighter.actionState : -1);
         _loc2_ = param1 && param1[_loc3_] ? param1[_loc3_] : _loc4_;
         return getAIResult(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5]);
      }
      
      protected function getAIResult(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : Boolean
      {
         var _loc7_:Number = Math.random() * 10;
         switch(AILevel)
         {
            case 0:
            case 1:
               return _loc7_ < param1;
            case 2:
               return _loc7_ < param2;
            case 3:
               return _loc7_ < param3;
            case 4:
               return _loc7_ < param4;
            case 5:
               return _loc7_ < param5;
            default:
               return _loc7_ < param6;
         }
      }
      
      protected function getTargetDistance(param1:IGameSprite) : Point
      {
         var _loc2_:Number = Math.abs(param1.x - _fighter.x);
         var _loc3_:Number = Math.abs(param1.y - _fighter.y);
         return new Point(_loc2_,_loc3_);
      }
      
      final public function targetInDistance(param1:IGameSprite, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:Point = getTargetDistance(param1);
         return _loc4_.x <= param2 && _loc4_.y <= param3;
      }
      
      final public function targetInRange(param1:String) : Boolean
      {
         var _loc2_:Rectangle = _target.getBodyArea();
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:Rectangle = _fighter.getHitRange(param1);
         if(!_loc3_)
         {
            return false;
         }
         return _loc2_.intersection(_loc3_).isEmpty() == false;
      }
      
      protected function mergeRateObject(param1:Object, param2:Object) : void
      {
         var _loc4_:int = 0;
         for(var _loc3_ in param2)
         {
            if(param1[_loc3_] == undefined)
            {
               param1[_loc3_] = param2[_loc3_];
            }
            else
            {
               while(_loc4_ < param2[_loc3_].length)
               {
                  if(param1[_loc3_][_loc4_] < param2[_loc3_][_loc4_])
                  {
                     param1[_loc3_][_loc4_] = param2[_loc3_][_loc4_];
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      protected function isBreakAct(param1:String) : Boolean
      {
         if(_breakActCache[param1] != undefined)
         {
            return _breakActCache[param1];
         }
         var _loc2_:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(param1);
         for each(var _loc3_ in _loc2_)
         {
            if(_loc3_.isBreakDef)
            {
               _breakActCache[param1] = true;
               return true;
            }
         }
         _breakActCache[param1] = false;
         return false;
      }
      
      protected function isHitDownAct(param1:String) : Boolean
      {
         if(_hitDownActCache[param1] != undefined)
         {
            return _hitDownActCache[param1];
         }
         var _loc2_:Vector.<HitVO> = _fighter.getCtrler().hitModel.getHitVOLike(param1);
         for each(var _loc3_ in _loc2_)
         {
            if(_loc3_.hurtType == 1)
            {
               _breakActCache[param1] = true;
               return true;
            }
         }
         _breakActCache[param1] = false;
         return false;
      }
      
      protected function targetCanBeHit() : Boolean
      {
         if(!_target)
         {
            return false;
         }
         if(_targetFighter)
         {
            return _targetFighter.isAllowBeHit;
         }
         return _target.getBodyArea() != null;
      }
   }
}

