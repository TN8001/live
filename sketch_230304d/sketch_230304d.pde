// オリジナルはこちらです。
// 【作者】Neill Bogieさん
// 【作品名】Top-down sprites: kenney pixel-shmup
// https://openprocessing.org/sketch/1521051

//Featuring sprites by Kenney: https://kenney.nl/assets/pixel-shmup

//TODO: different weapons fire different numbers of shots at different angles

ArrayList<PImage> shipImages = new ArrayList();
ArrayList<PImage> shipImagesGray = new ArrayList();
ArrayList<PImage> bulletImages = new ArrayList();
ArrayList<PImage> explosionImages = new ArrayList();
class Ship {
  PImage img, imgGray;
  PVector pos, vel;
  Weapon weapon;
  float angle;
  float size;
  float health;
  float shield;
}
ArrayList<Ship> ships;
class Bullet {
  PVector pos, vel;
  float angle;
  PImage img;
  float size;
  Ship ship;
  boolean isDead;
}
ArrayList<Bullet> bullets;
class Powerup {
  PVector pos, vel;
  String type;
  PImage img;
  float size;
  float rotation;
  float angle;
  boolean isDead;
}
ArrayList<Powerup> powerups;
class Explosion {
  PVector pos, vel;
  ArrayList<PImage> explosionImages;
  int animIx;
  PImage img;
  float size;
  float rotation;
  float angle;
  boolean isDead;
}
ArrayList<Explosion> explosions = new ArrayList();
PImage terrainImage;
class Weapon {
  PImage bulletImage;
  int numBullets;
}
ArrayList<Weapon> weapons = new ArrayList();

class PowerupImage {
  String type;
  PImage img;
  PowerupImage(String type) {
    this.type = type;
    img = loadImage("powerup_" + type + ".png");
  }
}
ArrayList<PowerupImage> powerupImageMap = new ArrayList();

class TerrainImage {
  String K;
  PImage img;
  TerrainImage(String K, String fileName) {
    this.K = K;
    this.img = loadImage(fileName);
  }
}
class TerrainImageMap {
  ArrayList<TerrainImage> tim = new ArrayList();
  void add(String K, String fileName) {
    TerrainImage ti = TerrainImage(K, fileName);
    tim.add(ti);
  }
  void add(String[] keys) {
    for (String K : keys) {
      TerrainImage ti = TerrainImage(K, K + ".png");
      tim.add(ti);
    }
  }
  PImage get(String K) {
    for (TerrainImage ti : tim) {
      if (ti.equals(K)) {
        return ti.img;
      }
    }
    return null;
  }
}
void preload() {
  for (int i = 0; i < 12; i++) {
    String s = "ship_00" + pad2(i) + ".png";
    PImage img = loadImage(s);
    shipImages.add(img);
    s = "ship_00" + pad2(i+12) + ".png";
    img = loadImage(s);
    shipImagesGray.add(img);
  }
  for (int i = 0; i < 4; i++) {
    String s = "bullet_00" + pad2(i) + ".png";
    PImage img = loadImage(s);
    bulletImages.add(img);
  }
  for (int i = 1; i < 6; i++) {
    String s = "explosion" + i + ".png";
    PImage img = loadImage(s);
    explosionImages.add(img);
  }
  powerupImageMap.add("health");
  powerupImageMap.add("power");
  powerupImageMap.add("shield");

  weapons = createWeapons();

  TerrainImageMap terrainImageMap = new TerrainImageMap();
  terrainImageMap.add("water", "tile_water.png");
  final imageKeys = generateImageKeys();
  terrainImageMap.add(imageKeys);
}

void setup() {
  P5JS.setup(this);

  size(1112, 834);
  background(100);
  ships = new ArrayList();

  noiseSeed(123);
  for (int i = 0; i < 40; i++) {
    createAndAddShip();
  }

  bullets = new ArrayList();
  powerups = new ArrayList();
  explosions = new ArrayList();
  imageMode(CENTER);
  terrainImage = drawMapToImage();
}

