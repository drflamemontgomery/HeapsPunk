package;

class Main extends hxd.App {

  public static var ME : Main;
  public var gh : GameHandler;

  static function main() {
    new Main();
  }
  
  public function new() {
    ME = this;
    super();
  }

  override function init() {
    gh = new GameHandler();
    new test.PerlinSquares(s2d);
  }

  override function update(dt:Float) {
    gh._update();
  }

}
