/*
*      Robotic Arm pinboard driver for wiring with moveable icons onscreen
 *
 *  features :
 *     - select the nearest icon from the pointer
 *     - icons are moveable
 *     - the arm is prepositionned when the selected icon is within the coldZone (see minIconToColdZoneDistance)
 *     - the head is positionned with the reight shapeHeight when whithin the hotZone  (see minIconToColdZoneDistance)
 *     - motorControl() is the place to send data to wiring
 *
 *  todo :
 *     - scaling of the rendering zone for the arm, so it act as a lens
 *     - add a timer so the head is not too jumpy when swithing Icon selected
 *
 *  authors : vincent roudaut, maurin donneaud, oren orev
 *  date : june 2 2006
 *  revisions : 
 *        1.4 : multiple icons (2 crappy), draggable
 *        1.5 : multiple icons (5 cool), icon text always on
 *        1.6 : icon animation with amort and bounce, mouseevents
 *        1.7 : split files, box selection, friction coeff, motorcontrol() don't send data if head still
 *        1.8 : collisions (done in selectIcon() ) , speed parameters, fixed right bounce
 *        1.9 : added icon manager, minor bugs (icon animation while dragging, ...), modified Circle
 */
//import processing.serial.*;
//Serial Serial;
static byte squareangle = 10;

Circle circleA, circleB, circleHotzone, circleColdzone, circleTactileZoneIn, circleTactileZoneOut, circleTactileZoneMiddle;
Icon selectedIcon, selectedIconSave;
float paX, paY;
PFont mafonte;
float teta1, teta2, teta1save, teta2save, headsave;
float iconToZoneDistance;
float minIconToZoneDistance; // min distance to activate the zone
float minIconToColdZoneDistance; // min distance to pre-activate the zone
float mouseXSave, mouseYSave, targetXSave, targetYSave;
boolean iconDragged = false;
boolean mouseMoved = false;
float selectionX = mouseX;
float selectionY = mouseY;
boolean selectionPending = false;
boolean onIcon = false;
IconManager iconManager;

//////////// customisation area /////////////
//////////// mess with care !  ///////////////
boolean DEBUG_MODE=false;
static float lengthA = 81;
static float lengthB = 81;
static float centerxA =150;
static float centeryA = 150;

static float xZoneOffset = 61;
static float yZoneOffset = 61;
static float sizeInZoneOffset = 32.5;
static float sizeOutZoneOffset = 50;
static float sizeMiddleZoneOffset =(sizeInZoneOffset + sizeOutZoneOffset )/2;
static float sizeIcon = 22.62;  // radius of the circle around an icon of 24 pixels .....
static float sizeHotzone = sizeInZoneOffset; // sensing zone
static float sizeColdzone = 100; // pre-positionning of the head zone
// dynamics
static float FRICTIONCOEFF = 300;  // approx > 10X the highest icon height
static float speedDivider = 1;
/////////////////////////////////////////////////////

