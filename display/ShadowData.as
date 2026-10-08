package net.play5d.game.bvn.display
{
   import net.play5d.game.bvn.fighter.FighterMain;
   
   public class ShadowData
   {
      
      public var owner:FighterMain;
      
      public var shadow:ShadowSprite;
      
      public var groundY:Number;
      
      public function ShadowData()
      {
         super();
      }
      
      public function reset() : void
      {
         owner = null;
         shadow = null;
         groundY = 0;
      }
      
      public function dispose() : void
      {
         if(shadow)
         {
            shadow.dispose();
            shadow = null;
         }
         reset();
      }
   }
}

