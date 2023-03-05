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

class PowerupImageMap {
  PImage health, power, shield;
  PowerupImageMap(String h, String p, String s) {
    health = loadImage(h);
    power = loadImage(p);
    shield = loadImage(s);
  }
}

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
  PowerupImageMap powerupImageMap("powerup_health.png", "powerup_power.png", "powerup_shield.png");

  weapons = createWeapons();

  TerrainImageMap terrainImageMap = new TerrainImageMap();
  terrainImageMap.add("water", "tile_water.png");
  final imageKeys = generateImageKeys();
  terrainImageMap.add(imageKeys);
}

void setup() {
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
  background('skyblue');

  push();
  imageMode(CORNER);
  image(terrainImage, 0, 0);
  pop();
  for (let ship of ships) {
    updateShip(ship);
  }

  for (let bullet of bullets) {
    updateBullet(bullet);
  }

  for (let powerup of powerups) {
    updatePowerup(powerup);
  }

  for (let explosion of explosions) {
    updateExplosion(explosion);
  }
  push();
  for (let powerup of powerups) {
    drawEntity(powerup);
  }
  for (let bullet of bullets) {
    drawEntity(bullet);
  }
  for (let ship of ships) {
    drawShip(ship);
  }
  for (let explosion of explosions) {
    drawEntity(explosion);
  }
  pop();

  powerups = powerups.filter(p => !p.isDead);
  ships = ships.filter(s => !s.isDead);
  bullets = bullets.filter(b => !b.isDead);
  explosions = explosions.filter(e => !e.isDead);

  if (random() < 0.1) {
    createAndAddPowerup();
  }
}

function drawMapToImage() {
  const g = createGraphics(width, height);
  drawTerrain(g);
  return g;
}


