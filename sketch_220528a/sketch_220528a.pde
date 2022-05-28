// https://openprocessing.org/sketch/1414059

ArrayList<Cell> prev, next;
int[] dx = {-1, 0, 1, 0};
int[] dy = {0, 1, 0, -1};
int[][] map;
int rez, cols, rows;
float col = 0.0f;

void setup() {
  size(1112, 834);
  background(0);
  noStroke();
  colorMode(HSB);
  rez = 2;
  cols = width / rez;
  rows = height / rez;
  prev = new ArrayList<Cell>();
  next = new ArrayList<Cell>();
  map = new int[cols][rows];
  prev.add(new Cell(cols / 2, rows / 2));
  map[cols / 2][rows / 2] = 1;
}

void draw() {
  next = new ArrayList<Cell>();
  fill(col, 255, 255);
  for (Cell c : prev)c.show();
  for (Cell c : prev) {
    for (int i = 0; i < 4; i++) {
      if (valid(c.x + dx[i], c.y + dy[i])) {
        next.add(new Cell(c.x + dx[i], c.y + dy[i]));
        map[c.x + dx[i]][c.y + dy[i]] = 1;
      }
    }
  }
  col = random(255);
  prev.clear();
  prev.addAll(next);
}
boolean valid(int x, int y) {
  int vecini = 0;
  for (int i = 0; i < 4; i++) {
    if (map[x + dx[i]][y + dy[i]] == 1)vecini++;
    if (vecini == 2)return false;
  }
  return true;
}

class Cell {
  int x, y;
  Cell(int x_, int y_) {
    x = x_;
    y = y_;
  }
  void show() {
    rect(x * rez, y * rez, rez, rez);
  }
}
