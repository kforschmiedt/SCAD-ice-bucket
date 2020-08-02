/*
 * (C)Copyright 2020 Kent Forschmiedt
 *
 * Released under Creative Commons
 */
 
use <MCAD/regular_shapes.scad>

/* [Shell Dimensions] */

Height = 100;
Radius = 50;
Thickness = 3.2;
ShelfHeight = 5.2;
ShelfRelief = 6.4;      // leave room for lid
ShellRingPct = 15;
HandlePct = 70;

/* [Texture] */
StarPoints = 12;
StarDepth = 1.5;
StarTwist = 40;

/* [Bucket] */

BucketBasePct = 98;     // taper
BucketDepthPct = 95;    // bottom clearance
BucketWall = 1.2;

/* [Lid] */


/* [Parts] */
Make_Shell = false;
Make_Tub = false;
Make_Lid = false;
Make_Star = false;

$fa = 0.5;
$fs = 0.5;

// no more params
module _dummy() {}

module starling()
{
    r1 = Radius;
    r2 = Radius + StarDepth;
    a1 = 360/StarPoints;
    a2 = a1/2;
    
    angles = [for (i = [0 : StarPoints]) i*a1];

    pts = [ for (i = [0 : StarPoints]) each
            [ [r1*cos(angles[i]), r1*sin(angles[i])],
              [r2*cos(angles[i]+a2), r2*sin(angles[i]+a2)] ]
    ];
    
    echo(pts);
    
    linear_extrude(height = Height, twist=StarTwist)
    polygon(pts);
}

/*
 * Hollow tube, with interior shelves top and bottom
 */

module in_bevel_ring(height, radius, wall)
{
    difference() {
        cylinder_tube(height=height,
                    radius=radius,
                    wall=wall);
        translate([0,0,-1])
        cone(height=radius+1, radius=radius+1);
    }
}

module out_bevel_ring(height, radius, wall)
{
    difference() {
        cylinder_tube(height=height,
                      radius=radius,
                      wall=wall);
        translate([0,0,height - wall - 1])
        in_bevel_ring(height=radius+1,
                      radius=radius+1,
                      wall=wall+1);
    }
}

module handles1()
{
    // Handles
    rhandle = Radius / 3;
    handle1 = Radius/8;
    handle2 = Radius / 6;
    
    for (rot = [0, 180]) {
        rotate([0,0,rot])
        difference() {
            translate([Radius - .3*rhandle,
                       0,
                       0.01 * HandlePct * Height - handle2])
            rotate([0, -35, 0])
                oval_torus(inner_radius = rhandle, thickness=[handle1,handle2]);

            cylinder(h=Height, r=Radius - .3);
        }
    }
}

module handles2()
{
    // Handles
    rhandle = Radius / 2;   // size of cone
    handle2 = Radius / 6;   // placement raduis
    sqr3 = sqrt(3);
    
    for (rot = [0, 180]) {
        rotate([0,0,rot])
        difference() {
            translate([.667 * Radius,
                       0,
                       0.01 * HandlePct * Height - handle2])
            rotate([0, -10, 0])
            difference() {
                minkowski() {
                    cone(height=rhandle*sqr3, radius=rhandle);
                    sphere(r=1);
                }
                translate([0,0,-Thickness*sqr3])
                    cone(height=rhandle*sqr3, radius=rhandle);
            }
            cylinder(h=2*Height, r=Radius - Thickness / 2);
        }
    }
    
}

module render_shell()
{
    difference() {
        union() {
          cylinder(h=Height, r=Radius);
          starling();
        }
        translate([0,0,-.5])
        cylinder(h=Height + 1, r=Radius-Thickness);
    }
    
    // bottom shelf, bottom piece
    translate([0,0,ShelfRelief])
    in_bevel_ring(height=ShelfHeight/2,
               radius=Radius-Thickness+.01,
               wall=Thickness+.01);

    // Bottom shelf, top piece
    translate([0,0,ShelfRelief + ShelfHeight -.01])
        rotate([180,0,0])
        in_bevel_ring(height=ShelfHeight/2 + .01,
                      radius=Radius-Thickness+.01,
                      wall=Thickness+.01);

    // Top shelf, bottom piece
    translate([0,0,Height - ShelfHeight - ShelfRelief])
        in_bevel_ring(height=ShelfHeight/2,
                      radius=Radius-Thickness+.01,
                      wall=Thickness+.01);
    // Top shelf, top piece
    translate([0,0,Height - ShelfRelief - .01])
        rotate([180,0,0])
        in_bevel_ring(height=ShelfHeight/2,
                      radius=Radius-Thickness+.01,
                      wall=Thickness+.01);
    
    // Bottom deco ring
    hdeco = .01 * ShellRingPct * Height;
    out_bevel_ring(height=hdeco,
                   radius=Radius + Thickness,
                   wall=Thickness + .01); 
    // Top deco ring
    translate([0,0,Height])
    rotate([180,0,0])
    out_bevel_ring(height=hdeco,
                   radius=Radius + Thickness,
                   wall=Thickness + .01); 

    handles2();

}

bbmult = 0.01 * BucketBasePct;
bdmult = 0.01 * BucketDepthPct;

function Tub() = [
/*0*/ [0, 0],
/*1*/ [bbmult * (Radius - 2*Thickness), 0],
/*2*/ [(Radius - 2*Thickness),
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight) - Thickness],
/*3*/ [(Radius - Thickness - .1),
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight)],
/*4*/ [(Radius - Thickness -.1),
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
/*5*/ [(Radius - 2*Thickness - BucketWall),
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
/*6a*/ [bbmult * (Radius - 2*Thickness) - BucketWall,
            BucketWall + BucketWall/3],
/*6b*/ [bbmult * (Radius - 2*Thickness) - BucketWall - BucketWall/3,
            BucketWall],

/*7*/ [0, BucketWall],
      [0, 0]
];

module render_tub()
{
    outline = Tub();
    echo(outline);
    
    rotate_extrude()
        polygon(outline);
}

module render_lid()
{
    linear_extrude(height=Thickness)
    circle(r=Radius - Thickness - .25);
    
    difference() {
        rotate([90,0,0])
        oval_torus(inner_radius = Radius/4, thickness=[Radius/12,Radius/5]);

        translate([0,0,-Radius/2])
        linear_extrude(height=Radius/2)
        circle(r=Radius);
    }
}

if (Make_Shell)
    render_shell();

if (Make_Tub)
    render_tub();

if (Make_Lid)
    render_lid();

if (Make_Star)
    starling();
