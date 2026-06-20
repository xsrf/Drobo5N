$dx = 160;
$dy = 122;
$fn = 32;
$h = 25;



difference() {
    rcube([$dx,$dy+6,$h],1);
    rcube([$dx-20,$dy-20,$h+2],1);
    // PCB Dummy:
    z($h-2) hull() {
        zcube([$dx+20,$dy,1.6]);
        zcube([$dx+20,$dy-1,2.5]);
    }
    z(2)zcube([$dx+20,$dy-3,$h-4]);
    t([($dx-15)/4+2.5,0,2])zcube([($dx-15)/2,$dy+10,$h+3]);
    t([($dx-15)/-4-2.5,0,2])zcube([($dx-15)/2,$dy+10,$h+3]);
}

for(i=[-1,0,1]) t([i*($dx/2-2.5),0,0]) zcube([1,$dy,5]);





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