void setup() {
  serialInit();

  mafonte = loadFont("monospaced.bold-25.vlw"); //HelveticaNeue-Light-20.vlw"); 
  textFont(mafonte, 25);
  size( 800, 600 );

  circleA = new Circle( centerxA, centeryA, lengthA , color(255,0,0), "circle A");
  circleB = new Circle( 0, 0, lengthB , color(0,255,0), "circle B");

  circleHotzone = new Circle( 0, 0, sizeHotzone, color(255,255,255), "hotZone" );
  circleColdzone = new Circle( 0, 0, sizeColdzone, color(200,200,200), "coldZone" );

  circleTactileZoneIn = new Circle( circleA.x + xZoneOffset, circleA.y + yZoneOffset, sizeInZoneOffset , color(0,0,0), "-" );    
  circleTactileZoneOut = new Circle( circleA.x + xZoneOffset, circleA.y + yZoneOffset, sizeOutZoneOffset , color(0,0,0), "+" ); 
  circleTactileZoneMiddle = new Circle( circleA.x + xZoneOffset, circleA.y + yZoneOffset, sizeMiddleZoneOffset, color(0,0,0), "=" );    
  // the circleTactileZoneMiddle is the max path for the head around the tatile pinboard

  minIconToZoneDistance = sizeHotzone;  // min distance to activate the head under the pins
  // the sizeIcon/2 is strange but it prevent the head from bumping...
  // too late to solve that.. leave it like that ;)
  minIconToColdZoneDistance = sizeIcon + sizeColdzone;  // min distance to pre-activate the head
  // move the head in advance when whithin the cold zone

    iconManager = new IconManager();

  iconManager.add( new Icon( 400, 400, sizeIcon , color(255,50,255), "maurin", 30, loadImage("1.gif") ));
  iconManager.add( new Icon( 450, 400, sizeIcon , color(255,100,200), "oren ", 25, loadImage("2.gif") ));
  iconManager.add( new Icon( 400, 410, sizeIcon , color(255,150,150), "jb", 20, loadImage("3.gif") ));
  iconManager.add( new Icon( 450, 420, sizeIcon , color(255,200,100), "dana", 15, loadImage("4.gif") ));
  iconManager.add( new Icon( 200, 410, sizeIcon , color(255,255,50), "vince", 10, loadImage("5.gif") ));

  ellipseMode(CENTER);
  smooth();
  noFill();
  framerate(60);
}

void draw() {
  background(127,127,127);
  text("click Right MouseButton to visualize arm movements", 10, height-20);  

  circleHotzone.x = mouseX;
  circleHotzone.y = mouseY;

  circleColdzone.x = mouseX;
  circleColdzone.y = mouseY;

  selectedIcon = iconManager.manage( iconDragged , selectedIcon ); // select the nearest and draw them all by the way ..

  if (iconDragged) {
    selectedIcon.x = mouseX;
    selectedIcon.y = mouseY;
  }

  circleB.x = (circleA.x - circleHotzone.x) + selectedIcon.x + xZoneOffset;
  circleB.y = (circleA.y - circleHotzone.y) + selectedIcon.y + yZoneOffset;

  // if( (circleB.x-targetXSave)!=0 || (circleB.y-targetYSave)!=0 ) // head moved ?

  iconToZoneDistance  = circleHotzone.distance( selectedIcon); // calculate distance from pointer to hotzone
  onIcon=false;

  if( iconToZoneDistance < minIconToColdZoneDistance) { 
    //
    // within min distance to activate the head
    //
    circleColdzone.draw(); 
    circleHotzone.draw();     
    circleTactileZoneIn.draw();   
    circleTactileZoneOut.draw();   

    if( iconToZoneDistance > minIconToZoneDistance)  {
      //
      // in between cold and hotzone
      //
      circleTactileZoneMiddle.intersect( circleB.x, circleB.y ); // intersection between line to mouse pointer and circle circleTactileZoneMiddle

      circleB.x = paX;
      circleB.y = paY;
      circleA.intersect( circleB );  // get the resulting angles
      calculateAngles (paX, paY); // intersection always on circleTactileZoneMiddle
      drawArms();

      motorControl(teta1, teta2, 0); // move the head in pre-position and DOWN
    } 
    else {
      //                           
      // in the hotzone !! then tactile is activated
      //
      onIcon=true;
      if(iconDragged && selectedIconSave==selectedIcon) { // same icon selected in the previous row
        selectedIcon.anim.dx = (mouseX - mouseXSave)/speedDivider; // set speed for the selected icon
        selectedIcon.anim.dy = (mouseY - mouseYSave)/speedDivider;
      }
      else if( circleA.intersect( circleB )) {
        //
        // in the hotzone but not dragged
        // check if the point is reachable (should be after the distance check)
        calculateAngles (paX, paY);

        //selectedIcon.selected=250;          
        selectedIcon.draw(250);

        drawArms();

        motorControl(teta1, teta2, selectedIcon.shapeHeight);
      }
    }
  }
  // saving for the next frame
  //
  selectedIconSave = selectedIcon;
  mouseXSave = mouseX;
  mouseYSave = mouseY;
  targetXSave = circleB.x;
  targetYSave = circleB.y;  
}
