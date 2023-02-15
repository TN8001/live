// こちらがオリジナルです。
// 【作者】Richard Bourneさん
// 【作品名】Wave
// https://openprocessing.org/sketch/1833308

PGraphics pg;
float gsx, gsy;
float loopLength;
float speed;
float sinput;
float pad = 20;

void setup() {
  size(1112, 834);

  pg = createGraphics(width, height);

  float gX = 32;
  float gY = 24;

  gsx = (width - pad * 2 ) / gX;
  gsy = (height - pad * 2 ) / gY;

  loopLength = 200;
  speed = 200;
}

// var colorMod = (togg, mod1, mod2) => sin(sinput + x*mod1 + y*mod2)*togg + cos(sinput + x*mod1 + y*mod2)*(1 - togg)
float colorMod(float togg, float mod1, float mod2, float x, float y) {
  return sin(sinput + x*mod1 + y*mod2)*togg + cos(sinput + x*mod1 + y*mod2)*(1 - togg);
}

void makeWave() {
  pg.beginDraw();
  pg.background(0, 0, 50, 20);
  for (float x = pad; x < width-pad+1; x+=gsx ) {
    for (float y = pad; y < height-pad+1; y+=gsy ) {
      float d = dist(x, y, x, x)/2.0f;

      float modulator = sin(sinput + x + y + sin(sinput + d));
      pg.strokeWeight(15 + 15 * modulator);

      var mod1 = 15;
      var mod2 = 15;

      pg.stroke(127.5 + 127.5 * colorMod(1, mod1, mod2, x, y),
        127.5 + 127.5 * colorMod(0, mod1, mod2, x, y),
        127.5 - 127.5 * colorMod(map(sin(sinput), -1, 1, 0, 1), mod1, mod2, x, y));
      pg.point(x, y );
    }
  }
  pg.endDraw();
}

void draw() {
  background(0, 0, 50, 40);

  float t = (frameCount%loopLength)/speed;
  sinput = map(t, 0, 1, 0, TAU);

  makeWave();
  image(pg, 0, 0, width, height);
}
