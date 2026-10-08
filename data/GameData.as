package net.play5d.game.bvn.data
{
   import net.play5d.game.bvn.ctrl.AssetManager;
   import net.play5d.game.bvn.data.mosou.MosouFighterModel;
   import net.play5d.game.bvn.data.mosou.MosouFighterSellVO;
   import net.play5d.game.bvn.data.mosou.MosouModel;
   import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
   import net.play5d.game.bvn.data.mosou.player.MosouPlayerData;
   import net.play5d.game.bvn.debug.Debugger;
   import net.play5d.game.bvn.interfaces.GameInterface;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class GameData
   {
      
      private static var _i:GameData;
      
      public var config:ConfigVO = new ConfigVO();
      
      public var mosouData:MosouPlayerData = new MosouPlayerData();
      
      public var p1Select:SelectVO;
      
      public var p2Select:SelectVO;
      
      public var selectMap:String;
      
      public var score:int = 0;
      
      public var winnerId:String;
      
      public var isFristRun:Boolean = true;
      
      private const SAVE_ID:String = "bvn3.5A";
      
      private const __MOSOU_DATA_ENABLED:Boolean = true;
      
      public function GameData()
      {
         super();
      }
      
      public static function get I() : GameData
      {
         if(!_i)
         {
            _i = new GameData();
         }
         return _i;
      }
      
      public function loadConfig(param1:Function, param2:Function = null) : void
      {
         var back:Function = param1;
         var fail:Function = param2;
         var loadFighterBack:* = function(param1:XML):void
         {
            FighterModel.I.initByXML(param1);
            AssetManager.I.loadXML("config/assist.xml",loadAssetsBack,loadAssisterFail);
         };
         var loadAssetsBack:* = function(param1:XML):void
         {
            AssisterModel.I.initByXML(param1);
            AssetManager.I.loadXML("config/select.xml",loadSelectBack,loadSelectFail);
         };
         var loadSelectBack:* = function(param1:XML):void
         {
            config.select_config.setByXML(param1);
            AssetManager.I.loadXML("config/map.xml",loadMapBack,loadMapFail);
         };
         var loadMapBack:* = function(param1:XML):void
         {
            MapModel.I.initByXML(param1);
            AssetManager.I.loadXML("config/mission.xml",loadMissionBack,loadMissionFail);
         };
         var loadMissionBack:* = function(param1:String):void
         {
            MessionModel.I.initByXML(new XML(param1));
            MosouModel.I.loadMapData(loadMosouDataBack,loadMosouFail);
         };
         var loadMosouDataBack:* = function():void
         {
            MosouFighterModel.I.init();
            validateSelect();
            validateMissionData();
            validateMosouData();
            if(back != null)
            {
               back();
            }
         };
         var loadFighterFail:* = function():void
         {
            Debugger.log("读取人物数据出错");
            if(fail != null)
            {
               fail("读取人物数据出错");
            }
         };
         var loadAssisterFail:* = function():void
         {
            Debugger.log("读取辅助角色数据出错");
            if(fail != null)
            {
               fail("读取辅助角色数据出错");
            }
         };
         var loadSelectFail:* = function():void
         {
            Debugger.log("读取选人场景数据出错");
            if(fail != null)
            {
               fail("读取选人场景数据出错");
            }
         };
         var loadMapFail:* = function():void
         {
            Debugger.log("读取地图场景数据出错");
            if(fail != null)
            {
               fail("读取地图场景数据出错");
            }
         };
         var loadMissionFail:* = function():void
         {
            Debugger.log("读取关卡数据出错");
            if(fail != null)
            {
               fail("读取关卡数据出错");
            }
         };
         var loadMosouFail:* = function():void
         {
            Debugger.log("读取无双数据出错");
            if(fail != null)
            {
               fail("读取无双数据出错");
            }
         };
         AssetManager.I.loadXML("config/fighter.xml",loadFighterBack,loadFighterFail);
      }
      
      public function initData() : void
      {
         mosouData.init();
         GameData.I.loadSaveData();
      }
      
      public function saveData() : void
      {
         var _loc1_:Object = {};
         _loc1_.id = "bvn3.5A";
         _loc1_.config = config.toSaveObj();
         _loc1_.mosou = mosouData.toSaveObj();
         GameInterface.instance.saveGame(_loc1_);
      }
      
      private function loadSaveData() : void
      {
         var _loc1_:Object = GameInterface.instance.loadGame();
         if(!_loc1_ || _loc1_.id != "bvn3.5A")
         {
            return;
         }
         trace("loadSaveData",JSON.stringify(_loc1_));
         if(_loc1_.config)
         {
            config.readSaveObj(_loc1_.config);
         }
         if(_loc1_.mosou)
         {
            mosouData.readSaveObj(_loc1_.mosou);
         }
      }
      
      public function loadSelect(param1:String) : void
      {
         var url:String = param1;
         AssetManager.I.loadXML(url,function(param1:XML):void
         {
            setSelectData(param1);
         },function():void
         {
            trace("loadSelect error!");
         });
      }
      
      public function loadDebugSelect(param1:String) : void
      {
         var url:String = param1;
         KyoURLoader.load(url,function(param1:String):void
         {
            var _loc2_:XML = new XML(param1);
            setSelectData(_loc2_);
         },function():void
         {
            trace("loadSelect error!");
         });
      }
      
      public function setSelectData(param1:XML) : void
      {
         config.select_config.setByXML(param1);
      }
      
      private function validateSelect() : void
      {
         var _loc4_:FighterVO = null;
         _loc4_ = null;
         var _loc1_:String = null;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         for each(var _loc2_ in config.select_config.charList.list)
         {
            for each(var _loc3_ in _loc2_.getAllFighterIDs())
            {
               _loc4_ = FighterModel.I.getFighter(_loc3_);
               if(_loc4_ == null)
               {
                  if(_loc5_.indexOf(_loc3_) == -1)
                  {
                     _loc5_.push(_loc3_);
                  }
               }
            }
         }
         for each(_loc2_ in config.select_config.assistList.list)
         {
            for each(_loc3_ in _loc2_.getAllFighterIDs())
            {
               _loc4_ = AssisterModel.I.getAssister(_loc3_);
               if(_loc4_ == null)
               {
                  if(_loc6_.indexOf(_loc3_) == -1)
                  {
                     _loc6_.push(_loc3_);
                  }
               }
            }
         }
         if(_loc5_.length > 0 || _loc6_.length > 0)
         {
            _loc1_ = "";
            if(_loc5_.length > 0)
            {
               _loc1_ += "fighter : " + _loc5_.join(" , ") + " ; ";
            }
            if(_loc6_.length > 0)
            {
               _loc1_ += "assister : " + _loc6_.join(" , ") + " ; ";
            }
            throw new Error("select.xml验证失败！ [" + _loc1_ + "]");
         }
      }
      
      private function validateMissionData() : void
      {
         var _loc4_:* = undefined;
         var _loc7_:FighterVO = null;
         var _loc11_:MapVO = null;
         var _loc12_:FighterVO = null;
         var _loc1_:String = null;
         var _loc8_:Array = [];
         var _loc6_:Array = [];
         var _loc9_:Array = [];
         var _loc3_:Array = MessionModel.I.getAllMissions();
         for each(var _loc10_ in _loc3_)
         {
            _loc4_ = _loc10_.stageList;
            for each(var _loc2_ in _loc4_)
            {
               for each(var _loc5_ in _loc2_.fighters)
               {
                  _loc7_ = FighterModel.I.getFighter(_loc5_);
                  if(_loc7_ == null)
                  {
                     if(_loc8_.indexOf(_loc5_) == -1)
                     {
                        _loc8_.push(_loc5_);
                     }
                  }
               }
               _loc11_ = MapModel.I.getMap(_loc2_.map);
               if(_loc11_ == null)
               {
                  if(_loc6_.indexOf(_loc2_.map) == -1)
                  {
                     _loc6_.push(_loc2_.map);
                  }
               }
               _loc12_ = AssisterModel.I.getAssister(_loc2_.assister);
               if(_loc12_ == null)
               {
                  if(_loc9_.indexOf(_loc2_.assister) == -1)
                  {
                     _loc9_.push(_loc2_.assister);
                  }
               }
            }
         }
         if(_loc8_.length > 0 || _loc9_.length > 0 || _loc6_.length > 0)
         {
            _loc1_ = "";
            if(_loc8_.length > 0)
            {
               _loc1_ += "fighter : " + _loc8_.join(" , ") + " ; ";
            }
            if(_loc9_.length > 0)
            {
               _loc1_ += "assister : " + _loc9_.join(" , ") + " ; ";
            }
            if(_loc6_.length > 0)
            {
               _loc1_ += "map : " + _loc6_.join(" , ") + " ; ";
            }
            throw new Error("mission.xml验证失败！ [" + _loc1_ + "]");
         }
      }
      
      private function validateMosouData() : void
      {
         var _loc7_:MosouWorldMapVO = null;
         var _loc6_:String = null;
         var _loc14_:MapVO = null;
         var _loc15_:Array = null;
         var _loc13_:FighterVO = null;
         var _loc11_:FighterVO = null;
         var _loc1_:String = null;
         var _loc10_:Object = MosouModel.I.getAllMap();
         for(var _loc4_ in _loc10_)
         {
            _loc7_ = _loc10_[_loc4_];
            for each(var _loc2_ in _loc7_.areas)
            {
               for each(var _loc5_ in _loc2_.missions)
               {
                  _loc6_ = _loc7_.id + " - " + _loc2_.id + " - " + _loc5_.id;
                  _loc14_ = MapModel.I.getMap(_loc5_.map);
                  if(_loc14_ == null)
                  {
                     throw new Error("mosou[" + _loc6_ + "]验证失败！未找到map: " + _loc5_.map);
                  }
                  _loc15_ = _loc5_.getAllEnemieIds();
                  for each(var _loc3_ in _loc15_)
                  {
                     _loc13_ = FighterModel.I.getFighter(_loc3_);
                     if(_loc13_ == null)
                     {
                        throw new Error("mosou[" + _loc6_ + "]验证失败！未找到fighter: " + _loc3_);
                     }
                  }
               }
            }
         }
         var _loc8_:Array = [];
         var _loc9_:Vector.<MosouFighterSellVO> = MosouFighterModel.I.fighters;
         for each(var _loc12_ in _loc9_)
         {
            _loc11_ = FighterModel.I.getFighter(_loc12_.id);
            if(!_loc11_ && _loc8_.indexOf(_loc12_.id) == -1)
            {
               _loc8_.push(_loc12_.id);
            }
         }
         if(_loc8_.length > 0)
         {
            _loc1_ = "";
            if(_loc8_.length > 0)
            {
               _loc1_ += "fighter : " + _loc8_.join(" , ") + " ; ";
            }
            throw new Error("FighterModel 验证失败！ [" + _loc1_ + "]");
         }
      }
   }
}

