                                                                     
                                                                     
                                                                     
                                             
// flob + kinect testing
// André Sier, 2010
// flob at s373.net/code/flob
import JMyron.*;


// Daniel Shiffman
// Basic Library functionality example
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

import org.openkinect.*;
import org.openkinect.processing.*;

PShape s;

int whichCorner = 0;

PVector location;
PVector velocity;

int canvas_height = 480;
int canvas_width = 640;

int carrom_gap = 10;
int shootingZoneGapSmall = 80;
int shootingZoneGapBig= 70;


int coin_radius = 8;
int striker_radius = 12;
int pocket_radius = 15;
int shootingZone_radius= 5;

PVector holes[];
int h=10; int w=590;
PVector playing_zones[][];

PVector detected_corner[];
PVector striker_cur_pos;
PVector coins_pos[];
int boundary_done = 0;

JMyron theMov;
int[][] globArray;

Kinect kinect;
boolean depth = true;
boolean rgb = false;
boolean ir = false;

float deg = 15; // Start at 15 degrees

int carrom_left_gap = 10;
int carrom_right_gap = 10;
int carrom_top_gap = 10;
int carrom_bottom_gap = 10;

int kinect_image_width = 640;
int kinect_image_height = 480;


void kinect_setup() {
  detected_corner = new PVector[4];
  detected_corner[0] = new PVector(0,0);
  detected_corner[1] = new PVector(0,0);
  detected_corner[2] = new PVector(0,0);
  detected_corner[3] = new PVector(0,0);
        
        striker_cur_pos = new PVector(0,0);
        coins_pos = new PVector[8];
   for(int i = 0; i < 8; i++) {
     coins_pos[i] = new PVector(0,0);
  }
  
  size(640,480,P2D);
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);
  kinect.enableRGB(rgb);
  kinect.enableIR(ir);
  kinect.tilt(deg);
  
    // downscale image to ease flob processing load
  //flob = new Flob(vrImage, this); 

  theMov = new JMyron();
  theMov.start(width, height);
  theMov.findGlobs(1);
 // theMov.trackColor(50, 31, 58, 40);   // for black coin
  //theMov.trackColor(120, 61, 95, 80); //queen
   //theMov.trackColor(160, 200, 250, 60); //striker-qr-blue

  //theMov.trackColor(45, 90, 85, 40); //green
  //theMov.trackColor(36, 59, 45, 30);
  stroke(255, 0, 0);  // red outline

  textFont(createFont("monospace",16));
  
}



void kinect_draw() {
  background(0);
    theMov.hijack(640,480,kinect.getVideoImage().pixels);
    theMov.update();
  int[] currFrame = theMov.image();
  
if (boundary_done < 2) {
// draw each pixel to the screen
  loadPixels();
  for (int i = 0; i < width*height; i++) {
    pixels[i] = currFrame[i];
  }
  updatePixels();

}
  
  //green
//  theMov.trackColor(45, 90, 85, 40);
//  theMov.hijack(640,480,kinect.getVideoImage().pixels);
//  theMov.update();
//  globDraw();

  theMov.trackColor(180, 200, 250, 70);
  theMov.hijack(640,480,kinect.getVideoImage().pixels);
  theMov.update();
  globDraw();
  if (globArray.length != 0) {
    
  int[] boxArray = globArray[0];

  striker_cur_pos.x = (2*boxArray[0] + boxArray[3])/2;
  striker_cur_pos.y = (2*boxArray[1] + boxArray[2])/2;
  }
//  theMov.trackColor(120, 61, 95, 80);
//  theMov.hijack(640,480,kinect.getVideoImage().pixels);
//  theMov.update();
//  globDraw();

  theMov.trackColor(239, 160, 52, 100);
  theMov.hijack(640,480,kinect.getVideoImage().pixels);
  theMov.update();
  globDraw();
  for(int i = 0; i < globArray.length; i++) {
    if (globArray.length >= 8) {
      break;
    }
  int[] boxArray = globArray[i];

  coins_pos[i].x = (2*boxArray[0] + boxArray[3])/2;
  coins_pos[i].y = (2*boxArray[1] + boxArray[2])/2;
  }
  
//  theMov.trackColor(165, 101, 187, 30);
//  theMov.hijack(640,480,kinect.getVideoImage().pixels);
//  theMov.update();
//  globDraw();

 
  

}

