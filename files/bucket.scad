/*
 * bucket.scad
 *
 * A parametric, printable ice bucket
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 */

use <../../lib/shapes.scad> 
use <MCAD/regular_shapes.scad>

/* [Shell Dimensions] */
Height = 100;
Radius = 50;
Thickness = 3.2;
ShelfHeight = 5.2;
ShelfRelief = 6.4;      // leave room for lid
ShellRingPct = 15;
HandlePct = 70;
TopShelf = true;

/* [Texture] */
UseStar = false;
StarPoints = 12;
StarDepth = 1.5;
StarTwist = 40;

/* [Handle] */
HandleType = 2;
HandlePoints = 6;
HandleDepth = 1.5;
HandleTwist = 0;

/* [Weave] */
UseWeave = false;
WWall = 1.5;
WScale = .5;
WCycles = 30;
WGap = 0.2;

/* [Tub] */
BucketBasePct = 98;     // taper
BucketDepthPct = 95;    // bottom clearance
BucketWall = 1.2;

/* [Lid] */
DomeRadius = 70;
KnobRadius = 10;
DomeRim = 0.6; 
LidType = 2;

/* [Tray] */
TrayBasePct = 90;
TrayDepthPct = 30;
TrayPostRadius = 5;
TrayPostHeight = 110;

/* [Parts] */
Make_Shell = false;
Make_Tub = false;
Make_Lid = false;
Make_Tray = false;
Make_Divider = false;
Make_Star = false;
Make_Starcone = false;
Make_Handles = false;

$fa = 0.5;
$fs = 0.5;
$fn = 0;

// no more params
module _dummy() {}

function _ibr(h, r, w) =
        [[r,0],[r-w,w],[r-w,h],[r,h],[r,0]];
function _i2br(h, r, w) =
        [[r,h/2],[r,-h/2],[r-w,-h/2+w],[r-w,h/2-w],[r,h/2]];
function _obr(h, r, w) =
        [[r-w,0],[r-w,h],[r,h],[r,w],[r-w,0]]; 

module in_bevel_ring(height, radius, wall, $fa=4)
{
    pts = _ibr(height,radius,wall);
    //render()
    rotate_extrude()
        polygon(pts);
}

module in2_bevel_ring(height, radius, wall, $fa=1)
{
    pts = _i2br(height,radius,wall);
    //render()
    rotate_extrude()
        polygon(pts);
}

module out_bevel_ring(height, radius, wall, $fa=1)
{
    pts = _obr(height,radius,wall);
    //render()
    rotate_extrude()
        polygon(pts);
}

/* 
 * handles1 - squashed torus handle
 */
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
    hpoints = HandlePoints;
    htwist = HandleTwist;
    hdepth = HandleDepth;
    
    handle2 = Radius / 5;   // placement radius
    sqr3 = sqrt(3);
    fn = hpoints/2;
    
    //render()
    difference() {
        vstripe(180) {
            // set height and angle of handle
            translate([.667 * Radius,
                       0,
                       0.01 * HandlePct * Height - handle2])
            rotate([0, -10, 0])
/*
            difference() {
                // make a cone, remove the interior
                //render()
                starcone(h=rhandle*sqr3,
                         r=rhandle,
                         points=hpoints,
                         depth=hdepth,
                         twist=htwist
                        );
                translate([0,0,-Thickness*sqr3])
                    //render()
                    cone(height=rhandle*sqr3,
                         radius=rhandle);
            }
*/
            starcone_shell(h=rhandle*sqr3,
                         r=rhandle,
                         wall=Thickness,
                         points=hpoints,
                         depth=hdepth,
                         twist=htwist
                        );
        }
        // subtract interior of shell
        //render()
        translate([0,0,0.01*HandlePct * Height - 2*handle2])
        cylinder(h=1.5*Height, r=Radius - Thickness / 2);
    }
}

