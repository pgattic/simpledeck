
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
BATTERY_WIDTH = 152.00;

KEYBOARD_THICKNESS = 12.00;
KEYBOARD_WIDTH = 153.00;
KEYBOARD_LENGTH = 59.00;

WALL_THICKNESS = 1.60;

RPI_BOTTOM_CLEARANCE = 2.3;
RPI_PCB_THICKNESS = 1.5;
RPI_LENGTH = 57.50;
RPI_HOLE_HEIGHT = RPI_BOTTOM_CLEARANCE + RPI_PCB_THICKNESS;

BOX_WIDTH = BATTERY_WIDTH;
BOX_LENGTH = BATTERY_LENGTH + RPI_LENGTH;
BOX_HEIGHT = BATTERY_THICKNESS + KEYBOARD_THICKNESS;
BOX_DIMENSIONS = [BOX_WIDTH, BOX_LENGTH, BOX_HEIGHT];

module rpi_support() {
  cylinder(RPI_BOTTOM_CLEARANCE, r=2.9, $fn=24);
  translate([0, 0, RPI_BOTTOM_CLEARANCE]) cylinder(2, r=1.15, $fn=24);
}

module display_shelf() {
  fn = 64;
  outer_rad = 4;
  inner_rad = 3;
  height = 12;
  taper = 8;

  translate([0, -inner_rad, 0]) difference() {
    translate([0, 0, -height]) union() {
      cylinder(height, r=outer_rad, $fn=fn);
      translate([-outer_rad, 0, 0]) cube([outer_rad*2, outer_rad, height]);
    }
    translate([0, 0, -height]) polyhedron(
      points = [
        [-outer_rad, -outer_rad, taper],
        [ outer_rad, -outer_rad, taper],
        [-outer_rad, -outer_rad, 0],
        [ outer_rad, -outer_rad, 0],
        [-outer_rad,  outer_rad, 0],
        [ outer_rad,  outer_rad, 0]
      ],
      faces = [
        [0, 1, 2], [2, 1, 3],
        [1, 0, 4], [1, 4, 5],
        [0, 2, 4],
        [3, 1, 5],
        [2, 3, 4], [4, 3, 5]
      ]
    );
    translate([0, 0, -height]) cylinder(height, r=inner_rad, $fn=fn);
  }
}

/// A side-mounted hole to drive a screw through
module screw_hole() {
  fn = 24;
  h = 4;
  o_rad = 2;
  i_rad = 1;
  translate([0, -i_rad, -h]) difference() {
    union() {
      cylinder(h, r=o_rad, $fn=fn);
      translate([-o_rad - i_rad, 0, 0]) cube([o_rad * 2 + i_rad * 2, i_rad, h]);
    }
    cylinder(h, r=i_rad, $fn=fn);
    translate([o_rad + i_rad, 0, 0]) cylinder(h, r=i_rad, $fn=fn);
    translate([-o_rad - i_rad, 0, 0]) cylinder(h, r=i_rad, $fn=fn);
    translate([-o_rad, i_rad, 0]) cube([o_rad*2, o_rad-i_rad, h]);
  }
}

/// Holes for RPi's USB and ethernet ports
module left_holes() {
  translate([0, RPI_HOLE_HEIGHT]) {
    translate([3,    0]) square([13, 14]);
    translate([20.5, 0]) square([13, 14]);
    translate([39.4, 0]) square([12.5, 11]);
  }
  translate([BOX_LENGTH - KEYBOARD_LENGTH + 12, BOX_HEIGHT-7]) offset(r = 1.6, $fn=24) square([28, 7]);
}

/// Holes for power bank's ports
module right_holes() {
  translate([21.5, BATTERY_THICKNESS / 2]) offset(r = 3, $fn=24) square([6, 0.001]);
  translate([54.7, BATTERY_THICKNESS / 2]) square([17, 9.4], center=true);
}

/// Holes for other RPi ports
module back_holes() {
  offset(r = 0.2) // This makes the holes a tiny bit bigger so the ports line up easier
  scale([-1, 1]) {
    translate([0, RPI_HOLE_HEIGHT]) {
      translate([34.4, 3.265]) circle(3.265, $fn=24);
      translate([45.2, -0.5]) square([7.2, 3.8]);
      translate([58.7, -0.5]) square([7.2, 3.8]);
      translate([74, 1.6]) offset(r = 1.6, $fn=24) square([6, 0.001]);
    }
    // Button for brightness
    translate([127, BOX_HEIGHT - 11]) scale([.6, -.5]) text("U", halign="center", valign="center");
  }
}

module bottom_shell() {
  box_corners = [1.5, 1.5, 5, 7];

  difference() {
    round_box(BOX_DIMENSIONS, box_corners, WALL_THICKNESS);

    translate([0, BOX_LENGTH, 0]) rotate([90, 0, -90]) linear_extrude(WALL_THICKNESS)
      left_holes();
    translate([BOX_WIDTH, 0, 0]) rotate([90, 0, 90]) linear_extrude(WALL_THICKNESS)
      right_holes();
    translate([0, BOX_LENGTH, 0]) rotate([90, 0, 180]) linear_extrude(WALL_THICKNESS)
      back_holes();

    translate([BOX_WIDTH+1, 34, BATTERY_THICKNESS+3]) rotate([0, -90, 0]) cylinder(r=5, 3, $fn=24);
    // Lanyard hole
    translate([BOX_WIDTH, 0, BATTERY_THICKNESS/2]) rotate_extrude() {
        translate([6, 0, 0]) {
            circle(r = 2, $fn=24);
        }
    }
  }
  // Shelves to hold the display
  shelf_center_dist = 99.2;
  translate([44,  BOX_LENGTH, BOX_HEIGHT - 7.8]) display_shelf();
  translate([44 + shelf_center_dist, BOX_LENGTH, BOX_HEIGHT - 7.8]) display_shelf();

  // Supports to hold the Pi above the floor
  pi_screw_width = 49;
  pi_screw_length = 57.7;
  translate([27, BOX_LENGTH - 5,  0]) rpi_support();
  translate([27, BOX_LENGTH - 50, 0]) rpi_support();
  translate([27 + pi_screw_length, BOX_LENGTH - 5,  0]) rpi_support();
  translate([27 + pi_screw_length, BOX_LENGTH - 50, 0]) rpi_support();

  // Holes for face plate screws
  screwhole_height = BOX_HEIGHT - 4;
  translate([BOX_WIDTH, BOX_LENGTH - 8, screwhole_height]) rotate([0, 0, -90]) screw_hole();
  translate([0, BOX_LENGTH - 8, screwhole_height]) rotate([0, 0, 90]) screw_hole();
  translate([BOX_WIDTH, BATTERY_LENGTH + 8, screwhole_height]) rotate([0, 0, -90]) screw_hole();
  translate([0, BATTERY_LENGTH + 8, screwhole_height]) rotate([0, 0, 90]) screw_hole();

  // Small indent to make up width difference between battery and keyboard
  translate([0, 24, 0]) cube([0.5, 24, BATTERY_THICKNESS*0.7]);
}

bottom_shell();

