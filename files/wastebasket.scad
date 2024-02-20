/*
 * bucket.scad
 *
 * A parametric, printable waste basket
 *
 * (C)Copyright 2020 Kent Forschmiedt, All Rights Reserved
 */

use <../../lib/shapes.scad> 
use <../../lib/fillet.scad> 

/* [Wastebasket] */
Height = 100;
TopRadius = 105;
BottomRadius = 70;
Thickness = 3.2;
TopRingPct = 8;
BottomRingPct = 20;

/* [Texture] */
UseStar = false;
StarPoints = 12;
StarDepth = 1.5;
StarTwist = 40;

/* [Parts] */
Make_Wastebasket = false;

$fa = 0.5;
$fs = 0.5;
$fn = 0;

// no more params
module _dummy() {}

module render_wbasket()
{
    cylinder(h=Thickness, r=BottomRadius, center=true);

    starcyl_shell(h=Height,
                  r1 = TopRadius,
                  r2 = BottomRadius,
                  wall=Thickness,
                  points=StarPoints,
                  depth=StarDepth,
                  twist=StarTwist);
    
    b_ring_height = Height * BottomRingPct/100;
    b_ring_delta = (TopRadius - BottomRadius) * BottomRingPct/100;
    translate([0,0,b_ring_height/2-Thickness/2])
    cyl_shell2(h = b_ring_height,
               r1=BottomRadius + StarDepth,
               r2=BottomRadius + StarDepth + b_ring_delta,
               wall=Thickness+StarDepth,
               center=true);

    t_ring_height = Height * TopRingPct/100;
    t_ring_delta = (TopRadius - BottomRadius) * TopRingPct/100;
    translate([0,0,Height-t_ring_height/2])
    cyl_shell2(h = t_ring_height,
               r1=TopRadius + StarDepth - t_ring_delta,
               r2=TopRadius + StarDepth,
               wall=Thickness+StarDepth,
               center=true);
             
    #base_fillet(r1=BottomRadius-.85*Thickness,
                r2=Thickness,
                arc=70,
                h=Thickness/2);

}

if (Make_Wastebasket)
    render_wbasket();