void draw() {
  background(#a0d8ef);

  push();
  imageMode(CORNER);
  image(terrainImage, 0, 0);
  pop();
  for (var ship : ships) {
    updateShip(ship);
  }

  for (var bullet : bullets) {
    updateBullet(bullet);
  }

  for (var powerup : powerups) {
    updatePowerup(powerup);
  }

  for (var explosion : explosions) {
    updateExplosion(explosion);
  }
  push();
  for (var powerup : powerups) {
    drawEntity(powerup);
  }
  for (var bullet : bullets) {
    drawEntity(bullet);
  }
  for (var ship : ships) {
    drawShip(ship);
  }
  for (var explosion : explosions) {
    drawEntity(explosion);
  }
  pop();

  ArrayList<Powerup> puList = new ArrayList();
  for (Powerup p : powerups) {
    if (!p.isDead) {
      puList.add(p);
    }
  }
  powerups = puList;
  ArrayList<Ship> shList = new ArrayList();
  for (Ship s : ships) {
    if (!s.isDead) {
      shList.add(s);
    }
  }
  ships = shList;
  ArrayList<Bullet> buList = new ArrayList();
  for (Bullet b : bullets) {
    if (!b.isDead) {
      buList.add(b);
    }
  }
  bullets = buList;
  explosions = explosions.filter(e => !e.isDead);
  ArrayList<Explosion> exList = new ArrayList();
  for (Explosion e : explosions) {
    if (!e.isDead) {
      exList.add(e);
    }
  }
  explosions = exList;

  if (random() < 0.1) {
    createAndAddPowerup();
  }
}

PGraphics drawMapToImage() {
  PGraphics g = createGraphics(width, height);
  drawTerrain(g);
  return g;
}

class GridPos {
  int colIx, rowIx;
  GridPos(int colIx, int rowIx) {
    this.colIx = colIx;
    this.rowIx = rowIx;
  }
}
class Row {
  String type;
  GridPos gridPos;
  Row(String type, int colIx, int rowIx) {
    this.type = type;
    this.gridPos = GridPos(colIx, rowIx);
  }
}
class DrawTerrain {
  ArrayList<ArrayList<Row>> rows;
  int numCols, numRows;
  DrawTerrain(ArrayList<ArrayList<Row>> rows, int numCols, int numRows) {
    this.rows = rows;
    this.numCols = numCols;
    this.numRows = numRows;
  }
  Row getCellAt(int cIx, int rIx) {
    ArrayList<Row> row = rows.get(rIx);
    Row r = row.get(cix);
    return r;
  }
  boolean inGridBounds(int x, int y) {
    return x >= 0 && y >= 0 && x < numCols && y < numRows;
  }
  Row getNextCell(GridPos gridPos, int xOff, int yOff) {
    int x = gridPos.colIx + xOff;
    int y = gridPos.rowIx + yOff;
    if (inGridBounds(x, y, numCols, numRows)) {
      return getCellAt(rows, x, y);
    } else {
      return null;
    }
  }
}
boolean isNotIncludesCell(Row c0, Row c1, Row c2) {
  // c0,c1,c2が有効でc2のtypeがc0およびc1のtypeと一致しない場合trueを返す
  if (c0 == null) {
    return false;
  }
  if (c1 == null) {
    return false;
  }
  if (c2 == null) {
    return false;
  }
  if (c0.type.equals(c2.type)) {
    return false;
  }
  if (c1.type.equals(c2.type)) {
    return false;
  }
  return true;
}
String makeImageCodeType(String type, Row c) {
  String s = "";
  if (c != null) {
    s += c.type;
  } else {
    s += type;
  }
  return s;
}
String makeImageCode(String type, Row c0, Row c1, Row c2, Row c3, Row c4, Row c5, Row c6, Row c7) {
  String s = "" + type;
  s += makeImageCodeType(type, c0);
  s += makeImageCodeType(type, c1);
  s += makeImageCodeType(type, c2);
  s += makeImageCodeType(type, c3);
  s += makeImageCodeType(type, c4);
  s += makeImageCodeType(type, c5);
  s += makeImageCodeType(type, c6);
  s += makeImageCodeType(type, c7);
  return s;
}
String makeImageCode(String type, Row c0, Row c1, Row c2, Row c3) {
  String s = "" + type;
  s += makeImageCodeType(type, c0);
  s += makeImageCodeType(type, c1);
  s += makeImageCodeType(type, c2);
  s += makeImageCodeType(type, c3);
  return s;
}
void drawTerrain(PGraphics g) {
  float noiseScale = 0.1;
  float tileScale = 3;

  float cellSize = 16 * tileScale;
  ArrayList<ArrayList<Row>> rows = new ArrayList();

  int numCols = ceil(width / cellSize);
  int numRows = ceil(height / cellSize);

  for (int rowIx = 0; rowIx < numRows; rowIx++) {
    ArrayList<Row> row = new ArrayList();
    rows.add(row);
    for (int colIx = 0; colIx < numCols; colIx++) {
      float n = g.noise(colIx * noiseScale, rowIx * noiseScale);
      String type;
      if (n > 0.6) {
        type = "e";
      } else if (n < 0.4) {
        type = "g";
      } else {
        type = "w";
      }

      Row r = new Row(type, colIx, rowIx);
      row.add(r);
    }
  }

  for (ArrayList<Row> row : rows) {
    for (Row cell : row) {
      String type = cell.type;
      int rowIx = cell.rowIx;
      int colIx = cell.colIx;
      if (rowIx == 16 && colIx == 1) {
        // debugger;
      }
      String imageCode;
      if (type.equals("g") || type.equals("e")) {
        DrawTerrain dt = new DrawTerrain(rows, numCols, numRows);
        Row upCell = dt.getNextCell(gridPos, 0, -1);
        Row rightCell = dt.getNextCell(gridPos, 1, 0);
        Row upRightCell = dt.getNextCell(gridPos, 1, -1);
        Row upLeftCell = dt.getNextCell(gridPos, -1, -1);
        Row downRightCell = dt.getNextCell(gridPos, 1, 1);
        Row downLeftCell = dt.getNextCell(gridPos, -1, 1);
        Row downCell = dt.getNextCell(gridPos, 0, 1);
        Row leftCell = dt.getNextCell(gridPos, -1, 0);

        if (
          isNotIncludesCell(upCell, rightCell, upRightCell) ||
          isNotIncludesCell(upCell, leftCell, upLeftCell) ||
          isNotIncludesCell(downCell, rightCell, downRightCell.type) ||
          isNotIncludesCell(downCell, leftCell, downLeftCell.type)
          ) {
          //make special code including corners
          imageCode = makeImageCode(type, upCell, upRightCell, rightCell, downRightCell, downCell, downLeftCell, leftCell, upLeftCell);
        } else {
          imageCode = makeImageCode(type, upCell, rightCell, downCell, leftCell);
        }

        if (imageCode.equals("ggggg") || imageCode.equals("eeeee")) {
          String abstractTileName = random() < 0.9 ? P5JS.random(["xxxxx1", "xxxxx2"]) : P5JS.random(["xxxxxtree1", "xxxxxtree2", "xxxxxtree3", "xxxxxhouse1", "xxxxxhouse2", "xxxxxflag"]);
          imageCode = abstractTileName.replace("x", imageCode[0]);
        }
      } else {
        imageCode = "water";
      }
      float x = colIx * cellSize;
      float y = rowIx * cellSize;
      g.push();
      g.noStroke();
      g.translate(x, y);
      PImage img = terrainImageMap.get(imageCode);
      if (!(img == null)) {
        // console.log("couldn't find image for " + imageCode);
        String s = imageCode[0];
        String replacementCode = s + s + s + s + s + "1";
        img = terrainImageMap.get(replacementCode);
      }
      if (!(img == null)) {
        println("no img: " + imageCode);
      }
      g.scale(tileScale);
      g.imageMode(CORNER);
      g.image(img, 0, 0);
      g.textAlign(CENTER, CENTER);
      g.textSize(3.5);
      // g.text(imageCode, 0, 0);
      // g.text([colIx, rowIx].toString(), 0, 5);
      g.pop();
    }
  }
}

void createAndAddShip() {
  int ix = round(random(0, 11));
  PImage img = shipImages.get(ix);
  PImage imgGray = shipImagesGray.get(ix);
  PVector vel = PVector.random2D().mult(random(1, 3));
  Weapon weapon = weapons.get(0);
  Ship ship = new Ship();
  ship.img = img;
  ship.imgGray = imgGray;
  ship.pos = randomScreenPosition();
  ship.vel = vel;
  ship.weapon = weapon;
  ship.angle = vel.heading() + PI / 2.0f;
  ship.size = P5JS.random(1, 2, 3);
  ship.health = 100;
  ship.shield = 100;
  spawnAndMaybeRemoveOlder(ship, ships, 30);
}


PVector randomScreenPosition() {
  return new PVector(random(width), random(height));
}

void updateShip(Ship ship) {
  ship.vel.rotate(radians(map(noise(frameCount / 100.0f), 0, 1, -3, 3)));
  ship.angle = ship.vel.heading() + PI / 2.0f;
  ship.pos.add(ship.vel);
  if (isFarFromScreen(ship.pos)) {
    ship.pos = randomScreenPosition();
  }

  if (random() < 0.01) {
    FloatList angleOffsets = new FloatList();
    if (ship.weapon.numBullets == 3) {
      angleOffsets.append(-PI / 10.0f);
      angleOffsets.append(0);
      angleOffsets.append(PI / 10.0f);
    } else {
      angleOffsets.append(0);
    }
    angleOffsets.forEach(angleOffset => createAndAddBullet(ship, angleOffset));
    for (float angleOffset : angleOffsets) {
      createAndAddBullet(ship, angleOffset));
    }
  }
  ship.tookDamageRecently--;
}

