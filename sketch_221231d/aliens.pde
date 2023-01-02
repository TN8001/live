ArrayList<Alien> aliens;
int aliensMoveDirectionIx;
ArrayList<Design[]> spriteDesigns = new ArrayList();

final int[][] aliensMoveDirections = { {1, 0}, {0, 1}, {-1, 0}, {0, 1} };

void createAliens() {
  createAlienSpriteDesigns();
  aliens = new ArrayList();
  for (int col = 0; col < 11; col++) {
    for (int row = 0; row < 5; row++) {
      aliens.add(new Alien(col, row));
    }
  }
}

class Alien {
  PVector pos;
  int row;
  boolean isDead;
  Alien(int col, int row) {
    float spacing = width / 14.0f;
    float x = (1 + col) * spacing;
    float y = (1 + row) * spacing;
    this.pos = new PVector(x, y);
    this.row = row;
    this.isDead = false;
  }
  void draw(float sz) {
    fill(255);
    noStroke();
    push();
    translate(pos.x, pos.y);
    drawAlienSprite(row, sz);
    pop();
  }
  void kill() {
    isDead = true;
    score += 20;
    // すべて死んでいたらnewLevel()する
    //if (!aliens.some(a => !a.isDead)) {
    //  newLevel();
    //}
    boolean bAllDead = true;
    for (Alien a : aliens) {
      if (!a.isDead) {
        bAllDead = false;
        break;
      }
    }
    if (bAllDead) {
      newLevel();
    }
  }
  void move(float alienStepSize) {
    if (movingDown()) {
      pos.y += 50;
    } else {
      //const [xOffset, yOffset] = currentMoveDirection().map(v => v * config.alienStepSize);
      int[] offset = currentMoveDirection();
      pos.x += alienStepSize * offset[0];
    }
  }
  boolean isAtScreenEdge() {
    return (
      (movingRight() && pos.x > width - 50) ||
      (movingLeft() && pos.x < 50));
  }
}

void drawAliens() {
  for (Alien a : aliens) {
    a.draw(config.alienSpriteSize);
  }
}

void drawAlienSprite(int alienNumber, float sz) {
  color c = lerpColor(magenta, cyan, alienNumber / 4.0f);
  fill(c);
  Design[] design = spriteDesigns.get(alienNumber);
  push();
  float pixelSize = sz / 5.0f;
  translate(-sz / 2.0f, -sz / 2.0f);
  //const designKeyForFrame = frameCount % 60 < 30 ? "main" : "alt";
  int designKeyForFrame = frameCount % 60 < 30 ? 0 : 1;
  Design ddd = design[designKeyForFrame];
  for (int row = 0; row < 5; row++) {
    for (int col = 0; col < 5; col++) {
      boolean bit = ddd.rows[row][col < 3 ? col : 4 - col];
      if (bit) {
        square(col * pixelSize, row * pixelSize, pixelSize);
      }
    }
  }
  pop();
}

int[] currentMoveDirection() {
  return aliensMoveDirections[aliensMoveDirectionIx];
}

boolean movingRight() {
  return currentMoveDirection()[0] > 0;
}

boolean movingLeft() {
  return currentMoveDirection()[0] < 0;
}

boolean movingDown() {
  return currentMoveDirection()[1] == 1;
}

void advanceMoveDirection() {
  aliensMoveDirectionIx = (aliensMoveDirectionIx + 1) % aliensMoveDirections.length;
}

boolean isAllAtScreenEdge() {
  for (Alien a : aliens) {
    if (a.isAtScreenEdge()) {
      return true;
    }
  }
  return false;
}
void updateAliens() {
  if (frameCount % config.framesBeforeAlienMove == 0) {
    for (Alien a : aliens) {
      a.move(config.alienStepSize);
    }
    if (movingDown()) {
      advanceMoveDirection();
    }
    if ((movingLeft() || movingRight()) && isAllAtScreenEdge()) {
      advanceMoveDirection();
    }
  }
  //aliens = aliens.filter(a => !a.isDead);
  ArrayList<Alien> newAliens = new ArrayList();
  for (Alien a : aliens) {
    if (a.isDead == false) {
      newAliens.add(a);
    }
  }
  aliens = newAliens;
}


void createAlienSpriteDesigns() {
  //spriteDesigns = collect(5, () => createRandomAlienSpriteDesign());
  for (int i = 0; i < 5; i++) {
    spriteDesigns.add(createRandomAlienSpriteDesign());
  }
}

class Design {
  boolean[][] rows = new boolean[5][3];
  Design() {
    for (int row = 0; row < rows.length; row++) {
      for (int col = 0; col < rows[row].length; col++) {
        if (random(1) < 0.5f) {
          rows[row][col] = true;
        } else {
          rows[row][col] = false;
        }
      }
    }
  }
  Design(Design src) {
    for (int row = 0; row < rows.length; row++) {
      for (int col = 0; col < rows[row].length; col++) {
        rows[row][col] = src.rows[row][col];
      }
    }
  }
}

// "main" ⇒ Design[0]、"alt" ⇒ Design[1]と決めた！
class IX {
  int x, y;
  IX(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

void swapIX(IX[] arr, int i, int j) {
  IX tmp = arr[i];
  arr[i] = arr[j];
  arr[j] = tmp;
}
IX[] shuffleIX(IX[] args) {
  IX[] arr = new IX[args.length];
  for (int i = 0; i < args.length; i++) {
    arr[i] = new IX(args[i].x, args[i].y);
  }
  for (int i = arr.length; 1 < i; i--) {
    swapIX(arr, i-1, (int)random(i));
  }
  return arr;
}
Design[] createRandomAlienSpriteDesign() {
  Design[] dsn = new Design[2];
  dsn[0] = new Design();  // "main"
  dsn[1] = new Design(dsn[0]);  // "alt"

  //generate the [x,y] values of the possible positions
  IX[] positions = new IX[15];
  for (int ix = 0; ix < positions.length; ix++) {
    positions[ix] = new IX(ix % 3, floor(ix / 3));
  }

  //choose which to mutate
  //IX[] positionsToToggle = shuffle(positions).slice(0, 3);
  IX[] shufflePositions = shuffleIX(positions);
  IX[] positionsToToggle = new IX[3];
  for (int i = 0; i < positionsToToggle.length; i++) {
    positionsToToggle[i] = shufflePositions[i];
  }
  for (IX ix : positionsToToggle) {
    dsn[1].rows[ix.y][ix.x] = !dsn[1].rows[ix.y][ix.x];
  }

  return dsn;
}