module render_shell()
{
    if (UseStar) {
        difference() {
            starcyl(h=Height,
                    r=Radius,
                    points=StarPoints,
                    depth=StarDepth,
                    twist=StarTwist);
            translate([0,0,-.5])
                cylinder(h=Height + 1, r=Radius-Thickness);
        }
    }

    if (UseWeave) {
        cyl_weave(h=Height,
                  r=Radius+WScale+WWall/2,
                  wwall=WWall,
                  wscale=WScale,
                  wcycles=WCycles,
                  wgap=WGap,
                  backfill=true,
                  fy=.5);
        cyl_shell(h=Height,
                  r=Radius,
                  wall=Thickness);
    }

    // Bottom shelf
    translate([0,0,ShelfRelief+ShelfHeight/2])
    in2_bevel_ring(height=ShelfHeight,
               radius=Radius-Thickness+.1,
               wall=Thickness+.1);

    // Top shelf
    if (TopShelf) {
        translate([0,0,Height-ShelfRelief-ShelfHeight/2])
        in2_bevel_ring(height=ShelfHeight,
                       radius=Radius-Thickness+.1,
                       wall=Thickness+.1);
    }
    
    // Bottom deco ring
    hdeco = .01 * ShellRingPct * Height;
    translate([0,0,hdeco])
    rotate([180,0,0])
    out_bevel_ring(height=hdeco,
                   radius=Radius + Thickness,
                   wall=Thickness + .05); 

    // Top deco ring
    translate([0,0,Height-hdeco])
    out_bevel_ring(height=hdeco,
                   radius=Radius + Thickness,
                   wall=Thickness + .05); 

    if (HandleType == 1) handles1();
    else if (HandleType == 2) handles2();
    
    rs = log(Radius);
    vstripe(120)
        translate([0, Radius-Thickness, rs + 1])
        sphere(r=rs);
}

function Tub() =
let (bbmult = 0.01 * BucketBasePct,
     bdmult = 0.01 * BucketDepthPct)