boolean isOffscreen(PVector pos) {
  return (pos.x < 0 || pos.y < 0 || pos.x > width || pos.y > height);
}

void updateBullet(Bullet bullet) {
  bullet.pos.add(bullet.vel);
  if (isOffscreen(bullet.pos)) {
    bullet.isDead = true;
    return;
  }
  for (Ship ship of ships) {
    if (bullet.owner == ship || ship.isDead || bullet.isDead) {
      continue;
    }
    if (PVector.dist(bullet.pos, ship.pos) < 50) {
      ship.tookDamageRecently = 6;
      ship.health -= 30;
      bullet.isDead = true;
      if (ship.health <= 0) {
        ship.isDead = true;
        createAndAddExplosion(ship);
        createAndAddShip();
      }
    }
  }
}

void updatePowerup(Powerup powerup) {
  powerup.pos.add(powerup.vel);
  powerup.angle += powerup.rotation;

  for (Ship ship of ships) {
    if (PVector.dist(powerup.pos, ship.pos) < 50) {
      processReceivedPowerup(ship, powerup);
      powerup.isDead = true;
    }
  }
}

void updateExplosion(Explosion explosion) {
  explosion.pos.add(explosion.vel);
  explosion.angle += explosion.rotation;

  if (frameCount % 10 == 0) {
    explosion.animIx++;
  }

  if (explosion.animIx > explosion.images.length - 1) {
    explosion.isDead = true;
  } else {
    explosion.img = explosion.images.get(explosion.animIx);
  }
}

