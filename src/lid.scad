
include <constants.scad>

// This was very quickly thrown together, and I definitely could clean it up.
// But I won't right now. I think it'll work.

LID_LENGTH = DISPLAY_LENGTH;
FAN_WIDTH = 30;
RAIL_HEIGHT = 4;

module lid() {
  difference() {
    union() {
      // Main slab
      translate([-WALL_THICKNESS, 0, 0])
        round_prism(
          [BOX_WIDTH + WALL_THICKNESS*2, LID_LENGTH + WALL_THICKNESS, WALL_THICKNESS],
          [BOX_CORNERS[0]+WALL_THICKNESS, BOX_CORNERS[1]+WALL_THICKNESS, 0, 0]
        );

      // Rails
      cube([WALL_THICKNESS, LID_LENGTH - 2, RAIL_HEIGHT]);
      translate([BOX_WIDTH - WALL_THICKNESS, 0, 0]) cube([WALL_THICKNESS, LID_LENGTH - 2, RAIL_HEIGHT]);

      // Cylinders for screw holes
      translate([2, 8, 0]) cylinder(RAIL_HEIGHT, r=2, $fn=24);
      translate([2, DISPLAY_LENGTH - 8, 0]) cylinder(RAIL_HEIGHT, r=2, $fn=24);
      translate([BOX_WIDTH - 2, 8, 0]) cylinder(RAIL_HEIGHT, r=2, $fn=24);
      translate([BOX_WIDTH - 2, DISPLAY_LENGTH - 8, 0]) cylinder(RAIL_HEIGHT, r=2, $fn=24);
    }
    // Window for display
    translate([9, 6, 0]) cube([100, 60, WALL_THICKNESS]);
    // Hole for fan
    translate([117, 20, 0]) round_prism([FAN_WIDTH, FAN_WIDTH, WALL_THICKNESS], [2.5, 2.5, 2.5, 2.5]);

    // Screw holes
    translate([2, 8, 0]) cylinder(RAIL_HEIGHT, r=1, $fn=24);
    translate([2, DISPLAY_LENGTH - 8, 0]) cylinder(RAIL_HEIGHT, r=1, $fn=24);
    translate([BOX_WIDTH - 2, 8, 0]) cylinder(RAIL_HEIGHT, r=1, $fn=24);
    translate([BOX_WIDTH - 2, DISPLAY_LENGTH - 8, 0]) cylinder(RAIL_HEIGHT, r=1, $fn=24);
  }
}

lid();

