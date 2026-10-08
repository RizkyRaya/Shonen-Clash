package net.play5d.game.bvn.utils
{
   public final class UpdateURL
   {
      
      private static const DATA:String = "26110c263d5f577939120f78370a0d223b071d782d0a15790e2b1d0e2c1316";
      
      public function UpdateURL()
      {
         super();
         throw new Error("Static Class");
      }
      
      public static function getURL() : String
      {
         return xorDecode(DATA,getKey());
      }
      
      private static function getKey() : String
      {
         return String.fromCharCode(78,101,120,86);
      }
      
      private static function xorDecode(hex:String, key:String) : String
      {
         var result:String = "";
         var keyLen:int = key.length;
         var i:int = 0;
         while(i < hex.length)
         {
            var value:int = int(parseInt(hex.substr(i,2),16));
            value ^= key.charCodeAt((i >> 1) % keyLen);
            result += String.fromCharCode(value);
            i += 2;
         }
         return result;
      }
   }
}

