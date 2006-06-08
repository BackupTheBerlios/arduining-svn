interface Behaviour {
  float processx(float xcoord){return xcoord;}
  float processy(float ycoord){return ycoord;}    
}

class Animator implements Behaviour {
  float dx, dy;
  float objSize = 0;  
  float amort = 0;

  Animator(float _amort, float _objSize){
    amort = _amort;
    objSize = _objSize;
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
