///// mouse events /////
void mousePressed() {
  if(mouseButton == RIGHT) { //toggle debug mode with the 2 MB pressed, dunno on mac what is center bt ?
    DEBUG_MODE = !DEBUG_MODE; 
    delay(300);
    println("debug mode " + (DEBUG_MODE? "":"des") + "activated!");
  }
  if(mouseButton == LEFT && onIcon==false) {
    selectionX = mouseX;
    selectionY = mouseY;
    selectionPending = true;
  }
  else     
    selectionPending = false;
}
void mouseDragged(){
  if (selectionPending) {
    noFill();
    stroke(100,100,100);
    strokeWeight(2);
    rect(selectionX, selectionY, mouseX-selectionX, mouseY-selectionY);
  }
  if(mouseButton == LEFT) iconDragged=true;
    else iconDragged=false;
}
void mouseMoved(){
  iconDragged=false;
  mouseMoved=true;
}
