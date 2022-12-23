// こちらがオリジナルです。
// 【作者】中内　純(ハンドルネーム：JunKiyoshi)さん
// 【作品名】Hexagon plate. Draw by openframeworks
// https://junkiyoshi.com/2022/03/20/

ArrayList<PVector> location_list = new ArrayList();
FloatList life_list = new FloatList();
FloatList noise_param_list = new FloatList();
ArrayList<PVector> noise_location_list = new ArrayList();

ofMesh face = new ofMesh();
ofMesh frame = new ofMesh();

//--------------------------------------------------------------
void setup() {
  size(720, 720, P3D);

  float radius = 8;
  float x_span = radius * sqrt(3);
  boolean flg = true;
  for (float y = -500; y < 500; y += radius * 1.5) {
    for (float x = -500; x < 500; x += x_span) {
      PVector location;
      if (flg) {
        location = new PVector(x, y, 0);
      } else {
        location = new PVector(x + (x_span / 2), y, 0);
      }

      location_list.add(location);
      life_list.append(0);
      noise_param_list.append(random(1000));
    }
    flg = !flg;
  }
}

//--------------------------------------------------------------
void update() {
  ofSeedRandom(39);

  face.clear();
  frame.clear();
  noise_location_list.clear();

  for (int i = 0; i < location_list.size(); i++) {
    //life_list[i] = life_list[i] > 0 ? life_list[i] - 0.05 : 0;
    float life = life_list.get(i);
    float value = 0;
    if (0 < life) {
      value = life - 0.05f;
    }
    life_list.set(i, value);
    if (0 < value) {
      float np = noise_param_list.get(i);
      np += map(value, 0, 100, 0.05, 0.1);
      noise_param_list.set(i, np);
    }
  }

  for (int i = 0; i < 1; i++) {
    int deg_start = (int)map(openFrameworks.ofNoise(random(1000), ofGetFrameNum() * 0.005), 0, 1, -360, 360);
    int radius = (int)map(openFrameworks.ofNoise(random(1000), ofGetFrameNum() * 0.01), 0, 1, 0, 400);
    for (int deg = deg_start; deg < deg_start + 360; deg += 60) {
      PVector noise_location = new PVector(radius * cos(deg * DEG_TO_RAD), radius * sin(deg * DEG_TO_RAD), 0);
      noise_location_list.add(noise_location);
      for (int ii = 0; ii < location_list.size(); ii++) {
        PVector loc = location_list.get(ii);
        if (PVector.dist(noise_location, loc) < 35) {
          //life_list[i] = life_list[i] < 100 ? life_list[i] + 8 : 100;
          float life = life_list.get(ii);
          float value = 100;
          if (life < 100) {
            value = life + 8;
          }
          life_list.set(ii, value);
        }
      }
    }
  }

  for (int i = 0; i < location_list.size(); i++) {
    float height = 5.f;
    float life = life_list.get(i);
    PVector loc = location_list.get(i);
    if (life > 10) {
      setHexagonToMesh(face, frame, loc, 8, height);
    } else if (life > 0) {
      setHexagonToMesh(face, frame, loc, map(life, 0, 10, 0, 8), height);
    } else {
      //setHexagonToMesh(face, frame, location_list[i], 15, height);
    }
  }
}

//--------------------------------------------------------------
void draw() {
  update();
  translate(width/2, height/2);
  background(255);
  ofSetLineWidth(3);

  face.draw();
  frame.draw();
}

//--------------------------------------------------------------
PVector makeLocation(PVector loc, float x, float y, float z) {
  return new PVector(loc.x + x, loc.y + y, loc.z + z);
}
void setHexagonToMesh(ofMesh face_target, ofMesh frame_target, PVector location, float radius, float height) {
  color face_color = color(255);
  color frame_color = color(0);

  for (int deg = 90; deg < 450; deg += 60) {
    float face_radius = radius - 0.5;
    int face_index = face_target.getNumVertices();

    ArrayList<PVector> vertices = new ArrayList();
    vertices.add(makeLocation(location, 0, 0, 0));
    vertices.add(makeLocation(location, face_radius * cos(deg * DEG_TO_RAD), face_radius * sin(deg * DEG_TO_RAD), 0));
    vertices.add(makeLocation(location, face_radius * cos((deg + 60) * DEG_TO_RAD), face_radius * sin((deg + 60) * DEG_TO_RAD), 0));
    vertices.add(makeLocation(location, 0, 0, height));
    vertices.add(makeLocation(location, face_radius * cos((deg + 60) * DEG_TO_RAD), face_radius * sin((deg + 60) * DEG_TO_RAD), height));
    vertices.add(makeLocation(location, face_radius * cos(deg * DEG_TO_RAD), face_radius * sin(deg * DEG_TO_RAD), height));

    face_target.addVertices(vertices);

    face_target.addIndex(face_index + 0);
    face_target.addIndex(face_index + 1);
    face_target.addIndex(face_index + 2);
    face_target.addIndex(face_index + 3);
    face_target.addIndex(face_index + 4);
    face_target.addIndex(face_index + 5);
    face_target.addIndex(face_index + 1);
    face_target.addIndex(face_index + 2);
    face_target.addIndex(face_index + 4);
    face_target.addIndex(face_index + 1);
    face_target.addIndex(face_index + 4);
    face_target.addIndex(face_index + 5);

    int frame_index = frame_target.getNumVertices();

    vertices.clear();
    vertices.add(makeLocation(location, 0, 0, 0));
    vertices.add(makeLocation(location, radius * cos(deg * DEG_TO_RAD), radius * sin(deg * DEG_TO_RAD), 0));
    vertices.add(makeLocation(location, radius * cos((deg + 60) * DEG_TO_RAD), radius * sin((deg + 60) * DEG_TO_RAD), 0));
    vertices.add(makeLocation(location, 0, 0, height));
    vertices.add(makeLocation(location, radius * cos((deg + 60) * DEG_TO_RAD), radius * sin((deg + 60) * DEG_TO_RAD), height));
    vertices.add(makeLocation(location, radius * cos(deg * DEG_TO_RAD), radius * sin(deg * DEG_TO_RAD), height));

    frame_target.addVertices(vertices);

    frame_target.addIndex(frame_index + 1);
    frame_target.addIndex(frame_index + 2);
    frame_target.addIndex(frame_index + 4);
    frame_target.addIndex(frame_index + 5);
    frame_target.addIndex(frame_index + 1);
    frame_target.addIndex(frame_index + 5);
    frame_target.addIndex(frame_index + 2);
    frame_target.addIndex(frame_index + 4);

    for (int i = 0; i < vertices.size(); i++) {
      face_target.addColor(face_color);
      frame_target.addColor(frame_color);
    }
  }
}
