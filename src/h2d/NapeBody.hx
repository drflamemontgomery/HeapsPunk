package h2d;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.geom.Vec2;

class NapeBody extends Object {

  public var body : Body;

  public var velocity(get, set) : Vec2;
  inline function get_velocity() {
    return body.velocity;
  }
  inline function set_velocity(v) {
    return body.velocity = v;
  }

  public function new(?parent : Object, bodyType : BodyType) {
    super(parent);
    body = new Body(bodyType);
    body.space = GameHandler.ME.napeSpace;
  }

  override function sync(ctx:RenderContext) {
    x = body.position.x;
    y = body.position.y;
    super.sync(ctx);
  }
}
