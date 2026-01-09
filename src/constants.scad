
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
RPI_LENGTH = 56.50;
RPI_HOLE_HEIGHT = RPI_BOTTOM_CLEARANCE + RPI_PCB_THICKNESS;

BOX_WIDTH = BATTERY_WIDTH;
BOX_LENGTH = BATTERY_LENGTH + RPI_LENGTH;
BOX_HEIGHT = BATTERY_THICKNESS + KEYBOARD_THICKNESS;
BOX_DIMENSIONS = [BOX_WIDTH, BOX_LENGTH, BOX_HEIGHT];
BOX_CORNERS = [1.5, 1.5, 6, 8];

DISPLAY_WIDTH = 106;
DISPLAY_LENGTH = 68;
DISPLAY_SUPPORT_RAD = 3;

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