function drawTerrain(g) {
  const noiseScale = 0.1;
  const tileScale = 3;

  const cellSize = 16 * tileScale;
  const rows = [];

  const numCols = ceil(width / cellSize);
  const numRows = ceil(height / cellSize);

  for (let rowIx = 0; rowIx < numRows; rowIx++) {

    const row = [];
    rows.push(row);
    for (let colIx = 0; colIx < numCols; colIx++) {
      const n = g.noise(colIx * noiseScale, rowIx * noiseScale);
      let type;
      if (n > 0.6) {
        type = "e";
      } else if (n < 0.4) {
        type = "g";
      } else {
        type = "w";
      }

      row.push( {
        type,
        gridPos:
        {
          colIx,
            rowIx;
        }
      }
      );
    }
  }

  function getCellAt(cIx, rIx) {
    return rows[rIx][cIx];
  }

  function inGridBounds(x, y) {
    return x >= 0 && y >= 0 && x < numCols && y < numRows;
  }

  function getNextCell(gridPos, xOff, yOff) {
    const [x, y] = [gridPos.colIx + xOff, gridPos.rowIx + yOff];
    if (inGridBounds(x, y)) {
      return getCellAt(x, y);
    } else {
      return undefined;
    }
  }

  for (let row of rows) {
    for (let cell of row) {
      const {
        type,
          gridPos
      }
      = cell;

      const {
        rowIx,
          colIx
      }
      = gridPos;
      if (rowIx === 16 && colIx === 1) {
        // debugger;
      }
      let imageCode;
      if (type === "g" || type === "e") {
        const upCell = getNextCell(gridPos, 0, -1);
        const rightCell = getNextCell(gridPos, 1, 0);
        const upRightCell = getNextCell(gridPos, 1, -1);
        const upLeftCell = getNextCell(gridPos, -1, -1);
        const downRightCell = getNextCell(gridPos, 1, 1);
        const downLeftCell = getNextCell(gridPos, -1, 1);
        const downCell = getNextCell(gridPos, 0, 1);
        const leftCell = getNextCell(gridPos, -1, 0);

        if (
          (upCell && rightCell && ![upCell.type, rightCell.type].includes(upRightCell.type)) ||
          (upCell && leftCell && ![upCell.type, leftCell.type].includes(upLeftCell.type)) ||
          (downCell && rightCell && ![downCell.type, rightCell.type].includes(downRightCell.type)) ||
          (downCell && leftCell && ![downCell.type, leftCell.type].includes(downLeftCell.type))
          ) {
          //make special code including corners
          const neighbours = [upCell, upRightCell, rightCell, downRightCell, downCell, downLeftCell, leftCell, upLeftCell].map(c => c?.type || type);
          imageCode = [type, ...neighbours].join("");
        } else {
          const neighbours = [upCell, rightCell, downCell, leftCell].map(c => c?.type || type);
          imageCode = [type, ...neighbours].join("");
        }

        if (imageCode === "ggggg" || imageCode === "eeeee") {

          const abstractTileName = random() < 0.9 ? random(["xxxxx1", "xxxxx2"]) : random(["xxxxxtree1", "xxxxxtree2", "xxxxxtree3", "xxxxxhouse1", "xxxxxhouse2", "xxxxxflag"]);
          imageCode = abstractTileName.replace(/x/g, imageCode[0]);
        }
      } else {
        imageCode = "water";
      }
      const x = colIx * cellSize;
      const y = rowIx * cellSize;
      g.push();
      g.noStroke();
      g.translate(x, y);
      let img = terrainImageMap[imageCode];
      if (!img) {
        // console.log("couldn't find image for " + imageCode);
        const replacementCode = (imageCode[0].repeat(5)) + "1";
        img = terrainImageMap[replacementCode];
      }
      if (!img) {
        console.error("no img: ", {
          imageCode;
        }
        );
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

function collect(num, callbackFn) {
  const arr = [];
  for (let i = 0; i < num; i++) {
    arr.push(callbackFn());
  }
  return arr;
}

function createAndAddShip() {
  const ix = round(random(0, 11));
  const [img, imgGray] = [shipImages[ix], shipImagesGray[ix]];
  const vel = p5.Vector.random2D().mult(random(1, 3));
  const weapon = weapons[0];
  const ship = {
    img,
    imgGray,
    pos: randomScreenPosition(),
    vel,
    weapon,
    angle: vel.heading() + PI / 2,
  size:
  random([1, 2, 3]),
  health:
  100,
  shield:
  100;
}
spawnAndMaybeRemoveOlder(ship, ships, 30);
}


function randomScreenPosition() {
  return createVector(random(width), random(height));
}

function updateShip(ship) {
  ship.vel.rotate(radians(map(noise(frameCount / 100), 0, 1, -3, 3)));
  ship.angle = ship.vel.heading() + PI / 2
    ship.pos.add(ship.vel);
  if (isFarFromScreen(ship.pos)) {
    ship.pos = randomScreenPosition();
  }

  if (random() < 0.01) {
    const angleOffsets = ship.weapon.numBullets === 3 ? [-PI / 10, 0, PI / 10] : [0];
    angleOffsets.forEach(angleOffset => createAndAddBullet(ship, angleOffset));
  }
  ship.tookDamageRecently--;
}

function isOffscreen(pos) {
  return (pos.x < 0 || pos.y < 0 || pos.x > width || pos.y > height);
}

function updateBullet(bullet) {
  bullet.pos.add(bullet.vel);
  if (isOffscreen(bullet.pos)) {
    bullet.isDead = true;
    return;
  }
  for (let ship of ships) {
    if (bullet.owner === ship || ship.isDead || bullet.isDead) {
      continue;
    }
    if (p5.Vector.dist(bullet.pos, ship.pos) < 50) {
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

function updatePowerup(powerup) {
  powerup.pos.add(powerup.vel);
  powerup.angle += powerup.rotation;

  for (let ship of ships) {
    if (p5.Vector.dist(powerup.pos, ship.pos) < 50) {
      processReceivedPowerup(ship, powerup);
      powerup.isDead = true;
    }
  }
}

function updateExplosion(explosion) {
  explosion.pos.add(explosion.vel);
  explosion.angle += explosion.rotation;

  if (frameCount % 10 === 0) {
    explosion.animIx++;
  }

  if (explosion.animIx > explosion.images.length - 1) {
    explosion.isDead = true;
  } else {
    explosion.img = explosion.images[explosion.animIx];
  }
}

function createAndAddBullet(ship, angleOffset) {
  const newVel = ship.vel.copy().add(ship.vel.copy().setMag(4 * ship.size));
  newVel.rotate(angleOffset);
  const bullet = {
  pos:
  ship.pos.copy(),
  vel:
  newVel,
  angle:
  ship.vel.heading() + PI / 2 + angleOffset,
  img:
  ship.weapon.bulletImage,
  size:
  ship.size,
  owner:
  ship,
  isDead:
  false
};

spawnAndMaybeRemoveOlder(bullet, bullets, 100);
}

function createAndAddPowerup() {
  const [type, img] = random(Object.entries(powerupImageMap));
  const powerup = {
  pos:
  randomScreenPosition(),
  vel:
  p5.Vector.random2D().mult(random(0.1, 0.5)),
    type,
    img,
  size:
  random(1, 3),
  rotation:
  random(0.01, 0.02) * random([-1, 1]),
  angle:
  random(TWO_PI),
  isDead:
  false
}

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

function collect(n, fn) {
  const arr = [];
  for (let i = 0; i < n; i++) {
    arr.push(fn(i));
  }
  return arr;
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
