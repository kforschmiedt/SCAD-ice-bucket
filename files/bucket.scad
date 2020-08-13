/*
 * bucket.scad
 *
 * A parametric, printable ice bucket
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 * Licensed under Creative Commons
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
DomeRadius = 70;
KnobRadius = 10;
DomeRim = 0.6; 

/* [Parts] */
Make_Shell = false;
Make_Tub = false;
Make_Lid = false;
Make_Star = false;
Make_Starcone = false;
Make_Handles = false;

$fa = 0.5;
$fs = 0.5;
$fn = 0;

// no more params
module _dummy() {}

module cyl_shell(height, radius, wall)
{
    difference() {
        cylinder(h=height, r=radius, center=false);
        translate([0,0,-1])
        cylinder(h=height+2, r=radius-wall, center=false);
    }
}

/*
 * Make cylinder by extruding star
 */
module starcyl(height, radius, points, depth, twist)
{
    r1 = radius;
    r2 = radius + depth;
    a1 = 360/points;
    a2 = a1/2;

    pts = [ for (i = [0 : points-1])
        let (a = i*a1,ap = a+a2)
        each [ [r1*cos(a), r1*sin(a)],
              [r2*cos(ap), r2*sin(ap)] ]
    ];
    
    //echo(pts);
    
    linear_extrude(height=height, twist=twist)
    polygon(pts);
}

/*
 * Cone version of star
 */
module starcone(height, radius, points, depth, twist)
{
    /* DIY extrude */

    a1 = 360/points;
    a2 = a1/2;
    slices = 4 * points;
    zstep = height / slices;
    astep = -twist / slices;
    
    echo("a1: ", a1, "a2: ", a2, "slices: ", slices, "zstep: ", zstep, "astep: ", astep);
    
    pts = [
        for (zi = [0 : slices])
            let (z = zi * zstep,
                 a = zi * astep,
                 r1 = radius - zi * radius/slices,
                 r2 = r1 + depth - zi * depth/slices)
            for (i = [0 : points])
                let (ai = a + i*a1, ap = ai+a2)
                each [
                    [r1*cos(ai), r1*sin(ai), z],
                    [r2*cos(ap), r2*sin(ap), z]
                ]
    ];
    //echo(pts);
            
    // stitch points into paths
    // every path is a parallelogram between adjacent layers
    // then close the bottom

    paths = concat([
        for (zi = [0 : slices-1])
            let (base = zi * 2 * (points+1),
                 b1 = base + 2 * (points+1))
            for (i = [0 : 2 * points - 1])
                [ base + i, b1 + i, b1 + i + 1, base + i + 1 ]
        ],
        [[for (i = [0: 2*points]) i ]]
    );

    polyhedron(points=pts, faces=paths);
    
}

/*
 * Hollow tube, with interior shelves top and bottom
 */

module in_bevel_ring(height, radius, wall)
{
    difference() {
        cyl_shell(height=height,
                  radius=radius,
                  wall=wall);
        translate([0,0,-1])
        cone(height=radius+1, radius=radius+1);
    }
}

module out_bevel_ring(height, radius, wall)
{
    difference() {
        cyl_shell(height=height,
                      radius=radius,
                      wall=wall);
        translate([0,0,height - wall - 1])
        in_bevel_ring(height=radius+1,
                      radius=radius+1,
                      wall=wall+1);
    }
}

/*
 * cone made by stacked extrusion
 */
module conish(height=160, radius=120, rc=4, step=5, fn=12)
{    
//    rc = 5;
//    step = 7;
//    height = 160;
//    radius = 120;
//    fn = 11;

    steps = floor(height/step);
    hstep = (radius-rc)/steps;
    
