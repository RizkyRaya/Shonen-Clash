package net.play5d.game.bvn.mob
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.media.Sound;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.interfaces.IAssetLoader;
   import net.play5d.kyo.loader.KyoLoaderLite;
   import net.play5d.kyo.loader.KyoURLoader;
   
   public class AssetLoader implements IAssetLoader
   {
      
      private static var _byteCache:Dictionary = new Dictionary();
      
      public function AssetLoader()
      {
         super();
         initModDirectory();
      }
      
      public static function clearCache() : void
      {
         for(var key in _byteCache)
         {
            delete _byteCache[key];
         }
         _byteCache = new Dictionary();
      }
      
      public function loadXML(url:String, onComplete:Function, onFail:Function = null) : void
      {
         var fullUrl:String = getFullUrl(url);
         var loadSuccess:Function = function(data:String):void
         {
            var xmlData:XML;
            try
            {
               xmlData = new XML(data);
               if(onComplete != null)
               {
                  onComplete(xmlData);
               }
            }
            catch(e:Error)
            {
               trace("AssetLoader.loadXML :: Gagal parsing XML dari " + fullUrl + "\n" + e.message);
               if(onFail != null)
               {
                  onFail();
               }
            }
            loadSuccess = null;
            onComplete = null;
            onFail = null;
         };
         var loadError:Function = function():void
         {
            if(onFail != null)
            {
               onFail();
            }
            loadSuccess = null;
            loadError = null;
            onComplete = null;
            onFail = null;
         };
         KyoURLoader.load(fullUrl,loadSuccess,loadError);
      }
      
      public function loadJSON(url:String, onComplete:Function, onFail:Function = null) : void
      {
         var fullUrl:String = getFullUrl(url);
         var loadSuccess:Function = function(data:String):void
         {
            var jsonObj:Object;
            try
            {
               jsonObj = JSON.parse(data);
               if(onComplete != null)
               {
                  onComplete(jsonObj);
               }
            }
            catch(e:Error)
            {
               trace("AssetLoader.loadJSON :: Gagal parsing JSON dari " + fullUrl + "\n" + e.message);
               if(onFail != null)
               {
                  onFail();
               }
            }
            loadSuccess = null;
            onComplete = null;
            onFail = null;
         };
         var loadError:Function = function():void
         {
            if(onFail != null)
            {
               onFail();
            }
            loadSuccess = null;
            loadError = null;
            onComplete = null;
            onFail = null;
         };
         KyoURLoader.load(fullUrl,loadSuccess,loadError);
      }
      
      public function loadSwf(url:String, onComplete:Function, onFail:Function = null, onProcess:Function = null) : void
      {
         var cachedBytes:ByteArray;
         var resolvedUrl:String;
         var cleanUrl:String = url;
         if(cleanUrl.indexOf("assets/") == 0)
         {
            cleanUrl = cleanUrl.substring(7);
         }
         if(_byteCache[cleanUrl])
         {
            cachedBytes = _byteCache[cleanUrl] as ByteArray;
            KyoLoaderLite.bytesToDisplay(cachedBytes,function(loader:*):void
            {
               if(onComplete != null)
               {
                  onComplete(loader);
               }
            },onFail);
            return;
         }
         resolvedUrl = getFullUrl(url);
         KyoLoaderLite.loadBytes(resolvedUrl,function(bytes:ByteArray):void
         {
            _byteCache[cleanUrl] = bytes;
            KyoLoaderLite.bytesToDisplay(bytes,function(loader:*):void
            {
               if(onComplete != null)
               {
                  onComplete(loader);
               }
            },onFail);
         },onFail,onProcess);
      }
      
      public function loadBitmap(url:String, onComplete:Function, onFail:Function = null, onProcess:Function = null) : void
      {
         KyoLoaderLite.load(getFullUrl(url),onComplete,onFail,onProcess);
      }
      
      public function loadSound(url:String, onComplete:Function, onFail:Function = null, onProcess:Function = null) : void
      {
         var fullUrl:String = getFullUrl(url);
         var s:Sound = new Sound();
         var clear:Function = function():void
         {
            s.removeEventListener(Event.COMPLETE,onSndComplete);
            s.removeEventListener(IOErrorEvent.IO_ERROR,onSndError);
            s.removeEventListener(ProgressEvent.PROGRESS,onSndProgress);
            clear = null;
            onSndComplete = null;
            onSndError = null;
            onSndProgress = null;
            onComplete = null;
            onFail = null;
            onProcess = null;
         };
         var onSndComplete:Function = function(e:Event):void
         {
            if(onComplete != null)
            {
               onComplete(s);
            }
            clear();
         };
         var onSndError:Function = function(e:IOErrorEvent):void
         {
            trace("AssetLoader.loadSound :: Gagal memuat suara dari " + fullUrl);
            if(onFail != null)
            {
               onFail();
            }
            clear();
         };
         var onSndProgress:Function = function(e:ProgressEvent):void
         {
            if(onProcess != null)
            {
               onProcess(e.bytesLoaded / e.bytesTotal);
            }
         };
         s.addEventListener(Event.COMPLETE,onSndComplete);
         s.addEventListener(IOErrorEvent.IO_ERROR,onSndError);
         s.addEventListener(ProgressEvent.PROGRESS,onSndProgress);
         s.load(new URLRequest(fullUrl));
      }
      
      public function dispose(url:String) : void
      {
         var cleanUrl:String = url;
         if(cleanUrl.indexOf("assets/") == 0)
         {
            cleanUrl = cleanUrl.substring(7);
         }
         if(_byteCache[cleanUrl])
         {
            delete _byteCache[cleanUrl];
         }
      }
      
      public function disposeAll() : void
      {
         clearCache();
      }
      
      public function needPreLoad() : Boolean
      {
         return false;
      }
      
      public function loadPreLoad(onComplete:Function, onProcess:Function = null, onFail:Function = null) : void
      {
      }
      
      private function getFullUrl(url:String) : String
      {
         var relativePath:String;
         var extPublicFile:File;
         var extAppDataFile:File;
         var internalFile:File;
         var cleanUrl:String = url;
         if(cleanUrl.indexOf("assets/") == 0)
         {
            cleanUrl = cleanUrl.substring(7);
         }
         relativePath = "assets/" + cleanUrl;
         try
         {
            extPublicFile = new File("/storage/emulated/0/" + relativePath);
            if(extPublicFile.exists)
            {
               return extPublicFile.url;
            }
         }
         catch(e:Error)
         {
         }
         try
         {
            extAppDataFile = File.applicationStorageDirectory.resolvePath(relativePath);
            if(extAppDataFile.exists)
            {
               return extAppDataFile.url;
            }
         }
         catch(e:Error)
         {
         }
         internalFile = File.applicationDirectory.resolvePath(relativePath);
         return internalFile.url;
      }
      
      private function initModDirectory() : void
      {
         var shonenclashDir:File;
         var foldersToCreate:Array = ["assets","assets/fighter","assets/fighter/char","assets/assist","assets/bgm","assets/ui","assets/config","assets/map"];
         createFoldersInBaseDir(File.applicationStorageDirectory,foldersToCreate);
         try
         {
            shonenclashDir = new File("/storage/emulated/0");
            createFoldersInBaseDir(shonenclashDir,foldersToCreate);
         }
         catch(e:Error)
         {
            trace("AssetLoader :: Folder Documents tidak dapat dibuat. Pastikan izin STORAGE diberikan.");
         }
      }
      
      private function createFoldersInBaseDir(baseDir:File, folders:Array) : void
      {
         var i:int = 0;
         while(i < folders.length)
         {
            var folder:File = baseDir.resolvePath(folders[i]);
            if(!folder.exists)
            {
               folder.createDirectory();
            }
            i++;
         }
      }
   }
}

