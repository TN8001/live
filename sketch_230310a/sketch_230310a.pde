// オリジナルはこちらです。
// 【作者】中内　純(ハンドルネーム：JunKiyoshi)さん
// 【作品名】Thick ameba sphere. Draw by openFrameworks
// https://junkiyoshi.com/openframeworks20230226/

ArrayList<ofMeshFace> triangle_list = new ArrayList();
ofMesh mesh = new ofMesh();
ofMesh frame = new ofMesh();

//--------------------------------------------------------------
void setup() {
  size(720, 720, P3D);

  //auto ico_sphere = ofIcoSpherePrimitive(300, 7);
  //triangle_list.insert(triangle_list.end(), ico_sphere.getMesh().getUniqueFaces().begin(), ico_sphere.getMesh().getUniqueFaces().end());
  Sphere sp = new Sphere(300, 7);
  ArrayList<PVector> vs = sp.getVertices();
  for (int i = 0; i < vs.size() / 3; i++) {
    PVector t0 = vs.get(i * 3 + 0);
    PVector t1 = vs.get(i * 3 + 1);
    PVector t2 = vs.get(i * 3 + 2);
    ofMeshFace mf = ofMeshFace(t0, t1, t2);
    triangle_list.add(mf);
  }
}

//--------------------------------------------------------------
PVector addCalc(PVector t, float r, PVetor avg) {  // （名前は適当＼(^_^)／）
  //vertices.add(glm::normalize(triangle_list[i].getVertex(0)) * (radius + 15) - avg);
  float x = (t.x * r) - avg.x;
  float y = (t.y * r) - avg.y;
  float z = (t.z * r) - avg.z;
  return new PVector(x, y, z);
}
void update() {
  ofSeedRandom(1000);

  mesh.clear();
  frame.clear();

  for (float radius = 150; radius <= 250; radius += 100) {
    float noise_seed = random(1000);
    for (int i = 0; i < triangle_list.size(); i++) {
      ofMeshFace mf = triangle_list.get(i);
      PVector t0 = mf.getVertex(0);
      PVector t1 = mf.getVertex(1);
      PVector t2 = mf.getVertex(2);
      //glm::vec3 avg = (triangle_list[i].getVertex(0) + triangle_list[i].getVertex(1) + triangle_list[i].getVertex(2)) / 3;
      float avgX = (t0.x + t1.x + t2.x) / 3.0f;
      float avgY = (t0.y + t1.y + t2.y) / 3.0f;
      float avgZ = (t0.z + t1.z + t2.z) / 3.0f;
      PVector avg = new PVector(avgX, avgY, avgZ);
      float noise_value = openFrameworksNoise.ofNoise(noise_seed, avg.x * 0.0025, avg.y * 0.0025 + ofGetFrameNum() * 0.035, avg.z * 0.0025);
      if (noise_value < 0.47 || noise_value > 0.52) {
        continue;
      }

      ArrayList<PVector> vertices = new ArrayList();

      vertices.add(addCalc(t0, radius + 15, avg));
      vertices.add(addCalc(t1, radius + 15, avg));
      vertices.add(addCalc(t2, radius + 15, avg));

      vertices.add(addCalc(t0, radius - 15, avg));
      vertices.add(addCalc(t1, radius - 15, avg));
      vertices.add(addCalc(t2, radius - 15, avg));

      for (auto& vertex : vertices) {
        vertex += avg;
      }

      mesh.addVertices(vertices);
      frame.addVertices(vertices);

      for (int k = 0; k < vertices.size(); k++) {

        if (radius == 150) {

          mesh.addColor(ofColor(192, 0, 0));
          frame.addColor(ofColor(255, 0, 0));
        } else {

          mesh.addColor(ofColor(50, 50, 192));
          frame.addColor(ofColor(100, 100, 255));
        }
      }

      mesh.addTriangle(mesh.getNumVertices() - 1, mesh.getNumVertices() - 2, mesh.getNumVertices() - 3);
      mesh.addTriangle(mesh.getNumVertices() - 4, mesh.getNumVertices() - 5, mesh.getNumVertices() - 6);

      mesh.addTriangle(mesh.getNumVertices() - 1, mesh.getNumVertices() - 2, mesh.getNumVertices() - 5);
      mesh.addTriangle(mesh.getNumVertices() - 1, mesh.getNumVertices() - 5, mesh.getNumVertices() - 4);

      mesh.addTriangle(mesh.getNumVertices() - 1, mesh.getNumVertices() - 3, mesh.getNumVertices() - 6);
      mesh.addTriangle(mesh.getNumVertices() - 1, mesh.getNumVertices() - 6, mesh.getNumVertices() - 4);

      mesh.addTriangle(mesh.getNumVertices() - 2, mesh.getNumVertices() - 3, mesh.getNumVertices() - 6);
      mesh.addTriangle(mesh.getNumVertices() - 2, mesh.getNumVertices() - 6, mesh.getNumVertices() - 5);

      frame.addIndex(frame.getNumVertices() - 1);
      frame.addIndex(frame.getNumVertices() - 2);
      frame.addIndex(frame.getNumVertices() - 2);
      frame.addIndex(frame.getNumVertices() - 3);
      frame.addIndex(frame.getNumVertices() - 1);
      frame.addIndex(frame.getNumVertices() - 3);

      frame.addIndex(frame.getNumVertices() - 4);
      frame.addIndex(frame.getNumVertices() - 5);
      frame.addIndex(frame.getNumVertices() - 5);
      frame.addIndex(frame.getNumVertices() - 6);
      frame.addIndex(frame.getNumVertices() - 4);
      frame.addIndex(frame.getNumVertices() - 6);

      frame.addIndex(frame.getNumVertices() - 1);
      frame.addIndex(frame.getNumVertices() - 4);
      frame.addIndex(frame.getNumVertices() - 2);
      frame.addIndex(frame.getNumVertices() - 5);
      frame.addIndex(frame.getNumVertices() - 3);
      frame.addIndex(frame.getNumVertices() - 6);
    }
  }
}

//--------------------------------------------------------------
void draw() {
  update();

  background(0);

  cam.begin();
  ofRotateY(ofGetFrameNum());

  mesh.drawFaces();
  frame.drawWireframe();

  cam.end();
}
