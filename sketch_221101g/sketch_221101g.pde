// こちらがオリジナルです。
// 【作者】独楽回しeddyさん
// 【作品名】PartialVisibleClock
// https://neort.io/art/c8cefic3p9fffhuguh30

class ColorPaletteClass {
  color colorT = #50d0d0;
  color colorM = #be1e3e;
  color colorK = #7967c3;
  color colorH = #ffc639;
  color colorN = #255699;
  color colorS = #aeb49c;
}
ColorPaletteClass ColorPalette = new ColorPaletteClass();

float m;
float h;
float s;
float clockR;
PVector centerPos;
PGraphics mask;

PGraphics maskPg;

void setup() {
  size(1112, 834);
  background(color(ColorPalette.colorN));

  clockR = height * 0.4;
  centerPos = new PVector(width/2, height/2);

  mask = createGraphics(width, height);
  maskPg = createGraphics(width, height);
}

void draw() {
  background(color(ColorPalette.colorN));
  m = minute();  // 分
  h = hour();    // 時間
  s = second();  // 秒

  push();
  translate(centerPos.x, centerPos.y);
  textSize(50);
  fill(color(ColorPalette.colorH));
  stroke(color(ColorPalette.colorH));
  textAlign(CENTER, CENTER);

  // 文字盤
  for (var i = 0; i < 12; i++) {
    var theta = TWO_PI / 12.0f * i;
    var x = clockR * cos(theta - HALF_PI + HALF_PI / 3.0f);
    var y = clockR * sin(theta - HALF_PI + HALF_PI / 3.0f);
    text(i+1, x, y);
  }

  // 秒間隔
  for (var i = 0; i < 60; i++) {
    var theta = TWO_PI / 60.0f * i;
    var x = (clockR + 60) * cos(theta - HALF_PI + HALF_PI / 3.0f);
    var y = (clockR + 60) * sin(theta - HALF_PI + HALF_PI / 3.0f);
    ellipse(x, y, 10, 10);
  }

  // 5秒間隔
  for (var i = 0; i < 12; i++) {
    var theta = TWO_PI / 12.0f * i;
    var x = (clockR + 60) * cos(theta - HALF_PI + HALF_PI / 3.0f);
    var y = (clockR + 60) * sin(theta - HALF_PI + HALF_PI / 3.0f);
    var dir = PVector.sub(centerPos, new PVector(x, y));
    push();
    translate(x, y);
    rectMode(CENTER);
    rect(0, 0, 20, 20);
    pop();
  }

  // 秒針
  var sTheta = map(s, 0, 60, 0, TWO_PI);
  var sx = (clockR + 60) * cos(sTheta - HALF_PI);
  var sy = (clockR + 60) * sin(sTheta - HALF_PI);
  strokeWeight(1);
  stroke(color(ColorPalette.colorK));
  fill(color(ColorPalette.colorK));
  ellipse(0, 0, 10, 10);
  strokeWeight(3);
  line(0, 0, sx, sy);

  // 分針
  var mTheta = map(m, 0, 60, 0, TWO_PI);
  var offsetMTheta = map(s, 0, 60, 0, TWO_PI/60.0f);
  var mx = (clockR + 20) * cos(mTheta + offsetMTheta - HALF_PI);
  var my = (clockR + 20) * sin(mTheta + offsetMTheta - HALF_PI);
  strokeWeight(1);
  stroke(color(ColorPalette.colorT));
  fill(color(ColorPalette.colorT));
  ellipse(0, 0, 15, 15);
  strokeWeight(5);
  line(0, 0, mx, my);

  // 時間の針
  var hTheta = map(h%12, 0, 12, 0, TWO_PI);
  var offsetHThetaM = map(m, 0, 60, 0, TWO_PI/12.0f);
  var hx = (clockR + 20) * cos(hTheta + offsetHThetaM - HALF_PI);
  var hy = (clockR + 20) * sin(hTheta + offsetHThetaM - HALF_PI);
  strokeWeight(1);
  stroke(color(ColorPalette.colorM));
  fill(color(ColorPalette.colorM));
  ellipse(0, 0, 20, 20);
  strokeWeight(10);
  line(0, 0, hx, hy);

  pop();

  color maskBg = color(ColorPalette.colorH);
  mask.beginDraw();
  mask.clear();
  mask.background(red(maskBg), green(maskBg), blue(maskBg), 200);
  mask.push();
  mask.translate(centerPos.x, centerPos.y);

  // 秒針
  mask.strokeWeight(1);
  mask.stroke(color(ColorPalette.colorK));
  mask.fill(color(ColorPalette.colorK));
  mask.ellipse(0, 0, 10, 10);
  mask.strokeWeight(3);
  mask.line(0, 0, sx, sy);
  //mask.erase();
  //mask.ellipse(sx/1.2, sy/1.2, 200, 200);
  //mask.noErase();

  // 分針
  mask.strokeWeight(1);
  mask.stroke(color(ColorPalette.colorT));
  mask.fill(color(ColorPalette.colorT));
  mask.ellipse(0, 0, 15, 15);
  mask.strokeWeight(5);
  mask.line(0, 0, mx, my);
  //mask.erase();
  //mask.ellipse(mx/1.1, my/1.1, 250, 250);
  //mask.noErase();

  // 時間の針
  mask.strokeWeight(1);
  mask.stroke(color(ColorPalette.colorM));
  mask.fill(color(ColorPalette.colorM));
  mask.ellipse(0, 0, 20, 20);
  mask.strokeWeight(10);
  mask.line(0, 0, hx, hy);
  //mask.erase();
  //mask.ellipse(hx/1.3, hy/1.3, 300, 300);
  //mask.noErase();

  mask.pop();
  mask.endDraw();

  maskPg.beginDraw();
  maskPg.translate(centerPos.x, centerPos.y);
  maskPg.background(255);
  maskPg.noStroke();
  maskPg.fill(0);
  maskPg.ellipse(sx/1.2, sy/1.2, 200, 200);
  maskPg.ellipse(mx/1.1, my/1.1, 250, 250);
  maskPg.ellipse(hx/1.3, hy/1.3, 300, 300);
  maskPg.endDraw();
  //mask.mask(maskPg);

  image(mask, 0, 0);
}
