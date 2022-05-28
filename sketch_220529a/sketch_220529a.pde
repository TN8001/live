// https://junkiyoshi.com/2022/02/09/

ArrayList<PVector> location_list;
ArrayList<ArrayList<Integer>> next_index_list;
ArrayList<Integer> destination_list;

ArrayList<Actor> actor_list;

//--------------------------------------------------------------
class Actor {
  int select_index;
  int next_index;

  PVector location;
  ArrayList<PVector> log;
  color col;

  Actor(ArrayList<PVector> location_list, ArrayList<Integer> destination_list) {
    this.select_index = (int)random(0, location_list.size());
    while (true) {
      //var itr = find(destination_list.begin(), destination_list.end(), this.select_index);
      //if (itr == destination_list.end()) {
      //  destination_list.push_back(this.select_index);
      //  break;
      //}
      int destinationSize = destination_list.size();
      int destination = destination_list.get(destinationSize - 1);
      if (destination == this.select_index) {
        destination_list.add(this.select_index);
        break;
      }

      this.select_index = (this.select_index + 1) % location_list.size();
    }

    this.next_index = this.select_index;
  }

  //--------------------------------------------------------------
  void update(int frame_span, ArrayList<PVector> location_list, ArrayList<ArrayList<Integer>> next_index_list, ArrayList<Integer> destination_list) {
    if (frameCount % frame_span == 0) {
      var tmp_index = this.select_index;
      this.select_index = this.next_index;
      ArrayList<Integer> nextIndexArray = next_index_list.get(this.select_index);
      int retry = nextIndexArray.size();
      this.next_index = nextIndexArray.get((int)random(0, next_index_list.get(this.select_index).size()));
      while (--retry > 0) {
        //var destination_itr = find(destination_list.begin(), destination_list.end(), this.next_index);
        //if (destination_itr == destination_list.end()) {
        //  if (tmp_index != this.next_index) {
        //    destination_list.push_back(this.next_index);
        //    break;
        //  }
        //}
        int destinationSize = destination_list.size();
        int destination = destination_list.get(destinationSize - 1);
        if (destination == this.next_index) {
          if (tmp_index != this.next_index) {
            destination_list.add(this.next_index);
            break;
          }
        }

        ArrayList<Integer> nextIndex = next_index_list.get(this.select_index);
        this.next_index = nextIndex.get((this.next_index + 1) % nextIndex.size());
      }
      if (retry <= 0) {
        destination_list.add(this.select_index);
        this.next_index = this.select_index;
      }
    }

    var param = frameCount % frame_span;
    PVector nextLocation = location_list.get(this.next_index);
    PVector selectLocation = location_list.get(this.select_index);
    var distance = nextLocation.sub(selectLocation);
    distance = distance.div(frame_span);
    distance = distance.mult(param);
    this.location = selectLocation.add(distance);

    this.log.add(0, this.location);
    while (this.log.size() > 20) {
      this.log.remove(this.log.size()-1);
    }
  }

  //--------------------------------------------------------------
  PVector getLocation() {
    return this.location;
  }

  //--------------------------------------------------------------
  ArrayList<PVector> getLog() {
    return this.log;
  }

  //--------------------------------------------------------------
  void setColor(color col) {
    this.col = col;
  }

  //--------------------------------------------------------------
  color getColor() {
    return this.col;
  }
}

//--------------------------------------------------------------
void setup() {
  size(720, 720);

  //  ofSetFrameRate(30);

  background(255);

  var span = 40;
  for (int x = -280; x <= 280; x += span) {
    for (int y = -280; y <= 280; y += span) {
      this.location_list.add(new PVector(x, y, 0));
    }
  }

  var param = span * sqrt(3);
  for (var location : location_list) {
    ArrayList<Integer> next_index = new ArrayList();
    int index = -1;
    for (var other : location_list) {
      index++;
      if (location == other) {
        continue;
      }

      float distance = PVector.dist(location, other);
      if (distance <= param) {
        next_index.add(index);
      }
    }

    next_index_list.add(next_index);
  }

  color[] base_color_list = { #ef476f, #ffd166, #06d6a0, #118ab2, #073b4c };

  for (int i = 0; i < 180; i++) {
    Actor actor = new Actor(location_list, destination_list);
    actor.setColor(base_color_list[(int)random(0, base_color_list.length)]);
    actor_list.add(actor);
  }
}

//--------------------------------------------------------------
void update() {
  int frame_span = 10;
  int prev_index_size = 0;

  if (frameCount % frame_span == 0) {
    prev_index_size = destination_list.size();
  }

  for (var actor : actor_list) {
    actor.update(frame_span, location_list, next_index_list, destination_list);
  }

  if (prev_index_size != 0) {
    //destination_list.erase(destination_list.begin(), destination_list.begin() + prev_index_size);
    ArrayList<Integer> newDestnationList = new ArrayList();
    for (int i = 0; i < prev_index_size; i++) {
      newDestnationList.add(destination_list.get(i));
    }
    destination_list = newDestnationList;
  }
}

//--------------------------------------------------------------
void draw() {
  update();

  //  ofTranslate(ofGetWindowSize() * 0.5);
  translate(width/2, height/2);

  stroke(0, 128);
  strokeWeight(1);
  fill(0, 128);
  for (auto location : location_list) {
    circle(location, 5);
  }

  strokeWeight(3);
  for (auto actor : actor_list) {
    fill(actor.getColor());
    circle(actor.getLocation(), 6);
    noFill();

    beginShape();
    for (auto l : actor.getLog()) {
      vertex(l);
    }
    endShape();
  }
}
