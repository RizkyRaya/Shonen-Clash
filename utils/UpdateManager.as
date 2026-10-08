package net.play5d.game.bvn.utils
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class UpdateManager
   {
      
      public function UpdateManager()
      {
         super();
      }
      
      public static function loadUpdate(swfName:String, onComplete:Function, onFail:Function = null, onLog:Function = null) : void
      {
         var appStorageDir:File;
         var searchPaths:Array;
         var targetFile:File;
         var pathStr:String;
         var checkFile:File;
         var sizeInMB:String;
         var fsDoc:FileStream;
         var bytes:ByteArray;
         var cleanFs:Function;
         var onFileReadComplete:Function;
         var onFileReadError:Function;
         var printLog:Function = function(msg:String):void
         {
            trace("[UpdateManager] " + msg);
            if(onLog != null)
            {
               onLog(msg);
            }
         };
         printLog("1. Memeriksa & memindai penyimpanan eksternal HP...");
         appStorageDir = File.applicationStorageDirectory;
         if(!appStorageDir.exists)
         {
            try
            {
               appStorageDir.createDirectory();
               printLog("Folder Android/data berhasil dibuat secara otomatis.");
            }
            catch(e:Error)
            {
               printLog("Gagal membuat folder Android/data secara otomatis: " + e.message);
            }
         }
         searchPaths = [appStorageDir.resolvePath(swfName).nativePath,"/storage/emulated/0/Android/data/com.jarworld.bleach.bvi/files/" + swfName,"/storage/emulated/0/assets/update/" + swfName,"/sdcard/assets/update/" + swfName,"/storage/emulated/0/Download/" + swfName,"/storage/emulated/0/Documents/" + swfName,"/sdcard/Download/" + swfName,"/sdcard/Documents/" + swfName,File.documentsDirectory.resolvePath(swfName).nativePath,File.userDirectory.resolvePath("Download/" + swfName).nativePath];
         targetFile = null;
         for each(pathStr in searchPaths)
         {
            try
            {
               checkFile = new File(pathStr);
               if(checkFile.exists && checkFile.size > 0)
               {
                  targetFile = checkFile;
                  printLog("File ditemukan! Path: " + pathStr);
                  break;
               }
            }
            catch(e:Error)
            {
            }
         }
         if(targetFile == null)
         {
            if(onFail != null)
            {
               onFail("File update \'" + swfName + "\' tidak ditemukan.\n\nSimpan file update di salah satu lokasi berikut:\n1. /storage/emulated/0/Android/data/com.jarworld.bleach.bvi/files/" + swfName + "\n2. /storage/emulated/0/assets/update/" + swfName);
            }
            return;
         }
         sizeInMB = (targetFile.size / (1024 * 1024)).toFixed(2);
         printLog("2. Ukuran File: " + sizeInMB + " MB. Membaca stream...");
         fsDoc = new FileStream();
         bytes = new ByteArray();
         cleanFs = function():void
         {
            fsDoc.removeEventListener(Event.COMPLETE,onFileReadComplete);
            fsDoc.removeEventListener(IOErrorEvent.IO_ERROR,onFileReadError);
            try
            {
               fsDoc.close();
            }
            catch(e:Error)
            {
            }
         };
         onFileReadComplete = function(e:Event):void
         {
            cleanFs();
            if(bytes.length == 0)
            {
               if(onFail != null)
               {
                  onFail("Error: Pembacaan file menghasilkan 0 Bytes.\nJika menaruh di luar Android/data, pastikan Izin Storage sudah diaktifkan di Pengaturan HP.");
               }
               return;
            }
            var readSizeInMB:String = (bytes.length / (1024 * 1024)).toFixed(2);
            printLog("3. Pembacaan file berhasil (" + readSizeInMB + " MB).\nMemuat SWF...");
            loadBytesToLoader(bytes,onComplete,onFail,printLog);
         };
         onFileReadError = function(e:IOErrorEvent):void
         {
            cleanFs();
            if(onFail != null)
            {
               onFail("Error Stream File: " + e.text);
            }
         };
         fsDoc.addEventListener(Event.COMPLETE,onFileReadComplete);
         fsDoc.addEventListener(IOErrorEvent.IO_ERROR,onFileReadError);
         try
         {
            fsDoc.openAsync(targetFile,FileMode.READ);
         }
         catch(e:Error)
         {
            cleanFs();
            if(onFail != null)
            {
               onFail("Gagal Buka Stream: " + e.message);
            }
         }
      }
      
      private static function loadBytesToLoader(bytes:ByteArray, onComplete:Function, onFail:Function, printLog:Function) : void
      {
         var loader:Loader;
         var cleanListeners:Function;
         var onLoaderComplete:Function;
         var onLoaderError:Function;
         var context:LoaderContext = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
         context.allowCodeImport = true;
         if(context.hasOwnProperty("allowLoadBytesCodeExecution"))
         {
            context["allowLoadBytesCodeExecution"] = true;
         }
         loader = new Loader();
         cleanListeners = function():void
         {
            if(loader && loader.contentLoaderInfo)
            {
               loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoaderComplete);
               loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoaderError);
               loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoaderError);
            }
         };
         onLoaderComplete = function(e:Event):void
         {
            cleanListeners();
            printLog("4. SWF Eksternal Berhasil Dimuat!");
            if(onComplete != null)
            {
               onComplete(loader.content);
            }
         };
         onLoaderError = function(e:Event):void
         {
            cleanListeners();
            var errText:String = "Loader Error";
            if(e is IOErrorEvent)
            {
               errText = (e as IOErrorEvent).text;
            }
            else if(e is SecurityErrorEvent)
            {
               errText = (e as SecurityErrorEvent).text;
            }
            if(onFail != null)
            {
               onFail("Gagal eksekusi SWF: " + errText);
            }
         };
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoaderError);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoaderError);
         try
         {
            loader.loadBytes(bytes,context);
         }
         catch(e:Error)
         {
            cleanListeners();
            if(onFail != null)
            {
               onFail("Crash saat eksekusi SWF: " + e.message);
            }
         }
      }
   }
}

