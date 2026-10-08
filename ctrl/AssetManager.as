package net.play5d.game.bvn.ctrl
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.system.System;
   import flash.utils.Dictionary;
   import net.play5d.game.bvn.data.AssisterModel;
   import net.play5d.game.bvn.data.FighterModel;
   import net.play5d.game.bvn.data.FighterVO;
   import net.play5d.game.bvn.data.MapModel;
   import net.play5d.game.bvn.data.MapVO;
   import net.play5d.game.bvn.interfaces.IAssetLoader;
   import net.play5d.game.bvn.utils.BitmapAssetLoader;
   import net.play5d.kyo.display.bitmap.BitmapFont;
   import net.play5d.kyo.display.bitmap.BitmapFontLoader;
   import net.play5d.kyo.loader.KyoClassLoader;
   import net.play5d.kyo.loader.KyoSoundLoader;
   import net.play5d.kyo.utils.KyoUtils;
   
   public class AssetManager
   {
      
      private static var _i:AssetManager;
      
      private var _swfLoader:KyoClassLoader = new KyoClassLoader();
      
      private var _soundLoader:KyoSoundLoader = new KyoSoundLoader();
      
      private var _bitmapLoader:BitmapAssetLoader = new BitmapAssetLoader();
      
      private var _bitmapFontLoader:BitmapFontLoader = new BitmapFontLoader();
      
      private var _assetLoader:IAssetLoader = null;
      
      private const _effectSwfPath:String = "effect.swf";
      
      private var _effectClassCache:Dictionary = new Dictionary(true);
      
      private var _bitmapDataCache:Dictionary = new Dictionary(false);
      
      public function AssetManager()
      {
         super();
      }
      
      public static function get I() : AssetManager
      {
         if(!_i)
         {
            _i = new AssetManager();
         }
         return _i;
      }
      
      public function init() : void
      {
      }
      
      public function setAssetLoader(loader:IAssetLoader) : void
      {
         _assetLoader = loader;
      }
      
      public function getFont(id:String) : BitmapFont
      {
         return _bitmapFontLoader.getFont(id);
      }
      
      public function loadBasic(onComplete:Function, onProcess:Function = null) : void
      {
         var loadStep:int = 0;
         var loadCount:int = 4;
         var currentType:String = "";
         var dispatchProcess:Function = function(progress:Number):void
         {
            if(onProcess != null)
            {
               onProcess(progress,currentType,loadStep,loadCount);
            }
         };
         var executeNext:Function = function():void
         {
            switch(loadStep)
            {
               case 0:
                  currentType = "Sound";
                  dispatchProcess(0);
                  loadPreLoadSounds(executeNext,dispatchProcess);
                  break;
               case 1:
                  currentType = "Effects";
                  dispatchProcess(0);
                  loadGraphics([_effectSwfPath],executeNext,dispatchProcess);
                  break;
               case 2:
                  currentType = "Fonts";
                  dispatchProcess(0);
                  loadFonts(executeNext,dispatchProcess);
                  break;
               case 3:
                  currentType = "Images";
                  dispatchProcess(0);
                  loadBitmaps(executeNext,dispatchProcess);
                  break;
               case 4:
                  initAssets();
                  if(onComplete != null)
                  {
                     onComplete();
                  }
                  onComplete = null;
                  onProcess = null;
                  executeNext = null;
                  dispatchProcess = null;
                  return;
            }
            ++loadStep;
         };
         executeNext();
      }
      
      private function loadPreLoadSounds(onComplete:Function, onProcess:Function) : void
      {
         var onXmlComplete:Function = function(xml:XML):void
         {
            if(!xml)
            {
               if(onComplete != null)
               {
                  onComplete();
               }
               onXmlComplete = null;
               return;
            }
            var snds:Array = [];
            var bgmPath:String = xml.bgm.@path;
            var sndPath:String = xml.sound.@path;
            for each(var bgmItem in xml.bgm.item)
            {
               snds.push(bgmPath + "/" + bgmItem.toString());
            }
            for each(var sndItem in xml.sound.item)
            {
               snds.push(sndPath + "/" + sndItem.toString());
            }
            loadSoundQueue(snds,onComplete,onProcess);
            onXmlComplete = null;
         };
         _assetLoader.loadXML("config/preload.xml",onXmlComplete);
      }
      
      private function loadSoundQueue(snds:Array, onComplete:Function, onProcess:Function) : void
      {
         var currentUrl:String;
         var queue:Array = snds.concat();
         var totalCount:int = queue.length;
         var loadNext:Function = function():void
         {
            if(queue.length == 0)
            {
               if(onComplete != null)
               {
                  onComplete();
               }
               loadNext = null;
               loadSuccess = null;
               loadFail = null;
               updateProgress = null;
               return;
            }
            currentUrl = queue.shift();
            _assetLoader.loadSound(currentUrl,loadSuccess,loadFail,updateProgress);
         };
         var loadSuccess:Function = function(snd:Sound):void
         {
            _soundLoader.addSound(currentUrl,snd);
            _assetLoader.dispose(currentUrl);
            loadNext();
         };
         var loadFail:Function = function():void
         {
            loadNext();
         };
         var updateProgress:Function = function(prog:Number):void
         {
            if(onProcess != null)
            {
               onProcess((totalCount - queue.length - 1 + prog) / totalCount);
            }
         };
         loadNext();
      }
      
      private function initAssets() : void
      {
         var font1:BitmapFont = getFont("font1");
         if(font1)
         {
            font1.charGap = -8;
            font1.spaceGap = 10;
            font1.offsetY = -5;
         }
      }
      
      public function getEffect(className:String) : *
      {
         var cls:Class = getEffectClass(className);
         return cls ? new cls() : null;
      }
      
      public function getSound(id:String) : Sound
      {
         return _soundLoader.getSound(id);
      }
      
      private function getBitmapClone(url:String) : Bitmap
      {
         if(!url)
         {
            return null;
         }
         var bmd:BitmapData = _bitmapDataCache[url];
         if(!bmd)
         {
            var loadedBitmap:Bitmap = _bitmapLoader.getBitmap(url);
            if(!loadedBitmap || !loadedBitmap.bitmapData)
            {
               return null;
            }
            bmd = loadedBitmap.bitmapData;
            _bitmapDataCache[url] = bmd;
         }
         return new Bitmap(bmd,"auto",true);
      }
      
      public function getFighterFace(vo:FighterVO, size:Point = null) : DisplayObject
      {
         return applySize(getBitmapClone(vo ? vo.faceUrl : null),size || new Point(50,50));
      }
      
      public function getFighterFaceBig(vo:FighterVO, size:Point = null) : DisplayObject
      {
         return applySize(getBitmapClone(vo ? vo.faceBigUrl : null),size || new Point(200,300));
      }
      
      public function getFighterFaceBar(vo:FighterVO, size:Point = null) : DisplayObject
      {
         return applySize(getBitmapClone(vo ? vo.faceBarUrl : null),size || new Point(102,64));
      }
      
      public function getFighterFaceWin(vo:FighterVO, size:Point = null) : DisplayObject
      {
         return applySize(getBitmapClone(vo ? vo.faceWinUrl : null),size || new Point(300,250));
      }
      
      public function getMapPic(vo:MapVO, size:Point = null) : DisplayObject
      {
         return applySize(getBitmapClone(vo ? vo.picUrl : null),size || new Point(450,240));
      }
      
      private function applySize(bmp:Bitmap, size:Point) : Bitmap
      {
         if(bmp)
         {
            bmp.width = size.x;
            bmp.height = size.y;
         }
         return bmp;
      }
      
      public function clearBitmapCache() : void
      {
         var key:String;
         var bmd:BitmapData;
         for(key in _bitmapDataCache)
         {
            bmd = _bitmapDataCache[key] as BitmapData;
            if(bmd)
            {
               try
               {
                  bmd.dispose();
               }
               catch(e:Error)
               {
               }
            }
            delete _bitmapDataCache[key];
         }
         _bitmapDataCache = new Dictionary(false);
      }
      
      public function loadXML(url:String, onCom:Function, onFail:Function) : void
      {
         _assetLoader.loadXML(url,onCom,onFail);
      }
      
      public function loadJSON(url:String, onCom:Function, onFail:Function) : void
      {
         _assetLoader.loadJSON(url,onCom,onFail);
      }
      
      public function loadSWF(url:String, onCom:Function, onFail:Function = null, onProc:Function = null) : void
      {
         _assetLoader.loadSwf(url,onCom,onFail,onProc);
      }
      
      public function loadSound(url:String, onCom:Function, onFail:Function = null, onProc:Function = null) : void
      {
         _assetLoader.loadSound(url,onCom,onFail,onProc);
      }
      
      public function loadBitmap(url:String, onCom:Function, onFail:Function = null, onProc:Function = null) : void
      {
         _assetLoader.loadBitmap(url,onCom,onFail,onProc);
      }
      
      public function disposeAsset(url:String) : void
      {
         _assetLoader.dispose(url);
      }
      
      public function needPreLoad() : Boolean
      {
         return _assetLoader.needPreLoad();
      }
      
      public function loadPreLoad(onCom:Function, onProc:Function = null, onFail:Function = null) : void
      {
         _assetLoader.loadPreLoad(onCom,onProc,onFail);
      }
      
      private function loadGraphics(urls:Array, onComplete:Function = null, onProcess:Function = null) : void
      {
         var currentUrl:String;
         var queue:Array = urls.concat();
         var loadNext:Function = function():void
         {
            if(queue.length < 1)
            {
               if(onComplete != null)
               {
                  onComplete();
               }
               loadNext = null;
               loadSuccess = null;
               loadFail = null;
               return;
            }
            currentUrl = queue.shift();
            _assetLoader.loadSwf(currentUrl,loadSuccess,loadFail,onProcess);
         };
         var loadSuccess:Function = function(loader:Loader):void
         {
            _swfLoader.addSwf(currentUrl,loader);
            _assetLoader.dispose(currentUrl);
            loadNext();
         };
         var loadFail:Function = function():void
         {
            loadNext();
         };
         loadNext();
      }
      
      private function loadBitmaps(onComplete:Function = null, onProcess:Function = null) : void
      {
         var urls:Array = getFighterFaceUrls(FighterModel.I.getAllFighters(),true,true);
         urls = urls.concat(getFighterFaceUrls(AssisterModel.I.getAllAssisters()));
         urls = urls.concat(getMapPicUrls(MapModel.I.getAllMaps()));
         KyoUtils.array_deleteSames(urls);
         _bitmapLoader.loadQueue(urls,onComplete,onProcess);
      }
      
      private function loadFonts(onComplete:Function = null, onProcess:Function = null) : void
      {
         var fontXML:XML;
         var fontBitmapUrl:String;
         var url:String = "font/font1.xml";
         var loadXMLCom:Function = function(xml:XML):void
         {
            fontXML = xml;
            var fileStr:String = xml.pages.page.@file;
            var basePath:String = url.substr(0,url.lastIndexOf("/") + 1);
            fontBitmapUrl = basePath + fileStr;
            _assetLoader.loadBitmap(fontBitmapUrl,bitmapCom,bitmapFail);
         };
         var bitmapCom:Function = function(disp:DisplayObject):void
         {
            var bmp:Bitmap = disp as Bitmap;
            if(bmp && bmp.bitmapData)
            {
               _bitmapFontLoader.addFont(fontXML,bmp.bitmapData);
            }
            _assetLoader.dispose(fontBitmapUrl);
            if(onComplete != null)
            {
               onComplete();
            }
            loadXMLCom = null;
            bitmapCom = null;
            bitmapFail = null;
            loadXMLFail = null;
         };
         var bitmapFail:Function = function():void
         {
            if(onComplete != null)
            {
               onComplete();
            }
            loadXMLCom = null;
            bitmapCom = null;
            bitmapFail = null;
            loadXMLFail = null;
         };
         var loadXMLFail:Function = function():void
         {
            if(onComplete != null)
            {
               onComplete();
            }
            loadXMLCom = null;
            bitmapCom = null;
            bitmapFail = null;
            loadXMLFail = null;
         };
         _assetLoader.loadXML(url,loadXMLCom,loadXMLFail);
      }
      
      private function getFighterFaceUrls(fighters:Object, includeBar:Boolean = false, includeWin:Boolean = false) : Array
      {
         var urls:Array = [];
         for each(var vo in fighters)
         {
            if(vo)
            {
               if(vo.faceUrl)
               {
                  urls.push(vo.faceUrl);
               }
               if(vo.faceBigUrl)
               {
                  urls.push(vo.faceBigUrl);
               }
               if(includeBar && vo.faceBarUrl)
               {
                  urls.push(vo.faceBarUrl);
               }
               if(includeWin && vo.faceWinUrl)
               {
                  urls.push(vo.faceWinUrl);
               }
            }
         }
         return urls;
      }
      
      private function getMapPicUrls(maps:Object) : Array
      {
         var urls:Array = [];
         for each(var mapVO in maps)
         {
            if(mapVO && mapVO.picUrl)
            {
               urls.push(mapVO.picUrl);
            }
         }
         return urls;
      }
      
      private function getEffectClass(className:String) : Class
      {
         var cls:Class = _effectClassCache[className];
         if(cls)
         {
            return cls;
         }
         cls = _swfLoader.getClass(className,_effectSwfPath);
         if(cls)
         {
            _effectClassCache[className] = cls;
         }
         return cls;
      }
      
      public function clearRuntimeCache() : void
      {
         clearEffectClassCache();
         clearBitmapCache();
         System.gc();
      }
      
      public function clearEffectClassCache() : void
      {
         _effectClassCache = new Dictionary(true);
      }
   }
}

