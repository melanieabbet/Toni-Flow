import processing.net.*;
import processing.video.*;

Dot[][]dots = new Dot[][]{}; //Zweidimensionales array

boolean USE_OPACITY = true;

int CENTER_DISTANCE = 30;
int MIN_INSET = 10;
int INITIAL_DOT_RADIUS = 5;
int MAX_DOT_RADIUS = CENTER_DISTANCE / 2;

int AFFECTED_RADIUS = 100;
float DARKEN_PERCENT = 0.025;
float GROW_PERCENT = 0.50;
float GROW_FACTOR = (float)Math.sqrt(1 + GROW_PERCENT);
int ACTION_LIFETIME_MILLIS = 2 * 60 * 1000; // 2 Minutes
// How long to wait before interacting with the same point again makes its max radius thicker
int INTERACTION_GRACE_MILLIS = 2 * 1000; // 2 Seconds
int MAXI = 0;

color BACKGROUND_COLOR = color(0, 0, 0);
color DOT_COLOR = color(255);

Timer BLACKNESS_UPDATE_TIMER = new Timer(30);

float inset;



Capture video;

Client client; 

Person[] people;

boolean sent = false;
long time;
long delay;

void setup() {
  fullScreen();

  background(BACKGROUND_COLOR);
  pixelDensity(displayDensity());

  ellipseMode(RADIUS);
  noStroke();
  
  float space = width - (2 * MIN_INSET);
  int dotCount = (int) space /  CENTER_DISTANCE;
  int dotsSpace = dotCount * CENTER_DISTANCE;
  inset = (width - dotsSpace) / 2; 

  dots = new Dot[dotCount][dotCount]; //Zweidimensionales array

  for (int x = 0; x<dots.length; x++) {
    for (int y = 0; y<dots[x].length; y++) {
      dots[x][y] = new Dot(
        inset + INITIAL_DOT_RADIUS + (CENTER_DISTANCE * x), 
        inset + INITIAL_DOT_RADIUS + (CENTER_DISTANCE * y)
      );
    }
  }



  video = new Capture(this, width, height, "Trust Webcam");
  //video = new Capture(this, width, height, 15);
  video.start();

  client = new Client(this, "cloudpose.joelgaehwiler.com", 1337);
  
}

void draw() {
  if(USE_OPACITY && BLACKNESS_UPDATE_TIMER.tick()) {
    if (people != null) {
    for (Person person : people) {
      updateBlackness(person.points[Person.MidHip].x, person.points[Person.MidHip].y);
    }
  }
    
  }
  
  //background(BACKGROUND_COLOR);
  // read video frame if available
  if (video.available()) {
    video.read();
  }


  // read client data if available
  if (client.available() > 0) {
    // read frame length
    int length = decodeInt(client.readBytes(8));

    // read frame
    people = decodeJSON(decodeString(client.readBytes(length)));

    // log
    println("received " + (8 + length));

    // set flag
    sent = false;
    delay = millis() - time;
  }

  // draw video image
  // image(video, 0, 0);
  
  if (people != null) {
    for (Person person : people) {
      personWalks(person.points[Person.MidHip].x, person.points[Person.MidHip].y);
    }
  }
  
  for (int x = 0; x<dots.length; x++) {
    for (int y = 0; y<dots[x].length; y++) {
      dots[x][y].paint();
    }
  }

  // draw people
  /*if (people != null) {
    for (Person person : people) {
      person.draw();
    }
  }*/
  
  // draw delay
  text(delay, 10, 20);

  if (!sent) {
    // encode image
    byte[] encoded = encodeJPG(video);

    // encode length
    byte[] length = encodeInt(encoded.length);

    // send data
    client.write(length);
    client.write(encoded);

    // log
    println("sent " + (8 + encoded.length));

    // set flag
    sent = true;
    time = millis();
  }
}

void personWalks(float personX, float personY) {
  for (int x = 0; x<dots.length; x++) {
    for (int y = 0; y<dots[x].length; y++) {
      Dot dot = dots[x][y];
      double distance = dot.distance(personX, personY, AFFECTED_RADIUS);

       if (distance < AFFECTED_RADIUS) {
        dot.addAction(new DistanceAction((float) distance / AFFECTED_RADIUS));
        int ts = millis();
          if (dot.lastInteractionTimestamp + INTERACTION_GRACE_MILLIS <= ts) {
          dot.addAction(new ThickenAction());
          // Nächstes Mal nicht dicker werden, ist immer noch dieselbe Interaktion
          //dot.startInteraction = false;
          
          //println(dot.startInteraction);
        }
        dot.lastInteractionTimestamp = ts;
      
    }
   }
  }
}
void updateBlackness(float personX, float personY) {
  for(int x = 0;x<dots.length;x++) {
    for(int y = 0;y<dots[x].length;y++) {
      Dot dot = dots[x][y];
      double distance = dot.distance(personX, personY, AFFECTED_RADIUS);
      if(distance < AFFECTED_RADIUS) {
        dot.addAction(new IntensifyAction());
      }
    }
  }
}
