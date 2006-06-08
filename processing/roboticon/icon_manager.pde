class IconManager {
  Circle[] icons = {  
    new Circle(), new Circle(), new Circle(), new Circle(), new Circle()         }; // add new empty icons here if you want more
  int index;

  IconManager(){
    int index = 0;
  }

  void add(Circle icon) {
    icons[index++] = icon;
  }
  Circle manage(boolean iconDragged, Circle selectedIcon){
    float currentDistance=width;
    float testedDistance=0, iconsDistance;
    Circle currentIcon = selectedIcon;//icons[0];
    float explodeDistance = 2*icons[0].r;

    for(  int i=0; i < icons.length; i++){
      if( !iconDragged ) {
        // dont reselect if already dragging an icon..
        testedDistance = circleHotzone.distance(icons[i]);
        // find the icond having the min distance 
        if( testedDistance < currentDistance) {
          currentIcon=icons[i];
          currentDistance = testedDistance;
        }
      }
      // draw all icons, reset their state, make them move 
      if (!(iconDragged && icons[i]==selectedIcon)) {
        icons[i].animate();  // don't animate if icon dragged ...
      }
      icons[i].draw(0);


      // test all icons for collision
      for(  int j=i+1; j < icons.length; j++){  // i != j otherwise would do a self test icon ;(
        testedDistance = icons[i].distance(icons[j]) ;//+ icons[i].iconAni.dx;
        iconsDistance = (icons[i].r + icons[j].r);

        if(testedDistance <= iconsDistance) {
          // icons i and j have encountered ...
          if(testedDistance < 0.50 * iconsDistance  && icons[j] != selectedIcon) { 
            // icons already collapsed ... need to explode
            icons[j].x += 2*random(explodeDistance) - explodeDistance ;
            icons[j].y += 2*random(explodeDistance) - explodeDistance;
          }
          else { 
            // normal collision 
            collide( icons[i], icons[j]);
            // println("collision entre "+i+" et "+j);
            icons[i].animate(); // ...animate collided icons so the escape the area asap ..
            icons[j].animate(); // ...gets less stuck with the other (testedDistance <= iconsDistance)
          }
        }
      }
    }
    currentIcon.draw(100);
    return currentIcon;
  }

  void collide(Circle cA, Circle cB) { // elastic collision
    // transpose to local variable naming
    float x1 = cA.x;
    float y1 = cA.y;
    float vx1 = cA.iconAni.dx;
    float vy1 = cA.iconAni.dy;
    float mass1 = cA.iconHeight;  

    float x2 = cB.x;
    float y2 = cB.y;
    float vx2 = cB.iconAni.dx;
    float vy2 = cB.iconAni.dy;
    float mass2 = cB.iconHeight;

    float ed=1; // for elactic collision (<= 1 in any case)

    float dx = x2-x1, dy = y2-y1;
    // where x1,y1 are center of ball1, and x2,y2 are center of ball2
    float distance = sqrt(dx*dx+dy*dy);
    // Unit vector in the direction of the collision
    float ax=dx/distance, ay=dy/distance;
    // Projection of the velocities in these axes
    float va1=(vx1*ax+vy1*ay), vb1=(-vx1*ay+vy1*ax);
    float va2=(vx2*ax+vy2*ay), vb2=(-vx2*ay+vy2*ax);
    // New velocities in these axes (after collision): ed<=1, for elastic collision ed=1
    float vaP1=va1 + (1+ed)*(va2-va1)/(1+mass1/mass2);
    float vaP2=va2 + (1+ed)*(va1-va2)/(1+mass2/mass1);
    // Undo the projections
    vx1=vaP1*ax-vb1*ay; 
    vy1=vaP1*ay+vb1*ax;
    vx2=vaP2*ax-vb2*ay; 
    vy2=vaP2*ay+vb2*ax;

    // back to local variable 
    cA.iconAni.dx =  vx1 ;
    cA.iconAni.dy = vy1;
    cB.iconAni.dx = vx2;
    cB.iconAni.dy = vy2;    

    // from : http://www.phy.ntnu.edu.tw/ntnujava/viewtopic.php?t=19
  }  
}