void keyPressed() {    
  
  if (key == 'd') {
    depth = !depth;
    kinect.enableDepth(depth);
  } 
  else if (key == 'r') {
    rgb = !rgb;
    if (rgb) ir = false;
    kinect.enableRGB(rgb);
  }
  else if (key == 'i') {
    ir = !ir;
    if (ir) rgb = false;
    kinect.enableIR(ir);
  } 
  else if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } 
    else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg,0,30);
    kinect.tilt(deg);
  }
}

void globDraw() {
  
  // draw the glob bounding boxes
  globArray = theMov.globBoxes();
  //println(globArray);
  for(int i = 0; i < globArray.length; i++) {
    int[] boxArray = globArray[i];
    //println(boxArray);

    // set the fill colour to the average of all colours in the bounding box
    int currColor = theMov.average(
      boxArray[0], 
      boxArray[1], 
      boxArray[0] + boxArray[2], 
      boxArray[1] + boxArray[3]);
   // fill(red(currColor), green(currColor), blue(currColor));
   //fill(0,0,0);

   // rect(boxArray[0], boxArray[1], boxArray[2], boxArray[3]);
  }
}

void stop() {
  kinect.quit();
  theMov.stop();
  super.stop();

}
void set_carrom_gaps() {
    carrom_left_gap = int(detected_corner[0].x);
    carrom_top_gap = int(detected_corner[0].y);
    carrom_right_gap = 640 - int(detected_corner[1].x);
    carrom_bottom_gap = 480 - int(detected_corner[1].y);
}
 
void carrom_board() {
  int cm_top_left_x = 0 + carrom_left_gap;
  int cm_top_left_y = 0 + carrom_top_gap;
  
  int cm_top_right_x = canvas_width - carrom_right_gap; 
  int cm_top_right_y = 0 + carrom_top_gap;
  
  int cm_bot_left_x = 0 + carrom_left_gap;
  int cm_bot_left_y = canvas_height - carrom_bottom_gap;
  
  int cm_bot_right_x = canvas_width - carrom_right_gap;
  int cm_bot_right_y = canvas_height - carrom_bottom_gap;
  
  strokeWeight(10);
//
//  line(cm_top_left_x,cm_top_left_y, cm_top_right_x, cm_top_right_y);
//  line(cm_top_left_x,cm_top_left_y, cm_bot_left_x, cm_bot_left_y);
//  line(cm_top_right_x, cm_top_right_y, cm_bot_right_x, cm_bot_right_y);
//  line(cm_bot_left_x, cm_bot_left_y, cm_bot_right_x, cm_bot_right_y);
  
  println("topleft: " +cm_top_left_x +", " +cm_top_left_y);
  println("topright: " +cm_top_right_x +", " +cm_top_right_y);
  println("bottomleft: " +cm_bot_left_x +", " +cm_bot_left_y);
  println("bottomright: " +cm_bot_right_x +", " +cm_bot_right_y);
  
  strokeWeight(0);
  holes=new PVector[4];
  holes[0]=new PVector(cm_top_left_x+pocket_radius,cm_top_left_y+pocket_radius);
  holes[1]=new PVector(cm_top_right_x-pocket_radius,cm_top_right_y+pocket_radius);
  holes[2]=new PVector(cm_bot_right_x-pocket_radius, cm_bot_right_y-pocket_radius);
  holes[3]=new PVector(cm_bot_left_x+pocket_radius, cm_bot_left_y-pocket_radius);  
  if(detected_corner[1].x == 0){
  fill(255,0,0);
  for(PVector hole: holes)
  {
    
    ellipse(hole.x,hole.y,pocket_radius*2,pocket_radius*2);
  }
  }
  
  playing_zones=new PVector[4][2];
  playing_zones[0][0] = new PVector(cm_top_left_x+shootingZoneGapBig,   cm_top_left_y+shootingZoneGapSmall);
  playing_zones[3][0] = new PVector(cm_top_left_x+shootingZoneGapSmall, cm_top_left_y+shootingZoneGapBig);
  playing_zones[0][1] = new PVector(cm_top_right_x-shootingZoneGapBig, cm_top_right_y+shootingZoneGapSmall);
  playing_zones[1][0] = new PVector(cm_top_right_x-shootingZoneGapSmall, cm_top_right_y+shootingZoneGapBig);
  playing_zones[1][1] = new PVector(cm_bot_right_x-shootingZoneGapSmall, cm_bot_right_y-shootingZoneGapBig);
  playing_zones[2][0] = new PVector(cm_bot_left_x+shootingZoneGapBig, cm_bot_left_y-shootingZoneGapSmall);
  playing_zones[2][1] = new PVector(cm_bot_right_x-shootingZoneGapBig, cm_bot_right_y-shootingZoneGapSmall);
  playing_zones[3][1] = new PVector(cm_bot_left_x+shootingZoneGapSmall, cm_bot_left_y-shootingZoneGapBig);

//  println(playing_zones[3][1].y);
//  fill(128,0,0);//brown
//  for(PVector[] zones: playing_zones)
//  {
//    for(PVector zone: zones)
//    {
//      ellipse(zone.x, zone.y, shootingZone_radius*2, shootingZone_radius*2);
//    } 
//  }
//  fill(0);
  
}

