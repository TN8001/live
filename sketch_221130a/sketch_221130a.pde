// こちらがオリジナルです。
// 【作者】中内　純(ハンドルネーム：JunKiyoshi)さん
// 【作品名】Dot or Line. Draw by openFrameworks
// https://junkiyoshi.com/2022/01/20/

ofMesh line = new ofMesh();
ofMesh draw_line = new ofMesh();
//--------------------------------------------------------------
void setup() {
  size(720, 720, P3D);

  Sphere sp = new Sphere(150, 3);
  ArrayList<PVector> triangles = sp.getVertices();
  for (int i = 0; i < vertices.size(); i+=3) {
    //var avg = new PVector(triangle.getVertex(0) + triangle.getVertex(1) + triangle.getVertex(2)) / 3;
    PVector t0 = vertices.get(i+0);
    PVector t1 = vertices.get(i+1);
    PVector t2 = vertices.get(i+2);
    PVector avg = PVector.add(t0, t1);
    avg.add(t2);
    avg.div(3.0f);
    line.addVertex(avg);
  }

  for (int i = 0; i < line.getNumVertices(); i++) {
    for (int k = i + 1; k < line.getNumVertices(); k++) {
      var location = line.getVertex(i);
      var other = line.getVertex(k);
      if (PVector.dist(location, other) < 15) {
        line.addIndex(i);
        line.addIndex(k);
      }
    }
  }
}

//--------------------------------------------------------------
void ofApp::update() {

  draw_line = line;

  for (var vertex : draw_line.getVertices()) {

    var noise_value = ofNoise(glm::vec4(vertex * 0.0015, ofGetFrameNum() * 0.01));

    if (noise_value > 0.5 && noise_value < 0.55) {

      vertex = glm::normalize(vertex) * ofMap(noise_value, 0.5, 0.55, 200, 300);
    } else if (noise_value > 0.55) {

      vertex = glm::normalize(vertex) * 300;
    } else {

      vertex = glm::normalize(vertex) * 200;
    }
  }
}

//--------------------------------------------------------------
void draw() {
  update();
  translate(width/2, height/2);

  ofBackground(0);
  ofSetColor(255);
  ofEnableDepthTest();
  ofSetLineWidth(1.5);

  cam.begin();
  ofRotateY(ofGetFrameNum());

  ofTranslate(-320, 0, 0);

  draw_line.drawWireframe();

  ofTranslate(640, 0, 0);

  for (var vertex : draw_line.getVertices()) {

    ofDrawSphere(vertex, 3.5);
  }

  cam.end();
}
