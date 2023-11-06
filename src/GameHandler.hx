package;

import Signal.Signal0;
import nape.space.Space;
import nape.geom.Vec2;

class GameHandler {

  public static var ME : GameHandler;
  
  public function new() {
    ME = this;
    
    var gravity = Vec2.weak(0, 0.2);
    napeSpace = new Space(gravity);
  }

  public var preUpdate : Signal0 = new Signal0();
  public var update : Signal0 = new Signal0();
  public var postUpdate : Signal0 = new Signal0();
  public var napeSpace : Space;

  public function _update() {
    preUpdate.invoke();
   
    napeSpace.step(hxd.Timer.tmod > 0 ? hxd.Timer.tmod : 1/60.0);

    update.invoke();
    postUpdate.invoke();
  }
}
