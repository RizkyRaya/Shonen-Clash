package net.play5d.game.bvn.mob.ctrls
{
   import flash.utils.ByteArray;
   import net.play5d.game.bvn.MainGame;
   import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
   import net.play5d.game.bvn.data.GameRunDataVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.mob.input.InputManager;
   import net.play5d.game.bvn.mob.utils.LANUtils;
   import net.play5d.game.bvn.state.GameState;
   import net.play5d.kyo.stage.Istage;
   
   public class LockFrameServerLogic
   {
      
      public var enabled:Boolean = true;
      
      private var _clientFrame:int;
      
      private var _renderFrame:int;
      
      private var _renderNextFrame:int;
      
      private var _renderSyncFrame:int;
      
      private var _clientK:int = -1;
      
      private var _serverK:int = 0;
      
      private var _syncUpdateArr:ByteArray;
      
      private var _sendUpdateFrame:int;
      
      private var _sendUpdateSyncFrame:int;
      
      private var _updateCache:Object = {};
      
      public function LockFrameServerLogic()
      {
         super();
      }
      
      public function reset() : void
      {
         _renderFrame = 0;
         _renderNextFrame = 0;
         _clientK = -1;
         _serverK = 0;
         _syncUpdateArr = null;
         _sendUpdateFrame = 0;
      }
      
      public function dispose() : void
      {
      }
      
      public function render() : Boolean
      {
         if(!enabled)
         {
            return true;
         }
         if(_clientK == -1)
         {
            return false;
         }
         if(_renderFrame > _clientFrame + LANUtils.LOCK_KEYFRAME)
         {
            if(_sendUpdateFrame == 0)
            {
               sendUpdate();
            }
            if(_sendUpdateSyncFrame == 0)
            {
               sendSyncUpdate();
            }
            if(++_sendUpdateFrame > LANUtils.LOCK_KEYFRAME)
            {
               _sendUpdateFrame = 0;
            }
            if(++_sendUpdateSyncFrame > LANUtils.SYNC_GAP)
            {
               _sendUpdateSyncFrame = 0;
            }
            return false;
         }
         InputManager.I.socket_input_p1.renderInput();
         if(_renderFrame % LANUtils.LOCK_KEYFRAME == 0)
         {
            if(_syncUpdateArr)
            {
               sendSyncUpdate();
               _renderSyncFrame = 0;
               _syncUpdateArr = null;
            }
            sendUpdate();
         }
         ++_renderFrame;
         ++_renderSyncFrame;
         renderUpdate();
         if(_renderSyncFrame > LANUtils.SYNC_GAP)
         {
            _syncUpdateArr = getSyncUpdate();
         }
         return true;
      }
      
      private function sendStart() : void
      {
         var _loc1_:Array = [_serverK,0];
         LANServerCtrl.I.sendTCP(_loc1_);
      }
      
      public function receiveInput(param1:ByteArray) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         param1.position = 0;
         var _loc2_:int = param1.readByte();
         if(_loc2_ != 8)
         {
            return false;
         }
         _clientFrame = param1.readShort();
         _clientK = param1.readShort();
         return true;
      }
      
      private function sendUpdate() : void
      {
         _renderNextFrame = _renderFrame + LANUtils.LOCK_KEYFRAME;
         _serverK = InputManager.I.socket_input_p1.getSocketData();
         InputManager.I.socket_input_p1.resetInput();
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeByte(9);
         _loc1_.writeShort(_renderFrame);
         _loc1_.writeShort(_serverK);
         _loc1_.writeShort(_clientK);
         LANServerCtrl.I.sendUDP(_loc1_);
         cacheUpdate();
      }
      
      private function sendSyncUpdate() : void
      {
         if(!_syncUpdateArr)
         {
            return;
         }
         _updateCache = {};
         LANServerCtrl.I.sendUDP(_syncUpdateArr);
      }
      
      private function getSyncUpdate() : ByteArray
      {
         var _loc4_:GameRunDataVO = null;
         var _loc5_:FighterMain = null;
         var _loc3_:FighterMain = null;
         var _loc2_:ByteArray = null;
         var _loc1_:Istage = MainGame.stageCtrl.currentStage;
         if(_loc1_ is GameState)
         {
            if(GameCtrl.I.actionEnable)
            {
               _loc4_ = GameCtrl.I.gameRunData;
               _loc5_ = _loc4_.p1FighterGroup.currentFighter;
               _loc3_ = _loc4_.p2FighterGroup.currentFighter;
               _loc2_ = new ByteArray();
               _loc2_.writeByte(10);
               _loc2_.writeShort(_renderFrame);
               _loc2_.writeByte(_loc4_.round);
               _loc2_.writeByte(_loc4_.gameTime);
               _loc2_.writeShort(_loc5_.hp << 0);
               _loc2_.writeShort(_loc5_.qi << 0);
               _loc2_.writeShort(_loc5_.x << 0);
               _loc2_.writeShort(_loc5_.y << 0);
               _loc2_.writeShort(_loc3_.hp << 0);
               _loc2_.writeShort(_loc3_.qi << 0);
               _loc2_.writeShort(_loc3_.x << 0);
               _loc2_.writeShort(_loc3_.y << 0);
               return _loc2_;
            }
         }
         return null;
      }
      
      private function cacheUpdate() : void
      {
         var _loc1_:int = 0;
         _loc1_ = _renderFrame;
         while(_loc1_ < _renderNextFrame)
         {
            _updateCache[_loc1_] = [_serverK,_clientK];
            _loc1_++;
         }
      }
      
      private function renderUpdate() : void
      {
         var _loc1_:Array = _updateCache[_renderFrame];
         if(_loc1_)
         {
            InputManager.I.socket_input_p1.setSocketData(_loc1_[0]);
            InputManager.I.socket_input_p2.setSocketData(_loc1_[1]);
         }
      }
   }
}

