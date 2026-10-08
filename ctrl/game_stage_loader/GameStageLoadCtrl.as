package net.play5d.game.bvn.ctrl.game_stage_loader
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   import net.play5d.game.bvn.ctrl.GameLoader;
   import net.play5d.game.bvn.ctrl.SoundCtrl;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.BgmVO;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   
   public class GameStageLoadCtrl extends EventDispatcher
   {
      
      private static var _i:GameStageLoadCtrl;
      
      public static var IGORE_OLD_FIGHTER:Boolean = true;
      
      private var _loadingType:int;
      
      private var _fighterCache:Dictionary;
      
      private var _assisterCache:Dictionary;
      
      private var _mapCache:Dictionary;
      
      private var _processCallBack:Function;
      
      private var _errorCallBack:Function;
      
      private var _loadFinishBack:Function;
      
      private var _loadStep:int;
      
      private var _loadStepLength:int;
      
      private var _curLoadStep:int;
      
      private var _curLoadStepLength:int;
      
      private var _curLoadName:String;
      
      private var _loadMapDatas:Vector.<MapVO>;
      
      private var _loadFighterDatas:Vector.<FighterVO>;
      
      private var _loadAssisterDatas:Vector.<FighterVO>;
      
      private var _loadBgmDatas:Vector.<BgmVO>;
      
      public function GameStageLoadCtrl()
      {
         super();
      }
      
      public static function get I() : GameStageLoadCtrl
      {
         if(!_i)
         {
            _i = new GameStageLoadCtrl();
         }
         return _i;
      }
      
      public function init(processCb:Function = null, errorCb:Function = null) : void
      {
         clearAllStageCache();
         _fighterCache = new Dictionary(false);
         _assisterCache = new Dictionary(false);
         _mapCache = new Dictionary(false);
         _loadStep = 0;
         _curLoadStep = 0;
         _processCallBack = processCb;
         _errorCallBack = errorCb;
      }
      
      public function clearAllStageCache() : void
      {
         if(_fighterCache)
         {
            clearCacheDict(_fighterCache);
         }
         if(_assisterCache)
         {
            clearCacheDict(_assisterCache);
         }
         if(_mapCache)
         {
            clearCacheDict(_mapCache);
         }
      }
      
      public function dispose() : void
      {
         clearAllStageCache();
         _fighterCache = null;
         _assisterCache = null;
         _mapCache = null;
         _processCallBack = null;
         _errorCallBack = null;
         _loadFinishBack = null;
         if(_loadMapDatas)
         {
            _loadMapDatas.length = 0;
         }
         if(_loadFighterDatas)
         {
            _loadFighterDatas.length = 0;
         }
         if(_loadAssisterDatas)
         {
            _loadAssisterDatas.length = 0;
         }
         if(_loadBgmDatas)
         {
            _loadBgmDatas.length = 0;
         }
         _loadMapDatas = null;
         _loadFighterDatas = null;
         _loadAssisterDatas = null;
         _loadBgmDatas = null;
         System.gc();
      }
      
      private function clearCacheDict(cacheDict:Dictionary) : void
      {
         if(!cacheDict)
         {
            return;
         }
         for(var key in cacheDict)
         {
            var item:Object = cacheDict[key];
            if(item)
            {
               if(item is MovieClip)
               {
                  var mc:MovieClip = item as MovieClip;
                  mc.stop();
                  if(mc.loaderInfo && mc.loaderInfo.loader)
                  {
                     forceUnload(mc.loaderInfo.loader);
                  }
               }
               else
               {
                  if(item.loader)
                  {
                     forceUnload(item.loader as Loader);
                  }
                  if(item.mcSlave && item.mcSlave.loaderInfo)
                  {
                     forceUnload(item.mcSlave.loaderInfo.loader as Loader);
                  }
                  item.domain = null;
                  item.loader = null;
                  item.mcSlave = null;
               }
            }
            delete cacheDict[key];
         }
      }
      
      private function forceUnload(loader:Loader) : void
      {
         if(!loader)
         {
            return;
         }
         try
         {
            loader.unloadAndStop(true);
         }
         catch(e:Error)
         {
            try
            {
               loader.unload();
            }
            catch(e2:Error)
            {
            }
         }
      }
      
      public function getFighterMc(assetUrl:String, mcType:String) : MovieClip
      {
         return getMcFromCache(_fighterCache,assetUrl);
      }
      
      public function getAssisterMc(assetUrl:String, mcType:String) : MovieClip
      {
         return getMcFromCache(_assisterCache,assetUrl);
      }
      
      public function getMapMc(assetUrl:String) : MovieClip
      {
         return _mapCache ? _mapCache[assetUrl] as MovieClip : null;
      }
      
      private function getMcFromCache(cacheDict:Dictionary, assetUrl:String) : MovieClip
      {
         var cache:Object;
         var domain:ApplicationDomain;
         var cls:Class;
         if(!cacheDict || !cacheDict[assetUrl])
         {
            return null;
         }
         cache = cacheDict[assetUrl];
         domain = cache.domain as ApplicationDomain;
         if(domain && domain.hasDefinition("main_mc"))
         {
            try
            {
               cls = domain.getDefinition("main_mc") as Class;
               if(cls)
               {
                  return new cls() as MovieClip;
               }
            }
            catch(e:Error)
            {
            }
         }
         if(!cache.usedMain && cache.loader && cache.loader.content)
         {
            cache.usedMain = true;
            return cache.loader.content as MovieClip;
         }
         if(!cache.usedSlave && cache.mcSlave)
         {
            cache.usedSlave = true;
            return cache.mcSlave as MovieClip;
         }
         return null;
      }
      
      public function loadGame(mapIds:Array, fighterIds:Array, assisterIds:Array, bgmIds:Array, finishCb:Function = null) : void
      {
         clearAllStageCache();
         _loadStep = 0;
         _loadStepLength = 0;
         if(mapIds)
         {
            ++_loadStepLength;
            _loadMapDatas = new Vector.<MapVO>();
            for each(var mid in unique(mapIds))
            {
               var mapVO:MapVO = MapModel.I.getMap(mid);
               if(mapVO)
               {
                  _loadMapDatas.push(mapVO);
               }
            }
         }
         if(fighterIds)
         {
            ++_loadStepLength;
            _loadFighterDatas = new Vector.<FighterVO>();
            for each(var fid in unique(fighterIds))
            {
               var fighterVO:FighterVO = FighterModel.I.getFighter(fid);
               if(fighterVO)
               {
                  _loadFighterDatas.push(fighterVO);
               }
            }
         }
         if(assisterIds)
         {
            ++_loadStepLength;
            _loadAssisterDatas = new Vector.<FighterVO>();
            for each(var aid in unique(assisterIds))
            {
               var assisterVO:FighterVO = AssisterModel.I.getAssister(aid);
               if(assisterVO)
               {
                  _loadAssisterDatas.push(assisterVO);
               }
            }
         }
         if(bgmIds)
         {
            ++_loadStepLength;
            _loadBgmDatas = new Vector.<BgmVO>();
            for each(var bid in unique(bgmIds))
            {
               var bgmVO:BgmVO = FighterModel.I.getFighterBGM(bid) || MapModel.I.getMapBGM(bid) || FighterModel.I.getBossBGM(bid);
               if(bgmVO)
               {
                  _loadBgmDatas.push(bgmVO);
               }
            }
         }
         _loadFinishBack = finishCb;
         _loadStep = 1;
         setTimeout(startLoadingMaps,100);
      }
      
      private function startLoadingMaps() : void
      {
         loadAssetsQueue(_loadMapDatas,0,function(lv:LoadAssetVO, succBack:Function):void
         {
            if(_mapCache[lv.url])
            {
               succBack();
               return;
            }
            GameLoader.loadSWF(lv.url,function(loader:Loader):void
            {
               _mapCache[lv.url] = loader.content;
               succBack();
            },onLoadError,onLoadProcess);
         },function():void
         {
            setTimeout(startloadFighters,50);
         });
      }
      
      private function startloadFighters() : void
      {
         loadAssetsQueue(_loadFighterDatas,1,function(lv:LoadAssetVO, succBack:Function):void
         {
            if(_fighterCache[lv.url])
            {
               succBack();
               return;
            }
            loadCharacterSWF(lv,_fighterCache,succBack);
         },function():void
         {
            setTimeout(startloadAssisters,50);
         });
      }
      
      private function startloadAssisters() : void
      {
         loadAssetsQueue(_loadAssisterDatas,2,function(lv:LoadAssetVO, succBack:Function):void
         {
            if(_assisterCache[lv.url])
            {
               succBack();
               return;
            }
            loadCharacterSWF(lv,_assisterCache,succBack);
         },function():void
         {
            setTimeout(startloadBGM,50);
         });
      }
      
      private function loadCharacterSWF(lv:LoadAssetVO, cacheRef:Dictionary, succBack:Function) : void
      {
         GameLoader.loadSWF(lv.url,function(loader:Loader):void
         {
            var appDomain:ApplicationDomain;
            var hasMainMc:Boolean;
            var cacheData:Object;
            var bytes:ByteArray;
            var slaveLoader:Loader;
            var context:LoaderContext;
            if(!loader || !loader.contentLoaderInfo)
            {
               onLoadError("Gagal membaca Loader Content: " + lv.url);
               return;
            }
            appDomain = loader.contentLoaderInfo.applicationDomain;
            hasMainMc = false;
            try
            {
               hasMainMc = appDomain.hasDefinition("main_mc");
            }
            catch(e:Error)
            {
            }
            cacheData = {
               "domain":appDomain,
               "loader":loader,
               "mcSlave":null,
               "usedMain":false,
               "usedSlave":false
            };
            cacheRef[lv.url] = cacheData;
            if(hasMainMc)
            {
               succBack();
               return;
            }
            try
            {
               bytes = loader.contentLoaderInfo.bytes;
               if(bytes && bytes.length > 0)
               {
                  slaveLoader = new Loader();
                  context = new LoaderContext(false,new ApplicationDomain());
                  if("allowCodeImport" in context)
                  {
                     context["allowCodeImport"] = true;
                  }
                  slaveLoader.contentLoaderInfo.addEventListener("complete",function(e:Event):void
                  {
                     e.target.removeEventListener("complete",arguments.callee);
                     cacheData.mcSlave = slaveLoader.content as MovieClip;
                     succBack();
                  });
                  slaveLoader.loadBytes(bytes,context);
                  return;
               }
            }
            catch(err:Error)
            {
            }
            succBack();
         },onLoadError,onLoadProcess);
      }
      
      private function startloadBGM() : void
      {
         if(!_loadBgmDatas || _loadBgmDatas.length == 0)
         {
            onAllFinish();
            return;
         }
         _loadingType = 3;
         _curLoadStep = 0;
         _curLoadStepLength = 1;
         SoundCtrl.I.loadFightBGM(_loadBgmDatas,onAllFinish,onAllFinish,onLoadProcess);
      }
      
      private function onAllFinish() : void
      {
         ++_loadStep;
         _curLoadName = null;
         if(_loadFinishBack != null)
         {
            var cb:Function = _loadFinishBack;
            _loadFinishBack = null;
            cb();
         }
      }
      
      private function loadAssetsQueue(dataList:*, loadingType:int, loadFunc:Function, callback:Function) : void
      {
         var loadNext:Function;
         var assets:Vector.<LoadAssetVO> = convertLoadAssets(dataList,{
            "id":"id",
            "name":"name",
            "url":"fileUrl"
         });
         _loadingType = loadingType;
         if(!assets || assets.length == 0)
         {
            if(callback != null)
            {
               callback();
            }
            return;
         }
         _curLoadStep = 0;
         _curLoadStepLength = assets.length;
         loadNext = function():void
         {
            var asset:LoadAssetVO;
            if(assets.length < 1)
            {
               ++_loadStep;
               _curLoadName = null;
               if(callback != null)
               {
                  callback();
               }
               return;
            }
            asset = assets.shift();
            _curLoadName = asset.name;
            loadFunc(asset,function():void
            {
               ++_curLoadStep;
               loadNext();
            });
         };
         loadNext();
      }
      
      private function onLoadProcess(progress:Number) : void
      {
         if(_processCallBack == null)
         {
            return;
         }
         var typeName:String = ["Scene Map","Fighter","Assister","BGM"][_loadingType] || "";
         var msg:String = "Memuat " + typeName + (_curLoadName ? " : " + _curLoadName : "") + " (" + _loadStep + "/" + _loadStepLength + ")";
         _processCallBack(msg,(_curLoadStep + progress) / _curLoadStepLength);
      }
      
      private function onLoadError(errorMsg:String) : void
      {
         if(_errorCallBack != null)
         {
            _errorCallBack(errorMsg);
         }
      }
      
      private function unique(arr:Array) : Array
      {
         var result:Array = [];
         var cache:Dictionary = new Dictionary();
         for each(var item in arr)
         {
            if(item !== null && item !== undefined && !cache[item])
            {
               cache[item] = true;
               result.push(item);
            }
         }
         return result;
      }
      
      private function convertLoadAssets(dataList:*, propMap:Object) : Vector.<LoadAssetVO>
      {
         var result:Vector.<LoadAssetVO> = new Vector.<LoadAssetVO>();
         if(!dataList)
         {
            return result;
         }
         var urlCache:Dictionary = new Dictionary();
         for each(var obj in dataList)
         {
            if(obj)
            {
               var vo:LoadAssetVO = new LoadAssetVO();
               for(var key in propMap)
               {
                  vo[key] = obj[propMap[key]];
               }
               if(vo.url && !urlCache[vo.url])
               {
                  urlCache[vo.url] = true;
                  result.push(vo);
               }
            }
         }
         return result;
      }
   }
}

class LoadAssetVO
{
   
   public var id:String;
   
   public var url:String;
   
   public var name:String;
   
   public function LoadAssetVO()
   {
      super();
   }
}