void createAndAddBullet(Ship ship, float angleOffset) {
  PVector newVel = ship.vel.copy().add(ship.vel.copy().setMag(4 * ship.size));
  newVel.rotate(angleOffset);
  Bullet bullet = new Bullet();
  bullet.pos = ship.pos.copy();
  bullet.vel = newVel;
  bullet.angle = ship.vel.heading() + PI / 2.0f + angleOffset;
  bullet.img = ship.weapon.bulletImage;
  bullet.size = ship.size;
  bullet.owner = ship;
  bullet.isDead = false;

  spawnAndMaybeRemoveOlder(bullet, bullets, 100);
}

void createAndAddPowerup() {
  PowerupImage pi = P5JS.random(powerupImageMap);
  String type = pi.type;
  PImage img = pi.img;
  Powerup powerup = new Powerup();
  powerup.pos = randomScreenPosition();
  powerup.vel = PVector.random2D().mult(random(0.1, 0.5));
  powerup.type = type;
  powerup.img = img;
  powerup.size = random(1, 3);
  powerup.rotation = random(0.01, 0.02) * P5JS.random(-1, 1);
  powerup.angle = random(TWO_PI);
  powerup.isDead = false;

  spawnAndMaybeRemoveOlder(powerup, powerups, 50);
}

function createAndAddExplosion(ship) {
  const explosion = {
  pos:
  ship.pos.copy(),
  vel:
  p5.Vector.random2D().mult(random(0.1, 0.5)),
  images:
  explosionImages,
  animIx:
  0,
  img:
  explosionImages[0],
  size:
  ship.size,
  rotation:
  random(0.01, 0.02) * random([-1, 1]),
  angle:
  random(TWO_PI),
  isDead:
  false
};

spawnAndMaybeRemoveOlder(explosion, explosions, 50);
}

