package net.play5d.game.bvn.ctrl
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.System;
   import flash.utils.ByteArray;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.fighter.Assister;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.map.MapMain;
   
   public class GameLoader
   {
      
      private static var _fighterCache:Object = {};
      
      private static var _loadedSwfCache:Vector.<Loader> = new Vector.<Loader>();
      
      private static var _swfUrlCache:Object = {};
      
      public function GameLoader()
      {
         super();
      }
      
      public static function loadAndCacheFighter(param1:String, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         var fv:FighterVO;
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         if(_fighterCache[fighterId])
         {
            if(back != null)
            {
               back();
            }
            return;
         }
         fv = FighterModel.I.getFighter(fighterId,true);
         if(!fv)
         {
            if(fail != null)
            {
               fail("ID Karakter Salah");
            }
            return;
         }
         loadSWF(fv.fileUrl,function(loader:Loader):void
         {
            var bytes:ByteArray;
            var slaveLoader:Loader;
            var context:LoaderContext;
            var onSlaveComplete:Function;
            var hasMainMc:Boolean = false;
            var cacheVO:FighterCacheVO = new FighterCacheVO();
            cacheVO.loader = loader;
            cacheVO.fighterData = fv;
            _fighterCache[fighterId] = cacheVO;
            if(loader && loader.contentLoaderInfo && loader.contentLoaderInfo.applicationDomain)
            {
               try
               {
                  hasMainMc = loader.contentLoaderInfo.applicationDomain.hasDefinition("main_mc");
               }
               catch(e:Error)
               {
               }
            }
            if(hasMainMc)
            {
               if(back != null)
               {
                  back();
               }
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
                  onSlaveComplete = function(e:*):void
                  {
                     e.target.removeEventListener("complete",onSlaveComplete);
                     cacheVO.loaderSlave = slaveLoader;
                     onSlaveComplete = null;
                     if(back != null)
                     {
                        back();
                     }
                  };
                  slaveLoader.contentLoaderInfo.addEventListener("complete",onSlaveComplete);
                  slaveLoader.loadBytes(bytes,context);
                  return;
               }
            }
            catch(e:Error)
            {
            }
            if(back != null)
            {
               back();
            }
         },fail,process,false);
      }
      
      public static function loadFighter(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var result:FighterMain = createCacheFighter(fighterId);
         if(result)
         {
            if(back != null)
            {
               customBackParam ? back(result,customBackParam) : back(result);
            }
            return;
         }
         loadAndCacheFighter(fighterId,function():void
         {
            result = createCacheFighter(fighterId);
            if(back != null)
            {
               customBackParam ? back(result,customBackParam) : back(result);
            }
         },fail,process);
      }
      
      public static function createCacheFighter(param1:String) : FighterMain
      {
         var appDomain:ApplicationDomain;
         var cls:Class;
         var fighter:FighterMain;
         var mcInst:MovieClip = null;
         var cache:FighterCacheVO = _fighterCache[param1];
         if(!cache || !cache.loader || !cache.loader.contentLoaderInfo)
         {
            return null;
         }
         appDomain = cache.loader.contentLoaderInfo.applicationDomain;
         if(appDomain)
         {
            try
            {
               if(appDomain.hasDefinition("main_mc"))
               {
                  cls = appDomain.getDefinition("main_mc") as Class;
                  if(cls)
                  {
                     mcInst = new cls() as MovieClip;
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         if(!mcInst)
         {
            if(!cache.usedContent && cache.loader.content)
            {
               mcInst = cache.loader.content as MovieClip;
               cache.usedContent = true;
            }
            else if(!cache.usedSlave && cache.loaderSlave && cache.loaderSlave.content)
            {
               mcInst = cache.loaderSlave.content as MovieClip;
               cache.usedSlave = true;
            }
         }
         if(!mcInst)
         {
            return null;
         }
         fighter = new FighterMain(mcInst);
         fighter.data = cache.fighterData;
         return fighter;
      }
      
      public static function loadAssister(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var fighterId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var fv:FighterVO = AssisterModel.I.getAssister(fighterId,true);
         if(!fv)
         {
            if(fail != null)
            {
               fail("ID Assister Salah");
            }
            return;
         }
         loadSWF(fv.fileUrl,function(loader:Loader):void
         {
            var appDomain:ApplicationDomain;
            var cls:Class;
            var assister:Assister;
            var mcInst:MovieClip = null;
            if(loader && loader.contentLoaderInfo)
            {
               appDomain = loader.contentLoaderInfo.applicationDomain;
               if(appDomain && appDomain.hasDefinition("main_mc"))
               {
                  try
                  {
                     cls = appDomain.getDefinition("main_mc") as Class;
                     if(cls)
                     {
                        mcInst = new cls() as MovieClip;
                     }
                  }
                  catch(e:Error)
                  {
                  }
               }
            }
            if(!mcInst && loader)
            {
               mcInst = loader.content as MovieClip;
            }
            assister = new Assister(mcInst);
            assister.data = fv;
            if(back != null)
            {
               customBackParam ? back(assister,customBackParam) : back(assister);
            }
         },fail,process);
      }
      
      public static function loadMap(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Object = null) : void
      {
         var mapId:String = param1;
         var back:Function = param2;
         var fail:Function = param3;
         var process:Function = param4;
         var customBackParam:Object = param5;
         var mv:MapVO = MapModel.I.getMap(mapId);
         if(!mv)
         {
            if(fail != null)
            {
               fail("ID Map Salah");
            }
            return;
         }
         loadSWF(mv.fileUrl,function(loader:Loader):void
         {
            var mapMain:MapMain = new MapMain(loader.content as Sprite);
            mapMain.data = mv;
            if(back != null)
            {
               customBackParam ? back(mapMain,customBackParam) : back(mapMain);
            }
         },fail,process);
      }
      
      public static function dispose() : void
      {
         clearFighterCache();
         clearSwfCache();
         System.gc();
      }
      
      public static function clearFighterCache(fighterId:String = null) : void
      {
         if(fighterId)
         {
            if(_fighterCache[fighterId])
            {
               disposeFighterVO(_fighterCache[fighterId] as FighterCacheVO);
               delete _fighterCache[fighterId];
            }
         }
         else
         {
            for(var key in _fighterCache)
            {
               disposeFighterVO(_fighterCache[key] as FighterCacheVO);
               delete _fighterCache[key];
            }
            _fighterCache = {};
         }
      }
      
      private static function disposeFighterVO(vo:FighterCacheVO) : void
      {
         if(!vo)
         {
            return;
         }
         if(vo.loaderSlave)
         {
            try
            {
               vo.loaderSlave.close();
            }
            catch(e:Error)
            {
            }
            try
            {
               vo.loaderSlave.unloadAndStop(true);
            }
            catch(e:Error)
            {
            }
         }
         if(vo.loader)
         {
            try
            {
               vo.loader.close();
            }
            catch(e:Error)
            {
            }
            try
            {
               vo.loader.unloadAndStop(true);
            }
            catch(e:Error)
            {
            }
         }
         vo.loader = null;
         vo.loaderSlave = null;
         vo.fighterData = null;
      }
      
      public static function clearSwfCache() : void
      {
         var loader:Loader;
         var url:String;
         while(_loadedSwfCache.length > 0)
         {
            loader = _loadedSwfCache.pop();
            if(loader)
            {
               try
               {
                  loader.close();
               }
               catch(e:Error)
               {
               }
               try
               {
                  loader.unloadAndStop(true);
               }
               catch(e:Error)
               {
               }
            }
         }
         for(url in _swfUrlCache)
         {
            delete _swfUrlCache[url];
         }
         _swfUrlCache = {};
      }
      
      public static function loadSWF(param1:String, param2:Function, param3:Function = null, param4:Function = null, param5:Boolean = false) : void
      {
         var cacheLoader:Loader;
         var url:String = param1;
         var forceNew:Boolean = param5;
         if(!forceNew && _swfUrlCache[url])
         {
            cacheLoader = _swfUrlCache[url] as Loader;
            if(cacheLoader && cacheLoader.content)
            {
               if(param2 != null)
               {
                  param2(cacheLoader);
               }
               return;
            }
            delete _swfUrlCache[url];
         }
         AssetManager.I.loadSWF(url,function(loader:Loader):void
         {
            if(!forceNew)
            {
               _swfUrlCache[url] = loader;
            }
            _loadedSwfCache.push(loader);
            if(param2 != null)
            {
               param2(loader);
            }
         },function():void
         {
            if(param3 != null)
            {
               param3("Gagal memuat SWF");
            }
         },param4);
      }
   }
}

import flash.display.Loader;
import net.play5d.game.bvn.data.FighterVO;

class FighterCacheVO
{
   
   public var loader:Loader;
   
   public var loaderSlave:Loader;
   
   public var fighterData:FighterVO;
   
   public var usedContent:Boolean = false;
   
   public var usedSlave:Boolean = false;
   
   public function FighterCacheVO()
   {
      super();
   }
}
