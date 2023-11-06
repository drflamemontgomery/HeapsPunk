package test;

import nape.phys.BodyType;
import nape.shape.Polygon;

import hxd.Key as K;

class Test extends h2d.NapeBody {

  public function new(?parent : h2d.Object) {
    super(parent, BodyType.DYNAMIC);
    body.shapes.add(new Polygon(Polygon.box(32, 32)));
    new h2d.Bitmap(h2d.Tile.fromColor(0xFF00FF, 32, 32), this);

  }

  override function onAdd() {
    super.onAdd();
    GameHandler.ME.preUpdate.bind(preUpdate);
  }

  override function onRemove() {
    super.onRemove();
    GameHandler.ME.preUpdate.remove(preUpdate);
  }


  function preUpdate() {
    velocity.x = 0;
    if(K.isDown(K.LEFT)) velocity.x = -1.0;
    else if(K.isDown(K.RIGHT)) velocity.x = 1.0;
  }
}
