// こちらがオリジナルです。
// 【作者】中内　純(ハンドルネーム：JunKiyoshi)さん
// 【作品名】Symmetrical ribbons flower. Draw by openFrameworks
// https://junkiyoshi.com/2021/12/25/

ofMesh face, line;
//--------------------------------------------------------------
void setup() {
  face = new ofMesh();
  line = new ofMesh();
}

//--------------------------------------------------------------
void update() {
  randomSeed(39);

  face.clear();
  line.clear();

  var noise_seed = new PVector(ofRandom(1000), ofRandom(1000));
  int start_index = face.getNumVertices();
  for (float x = 128; x < 255; x += 1) {
    float next_x = x + 1;
    int index = face.getNumVertices();

    float angle_x = map(openFrameworks.ofNoise(noise_seed.x, x * 0.0035 + frameCount * 0.01), 0, 1, PI * -2, PI * 2);
    //auto rotation_x = glm::rotate(glm::mat4(), angle_x, glm::vec3(1, 0, 0));
    PMatrix3D rotation_x = new PMatrix3D();
    rotation_x.rotateX(angle_x);

    float angle_y = map(openFrameworks.ofNoise(noise_seed.y, x * 0.0035 + frameCount * 0.01), 0, 1, PI * -2, PI * 2);
    //auto rotation_y = glm::rotate(glm::mat4(), angle_y, glm::vec3(0, 1, 0));
    PMatrix3D rotation_y = new PMatrix3D();
    rotation_y.rotateY(angle_y);

    float next_angle_x = map(openFrameworks.ofNoise(noise_seed.x, next_x * 0.0035 + frameCount * 0.01), 0, 1, PI * -2, PI * 2);
    //auto next_rotation_x = glm::rotate(glm::mat4(), next_angle_x, glm::vec3(1, 0, 0));
    PMatrix3D next_angle_x = new PMatrix3D();
    next_angle_x.rotateX(next_angle_x);

    float next_angle_y = map(openFrameworks.ofNoise(noise_seed.y, next_x * 0.0035 + ofGetFrameNum() * 0.01), 0, 1, PI * -2, PI * 2);
    //auto next_rotation_y = glm::rotate(glm::mat4(), next_angle_y, glm::vec3(0, 1, 0));
    PMatrix3D next_rotation_y = new PMatrix3D();
    next_rotation_y.rotateY(next_angle_y);

    ArrayList<PVector> vertices = new ArrayList();
    //vertices.push_back(glm::vec4(x, 10, 0, 0) * rotation_y * rotation_x);
    PVector v = new PVector(x, 10, 0);
    PMatrix3D rotation_yx = new PMatrix3D(rotation_y);
    rotation_yx.apply(rotation_x);
    v = rotation_yx.mult(v, null);
    vertices.add(v);
    //vertices.push_back(glm::vec4(next_x, 10, 0, 0)* next_rotation_y* next_rotation_x);
    v = new PVector(next_x, 10, 0);
    PMatrix3D next_rotation_yx = new PMatrix3D(next_rotation_y);
    next_rotation_yx.apply(next_rotation_x);
    v = next_rotation_yx.mult(v, null);
    vertices.add(v);
    //vertices.push_back(glm::vec4(next_x, -10, 0, 0) * next_rotation_y * next_rotation_x);
    v = new PVector(next_x, -10, 0);
    v = next_rotation_yx.mult(v, null);
    vertices.add(v);
    //vertices.push_back(glm::vec4(x, -10, 0, 0) * rotation_y * rotation_x);
    v = new PVector(x, -10, 0);
    v = rotation_yx.mult(v, null);
    vertices.add(v);

    face.addVertices(vertices);
    line.addVertices(vertices);

    push();
    colorMode(HSB, 255, 255, 255);
    //color.setHsb(ofMap((int)(x + ofGetFrameNum() * 1) % 128, 1, 128, 0, 255), 180, 255);
    int h = (int)map((int)(x + ofGetFrameNum() * 1) % 128, 1, 128, 0, 255);
    color col = color(h, 180, 255);
    //next_color.setHsb(ofMap((int)(next_x + ofGetFrameNum() * 1) % 128, 1, 128, 0, 255), 180, 255);
    h = (int)map((int)(next_x + ofGetFrameNum() * 1) % 128, 1, 128, 0, 255);
    color next_col = color(h, 180, 255);
    pop();

    face.addColor(col);
    face.addColor(next_col);
    face.addColor(next_col);
    face.addColor(col);

    face.addIndex(index + 0);
    face.addIndex(index + 1);
    face.addIndex(index + 2);
    face.addIndex(index + 0);
    face.addIndex(index + 2);
    face.addIndex(index + 3);

    line.addIndex(index + 0);
    line.addIndex(index + 1);
    line.addIndex(index + 2);
    line.addIndex(index + 3);
  }

  line.addIndex(start_index + 0);
  line.addIndex(start_index + 3);
  line.addIndex(line.getNumVertices() - 2);
  line.addIndex(line.getNumVertices() - 3);
}

//--------------------------------------------------------------
void draw() {
  update();
  translate(width/2, height/2);

  background(0);
  strokeWeight(2);

  this->cam.begin();
  ofRotateY(270);

  for (int i = 0; i < 8; i++) {

    ofRotateX(45);

    this->line.drawWireframe();
    this->face.draw();
  }

  this->cam.end();
}

//--------------------------------------------------------------
int main() {

  ofSetupOpenGL(720, 720, OF_WINDOW);
  ofRunApp(new ofApp());
}
