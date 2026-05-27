$fn = 32;
$pos = [
    [0,0],
    [120.5,0],
    [163.5,0],
    [0,106],
    [120.5,106],
    [163.5,106]
];
$mid = $pos[5]/2;

for($p = $pos) {
    t($p) standoff();
    hull() {
        t($p) cylinder(r=5/2,h=2);
        t($mid) cylinder(r=5/2,h=2);
    }
}




module standoff() {
    cylinder(r=2.8/2,h=13);
    cylinder(r=5/2,h=10);
    
}



module rcube(dim,r=1) {
    linear_extrude(dim[2]) offset(r) square([dim[0]-2*r,dim[1]-2*r],center=true);
}

module rcubeo(dim,r=1) {
    linear_extrude(dim[2]) offset(r) square([dim[0],dim[1]],center=true);
}

module zcube(dim) {
    translate([0,0,dim[2]/2]) cube(dim,center=true);
}

module t(dim) translate(dim) children();

module z(dim) translate([0,0,dim]) children();

module r(dim) rotate(dim) children();