package net.play5d.game.bvn.interfaces
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   import net.play5d.game.bvn.GameConfig;
   import net.play5d.game.bvn.ctrl.GameRender;
   import net.play5d.game.bvn.data.TeamVO;
   import net.play5d.game.bvn.fighter.models.HitVO;
   import net.play5d.kyo.utils.UUID;
   
   public class BaseGameSprite extends EventDispatcher implements IGameSprite
   {
      
      public var isInAir:Boolean;
      
      public var isTouchBottom:Boolean;
      
      public var isAllowBeHit:Boolean = true;
      
      public var isCross:Boolean = false;
      
      public var isAlive:Boolean = true;
      
      public var isAllowLoseHP:Boolean = true;
      
      public var isApplyG:Boolean = true;
      
      public var heavy:Number = 2;
      
      public var hp:Number = 1000;
      
      public var hpMax:Number = 1000;
      
      public var defense:Number = 0;
      
      public var isAllowCrossX:Boolean = false;
      
      public var isAllowCrossBottom:Boolean = false;
      
      private var _attackRate:Number = 1;
      
      private var _defenseRate:Number = 1;
      
      public var id:String = UUID.create();
      
      protected var _x:Number = 0;
      
      protected var _y:Number = 0;
      
      protected var _g:Number = 0;
      
      private var _direct:int = 1;
      
      private var _scale:Number = 1;
      
      protected var _mainMc:MovieClip;
      
      protected var _area:Rectangle;
      
      private var _cacheArea:Rectangle = new Rectangle();
      
      protected var _isTouchSide:Boolean = false;
      
      protected var _isActive:Boolean = false;
      
      protected var _destoryed:Boolean;
      
      private var _team:TeamVO;
      
      private var _speedPlus:Number = GameConfig.SPEED_PLUS;
      
      private var _dampingRate:Number = 1;
      
      private var _velocity:Point = new Point();
      
      private var _damping:Point = new Point();
      
      private var _velocity2:Point = new Point();
      
      private var _damping2:Point = new Point();
      
      private var _recoverableHp:Number = 1000;
      
      private var _lastHitTime:int = 0;
      
      private var _regenDelay:int = 3000;
      
      private var _regenAmount:Number = 0.1;
      
      private var _frameFuncs:Array = [];
      
      private var _frameAnimateFuncs:Array = [];
      
      public function BaseGameSprite(param1:MovieClip)
      {
         super();
         _mainMc = param1;
         if(_mainMc)
         {
            _area = _mainMc.getBounds(_mainMc);
         }
      }
      
      public function getActive() : Boolean
      {
         return _isActive;
      }
      
      public function setActive(param1:Boolean) : void
      {
         _isActive = param1;
      }
      
      public function get attackRate() : Number
      {
         if(hp > 0 && hpMax > 0 && hp / hpMax <= 0.3)
         {
            return _attackRate * 1.3;
         }
         return _attackRate;
      }
      
      public function set attackRate(param1:Number) : void
      {
         _attackRate = param1;
      }
      
      public function get defenseRate() : Number
      {
         if(hp > 0 && hpMax > 0 && hp / hpMax <= 0.3)
         {
            return _defenseRate + 0.3;
         }
         return _defenseRate;
      }
      
      public function set defenseRate(param1:Number) : void
      {
         _defenseRate = param1;
      }
      
      public function get mc() : MovieClip
      {
         return _mainMc;
      }
      
      public function get x() : Number
      {
         return _x;
      }
      
      public function set x(param1:Number) : void
      {
         _x = param1;
      }
      
      public function get y() : Number
      {
         return _y;
      }
      
      public function set y(param1:Number) : void
      {
         _y = param1;
      }
      
      public function get scale() : Number
      {
         return _scale;
      }
      
      public function set scale(param1:Number) : void
      {
         _scale = param1;
         if(_mainMc)
         {
            _mainMc.scaleX = _direct * param1;
            _mainMc.scaleY = param1;
         }
      }
      
      public function get direct() : int
      {
         return _direct;
      }
      
      public function set direct(param1:int) : void
      {
         _direct = param1;
         if(_mainMc)
         {
            _mainMc.scaleX = _direct * _scale;
         }
      }
      
      public function get team() : TeamVO
      {
         return _team;
      }
      
      public function set team(param1:TeamVO) : void
      {
         _team = param1;
      }
      
      public function updatePosition() : void
      {
         if(!_mainMc)
         {
            return;
         }
         _mainMc.x = _x;
         _mainMc.y = _y;
      }
      
      public function setVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = null;
         if(_mainMc)
         {
            _loc2_ = _mainMc.soundTransform;
            if(_loc2_)
            {
               _loc2_.volume = param1;
               _mainMc.soundTransform = _loc2_;
            }
         }
      }
      
      public function isDestoryed() : Boolean
      {
         return _destoryed;
      }
      
      public function destory(param1:Boolean = true) : void
      {
         if(_destoryed)
         {
            return;
         }
         _destoryed = true;
         isAlive = false;
         isAllowBeHit = false;
         isInAir = false;
         isTouchBottom = false;
         isCross = false;
         stopRenderSelf();
         if(_frameFuncs)
         {
            _frameFuncs.length = 0;
            _frameFuncs = null;
         }
         if(_frameAnimateFuncs)
         {
            _frameAnimateFuncs.length = 0;
            _frameAnimateFuncs = null;
         }
         if(_velocity)
         {
            _velocity.x = 0;
            _velocity.y = 0;
            _velocity = null;
         }
         if(_velocity2)
         {
            _velocity2.x = 0;
            _velocity2.y = 0;
            _velocity2 = null;
         }
         if(_damping)
         {
            _damping.x = 0;
            _damping.y = 0;
            _damping = null;
         }
         if(_damping2)
         {
            _damping2.x = 0;
            _damping2.y = 0;
            _damping2 = null;
         }
         _team = null;
         _area = null;
         _g = 0;
         _x = 0;
         _y = 0;
         if(param1)
         {
            if(_mainMc)
            {
               try
               {
                  _mainMc.filters = null;
               }
               catch(e:Error)
               {
               }
               try
               {
                  _mainMc.stopAllMovieClips();
               }
               catch(e:Error)
               {
               }
               try
               {
                  if(_mainMc.parent)
                  {
                     _mainMc.parent.removeChild(_mainMc);
                  }
               }
               catch(e:Error)
               {
               }
               _mainMc = null;
            }
         }
      }
      
      public function loseHp(param1:Number) : void
      {
         if(!isAllowLoseHP)
         {
            return;
         }
         var currentTime:int = getTimer();
         if(currentTime - _lastHitTime > _regenDelay)
         {
            _recoverableHp = hp;
         }
         _lastHitTime = currentTime;
         var _loc3_:Number = 2 - defenseRate;
         if(_loc3_ < 0.1)
         {
            _loc3_ = 0.1;
         }
         if(_loc3_ > 1)
         {
            _loc3_ = 1;
         }
         var _loc2_:Number = param1 * _loc3_ - defense;
         if(_loc2_ < 0)
         {
            return;
         }
         hp -= _loc2_;
         if(hp < 0)
         {
            hp = 0;
         }
      }
      
      public function renderAnimate() : void
      {
         if(_destoryed)
         {
            return;
         }
         renderAnimateFrameOut();
      }
      
      public function render() : void
      {
         if(_destoryed || !_mainMc)
         {
            return;
         }
         renderVelocity();
         renderFrameOut();
         if(hp > 0 && hp < _recoverableHp)
         {
            if(getTimer() - _lastHitTime > _regenDelay)
            {
               hp += _regenAmount;
               if(hp > _recoverableHp)
               {
                  hp = _recoverableHp;
               }
               if(hp > hpMax)
               {
                  hp = hpMax;
               }
            }
         }
         _mainMc.x = _x;
         _mainMc.y = _y;
      }
      
      public function getDisplay() : DisplayObject
      {
         return _mainMc;
      }
      
      public function move(param1:Number = 0, param2:Number = 0) : void
      {
         if(param1 != 0)
         {
            _x += param1 * _speedPlus;
         }
         if(param2 != 0)
         {
            _y += param2 * _speedPlus;
         }
      }
      
      public function setSpeedRate(param1:Number) : void
      {
         _speedPlus = param1;
         _dampingRate = param1 / GameConfig.SPEED_PLUS_DEFAULT;
      }
      
      public function getVelocity() : Point
      {
         return _velocity;
      }
      
      public function getVecX() : Number
      {
         return _velocity.x;
      }
      
      public function getVecY() : Number
      {
         return _velocity.y;
      }
      
      public function setVecX(param1:Number) : void
      {
         _velocity.x = param1;
      }
      
      public function setVecY(param1:Number) : void
      {
         _velocity.y = param1;
      }
      
      public function setVelocity(param1:Number = 0, param2:Number = 0) : void
      {
         _velocity.x = param1;
         _velocity.y = param2;
         setDamping(0,0);
      }
      
      public function addVelocity(param1:Number = 0, param2:Number = 0) : void
      {
         _velocity.x += param1;
         _velocity.y += param2;
      }
      
      public function setVec2(param1:Number = 0, param2:Number = 0, param3:Number = 0, param4:Number = 0) : void
      {
         _velocity2.x = param1;
         _velocity2.y = param2;
         _damping2.x = param3 * GameConfig.SPEED_PLUS_DEFAULT * 6;
         _damping2.y = param4 * GameConfig.SPEED_PLUS_DEFAULT * 6;
      }
      
      public function getVec2() : Point
      {
         return _velocity2;
      }
      
      public function getDampingX() : Number
      {
         return _damping.x;
      }
      
      public function getDampingY() : Number
      {
         return _damping.y;
      }
      
      public function setDampingX(param1:Number) : void
      {
         _damping.x = param1;
      }
      
      public function setDampingY(param1:Number) : void
      {
         _damping.y = param1;
      }
      
      public function setDamping(param1:Number = 0, param2:Number = 0) : void
      {
         _damping.x = param1 * GameConfig.SPEED_PLUS_DEFAULT * 2;
         _damping.y = param2 * GameConfig.SPEED_PLUS_DEFAULT * 2;
      }
      
      public function addDamping(param1:Number = 0, param2:Number = 0) : void
      {
         _damping.x += param1;
         _damping.y += param2;
      }
      
      private function renderVelocity() : void
      {
         var moveX:Number = 0;
         var moveY:Number = 0;
         var rate:Number = _dampingRate;
         if(_velocity.x != 0)
         {
            moveX += _velocity.x;
            if(_damping.x > 0)
            {
               if(_velocity.x > 0)
               {
                  _velocity.x -= _damping.x * rate;
                  if(_velocity.x < 0)
                  {
                     _velocity.x = 0;
                  }
               }
               else
               {
                  _velocity.x += _damping.x * rate;
                  if(_velocity.x > 0)
                  {
                     _velocity.x = 0;
                  }
               }
            }
         }
         if(_velocity.y != 0)
         {
            moveY += _velocity.y;
            if(_damping.y > 0)
            {
               if(_velocity.y > 0)
               {
                  _velocity.y -= _damping.y * rate;
                  if(_velocity.y < 0)
                  {
                     _velocity.y = 0;
                  }
               }
               else
               {
                  _velocity.y += _damping.y * rate;
                  if(_velocity.y > 0)
                  {
                     _velocity.y = 0;
                  }
               }
            }
         }
         if(_velocity2.x != 0)
         {
            moveX += _velocity2.x;
            if(_damping2.x > 0)
            {
               if(_velocity2.x > 0)
               {
                  _velocity2.x -= _damping2.x * rate;
                  if(_velocity2.x < 0)
                  {
                     _velocity2.x = 0;
                  }
               }
               else
               {
                  _velocity2.x += _damping2.x * rate;
                  if(_velocity2.x > 0)
                  {
                     _velocity2.x = 0;
                  }
               }
            }
         }
         if(_velocity2.y != 0)
         {
            moveY += _velocity2.y;
            if(_damping2.y > 0)
            {
               if(_velocity2.y > 0)
               {
                  _velocity2.y -= _damping2.y * rate;
                  if(_velocity2.y < 0)
                  {
                     _velocity2.y = 0;
                  }
               }
               else
               {
                  _velocity2.y += _damping2.y * rate;
                  if(_velocity2.y > 0)
                  {
                     _velocity2.y = 0;
                  }
               }
            }
         }
         if(moveX != 0)
         {
            _x += moveX * _speedPlus;
         }
         if(moveY != 0)
         {
            _y += moveY * _speedPlus;
         }
      }
      
      public function applayG(param1:Number) : void
      {
         var _loc2_:Number = Number(NaN);
         if(!isApplyG)
         {
            _g = 0;
            return;
         }
         if(_velocity.y < 0)
         {
            _g = 0;
            return;
         }
         if(_g < param1)
         {
            _loc2_ = 1.2 * GameConfig.SPEED_PLUS;
            _g += _loc2_;
            if(_g > param1)
            {
               _g = param1;
            }
         }
         move(0,_g);
      }
      
      public function setInAir(param1:Boolean) : void
      {
         if(!param1)
         {
            _g = 4;
         }
         isInAir = param1;
      }
      
      public function hit(param1:HitVO, param2:IGameSprite) : void
      {
         var _loc5_:DisplayObject = null;
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObjectContainer = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2 && param2.getDisplay())
         {
            _loc5_ = getDisplay();
            _loc3_ = param2.getDisplay();
            if(_loc5_ && _loc3_ && _loc5_.parent && _loc5_.parent == _loc3_.parent)
            {
               _loc4_ = _loc5_.parent;
               _loc6_ = _loc4_.getChildIndex(_loc5_);
               _loc7_ = _loc4_.getChildIndex(_loc3_);
               if(_loc6_ != -1 && _loc7_ != -1 && _loc6_ < _loc7_)
               {
                  _loc4_.setChildIndex(_loc3_,_loc6_);
                  _loc4_.setChildIndex(_loc5_,_loc7_);
               }
            }
         }
      }
      
      public function beHit(param1:HitVO, param2:Rectangle = null) : void
      {
      }
      
      public function getCurrentHits() : Array
      {
         return null;
      }
      
      public function getArea() : Rectangle
      {
         if(!_area)
         {
            return null;
         }
         _cacheArea.x = _area.x + _x;
         _cacheArea.y = _area.y + _y;
         _cacheArea.width = _area.width;
         _cacheArea.height = _area.height;
         return _cacheArea;
      }
      
      public function getBodyArea() : Rectangle
      {
         return null;
      }
      
      public function allowCrossMapXY() : Boolean
      {
         return isAllowCrossX;
      }
      
      public function allowCrossMapBottom() : Boolean
      {
         return isAllowCrossBottom;
      }
      
      public function getIsTouchSide() : Boolean
      {
         return _isTouchSide;
      }
      
      public function setIsTouchSide(param1:Boolean) : void
      {
         _isTouchSide = param1;
      }
      
      public function addHp(param1:Number) : void
      {
         hp += param1;
         if(hp > hpMax)
         {
            hp = hpMax;
         }
      }
      
      public function delayCall(param1:Function, param2:int) : void
      {
         _frameFuncs.push({
            "func":param1,
            "frame":param2
         });
      }
      
      public function renderSelf() : void
      {
         GameRender.add(renderSelfEnterFrame,this);
      }
      
      private function renderSelfEnterFrame() : void
      {
         if(_destoryed)
         {
            return;
         }
         render();
         renderAnimate();
      }
      
      public function stopRenderSelf() : void
      {
         GameRender.remove(renderSelfEnterFrame,this);
      }
      
      public function setAnimateFrameOut(param1:Function, param2:int) : void
      {
         _frameAnimateFuncs.push({
            "func":param1,
            "frame":param2
         });
      }
      
      private function renderAnimateFrameOut() : void
      {
         if(!_frameAnimateFuncs || _frameAnimateFuncs.length < 1)
         {
            return;
         }
         var i:int = _frameAnimateFuncs.length - 1;
         while(i >= 0)
         {
            var obj:Object = _frameAnimateFuncs[i];
            var _loc3_:Object = obj;
            var _loc4_:Number = Number(_loc3_.frame) - 1;
            _loc3_.frame = _loc4_;
            if(obj.frame < 1)
            {
               obj.func();
               _frameAnimateFuncs.splice(i,1);
            }
            i--;
         }
      }
      
      private function renderFrameOut() : void
      {
         if(!_frameFuncs || _frameFuncs.length < 1)
         {
            return;
         }
         var i:int = _frameFuncs.length - 1;
         while(i >= 0)
         {
            var obj:Object = _frameFuncs[i];
            var _loc3_:Object = obj;
            var _loc4_:Number = Number(_loc3_.frame) - 1;
            _loc3_.frame = _loc4_;
            if(obj.frame < 1)
            {
               obj.func();
               _frameFuncs.splice(i,1);
            }
            i--;
         }
      }
   }
}