function spawnAndMaybeRemoveOlder(entity, list, maxInGame) {
  list.unshift(entity);//TODO: unshift is O(n) - bad for lots of bullets!

  if (list.length > maxInGame) {
    list.length = maxInGame;
  }
}

function drawShip(ship) {
  push();
  translate(ship.pos.x, ship.pos.y);
  push();
  rotate(ship.angle);
  scale(ship.size, ship.size);
  if (ship.tookDamageRecently > 0) {
    image(ship.imgGray, 0, 0);
  } else {
    image(ship.img, 0, 0);
  }
  pop();
  textSize(10);
  text(ship.health + "\n" + ship.shield, 20, 20);
  pop();
}

//bullets, powerups, other
function drawEntity(ent) {
  push();
  imageMode(CENTER);
  translate(ent.pos.x, ent.pos.y);
  rotate(ent.angle);
  scale(ent.size, ent.size);
  image(ent.img, 0, 0);
  pop();
}

function repeat(n, fn) {
  for (let i = 0; i < n; i++) {
    fn(i);
  }
}

function pad2(n) {
  return n > 9 ? n + "" : "0" + n;
}

function processReceivedPowerup(ship, powerup) {
  if (powerup.type === "power") {
    ship.weapon = random(weapons);
  }
  if (powerup.type === "health") {
    ship.health += 20;
  }
  if (powerup.type === "shield") {
    ship.shield += 10;
  }
}

function createWeapons() {
  return [ {
  bulletImage:
    bulletImages[0],
    numBullets:
    1;
  }
  ,
  {
  bulletImage:
    bulletImages[1],
    numBullets:
    1;
  }
  ,
  {
  bulletImage:
    bulletImages[2],
    numBullets:
    1;
  }
  ,
  {
  bulletImage:
    bulletImages[3],
    numBullets:
    3;
  }
  ];
}

function isFarFromScreen(pos) {
  const margin = 300;
  return pos.x < -margin || pos.x > width + margin || pos.y < -margin || pos.y > height + margin;
}

String[] generateImageKeys() {
  final String[] imageKeys = {
    "gggww",
    "gwggw",
    "ggggw",
    "ggwwg",
    "gggwg",
    "gwwgg",
    "ggwgg",
    "gwggg",
    "eeeww",
    "eweew",
    "eeeew",
    "eewwe",
    "eeewe",
    "ewwee",
    "eewee",
    "eweee",
    "ggwgggggg",
    "ggggwgggg",
    "ggggggwgg",
    "ggggggggw",
    "ggggg1",
    "ggggg2",
    "gggggtree1",
    "gggggtree2",
    "gggggtree3",
    "ggggghouse1",
    "ggggghouse2",
    "gggggflag",
    "ggggglamppost",
    "eeweeeeee",
    "eeeeweeee",
    "eeeeeewee",
    "eeeeeeeew",
    "eeeee1",
    "eeeee2",
    "eeeeetree1",
    "eeeeetree2",
    "eeeeetree3",
    "eeeeehouse1",
    "eeeeehouse2",
    "eeeeeflag",
    "eeeeelamppost",
  };
  return imageKeys;
}