    for (i = [0: 1: steps]) {
        z = step * i;
        x = hstep * i;
        translate([0, 0, z])
        rotate_extrude(angle=360)
            translate([radius - x, 0, 0])
            circle(r=rc, $fn=fn);
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

/*
 * Section of base of cone, tilted for printable angle
 */
module handles2()
{
    // Handles
    rhandle = Radius / 1.8;   // size of cone
    hpoints = floor(StarPoints / 1.7);
    htwist = StarTwist * 2;
    
    handle2 = Radius / 5;   // placement radius
    sqr3 = sqrt(3);
    fn = StarPoints/2;
    
    for (rot = [0, 180]) {
        rotate([0,0,rot])
        difference() {
            // set height and angle of handle
            translate([.667 * Radius,
                       0,
                       0.01 * HandlePct * Height - handle2])

            rotate([0, -10, 0])
/*
            conish(height=rhandle*sqr3,
                   radius=rhandle,
                   rc=3,
                   step=4,
                   fn=7);
*/
/*
            rotate([0, -10, 0])
            difference() {
                // Add sphere to cone to round off edges
                minkowski() {
                    cone(height=rhandle*sqr3, radius=rhandle, $fn=fn);
                    sphere(r=1);
                }
                translate([0,0,-Thickness*sqr3])
                    cone(height=rhandle*sqr3,
                         radius=rhandle,
                         $fn=fn);
            }
*/
            rotate([0, 0, 0])
            difference() {
                // Add sphere to cone to round off edges
                starcone(height=rhandle*sqr3,
                         radius=rhandle,
                         points=hpoints,
                         depth=StarDepth,
                         twist=htwist
                        );
                translate([0,0,-Thickness*sqr3])
                    cone(height=rhandle*sqr3,
                         radius=rhandle);
            }

            // subtract interior of shell
            cylinder(h=2*Height, r=Radius - Thickness / 2);
        }
    }
}
    
module render_shell()
{
    difference() {
        union() {
          cylinder(h=Height, r=Radius);
          starcyl(height=Height,
                  radius=Radius,
                  points=StarPoints,
                  depth=StarDepth,
                  twist=StarTwist);

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

module render_lid1()
{
    // disc
    linear_extrude(height=Thickness)
    circle(r=Radius - Thickness - .25);
    
    difference() {
        // donut handle
        rotate([90,0,0])
        oval_torus(inner_radius = Radius/4, thickness=[Radius/12,Radius/5]);

        // slice off unused donut
        translate([0,0,-Radius/2])
        linear_extrude(height=Radius/2)
        circle(r=Radius);
    }
}

// spike knob
function Knob1(scale) = scale * [
/*0*/ [0, 0],
/*1*/ [3, 0],
/*2*/ [2, 1],
/*3*/ [2, 2],
/*4*/ [4, 4],
/*4a*/[0.05,7],
/*5*/ [0, 7],
      [0, 0]
];

module knob1(r, offset)
{
    outline = Knob1(r/5);
    echo(outline);
    
    translate([0, 0, offset - r/24])
    rotate_extrude()
        polygon(outline);
}

module knob2(r, offset)
{
    translate([0, 0, offset + r * 11 / 16 ])
    sphere(r=r);
}

module render_lid2()
{
    rl = Radius + Thickness;
    p = sqrt(DomeRadius*DomeRadius - rl*rl); 
    depth = ShelfRelief - 1.2*BucketWall;

    difference() {
      difference() {
        difference() {
          translate([0,0,-p+depth+DomeRim])
              sphere(r=DomeRadius);

          // slice off most of sphere
          translate([0, 0, -DomeRadius-.5])
              cube(size=2*DomeRadius + 1, center=true);
        }
        // insert part
        translate([0, 0, -1])
        cyl_shell(height=depth + 1,
                  radius=rl+40-.40,
                  wall=2*Thickness+40);
      }
      // square off rim
      cyl_shell(height=depth+DomeRim+1,
                radius=rl+20,
                wall=20);
    }

    knob1(r=KnobRadius, offset=DomeRadius - p + depth);
//    knob2(r=KnobRadius, offset=DomeRadius - p + depth);
}

if (Make_Shell)
    render_shell();

if (Make_Tub)
    render_tub();

if (Make_Lid)
    render_lid2();

if (Make_Star)
    starcyl(height=Height,
            radius=Radius,
            points=StarPoints,
            depth=StarDepth,
            twist=StarTwist);

if (Make_Starcone)
    starcone(height=Height, radius=Radius, points=StarPoints, depth=StarDepth, twist=StarTwist);


if (Make_Handles)
    conish();
