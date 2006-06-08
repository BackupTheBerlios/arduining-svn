class Circle {
  float x, y, r, d, r2, iconHeight;
  color c;
  String text;
  PImage pic;
  Animator iconAni = new Animator(0,0,0);
  Circle() {
  }
  Circle( float px, float py, float pr, color _c, String _text ) {
    x = px;
    y = py;
    r = pr;
    d = 2*r;
    r2 = r*r;
    c=_c;
    text = new String(_text);
  }
  Circle( float px, float py, float pr, color _c, String _text, float _iconHeight, PImage _pic ) {
    x = px;
    y = py;
    if(_pic!=null)  {
      r = sqrt(_pic.width*_pic.width + _pic.height*_pic.width)/2; 
      //println("r = "+r);
    }
    else { 
      r = pr; 
    }
    d = 2*r;
    r2 = r*r;    
    c=_c;
    iconHeight = _iconHeight;
    text = new String(_text);
    pic = _pic;
    iconAni.amort = 1 - iconHeight/frictionCoeff; // the higher the head, the heavier the file
    iconAni.objSize = d;
  }

  void draw(){
    if(DEBUG_MODE) { // dont draw circle only in DEBUG
      noFill();       
      strokeWeight(1);
      stroke(c);
      ellipse( x, y, r*2, r*2 );
      fill(c);
      if(pic==null) text (text, x - 20, y+r+8);
    }
    if(pic!=null) {  // this is an icon, always draw its image
      if(x<r) x=r;   // icon move, and must remain within the screen
      else if(x>width-r) x=width-r;
      if(y<r) y=r;
      else if(y>height-r) y=height-r;

      image(pic, x - pic.width/2 , y - pic.height/2 ); // display the image in the center
      fill(c);
      text (text, x - pic.width/2, y+r+8);
    }
  }
  void draw(int intensity){
    tint(255, 255, 255, 126); // tint icon if selected
    fill(intensity);
    this.draw();
  }
  boolean intersect(float tx, float ty){ // intersection with the line from the center of the circle to that point
    float dx = tx - x;
    float dy = ty - y;
    float d2 = dx*dx + dy*dy;
    float d = sqrt( d2 );
    float ratio=r/d;     // thank to thales in triangle
    paX=x+ratio*dx;
    paY=y+ratio*dy;
    return true;
  }
  boolean intersect( Circle cB ) {
    float dx = x - cB.x;
    float dy = y - cB.y;
    float d2 = dx*dx + dy*dy;
    float d = sqrt( d2 );

    if (d>r+cB.r) {
      return false; // no solution
    }

    float a = (r2 - cB.r2 + d2)/(2*d);
    float h = sqrt( r2 - a*a );
    float x2 = x + a*(cB.x - x)/d;
    float y2 = y + a*(cB.y - y)/d;

    paX = x2 + h*(cB.y - y)/d;
    paY = y2 - h*(cB.x - x)/d;
    //pbX = x2 - h*(cB.y - y)/d;  // the other instersection-solution, not used here
    //pbY = y2 + h*(cB.x - x)/d;
    return true;
  }  
  float distance( Circle cB ) {
    return sqrt((x-cB.x)*(x-cB.x) + (y-cB.y)*(y-cB.y));
  }
  void animate(){
    x = iconAni.processx(x);
    y = iconAni.processy(y);
  }

}

class Animator {
  float dx, dy;
  float amort = 0;
  float objSize=0;

  Animator(float _dx, float _dy, float _objSize){
    dx=_dx;
    dy=_dy;
    objSize=_objSize;
  }

  float processx(float xcoord){
    dx *= amort;
    float newx = (xcoord + dx);
    if(newx>(width-objSize) || newx<objSize) {
      dx *= -1;
      newx = (xcoord + dx);
    }  
    return newx;
  }
  float processy(float ycoord){
    dy *= amort;
    float newy = (ycoord + dy);
    if(newy>(height-objSize) || newy<objSize) {
      dy *= -1;
      newy = (ycoord + dy);
    }  
    return newy;
  }
}
