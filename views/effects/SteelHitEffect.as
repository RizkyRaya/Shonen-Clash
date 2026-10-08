package net.play5d.game.bvn.views.effects
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.ctrl.EffectCtrl;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class SteelHitEffect extends EffectView
   {
      
      private var _fighter:FighterMain;
      
      private var _colorTransform:ColorTransform;
      
      public function SteelHitEffect(param1:EffectVO)
      {
         super(param1);
      }
      
      override public function setTarget(param1:IGameSprite) : void
      {
         var v:IGameSprite = param1;
         super.setTarget(v);
         if(v is FighterMain)
         {
            _fighter = v as FighterMain;
            if(_fighter.isSteelBody)
            {
               if(!_colorTransform)
               {
                  _colorTransform = new ColorTransform();
               }
               _colorTransform.redOffset = 150;
               _colorTransform.greenOffset = 150;
               _colorTransform.blueOffset = 150;
               if(_fighter.isSuperSteelBody)
               {
                  _colorTransform.blueOffset = 0;
                  EffectCtrl.I.shine(16776960,0.3);
               }
               _fighter.changeColor(_colorTransform);
               EffectCtrl.I.setOnFreezeOver(onFreezeOverHandler);
            }
         }
      }
      
      private function onFreezeOverHandler() : void
      {
         if(_fighter)
         {
            _fighter.resumeColor();
         }
      }
   }
}

