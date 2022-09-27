/*
 * Jeremy Vidaurri - Project 1 for CS 3366 Human-Computer Interaction.
 * Elevator was designed based on the Texas Tech Library Stacks elevator.
 * 'Top Section' refers to the section containing the speaker/mic.
 * 'Mid Section' refers to the section containing the buttons and labels for each floor.
 * 'Bottom Section' refers to the section containing the buttons and labels for emergency services and close/open elevator.
*/ 


PImage speaker;
PImage mic;
int speakerSize = 120;
int micSize =50;

int buttonSize = 90;
PImage button_notlit;
PImage button_lit;
boolean[] buttonStatus = {false,false,false,false,false,false,false,false};
boolean[] buttonHeld = {false, false};
boolean helpStatus = false;

int labelLength = 90;
int labelWidth = 150;
int labelRadii = 28;
PFont labelFont;
PFont infoFont;
PImage star;
PImage open;
PImage close;

int helpTime = -1;
int startTime = -1;
ArrayList<Integer> queue = new ArrayList<Integer>();
int curFloor = 1;

String[][] floorLabels = {{"Stacks 4","PS3000-QL","6"},{"Stacks 2","H-LT","4"},{"Mezzanine","Offices","2"},{"Basement","ATLC","0"},
                          {"Stacks 5","QM-Z","7"},{"Stacks 3","M-PS2999","5"},{"Stacks 1","A-GV","3"},{"Ground      ","Main Floor","1"},};



void setup(){
  size(600,1000);
  ellipseMode(RADIUS);
  
  labelFont = createFont("Roboto",26);
  infoFont = createFont("Roboto",16);

  xGradient(0, 0, width/2, height, color(#3A3B3C), color(175));
  xGradient(width/2, 0, width/2, height, color(175), color(#3A3B3C));

  button_notlit = loadImage("images/button_notlit.png");
  button_lit = loadImage("images/button_lit.png");
  speaker = loadImage("images/speaker.png");
  mic = loadImage("images/mic.png");
  star = loadImage("images/star.png");
  open = loadImage("images/open.png");
  close = loadImage("images/close.png");

  noStroke();
}


  
void draw(){
  
  // Top section
  image(speaker,width/2-speakerSize/2,20,speakerSize,speakerSize);
  image(mic,width/2-micSize/2,150,micSize,micSize);
  
  // Labels and buttons for the mid section
  for(int i=0;i<4;i++){
    for(int j=0;j<2;j++){
      // Labels
      fill(0);
      rect(25+400*j,250+100*i,labelWidth,labelLength,labelRadii);

      // Buttons
      if(buttonStatus[i+j*4]){
        image(button_lit,195+120*j,250+100*i,buttonSize,buttonSize);
      }else{
        image(button_notlit,195+120*j,250+100*i,buttonSize,buttonSize);
      }
      

      // Text for labels
      textAlign(CENTER);
      fill(255);
      textFont(labelFont);
      text(floorLabels[i+j*4][0],400*j+100,100*i+290);

      // Text for floor info
      fill(255);
      textFont(infoFont);
      text(floorLabels[i+j*4][1],400*j+100,100*i+320);

     }
  }

  image(star, 530,565,30,30);
  // Bottom Section

  // Open Doors
  if(!buttonHeld[0]){
    fill(0);
    rect(25,750,labelWidth,labelLength,labelRadii);
    fill(255);
    textFont(labelFont);
    text("Open Doors", 100,795);
    image(button_notlit, 195,750,buttonSize,buttonSize);
  }

  image(open,75,790,50,50);

  // Close Doors
  if(!buttonHeld[1]){
    fill(0);
    rect(425,750,labelWidth,labelLength,labelRadii);
    fill(255);
    textFont(labelFont);
    text("Close Doors", 500,795);
    image(button_notlit, 315,750,buttonSize,buttonSize);
  }

  image(close,475,790,50,50);

  // Assistance button
  if(!helpStatus){
    fill(0);
    rect(360,865,labelWidth,labelLength,labelRadii);
    fill(255);
    textFont(labelFont);
    text("Assistance", 435,915);
    image(button_notlit, 255,865,buttonSize,buttonSize);
  } else{
    image(button_lit, 255,865,buttonSize,buttonSize);
  }

  // If there any floor requests, mark the time to simulate switching floors.
  // Then calculate the distance and multiply it by 2s.
  // Once the floor is reached, remove it from the queue and reset the timer.
  // If there are no more items in the queue, disable the timer by setting it to -1.
  if (queue.size() >0 && startTime == -1){
    startTime = millis();
  } else if (queue.size() >0 && millis() - startTime > 1500 * abs(int(floorLabels[queue.get(0)][2]) - curFloor)){
    curFloor = int(floorLabels[queue.get(0)][2]);
    buttonStatus[queue.get(0)] = false;
    queue.remove(0);

    if (queue.size() > 0){
      startTime = millis();
    }else{
      startTime = -1;
    }
  }

  // Once the assistance button has been pressed, set the timer for 10s.
  // This is to simulate the amount of time until a representative will answer.
  if (helpStatus && millis() - helpTime > 10000){
    helpStatus = false;
    helpTime = -1;
  } else if (!helpStatus && helpTime == -1) {
    helpTime = millis();
  }

  fill(0);
  line(300,0,300,1000);
}

// This function is derived from the linear gradient example provided by Processing
void xGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();

  for (int i = x; i <= x+w; i++) {
    float inter = map(i, x, x+w, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(i, y, i, y+h);
  }
}

void mouseClicked(){
  int column = round((mouseX - 250) / 100);
  int row = round((mouseY - 195) / 120);
  int button = column * 4 + row;
  
  // Edge case for clicking the assistance button
  if(mouseY > 850 && mouseY<1000 && mouseX > 200 && mouseX <350){
    helpStatus=true;
    return;
  }

  // Check if the mouse was pressed outside of the floor buttons.
  // Also check if the button is already on.
  // If either are true, we do nothing and return to main.
  if(button >=8 || row >=4 || row<0 || column >=2 || column<0 ||buttonStatus[button] ){
    return;
  }

  // If we get this far, the button should light up and be added to the request queue.
  buttonStatus[button] = true;
  queue.add(button);
}

void mousePressed(){
  // While holding down the open/close door button, it should stay lit.
  if(mouseX>=200 && mouseX<=275 && mouseY <= 850 && mouseY >= 750){
    image(button_lit, 195,750,buttonSize,buttonSize);
    buttonHeld[0] = true;
  } else if (mouseX>=315 && mouseX<=410 && mouseY <= 850 && mouseY >= 750){
    image(button_lit, 315,750, buttonSize,buttonSize);
    buttonHeld[1] = true;
  }
}

void mouseReleased(){
  // Once the open/close door button has been released, reset its status.
  for(int i = 0; i<2; i++)
    buttonHeld[i] = false;
}