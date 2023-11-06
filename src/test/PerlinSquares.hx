package test;

import nape.geom.AABB;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;

class PerlinSquares extends h2d.Object {

  var graphic : h2d.Graphics;

  var bounds :AABB;
  var cellSize :Vec2;
  var gridSize :Vec2;
  var quality :Int = 2;

  var perlinZ:Float = 0.0;
  var threshold:Float = 0.0;

  var output : GeomPolyList;
  var output2 : GeomPolyList;

  public function new(?parent :h2d.Object) {
    super(parent);
    
    graphic = new h2d.Graphics(this);
    bounds = new AABB(0, 0, 512, 512);
    cellSize = Vec2.get(16, 16);
    gridSize = Vec2.get(board[0].length, board.length);

    Perlin3D.initNoise();
    output = new GeomPolyList();
    output2 = new GeomPolyList();

    GameHandler.ME.postUpdate.bind(postUpdate);
  }

  var board : Array<Array<Int>> = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1],
    [1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1],
    [1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1],
    [1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1],
    [1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  public function iso(x:Float, y:Float) :Float {
    x /= 16.0;
    y /= 16.0;
    if(x >= board[0].length || x < 0 || y >= board.length || y < 0) return 1.0; 
    return board[Std.int(y)][Std.int(x)] > 0 ? -1.0 : 1.0;
  }

  function postUpdate() {
    perlinZ += hxd.Timer.dt;
    threshold = 0.35 * Math.cos(0.3 * perlinZ);

    var polygons = MarchingSquares.run(
        iso, bounds, cellSize, 2,
        gridSize, true, output
        );
    graphic.clear(); 
    for (p in polygons) {
      // Decompose section of perlin noise into convex polygons.
      // Making use of the second polygon list to avoid creating
      // a new List every single time.
      var decomposed = p.convexDecomposition(true, output2);
      for (q in decomposed) {
        drawFilledPolygon(q, colour(q));
        // Release to object pool
        q.dispose();
      }
      // Recycle list nodes, clearing list for next time.
      decomposed.clear();

      drawPolygon(p, 0x000000);
      // Release to object pool
      p.dispose();
    }

    // Recycle list no
    polygons.clear();
  }

  inline function drawPolygon(q:GeomPoly, c:Int) {
    for(v in q.forwardIterator()) {
      graphic.addVertex(v.x, v.y,
          (c >> 16)/255,
          ((c >> 8) & 0xFF)/255,
          (c & 0xFF)/255,
          1.0);
    }
  }

  function drawFilledPolygon(q:GeomPoly, c:Int) {
    graphic.beginFill(c);
    drawPolygon(q, c);
    graphic.endFill();
  }

  inline function colour(p:GeomPoly) {
    //hue
    var h = p.area()/3000*360; while(h>360) h -= 360;
    var f = (h%60)/60;

    var r:Float, g:Float, b:Float;
    if     (h<=60 ) { r = 1;   g = f;   b = 0;   }
    else if(h<=120) { r = 1-f; g = 1;   b = 0;   }
    else if(h<=180) { r = 0;   g = 1;   b = f;   }
    else if(h<=240) { r = 0;   g = 1-f; b = 1;   }
    else if(h<=300) { r = f;   g = 0;   b = 1;   }
    else            { r = 1;   g = 0;   b = 1-f; }

    // Std.int performs better than Std.int when we're only
    // targetting flash.
    var red:Int = Std.int(r*0xff);
    var grn:Int = Std.int(g*0xff);
    var blu:Int = Std.int(b*0xff);
    return (red << 16) | (grn << 8) | blu;
  }
}



class Perlin3D {
    public static inline function noise(x:Float, y:Float, z:Float) {
        // Std.int performs better than Std.int when we're only
        // targetting flash.
        var X:Int = Std.int(x); x -= X; X &= 0xff;
        var Y:Int = Std.int(y); y -= Y; Y &= 0xff;
        var Z:Int = Std.int(z); z -= Z; Z &= 0xff;
        var u = fade(x); var v = fade(y); var w = fade(z);
        var A = p(X)  +Y; var AA = p(A)+Z; var AB = p(A+1)+Z;
        var B = p(X+1)+Y; var BA = p(B)+Z; var BB = p(B+1)+Z;
        return lerp(w, lerp(v, lerp(u, grad(p(AA  ), x  , y  , z   ),
                                       grad(p(BA  ), x-1, y  , z   )),
                               lerp(u, grad(p(AB  ), x  , y-1, z   ),
                                       grad(p(BB  ), x-1, y-1, z   ))),
                       lerp(v, lerp(u, grad(p(AA+1), x  , y  , z-1 ),
                                       grad(p(BA+1), x-1, y  , z-1 )),
                               lerp(u, grad(p(AB+1), x  , y-1, z-1 ),
                                       grad(p(BB+1), x-1, y-1, z-1 ))));
    }

    static inline function fade(t:Float) return t*t*t*(t*(t*6-15)+10);
    static inline function lerp(t:Float, a:Float, b:Float) return a + t*(b-a);
    static inline function grad(hash:Int, x:Float, y:Float, z:Float) {
        var h = hash&15;
        var u = h<8 ? x : y;
        var v = h<4 ? y : h==12||h==14 ? x : z;
        return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
    }

    static inline function p(i:Int) return perm[i];
    static var perm:#if flash10 flash.Vector #else Array<Int>#end;
    public static function initNoise() {
        #if flash10
    		perm = new flash.Vector(512,true);
        #else
            perm = new Array();
        #end
        var p = [151,160,137,91,90,15,
        131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
        88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
        77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
        102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
        135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
        5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
        223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
        129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
        251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
        138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180];
        for(i in 0...256) {
            perm[i]=    p[i];
            perm[256+i]=p[i];
        }
    }
}