[
/*0*/ [0, 0],
/*1*/ [bbmult * (Radius - 2*Thickness), 0],         // lower edge
/*2*/ [(Radius - 2*Thickness),                      // start of shelf
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight) - Thickness],
/*3*/ [(Radius - Thickness - .1),                   // bottom of rim
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight)],
/*4*/ [(Radius - Thickness -.1),                    // top edge
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
/*5*/ [(Radius - 2*Thickness - BucketWall),         // interior top
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
/*6a*/ [bbmult * (Radius - 2*Thickness) - BucketWall,
            BucketWall + BucketWall/3],             // interior bevel top
/*6b*/ [bbmult * (Radius - 2*Thickness) - BucketWall - BucketWall/3,
            BucketWall],                            // floor bevel edge

/*7*/ [0, BucketWall],                              // floor center
      [0, 0]
];

function Divider(bpct, dpct, tAdj) =
let(bbmult = .01*bpct,
    bdmult = .01*dpct)
[
    [0, BucketWall],                              // floor center
    [bbmult * (Radius - tAdj*Thickness) - BucketWall,
            BucketWall],                          // floor edge
    [(Radius - tAdj*Thickness - BucketWall),         // interior top
            bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
    [0,     bdmult * (Height - 2 * ShelfRelief - ShelfHeight + BucketWall)],
    [0, BucketWall]                              // floor center
];



function Tray() =
let (tbmult = 0.01 * TrayBasePct,
     tdmult = 0.01 * TrayDepthPct,
     topRadius = Radius - 1.5*Thickness,
     ptRadius = TrayPostRadius - BucketWall)
[
/*00*/ [0, TrayPostHeight],
/* 0*/ [0, 0],
/* 1*/ [tbmult * topRadius, 0],                     // lower edge
/* 2*/ [topRadius, (tdmult * Height - Thickness)],  // bottom of rim
/* 3*/ [topRadius, (tdmult * Height)],              // top of rim
/* 4*/ [(topRadius - BucketWall), (tdmult * Height)], // interior rim
/* 5*/ [tbmult * topRadius - BucketWall, BucketWall], // interior lower edge
/* 6*/ [TrayPostRadius, BucketWall],                // bottom of post
/* 7*/ [TrayPostRadius, Height - 2*(ShelfRelief)],  // post ledge
/* 8*/ [TrayPostRadius - BucketWall, Height - 2*(ShelfRelief)], // inner ledge
/* 9*/ [TrayPostRadius - BucketWall, TrayPostHeight - 2*ptRadius],
/*10*/ for (r = [0: 6: 30]) [ ptRadius * cos(r),
                              TrayPostHeight - 2*ptRadius + ptRadius * sin(r)],
/*11*/ for (r = [-30: 6: 90]) [ ptRadius * cos(r),
                              TrayPostHeight - ptRadius + ptRadius * sin(r)],
/*00*/ [0, TrayPostHeight]
];


module render_tub()
{
    outline = Tub();
    //echo(outline);
    rotate_extrude()
        polygon(outline);
}

module render_div(bpct, dpct, tadj)
{
    outline = Divider(bpct, dpct, tadj);
    translate([0,BucketWall/2,0])
    rotate([90, 0, 0])
    linear_extrude(BucketWall)
        polygon(outline);
    translate([0,-BucketWall/2,0])
    rotate([90, 0, 180])
    linear_extrude(BucketWall)
        polygon(outline);
}

module render_tray()
{
    outline = Tray();
    //echo(outline);
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
    //echo(outline);
    
    translate([0, 0, offset - r/24])
    rotate_extrude()
        polygon(outline);
}

module knob2(r, offset)
{
    translate([0, 0, offset + r * 11 / 16 ])
    sphere(r=r);
}

module render_lid2(hole=false)
{
    rl = Radius + Thickness;
    p = sqrt(DomeRadius*DomeRadius - rl*rl); 
    depth = ShelfRelief - 1.2*BucketWall;

    difference() {
        translate([0,0,-p+depth+DomeRim])
            sphere(r=DomeRadius);

        // slice off most of sphere
        translate([0, 0, -DomeRadius-.5])
            cube(size=2*DomeRadius + 1, center=true);

        // insert part
        translate([0, 0, -1])
            cyl_shell(h=depth + 1,
                      r=rl+40-.40,
                      wall=2*Thickness+40);

        // square off rim
        cyl_shell(h=depth+DomeRim+1,
                  r=rl+20,
                  wall=20);

        if (hole)
            #cylinder(h=TrayPostHeight - Height + 2*(ShelfRelief),
                     r=TrayPostRadius - BucketWall);
    }

    knob1(r=KnobRadius, offset=DomeRadius - p + depth);
//    knob2(r=KnobRadius, offset=DomeRadius - p + depth);
}

module render_lid3()
{
    // disc
    linear_extrude(height=Thickness)
    difference() {
        circle(r=Radius - Thickness - .25);
        circle(r=TrayPostRadius - BucketWall + .25);
    }
}

/****************************

 Wrappers

****************************/

if (Make_Shell)
    render_shell();

if (Make_Tub) {
    render_tub();
    if (Make_Divider)
        #render_div(BucketBasePct, BucketDepthPct, 2);
}

if (Make_Lid) {
    if (LidType == 1)
        render_lid1();
    else if (LidType == 2)
        render_lid2();
    else if (LidType == 3)
        render_lid3();
    else if (LidType == 4)
        render_lid2(hole=true);
}

if (Make_Tray) {
    render_tray();
    if (Make_Divider)
        #render_div(TrayBasePct, TrayDepthPct, 1.5);
}

if (Make_Star)
    starcyl(h=Height,
            r=Radius,
            points=StarPoints,
            depth=StarDepth,
            twist=StarTwist);

if (Make_Starcone)
    starcone(height=Height,
             radius=Radius,
             points=StarPoints,
             depth=StarDepth,
             twist=StarTwist);

if (Make_Handles)
    conish();