void setup() {
  //size(canvas_height,canvas_width);
  smooth();
  background(0);

  kinect_setup();
    
}


void carrom_add_coins() {
  
}

int get_striker_side(PVector striker) {

  PVector[] shootingSideMids = new PVector[4];
  
  for(int index= 0; index<shootingSideMids.length; index++)
  {
    shootingSideMids[index]= new PVector(
                         (playing_zones[index][0].x + playing_zones[index][1].x)/2,
                         (playing_zones[index][0].y + playing_zones[index][1].y)/2);
  }
  
  int result =  get_nearest_candidate_index(striker, shootingSideMids);
  println("striker side: " +result);
  
  return result;
}


int get_nearest_candidate_index(PVector target, PVector[] candidates) {
  double min_dist=Math.sqrt((candidates[0].x-target.x)*(candidates[0].x-target.x)+(candidates[0].y-target.y)*(candidates[0].y-target.y));
  int chosen_i=0;
  for (int i=1; i<candidates.length; i++)
  {
    double dist=Math.sqrt((candidates[i].x-target.x)*(candidates[i].x-target.x)+(candidates[i].y-target.y)*(candidates[i].y-target.y));
    if (dist < min_dist)
    {
      min_dist=dist;
      chosen_i=i;
    }
  }
  return chosen_i;
}



int get_optimal_pocket(PVector striker, PVector coin) {
 
 int side = get_striker_side(striker);
 int opposite_side = (side+2)%4;
 int corner1 = opposite_side;
 int corner2 = (opposite_side+1)%4;
 
 
 
  PVector[] opp_corners = new PVector[2];
  opp_corners[0] = holes[corner1];
  opp_corners[1] = holes[corner2]; 

 int opt_corner = get_nearest_candidate_index(coin, opp_corners);
 if (opt_corner == 0) {
   println(corner1);
   return corner1;
 }
 else
 {
      println(corner2);
   return corner2;
 }
}


PVector draw_path_from_striker_to_coin(PVector pocket, PVector coin, PVector striker) {

  int x_mult = 1;
  int y_mult = 1;
  
  if((pocket.x-coin.x)>0)
    x_mult = -1;
    
  if((pocket.y - coin.y)>0)
    y_mult = -1;
  
  float theta = atan((pocket.y-coin.y)/(pocket.x- coin.x));
  float final_x= coin.x + abs((coin_radius+striker_radius)*cos(theta))*x_mult;
  float final_y= coin.y + abs((coin_radius+striker_radius)*sin(theta))*y_mult;
  stroke(0, 255, 0);    
  line(striker.x,striker.y, final_x, final_y);
  stroke(0);
//  println("drawing line from "+striker.x +"," +striker.y +" to " +final_x +"," +final_y);
  return new PVector(final_x,final_y);
}

void draw_path_from_coin_to_hole(PVector pocket, PVector coin){
    stroke(255,0,0);
    line(pocket.x, pocket.y, coin.x, coin.y);
}

PVector lineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4)
{
  float bx = x2 - x1;
  float by = y2 - y1;
  float dx = x4 - x3;
  float dy = y4 - y3; 
  float b_dot_d_perp = bx*dy - by*dx;
  if(b_dot_d_perp == 0) {
    return null;
  }
  float cx = x3-x1; 
  float cy = y3-y1;
  float t = (cx*dy - cy*dx) / b_dot_d_perp; 
 
  return new PVector(x1+t*bx, y1+t*by); 
}

int get_optimal_striker_pos(PVector pocket, PVector striker, PVector coin) {
  
//  get_striker_side(PVector striker);
//  lineIntersection(pocket.x, pocket.y, coin.x, coin.y,
  return 0;
}

float distance_between_points(PVector lpoint, PVector rpoint){
  double dist = Math.sqrt((lpoint.x - rpoint.x)*(lpoint.x - rpoint.x) + (lpoint.y - rpoint.y)*(lpoint.y - rpoint.y));
  return (float)dist;
}

boolean is_point_on_line_segment(PVector lpoint, PVector rpoint, PVector point ) {
  return (abs(distance_between_points(lpoint,rpoint) - (distance_between_points(lpoint,point) + distance_between_points(point,rpoint))) < 0.01);
}

