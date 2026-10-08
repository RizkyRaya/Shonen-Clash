package net.play5d.game.bvn.mob.ctrls
{
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.utils.LANUtils;
   
   public class LockFrameClientLogic
   {
      
      public var enabled:Boolean = true;
      
      private var _updateCache:Object = {};
      
      private var _clientK:int;
      
      private var _serverK:int;
      
      private var _clientFrame:int;
      
      private var _serverFrame:int;
      
      private var _serverNextFrame:int;
      
      private var _lastSendK:int;
      
      private var _delayTimer:int = 0;
      
      private var _sendAnyWay:Boolean = false;
      
      private var _sendStartFrame:int = 0;
      
      public function LockFrameClientLogic()
      {
         super();
      }
      
      public function reset() : void
      {
         _updateCache = {};
         _clientK = 0;
         _serverK = 0;
         _clientFrame = 0;
         _serverFrame = 0;
         _serverNextFrame = 0;
         _lastSendK = 0;
         _sendStartFrame = 0;
      }
      
      public function dispose() : void
      {
         _updateCache = {};
      }
      
      public function receiveUpdate(param1:ByteArray) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         param1.position = 0;
         var _loc3_:int = param1.readByte();
         if(_loc3_ != 9)
         {
            return false;
         }
         _serverFrame = param1.readShort();
         _serverK = param1.readShort();
         _clientK = param1.readShort();
         _serverNextFrame = _serverFrame + LANUtils.LOCK_KEYFRAME;
         cacheUpdate();
         var _loc2_:int = getTimer() - _delayTimer;
         LANClientCtrl.I.updateDelay(_loc2_);
         _delayTimer = getTimer();
         _sendAnyWay = true;
         return true;
      }
      
      public function receiveSyncUpdate(param1:ByteArray) : Boolean
      {
         var _loc7_:int;
         var _loc10_:int;
         var _loc6_:int;
         var _loc9_:int;
         var _loc8_:int;
         var _loc11_:int;
         var _loc12_:int;
         var _loc15_:int;
         var _loc5_:int;
         var _loc2_:int;
         var _loc14_:int;
         var _loc13_:int;
         var _loc4_:FighterMain = null;
         var _loc3_:FighterMain = null;
         if(!param1)
         {
            return false;
         }
         param1.position = 0;
         _loc7_ = param1.readByte();
         if(_loc7_ != 10)
         {
            return false;
         }
         _updateCache = {};
         _loc10_ = param1.readShort();
         _loc6_ = param1.readByte();
         _loc9_ = param1.readByte();
         _loc8_ = param1.readShort();
         _loc11_ = param1.readShort();
         _loc12_ = param1.readShort();
         _loc15_ = param1.readShort();
         _loc5_ = param1.readShort();
         _loc2_ = param1.readShort();
         _loc14_ = param1.readShort();
         _loc13_ = param1.readShort();
         _serverFrame = _loc10_;
         try
         {
            if(GameCtrl.I.gameRunData.round != _loc6_)
            {
               LANClientCtrl.I.syncError(true);
               return true;
            }
            GameCtrl.I.gameRunData.gameTime = _loc9_;
            _loc4_ = GameCtrl.I.gameRunData.p1FighterGroup.currentFighter;
            _loc3_ = GameCtrl.I.gameRunData.p2FighterGroup.currentFighter;
            _loc4_.hp = _loc8_;
            _loc4_.qi = _loc11_;
            _loc4_.x = _loc12_;
            _loc4_.y = _loc15_;
            _loc3_.hp = _loc5_;
            _loc3_.qi = _loc2_;
            _loc3_.x = _loc14_;
            _loc3_.y = _loc13_;
            if(_loc4_.hp > 0 && !_loc4_.isAlive)
            {
               _loc4_.relive();
            }
            if(_loc3_.hp > 0 && !_loc4_.isAlive)
            {
               _loc3_.relive();
            }
            LANClientCtrl.I.resetSyncError();
         }
         catch(e:Error)
         {
            trace(e);
            LANClientCtrl.I.syncError(true);
         }
         return true;
      }
      
      public function render() : Boolean
      {
         var _loc1_:ByteArray = null;
         if(!enabled)
         {
            return true;
         }
         if(_serverNextFrame == 0 && _serverFrame == 0)
         {
            if(_sendStartFrame++ == 0)
            {
               _loc1_ = new ByteArray();
               _loc1_.writeByte(8);
               _loc1_.writeShort(0);
               _loc1_.writeShort(0);
               LANClientCtrl.I.sendUDP(_loc1_);
            }
            else if(_sendStartFrame > 5)
            {
               _sendStartFrame = 0;
            }
            return false;
         }
         if(_clientFrame < _serverNextFrame)
         {
            ++_clientFrame;
            renderUpdate();
            InputManager.I.socket_input_p2.renderInput();
            if(_clientFrame % 2 == 0)
            {
               sendCtrl();
            }
            return true;
         }
         return false;
      }
      
      private function sendCtrl() : void
      {
         var _loc2_:int = InputManager.I.socket_input_p2.getSocketData();
         if(_lastSendK == _loc2_ && !_sendAnyWay)
         {
            return;
         }
         _sendAnyWay = false;
         InputManager.I.socket_input_p2.resetInput();
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeByte(8);
         _loc1_.writeShort(_clientFrame);
         _loc1_.writeShort(_loc2_);
         LANClientCtrl.I.sendUDP(_loc1_);
         _lastSendK = _loc2_;
      }
      
      private function cacheUpdate() : void
      {
         var _loc1_:int = 0;
         _loc1_ = _serverFrame;
         while(_loc1_ < _serverNextFrame)
         {
            _updateCache[_loc1_] = [_serverK,_clientK];
            _loc1_++;
         }
      }
      
      private function renderUpdate() : void
      {
         var _loc1_:Array = _updateCache[_clientFrame];
         if(_loc1_)
         {
            InputManager.I.socket_input_p1.setSocketData(_loc1_[0]);
            InputManager.I.socket_input_p2.setSocketData(_loc1_[1]);
         }
      }
   }
}

