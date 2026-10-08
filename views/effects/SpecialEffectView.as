package net.play5d.game.bvn.views.effects
{
   import flash.geom.ColorTransform;
   import net.play5d.game.bvn.data.EffectVO;
   import net.play5d.game.bvn.fighter.FighterMain;
   import net.play5d.game.bvn.interfaces.IGameSprite;
   
   public class SpecialEffectView extends EffectView
   {
      
      private var _fighter:FighterMain;
      
      private var _finished:Boolean;
      
      private var _colorTransform:ColorTransform;
      
      public function SpecialEffectView(param1:EffectVO)
      {
         super(param1);
      }
      
      override public function setTarget(param1:IGameSprite) : void
      {
         super.setTarget(param1);
         if(param1 is FighterMain)
         {
            _fighter = param1 as FighterMain;
            if(_data.targetColorOffset)
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
      }
      
      override public function start(param1:Number = 0, param2:Number = 0, param3:int = 1, param4:Boolean = true) : void
      {
         super.start(param1,param2,param3,param4);
         _finished = false;
      }
      
      override public function render() : void
      {
         super.render();
         if(_finished)
         {
            return;
         }
         if(!_fighter)
         {
            return;
         }
         switch(_fighter.actionState)
         {
            case 23:
            case 24:
            case 0:
               gotoAndPlay("finish");
               _finished = true;
               if(_data.targetColorOffset)
               {
                  _fighter.resumeColor();
               }
               break;
            default:
               setPos(_fighter.x,_fighter.y);
         }
      }
   }
}