void draw_scope_vector(PVector pocket, PVector coin, PVector striker) {

  boolean on_line = false;
  int opt_pocket_idx;
float y_intercept_perpendicular = (( (coin.x - pocket.x) / (coin.y - pocket.y) )*coin.x) + coin.y; 
PVector second_point;
  if( (1/y_intercept_perpendicular) != 0)
    second_point = new PVector(0, y_intercept_perpendicular);
  else
    second_point = new PVector(coin.x, coin.y+50);
  // check the intersection between coin, pocket and valid line of striker
  int striker_side = get_striker_side(striker);
PVector op = lineIntersection(second_point.x, second_point.y, coin.x, coin.y, playing_zones[striker_side][0].x, playing_zones[striker_side][0].y, playing_zones[striker_side][1].x, playing_zones[striker_side][1].y);
  if (op == null)
  {
    on_line = false;
  }
  else
  {
   // check the output is beyond the line 
   on_line = is_point_on_line_segment(playing_zones[striker_side][0],playing_zones[striker_side][1], op);
  }
  
  if (on_line == false)
  {
     draw_path_from_striker_to_coin(pocket,coin,playing_zones[striker_side][0]);
     draw_path_from_striker_to_coin(pocket,coin,playing_zones[striker_side][1]);
  }
  else 
  {
    opt_pocket_idx = get_optimal_pocket(striker,coin);
    draw_path_from_striker_to_coin(pocket,coin,op);
    
    float dist0 = distance_between_points(playing_zones[striker_side][0],holes[opt_pocket_idx]);
    float dist1 = distance_between_points(playing_zones[striker_side][1],holes[opt_pocket_idx]);
    
    if(op!=null)
    {
      draw_path_from_striker_to_coin(pocket, coin, op);
    }
    if (dist0 < dist1)
    {
      draw_path_from_striker_to_coin(pocket,coin,playing_zones[striker_side][1]);
    }
    else
    {
       draw_path_from_striker_to_coin(pocket,coin,playing_zones[striker_side][0]);
    }
  }
  
  // put the one point as a scope end point
  
  // Add a perpendicular line as end of scope and find its intersection with the line  
}

void draw_current_path_vector(PVector pocket, PVector coin, PVector striker) {
  //check for valid path between striker and coin  
  //check for obstacles 
  stroke(255,0,255);  
  draw_path_from_coin_to_hole(pocket,coin);
  stroke(0,255,0);  
  draw_path_from_striker_to_coin(pocket,coin,striker);
  stroke(0,0,0);  
}

void mouseReleased(){
  //println("ha");
     detected_corner[whichCorner].x = mouseX;
    detected_corner[whichCorner].y = mouseY;
    whichCorner = (whichCorner + 1)%2;
    boundary_done = boundary_done + 1;
    
    set_carrom_gaps();
}


void draw() {
    stroke(0,0,255);
    
// strikers
  //PVector striker = new PVector(150,80);  // bottom striker
  //PVector striker = new PVector(190,50);   // top striker
  //PVector striker = new PVector(50,300);   // left striker
  
  // coin
  //PVector coin = new PVector(200,400);    // top left up
  //PVector coin = new PVector(100,50);    // top left mid
  //PVector coin = new PVector(400,50);    // top right mid
  //PVector coin = new PVector(400,25);    // top right maxUp- should cut boundary
  //PVector coin = new PVector(100,25);    // top left maxUp- should cut boundary
  //PVector coin = new PVector(400,350);   // bottom right up
  //PVector coin = new PVector(400, 575);  // bottom right maxDown
  //PVector coin = new PVector(575, 250);    // right up maxRight
  
  //striker_cur_pos = striker;
  //coins_pos[0] = coin;
  
  kinect_draw();
  carrom_board();

//  fill(0,100, 0);//darkgreen
//  ellipse(coins_pos[0].x, coins_pos[0].y, coin_radius*2, coin_radius*2);
//  fill(0, 0, 100);//darkblue
//  ellipse(striker_cur_pos.x, striker_cur_pos.y, striker_radius*2, striker_radius*2);
//  fill(0,0,0);
  
     stroke(0,255,0);
     strokeWeight(2);
  
  int pocket_index = get_optimal_pocket(striker_cur_pos,coins_pos[0]);
  draw_current_path_vector(holes[pocket_index], coins_pos[0], striker_cur_pos);
  


  //draw_scope_vector(holes[pocket_index], coins_pos[0], striker_cur_pos);
  
}
