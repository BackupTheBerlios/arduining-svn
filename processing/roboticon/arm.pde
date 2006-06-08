void drawArms() {

  circleTactileZoneIn.draw();   
  circleTactileZoneOut.draw();      

  circleA.text="circle A, t1= "+int(teta1);
  circleB.text="circle B, t2= "+int(teta2);

  circleA.draw();
  circleB.draw();  

  if(!DEBUG_MODE) 
    return;

  // draw intersections
  strokeWeight(10);
  stroke(0,0,255);
  point(paX,paY);

  // draw axis   
  strokeWeight(1);
  stroke(100,100,100);
  line(circleA.x, 0, circleA.x, height);
  line(0, circleA.y, width, circleA.y);  

  // draw the 2 segments
  stroke(200);
  strokeWeight(4);
  line(circleA.x, circleA.y, paX, paY);           
  line(paX, paY, circleB.x, circleB.y); 

  // draw head
  strokeWeight(10);
  stroke(0,255,255);
  point(circleB.x, circleB.y);
}

void  calculateAngles (float interx, float intery){
  teta1 = atan2(intery-circleA.y, interx-circleA.x);
  float absAngle =  atan2(circleB.y-intery , circleB.x-interx);
  teta2 = teta1-absAngle;

  teta1 = 180*teta1/PI + 50;
  teta2 = -180*teta2/PI;
}
