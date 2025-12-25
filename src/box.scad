
module bottom_dome(radius) {
  difference() {
    sphere(radius, $fn=24);
    translate([-radius, -radius, 0]) cube([radius*2, radius*2, radius]);
  }
}

module round_prism(dimensions, radii) {
  assert(is_list(dimensions) && len(dimensions) == 3, "'dimensions' must be of the pattern [w, l, h]!");
  assert(is_list(radii) && len(radii) == 4, "'radii' must be of the pattern [fl, fr, bl, br]!");
  w = dimensions[0];
  l = dimensions[1];
  h = dimensions[2];
  eps = 0.001;
  fl = max(radii[0], eps);
  fr = max(radii[1], eps);
  bl = max(radii[2], eps);
  br = max(radii[3], eps);

  fn = 64;
  hull() {
    translate([bl, bl, 0]) cylinder(h, r=bl, $fn=fn); // bl
    translate([w-br, br, 0]) cylinder(h, r=br, $fn=fn); // br
    translate([fl, l-fl, 0]) cylinder(h, r=fl, $fn=fn); // fl
    translate([w-fr, l-fr, 0]) cylinder(h, r=fr, $fn=fn); // fr
  }
}

module round_box(dimensions, radii, wall_thickness) {
  difference() {
    minkowski() {
      round_prism(dimensions, radii);
      bottom_dome(wall_thickness);
    }
    round_prism([dimensions[0], dimensions[1], dimensions[2]+0.1], radii);
  }
}

/// Produces a rounded rectangular prism
/// Uses a hull to allow lengths of 0, which a minkowski would fail at
module rounded(dimensions, radius) {
  d0 = dimensions[0];
  d1 = dimensions[1];
  d2 = dimensions[2];
  fn = 24;
  hull() {
    sphere(radius, $fn=fn);
    translate([d0, 0, 0]) sphere(radius, $fn=fn);
    translate([0, d1, 0]) sphere(radius, $fn=fn);
    translate([d0, d1, 0]) sphere(radius, $fn=fn);
    translate([0, 0, d2]) sphere(radius, $fn=fn);
    translate([d0, 0, d2]) sphere(radius, $fn=fn);
    translate([0, d1, d2]) sphere(radius, $fn=fn);
    translate(dimensions) sphere(radius, $fn=fn);
  }
}

// CONSTANTS
// All lengths in millimeters

BATTERY_LENGTH = 71.50;
BATTERY_THICKNESS = 16.20;
BATTERY_WIDTH = 153.00;

KEYBOARD_THICKNESS = 12.00;
KEYBOARD_WIDTH = 153.00;

WALL_THICKNESS = 1.60;

RPI_BOARD_HEIGHT = 2.95;
RPI_LENGTH = 57.50;

BOX_WIDTH = BATTERY_WIDTH;
BOX_LENGTH = BATTERY_LENGTH + RPI_LENGTH;
BOX_HEIGHT = BATTERY_THICKNESS + KEYBOARD_THICKNESS;
BOX_DIMENSIONS = [BOX_WIDTH, BOX_LENGTH, BOX_HEIGHT];

module rpi_support() {
  base_height = 3.5; // stolen from original pi_hole_height variable, needs confirmation
  cylinder(base_height, r=3, $fn=24);
  translate([0, 0, base_height]) cylinder(3, r=1.5, $fn=24);
}

module display_shelf() {
  fn = 64;
  outer_rad = 4;
  inner_rad = 3;
  height = 12;
  taper = 8;

  translate([0, -outer_rad, 0]) difference() {
    translate([0, 0, -height]) union() {
      cylinder(height, r=outer_rad, $fn=fn);
      translate([-outer_rad, 0, 0]) cube([outer_rad*2, outer_rad, height]);
    }
    translate([0, 0, -height-0.001]) polyhedron(
      points = [
        [-outer_rad-.001, -outer_rad, taper],
        [ outer_rad+.001, -outer_rad, taper],
        [-outer_rad-.001, -outer_rad, 0],
        [ outer_rad+.001, -outer_rad, 0],
        [-outer_rad-.001,  outer_rad, 0],
        [ outer_rad+.001,  outer_rad, 0]
      ],
      faces = [
        [0, 1, 2], [2, 1, 3],
        [1, 0, 4], [1, 4, 5],
        [0, 2, 4],
        [3, 1, 5],
        [2, 3, 4], [4, 3, 5]
      ]
    );
    translate([0, 0, -height]) cylinder(height+0.001, r=inner_rad, $fn=fn);
  }
}

/// Holes for RPi's USB and ethernet ports
module left_holes() {
  translate([3,    0]) square([13, 14]);
  translate([20.5, 0]) square([13, 14]);
  translate([39.4, 0]) square([12.5, 11]);
}

/// Holes for power bank's ports
module right_holes() {
  translate([21.5, 8.1]) offset(r = 3, $fn=24) square([6, 0.001]);
  translate([46.2, 3.5]) square([17, 9.4]);
}

/// Holes for other RPi ports
module back_holes() {
  translate([34.2, 6.1]) circle(3.265, $fn=24);
  translate([45, 2.95]) square([7.5, 3.9]);
  translate([58.5, 2.95]) square([7.5, 3.9]);
  translate([73.8, 2.95 + (3.6 / 2)]) offset(r = 1.8, $fn=24) square([6, 0.001]);
}

module bottom_shell() {
  pi_hole_height = 3.5; // FIXME: This will need adjustment thanks to the new supports
  box_corners = [0, 0, 3, 6];

  difference() {
    // FIXME: corner radii are eyeballed
    round_box(BOX_DIMENSIONS, box_corners, WALL_THICKNESS);

    translate([0, BOX_LENGTH, pi_hole_height]) rotate([90, 0, -90]) scale([1, 1, 4])
      left_holes();
    translate([BOX_WIDTH, 0, 0]) rotate([90, 0, 90]) scale([1, 1, 4])
      right_holes();
    translate([0, BOX_LENGTH, 0]) rotate([90, 0]) scale([1, 1, 4])
      back_holes();
  }
  // FIXME: Positions/dimensions of shelves are eyeballed
  translate([64,  BOX_LENGTH, 24]) display_shelf();
  translate([138, BOX_LENGTH, 24]) display_shelf();
  // FIXME: Positions/dimensions of supports are eyeballed
  translate([25, BOX_LENGTH - 5,  0]) rpi_support();
  translate([25, BOX_LENGTH - 50, 0]) rpi_support();
  translate([90, BOX_LENGTH - 5,  0]) rpi_support();
  translate([90, BOX_LENGTH - 50, 0]) rpi_support();
}

bottom_shell();

