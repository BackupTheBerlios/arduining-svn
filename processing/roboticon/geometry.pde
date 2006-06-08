class Shape2D{
  float x, y, r, d, shapeHeight=1 ;
  color c;
  String text;
  Behaviour anim = new Animator(0,0);

  Shape2D(){
  }
  Shape2D( float px, float py, float pr, color _c, String _text ) {
    x = px;
    y = py;
    c = _c;
    r = pr;
    d = 2*r;
    text = new String(_text);
  }

  float distance( Shape2D B ) {
    return sqrt((x-B.x)*(x-B.x) + (y-B.y)*(y-B.y));
  }
  void animate(){
    x = anim.processx(x);
    y = anim.processy(y);
  }

}

class Icon extends Shape2D {
  PImage pic;

  Icon(){
  }
  Icon( float px, float py, float pr, color _c, String _text, float _shapeHeight, PImage _pic ) {
    super( px,  py,  pr,  _c,  _text);
    shapeHeight = _shapeHeight;
    if(_pic!=null)  {
      r = sqrt(_pic.width*_pic.width + _pic.height*_pic.width)/2; 
      pic = _pic;
    }
    else { 
      r = pr; 
    }
    anim = new Animator(1 - shapeHeight/FRICTIONCOEFF, d); // the higher the head, the heavier the file
  }    

  void draw(){
    if(pic!=null) {  // this is an icon, always draw its image
      if(x<r) x=r;   // icon move, and must remain within the screen
      else if(x>width-r) x=width-r;
      if(y<r) y=r;
      else if(y>height-r) y=height-r;

      image(pic, x - pic.width/2 , y - pic.height/2 ); // display the image in the center
      fill(c);
      text (text, x - pic.width/2, y+r+8);
    }
    else
      text (text, x - 20, y+r+8);
  }
  void draw(int intensity){
    tint(255, 255, 255, 126); // tint icon if selected
    fill(intensity);
    draw();
  }  
}

class Circle extends Shape2D {
  float r2;

  Circle() {
  }
  Circle(float px, float py, float pr, color _c, String _text) {
    super( px,  py,  pr,  _c,  _text);
    r2 = r*r;
  }

  void draw(){
    if(DEBUG_MODE) { // dont draw circle only in DEBUG
      noFill();       
      strokeWeight(1);
      stroke(c);
      ellipse( x, y, d, d );
    }
  }

  boolean intersect(float tx, float ty){ // intersection with the line from the center of the circle to that point
    float dx = tx - x;
    float dy = ty - y;
    float d2 = dx*dx + dy*dy;
    float diag = sqrt( d2 );
    float ratio=r/diag;     // thank to thales in triangle
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
}
