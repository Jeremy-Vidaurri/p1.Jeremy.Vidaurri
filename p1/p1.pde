/*
 * Jeremy Vidaurri - Project 1 for CS 3366 Human-Computer Interaction.
 * Elevator was designed based on the Texas Tech Library Stacks elevator.
 * 'Top Section' refers to the section containing the sign displaying floor number.
 * 'Mid Section' refers to the section containing the buttons and labels for each floor.
 * 'Bottom Section' refers to the section containing the buttons and labels for emergency services and close/open elevator.
*/ 

/* TODO:
 *  Add bottom section in its entirety.
 *  Add display for floor numbers in top section.
 *  Add functionality for switching floors. They need to be displayed at the top.
 *  Maybe make labels look nicer.
 *  Add a star symbol next to the ground floor label
*/ 

int buttonSize = 90;
int lightSize = 45;
PImage button_notlit;
PImage button_lit;
boolean[] buttonStatus = {false,false,false,false,false,false,false,false};

int labelLength = 90;
int labelWidth = 150;
int labelRadii = 28;
PFont labelFont;
PFont infoFont;

int millis;
int startTime = -1;
ArrayList<Integer> queue = new ArrayList<Integer>();

String[][] floorLabels = {{"Stacks 4","PS3000-QL"},{"Stacks 2","H-LT"},{"Mezzanine","Offices"},{"Basement","ATLC"},
                          {"Stacks 5","QM-Z"},{"Stacks 3","M-PS2999"},{"Stacks 1","A-GV"},{"Ground","Main Floor"},};



void setup(){
  size(600,1000);
  ellipseMode(RADIUS);
  
  labelFont = createFont("Roboto",28);
  infoFont = createFont("Roboto",18);

  xGradient(0, 0, width/2, height, color(#3A3B3C), color(175));
  xGradient(width/2, 0, width/2, height, color(175), color(#3A3B3C));

  button_notlit = loadImage("images/button_notlit.png");
  button_lit = loadImage("images/button_lit.png");

  noStroke();
}


  
void draw(){
  
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

  // TEMPORARY HACK: should change to calculating based on the distance of the floors. 1 floor = 2000ms or something.
  if (queue.size() >0 && startTime == -1){
    startTime = millis();
  } else if (queue.size() >0 && millis() - startTime > 2000){
    buttonStatus[queue.get(0)] = false;
    queue.remove(0);
    if (queue.size() > 0){
      startTime = millis();
    }else{
      startTime = -1;
    }
  } 
  
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

  // Check if the mouse was pressed outside of the buttons.
  // Also check if the button is already on.
  // If either are true, we do nothing and return to main.
  if(button >=8 || row >=4 || column >=2 ||buttonStatus[button] ){
    return;
  }

  buttonStatus[button] = true;
  queue.add(button);
}