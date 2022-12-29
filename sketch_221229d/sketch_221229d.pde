// こちらがオリジナルです。
// 【作者】はぅ君さん
// 【作品名】つぶやきCoding | 2022/03/21 by はぅ君
// https://twitter.com/Hau_kun/status/1505872956488314881

float t=0;
float W = 720;
void setup() {
  size(720, 720, P3D);
}
void draw() {
  t+=.01;
  colorMode(HSB, 360, 100, 100);
  background(0);
  float P=PI/6.0f;
  for (float d=520; 0 < d; d-=40) {
    for (float r=d; r<6+d; r+=P) {
      fill(noise(d/99+t, r)*W%360, 60, W);
      beginShape();
      for (float i=0; i<P*2; i+=.05) {
        //vertex(cos(R=r+(P-abs(i-P)))*(D=i<P?d:d-30)+360, sin(R)*D+360);
        float R=r+(P-abs(i-P));
        float D=i<P?d:d-30;
        vertex(cos(R)*D+360, sin(R)*D+360);
      }
      endShape();
    }
  }
}
