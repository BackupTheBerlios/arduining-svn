///// serial communcation with wiring //////
void serialInit(){
  //println(Serial.list());
  // Open the port that the Wiring board is connected to (in this case #2)
  // Make sure to open the port at the same speed Wiring is using (9600bps)
  //Serial = new Serial(this, Serial.list()[3], 9600); // chang the port to your PORT (1, 2, 3...)
  /*
  Serial.write(255); // init
   Serial.write(squareangle); // init
   Serial.write(squareangle); // init
   Serial.write(0); // init
   delay(2000);
   */
}

void motorControl (float teta1, float teta2, float head){
  if(  (teta1save - teta1) != 0 || (teta1save - teta1) != 0 || (headsave - head) != 0) {
    /*
     Serial.write(255);
     Serial.write((byte)teta1);
     Serial.write((byte)teta2);
     Serial.write((byte)head);    
     */
    if (DEBUG_MODE) println("teta1= "+(int)teta1+", teta2= "+(int)teta2+", head= "+(int)head);
  }
  teta1save = teta1;
  teta2save = teta2;
  headsave = head;
}
