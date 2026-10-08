package net.play5d.game.bvn.data
{
   import net.play5d.kyo.utils.KyoRandom;
   
   public class FighterVO
   {
      
      public var id:String;
      
      public var name:String;
      
      public var comicType:int;
      
      public var fileUrl:String;
      
      public var startFrame:int;
      
      public var faceUrl:String;
      
      public var faceBigUrl:String;
      
      public var faceBarUrl:String;
      
      public var faceWinUrl:String;
      
      public var contactFriends:Array;
      
      public var contactEnemys:Array;
      
      public var says:Array;
      
      public var bgm:String;
      
      public var bgmRate:Number = 1;
      
      public var isAlive:Boolean;
      
      private var _cloneKey:Array = ["id","name","comicType","fileUrl","startFrame","faceUrl","contactFriends","contactEnemys","says","faceBigUrl","faceBarUrl","bgm","bgmRate"];
      
      public function FighterVO()
      {
         super();
      }
      
      public function initByXML(param1:XML) : void
      {
         id = param1.@id;
         name = param1.@name;
         comicType = int(param1.@comic_type);
         fileUrl = param1.file.@url;
         startFrame = int(param1.file.@startFrame);
         faceUrl = param1.face.@url;
         faceBigUrl = param1.face.@big_url;
         faceBarUrl = param1.face.@bar_url;
         faceWinUrl = param1.face.@win_url;
         contactFriends = param1.contact.friend.toString().split(",");
         contactEnemys = param1.contact.enemy.toString().split(",");
         bgm = param1.bgm.@url;
         bgmRate = Number(param1.bgm.@rate) / 100;
         says = [];
         for each(var _loc2_ in param1.says.say_item)
         {
            says.push(_loc2_.children().toString());
         }
         if(startFrame != 0 && !bgm)
         {
            trace(id + "没有定义bgm!");
         }
      }
      
      public function getRandSay() : String
      {
         return KyoRandom.getRandomInArray(says);
      }
      
      public function clone() : FighterVO
      {
         var _loc1_:FighterVO = new FighterVO();
         for each(var _loc2_ in _cloneKey)
         {
            _loc1_[_loc2_] = this[_loc2_];
         }
         return _loc1_;
      }
   }
}

