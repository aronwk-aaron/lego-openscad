length = 120;

module rail_main(length) {
    poly = [[0,0],[0,8],[3,8],[3,7],[4,7],[7,5.25],[9,5.25],[9,2.75],[7,2.75],[4,1],[3,1],[3,0]];
    rotate([90,-90,180]) linear_extrude(length) polygon(poly);
}

module rail_endpoint_right() {
  off_l=0.5;
  off_h=-0.15;
    poly = [[0,2],[0,6],[3+off_h,6],[3+off_h,4],[9,4],[9,2.75],[7,2.75],[4,2],[3+off_h,2]];
    translate([0,off_l,0]) rotate([90,-90,180]) linear_extrude(8-off_l) polygon(poly);
}

module rail_endpoint_left() {
  off_l=0.5;
  off_h=0.15;
    poly = [[3+off_h,8],[3+off_h,4],[9,4],[9,2.75],[7,2.75],[4,1],[3+off_h,1]];
    translate([0,off_l,0]) rotate([90,-90,180]) linear_extrude(8-off_l) polygon(poly);
    // support
    translate([-1.5,off_l,0]) cube([8,1,3+off_h], false);
}

module attach_poly(h) {
 off_l=0.3;
     linear_extrude(h) polygon([[0-off_l,0],[2-off_l,1.9],[6+off_l,1.9],[8+off_l,0]]);
}

module attach(l) {
  off=0.1;
    union() {
        difference() {
            union() {
                cube([41,l,1.5], false);
                cube([41,3,3], false);
                difference() {
                    translate ([7.5,-4,0]) cube([36,6,3], false);
                    translate ([12,-4.11,-0.5]) attach_poly(4);
                }
                difference() {
            union() {
                    translate ([16,-2.2,0]) cylinder(3,1,1,false, $fn = 80);
                    translate ([16,-4,0]) cylinder(3,1.95,1.95,false, $fn = 80);
            }
            translate ([16,-4,-0.5]) cylinder(4,.8,.8,false, $fn = 80);
                }
                translate ([28,-3.4,0]) mirror([0,1,0]) attach_poly(3);
            }
            translate ([32,-4,-0.5]) cylinder(4,2-off,2+off,false, $fn = 80);
        }
        translate ([12,0,3]) cylinder(d=4.9,h=2, $fn = 50);
        translate ([20,0,3]) cylinder(d=4.9,h=2, $fn = 50);
        translate ([28,0,3]) cylinder(d=4.9,h=2, $fn = 50);
        translate ([36,0,3]) cylinder(d=4.9,h=2, $fn = 50);
    }
}

module full_endpoint() {
    translate([0,-8,0]) rail_endpoint_left();
    translate([40,-8,0]) rail_endpoint_right();
    attach(8);
}

module barreau() {
    translate([8,0,0]) cube([36,6,1.5], false);
}

module main(length=120, barreau=1) {
    rail_main(length);
    translate([40,0,0]) rail_main(length);

    full_endpoint();

    translate([48,length,0]) rotate([180,180,0]) full_endpoint();


if(barreau==1) {
    translate([0,length/2-3,0]) barreau();
} else if(barreau==2) {
    translate([0,length*0.333-3,0]) barreau();
    translate([0,length*0.666-3,0]) barreau();
} else if(barreau==3) {
    translate([0,length/2-3,0]) barreau();
    translate([0,length*0.75-3,0]) barreau();
    translate([0,length*0.25-3,0]) barreau();
}
  
  }
  
  
  
  
  
  
module bahnuebergang(l=120) {
  
  off=8*2;
  
 # rotate([0,0,90]) main(l,barreau=0);
  
  translate([-off/2,0,0]) bahnuebergang_schraege(l-off);

  translate([-l+off/2,48,0])rotate([0,0,180]) bahnuebergang_schraege(l-off);

difference() {
  translate([-l+off/2,8,0]) cube([l-off,32,8]);
    for(i=[1:4]) {
  translate([-l+4+off/2,32+8+4-(i*8),0]) rotate([0,90,0]) cylinder(d=6,h=l-8-off, $fn=4);
}
}
}
module bahnuebergang_schraege(l=100) {
  difference() {
    hull() {
  translate([-l,-2,0]) cube([l,2,8]);
  translate([-l,-40,0]) cube([l,2,2]);
  }
  for(i=[0:3]) {
  translate([-l+4,-2-4-(i*8),0]) rotate([0,90,0]) cylinder(d=6,h=l-8, $fn=4);
}
}

x=10;
  translate([-0,-40,0]) {
        translate ([4,4+8,3]) cylinder(d=4.9,h=2.2, $fn = 80);
        translate ([4+8,4+8,3]) cylinder(d=4.9,h=2.2, $fn = 80);
        translate ([4,4,3]) cylinder(d=4.9,h=2.2, $fn = 80);
        translate ([4+8,4,3]) cylinder(d=4.9,h=2.2, $fn = 50);
  
        translate ([4+8,4+8+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);
        translate ([4,4+8+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);

    cube([16,24,3.2], false);
  }

  translate([-l-16,-40,0]) {
        translate ([4,4+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);
        translate ([4+8,4+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);
        translate ([4,4,3]) cylinder(d=4.9,h=2.2, $fn = 80);
        translate ([4+8,4,3]) cylinder(d=4.9,h=2.2, $fn = 50);
  
        translate ([4+8,4+8+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);
        translate ([4,4+8+8,3]) cylinder(d=4.9,h=2.2, $fn = 50);
  
    cube([16,24,3.2], false);
  }

}
bahnuebergang(40);



/*



a=120;
b=120+60-8-8-(4/3);
c=240+8;
d=120+60+8-4;
e=120/2-4;
f=120/3-4-(4/3);

echo("a",a);
echo("b",b);
echo("c",c);
echo("d",d);
echo("e",e);
echo("f",f);

%translate([0,-150,0]) rotate([0,0,90]) main(f,barreau=0);
%translate([-f-8,-150,0]) rotate([0,0,90]) main(f,barreau=0);
%translate([-f-8-f-8,-150,0]) rotate([0,0,90]) main(f,barreau=0);

%translate([0,-100,0]) rotate([0,0,90]) main(e,barreau=0);
%translate([-e-8,-100,0]) rotate([0,0,90]) main(e,barreau=0);
  
translate([0,-50,0]) rotate([0,0,90]) main(d,barreau=2);
%translate([-d-8,-50,0]) rotate([0,0,90]) main(d,barreau=2);
  
#%rotate([0,0,90]) main(a);
#%translate([-a-8,0,0]) rotate([0,0,90]) main(a);
#%translate([-a-8-120-8,0,0]) rotate([0,0,90]) main(a);
#%translate([-a-8-120-8-120-8,0,0]) rotate([0,0,90]) main(a);

%translate([0,50,0]) rotate([0,0,90]) main(b,barreau=2);
%translate([-b-8,50,0]) rotate([0,0,90]) main(b,barreau=2);
%translate([-b-8-b-8,50,0]) rotate([0,0,90]) main(b,barreau=2);

%translate([0,100,0]) rotate([0,0,90]) main(c,barreau=3);
%translate([-c-8,100,0]) rotate([0,0,90]) main(c,barreau=3);


*/
