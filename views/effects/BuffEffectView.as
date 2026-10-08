package net.play5d.game.bvn.views.effects
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.fighter.vos.FighterBuffVO;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class BuffEffectView extends EffectView
   {
      
      private var _fighter:FighterMain;
      
      private var _buff:FighterBuffVO;
      
      private var _colorTransform:ColorTransform;
      
      public function BuffEffectView(param1:EffectVO)
      {
         super(param1);
         this.loopPlay = true;
      }
      
      public function setBuff(param1:FighterBuffVO) : void
      {
         _buff = param1;
      }
      
      override public function setTarget(param1:IGameSprite) : void
      {
         super.setTarget(param1);
         if(param1 is FighterMain)
         {
            _fighter = param1 as FighterMain;
         }
         if(_fighter && _data.targetColorOffset)
         {
            if(!_colorTransform)
            {
               _colorTransform = new ColorTransform();
            }
            _colorTransform.redOffset = _data.targetColorOffset[0];
            _colorTransform.greenOffset = _data.targetColorOffset[1];
            _colorTransform.blueOffset = _data.targetColorOffset[2];
            _fighter.changeColor(_colorTransform);
         }
      }
      
      override public function render() : void
      {
         super.render();
         if(_buff.finished)
         {
            if(_data.targetColorOffset && _fighter)
            {
               _fighter.resumeColor();
            }
            remove();
         }
         else if(_fighter)
         {
            setPos(_fighter.x,_fighter.y);
         }
      }
   }
}

