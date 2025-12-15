// ============================================================================
// OpenSCAD Curved Train Track Generator
// ============================================================================
// No extra libraries are required and it works under 
//      OpenSCAD 2014 and OpenSCAD 2015.
//
// This file generates parametric curved train track sections with customizable
// radius and angle. The track includes rails, ties, and connection endpoints.
//
// Available standard radius values (in mm):
//1;1.2;1.5;1.6;1.8;2;2.4;2.5;3;3.6;4;4.5;4.8;5;6;7,2;7.5;8;9;10;12,14.4;15,18;20;22.5;
//40;56;72;88;104;120;136;152;168;184;200;216;232;248;264;280;296;312;328;344;360

// ============================================================================
// Main Parameters - Modify these to customize your track
// ============================================================================

// Length of the track segment, 90 degrees is a quarter circle
SegAng = 22.5001;

// Curve radius in Studs (1 Stud = 8mm)
Radius = 40;

// If true, creates full sleepers/ties; if false, creates simplified sleepers
full = true;

// Controls the number of sleepers along the curve (higher = fewer sleepers)
diverse = 1800;

// Enable/disable track generation (rails, sleepers, endpoints)
generate_track = true;

// ============================================================================
// Ballast Plate Parameters
// ============================================================================

// Enable/disable ballast plate generation
generate_ballast = true;

// Enable/disable ballast buddy (extra bottom layer)
generate_ballast_buddy = true;

// Name to engrave on ballast plate
name = "ARON"; 

// ============================================================================
// Internal Constants (do not modify)
// ============================================================================




ballast_thickness = 6.4; // Height: always 6.4mm to align with sleeper tops
ballast_offset_z = -3.2; // Vertical offset: ballast top = -3.2 + 6.4 = 3.2mm (sleeper height)

// ============================================================================
// Rail Profile Module
// ============================================================================
// Creates the cross-sectional profile of a single rail
// This profile gets extruded along the curve to form the rails
module RailProfile() {
  // Define the rail profile shape using a polygon
  // This creates a realistic rail cross-section
  translate([0, 1.5, 0]) polygon(
      points=[
        [1, 4.7],
        [1, 4.5],
        [1.2, 4.5],
        [1.2, 0.4],
        [1.6, -0.7],
        [3, -1.1],
        [3, -1.7],
        [3.9, -1.7],
        [3.9, -4.7],
        [2.6, -4.7],
        [2.6, -4.3],
        [2.5, -4.3],
        [2.5, -2.3],
        [-2.5, -2.3],
        [-2.5, -4.3],
        [-2.6, -4.3],
        [-2.6, -4.7],
        [-3.9, -4.7],
        [-3.9, -1.7],
        [-3, -1.7],
        [-3, -1.1],
        [-1.6, -0.7],
        [-1.2, 0.4],
        [-1.2, 4.5],
        [-1, 4.5],
        [-1, 4.7],
        [-0.1, 4.7],
        [-0.1, 4.5],
        [0.1, 4.5],
        [0.1, 4.7],
        [1, 4.7],
      ], convexity=10
    );
}

// Track gauge: distance between the rails (in mm)
TrakGage = 39.8;

// ============================================================================
// Rail Endpoint Modules
// ============================================================================
// Creates the connection endpoints for the right side of the track
module rail_endpoint_right() {
  off_l = 0.5; // Length offset for adjustment
  off_h = -0.15; // Height offset for adjustment
  // Define the endpoint profile polygon
  poly = [[0, 2], [0, 6], [3.2 + off_h, 6], [3.2 + off_h, 4], [9.4, 4], [9.4, 3.1], [7, 3.1], [4, 2], [3.2 + off_h, 2]];
  // Extrude the polygon to create the 3D endpoint
  translate([0, off_l, 0]) rotate([90, -90, 180]) linear_extrude(8 - off_l) polygon(poly);
}

// Creates the connection endpoints for the left side of the track
module rail_endpoint_left() {
  off_l = 0.5; // Length offset for adjustment
  off_h = 0.515; // Height offset for adjustment
  // Define the endpoint profile polygon
  poly = [[3 + off_h, 8], [3 + off_h, 4], [9.4, 4], [9.4, 3.05], [7, 3.05], [4, 1], [3 + off_h, 1]];
  // Extrude the polygon to create the 3D endpoint
  translate([0, off_l, 0]) rotate([90, -90, 180]) linear_extrude(8 - off_l) polygon(poly);
  // Add support structure underneath
  translate([-1.5, off_l, 0]) cube([8, 1, 3 + off_h], false);
}

// Creates an attachment polygon profile (used for connection features)
module attach_poly(h) {
  off_l = 0.3; // Offset for polygon adjustment
  // Extrude a trapezoid-like polygon for attachment features
  linear_extrude(h) polygon([[0 - off_l, 0], [2 - off_l, 1.9], [6 + off_l, 1.9], [8 + off_l, 0]]);
}

// ============================================================================
// Attachment Module
// ============================================================================
// Creates the connection base with holes for joining track pieces
// This forms the baseplate with mounting holes at regular intervals
module attach(l) {
  off = 0.1; // Small offset for precise fitting
  union() {
    difference() {
      // Build the base structure with cylinders for mounting posts
      union() {
        // Create mounting posts at regular intervals
        translate([-4, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([-8, -4, 0]) cube([8.3, 8, 3.2], false);
        translate([12, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([20, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([28, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([36, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([52, 0, 3]) cylinder(d=4.9, h=2, $fn=50);
        translate([48, -4, 0]) cube([8, 8, 3.2], false);
        // Add thin layer if not in full mode (simplified version)
        if (!full) translate([7.5, 0, 0]) cube([33, 10, 0.4], false);
        // Central support structure
        translate([8, 0, 0]) cube([33, 3.2, 3.2], false);
        // Create connection features with cutouts
        difference() {
          translate([8.2, -4, 0]) cube([35.6, 8, 3.2], false);
          translate([12, -4.11, -0.5]) attach_poly(4); // Subtract attachment shape
        }
        // Create tapered connector feature
        difference() {
          union() {
            translate([16, -2.2, 0]) cylinder(3.2, 1, 1, false, $fn=80);
            translate([16, -4, 0]) cylinder(3.2, 1.9 - off, 1.9 + off, false, $fn=80);
          }
          translate([16, -4, -0.5]) cylinder(4, 1, 1, false, $fn=80); // Hollow center
        }
        translate([28, -3.4, 0]) mirror([0, 1, 0]) attach_poly(3.2); // Mirror attachment
      }
      // Create tapered hole for connection
      translate([32, -3.8, -0.5]) cylinder(4, 2.1 + off, 2.1 - off, false, $fn=80);
      // Subtract mounting holes at each post location
      translate([-4, 0, 0]) translate([-2.5, -2.5, -1]) cube([5, 5, 3.2], false);
      translate([12, 0, 0]) {
        translate([-2.5, -2.5, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([-2.5, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cylinder(d=5, h=3.2, $fn=50);
      }
      translate([20, 0, 0]) {
        translate([0, -2.5, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([-2.5, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cylinder(d=5, h=3.2, $fn=50);
      }
      translate([28, 0, 0]) {
        translate([-2.5, -2.5, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([-2.5, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cylinder(d=5, h=3.2, $fn=50);
      }
      translate([36, 0, 0]) {
        translate([0, -2.5, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([-2.5, 0, -1]) cube([2.5, 2.5, 3.2], false);
        translate([0, 0, -1]) cylinder(d=5, h=3.2, $fn=50);
      }
      translate([52, 0, -1]) translate([-2.5, -2.5, 0]) cube([5, 5, 3.2], false);
    }
  }
}

// ============================================================================
// Full Endpoint Assembly
// ============================================================================
// Combines left and right rail endpoints with attachment base
module full_endpoint() {
  translate([0, -8, 0]) rail_endpoint_left();
  translate([40, -8, 0]) rail_endpoint_right();
  attach(8); // Add the connection base
}

// ============================================================================
// Curved Rail Module
// ============================================================================
// Creates the actual curved rails by extruding the rail profile around a curve
// Parameters:
//   CurveRad: Radius of the curve
//   CurveSegAng: Angle of the curved segment in degrees
module CurvedRail(CurveRad, CurveSegAng) {
  // Use rotate_extrude to create the curved rails
  // Note: angle parameter does not work for pre-2016 versions of OpenSCAD
  rotate_extrude(angle=CurveSegAng, convexity=10, $fn=9 * CurveRad) {
    // Position the two rails at the correct track gauge distance
    // Left rail
    translate([-0.5 * TrakGage - 0.125 + CurveRad, 0, 0]) RailProfile();
    // Right rail
    translate([0.5 * TrakGage + 0.125 + CurveRad, 0, 0]) RailProfile();
  }
}

// ============================================================================
// Barreau Module (Sleepers/Ties)
// ============================================================================
// Creates the cross-ties (sleepers) that go between the rails
// Supports two modes: full (detailed) and simplified
// simplified_bottom: if true, only create top geometry (for fused ballast+track printing)
module barreau(simplified_bottom = false) {
  // Full mode: creates detailed sleepers with mounting holes
  if (full) {
    skip = 0.3;
    translate([-16, 0, 0]) {
      if (simplified_bottom) {
        // Only the top structure, no underside cutouts
        union() {
          translate([-8, -8, 0]) cube([8 + skip, 16, 3.2], false);
          translate([-4, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([12, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([20, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([28, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([36, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([52, -4, 3]) cylinder(d=4.9, h=2, $fn=50);

          translate([8 - skip, -8, 0]) cube([32 + (2 * skip), 16, 3.2], false);

          translate([-4, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([12, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([20, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([28, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([36, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
          translate([52, 4, 3]) cylinder(d=4.9, h=2, $fn=50);

          translate([48 - skip, -8, 0]) cube([8 + skip, 16, 3.2], false);
        }
      } else {
        // Full detailed sleeper with underside cutouts
        difference() {
          union() {
            translate([-8, -8, 0]) cube([8 + skip, 16, 3.2], false);
            translate([-4, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([12, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([20, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([28, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([36, -4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([52, -4, 3]) cylinder(d=4.9, h=2, $fn=50);

            translate([8 - skip, -8, 0]) cube([32 + (2 * skip), 16, 3.2], false);

            translate([-4, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([12, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([20, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([28, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([36, 4, 3]) cylinder(d=4.9, h=2, $fn=50);
            translate([52, 4, 3]) cylinder(d=4.9, h=2, $fn=50);

            translate([48 - skip, -8, 0]) cube([8 + skip, 16, 3.2], false);
          }
          translate([-6.5, -6.5, -1]) cube([5, 5, 3.2], false);
          translate([9, -6.5, -1]) cube([30, 5, 3.2], false);
          translate([49.5, -6.5, -1]) cube([5, 5, 3.2], false);

          translate([-6.5, 1.5, -1]) cube([5, 5, 3.2], false);
          translate([9, 1.5, -1]) cube([30, 5, 3.2], false);
          translate([49.5, 1.5, -1]) cube([5, 5, 3.2], false);
        }
      }
    }
  } else {
    // Simplified mode: creates a simple rectangular sleeper
    translate([-9.5, 0, 0]) cube([35, 6, 1.5], false);
  }
}

// ============================================================================
// Ballast Plate Module
// ============================================================================
// Creates a curved ballast plate that spans the full track length
// Parameters:
//   CurveRad: Radius of the curve (matches the track radius)
//   CurveSegAng: Angle of the curved segment in degrees
//   with_track: If true, skip sleeper cutouts (for combined printing)
module BallastPlate(CurveRad, CurveSegAng, with_track = false, skip_text = false) {
  // Pre-calculate sleeper positions for reuse
  temp = round(CurveRad * CurveSegAng / diverse);
  b = CurveSegAng / temp;
  
  // Define variables used throughout the module
  ballast_top_width = 64; // Top layer width (matches sleeper extent)
  ballast_mid_width = 80; // Middle layer width
  ballast_bottom_width = 96; // Bottom layer width (extends 8mm more on each side)
  edge_wall = 4; // Wall thickness on each side
  cutout_radial_width = 80 - 2 * edge_wall; // Radial extent of cutout (72mm)
  tangential_inset = 4; // Small inset from the tangential edge
  cutout_depth = 2.0; // Deep enough for LEGO studs
  // Create curved ballast base with rail assembly cutouts and stepped edges
  union() {
    difference() {
      union() {
        // Main ballast body with stepped profile
        rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad) {
        // Create ballast profile with stepped edges
        // Top section at 64mm width (full thickness: 6.4mm)
        translate([CurveRad - ballast_top_width/2, 0, 0])
          square([ballast_top_width, ballast_thickness]);
        // Middle stepped edge (half thickness: 3.2mm, width 80mm)
        translate([CurveRad - ballast_mid_width/2, 0, 0])
          square([ballast_mid_width/2 - ballast_top_width/2 + 4, ballast_thickness / 2]);
        translate([CurveRad + ballast_top_width/2, 0, 0])
          square([ballast_mid_width/2 - ballast_top_width/2, ballast_thickness / 2]);
      }
      }
      
      // Cut text into the bottom level at the start showing the radius
      // Skip text if ballast buddy is being generated separately (text goes on buddy instead)
      if (!skip_text) {
        // Positioned to avoid the antistud cutout and sleeper projection areas
        // Place it on the inside of the curve between the cutout edge and the first sleeper position
        rotate([0, 0, CurveSegAng/2]) {
          translate([CurveRad - 30, 0, -0.1])
            rotate([0, 0, -90])
              mirror([1, 0, 0])
                linear_extrude(height = 1.0)
                  text(str("R", round(CurveRad/8)), size=8, font="Liberation Sans:style=Bold", halign="center", valign="center");
        }      
        // Cut "ARON-TRACKS" text on the outer curve of the bottom level
        rotate([0, 0, CurveSegAng/2]) {
          translate([CurveRad + 28, 0, -0.1])
            rotate([0, 0, -90])
              mirror([1, 0, 0])
                linear_extrude(height = 1.0)
                  text(str(name, "-TRACKS"), size=6, font="Liberation Sans:style=Bold", halign="center", valign="center");
        }
      }      
      // Use top-down projection of track to remove material from ballast (top half only)
    intersection() {
      // Only affect the top half of the ballast in the top width area
      translate([0, 0, ballast_thickness / 2]) {
        rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad) {
          translate([CurveRad - ballast_top_width/2, 0, 0])
            square([ballast_top_width, ballast_thickness / 2 + 10]);
        }
      }
      
      // Project track geometry and extrude it
      translate([0, 0, -10]) {
        linear_extrude(height = ballast_thickness + 20) {
          projection(cut = false) {
            // Project the rail assembly from above
            translate([0, 0, 3.2 - ballast_offset_z]) CurvedRail(CurveRad, CurveSegAng);
            
            // Project the start endpoint
            rotate([0, 0, 0]) 
              translate([CurveRad - 0.25 - 24, 4, -ballast_offset_z]) 
                full_endpoint();
            
            // Project the end endpoint
            rotate([0, 0, CurveSegAng]) 
              translate([CurveRad - 0.25 + 24.5, -4, -ballast_offset_z]) 
                rotate([0, 0, 180]) 
                  full_endpoint();
            
            // Project all sleepers from above
            if (temp > 1) {
              for (i = [1:temp - 1]) {
                rotate([0, 0, (i * b)]) 
                  translate([CurveRad - 0.25 - 7.75, 0, -ballast_offset_z]) 
                    barreau();
              }
            }
          }
          
          // Add extensions at the very edges to remove round attachment point nubs
          // Extension at start edge (before the curve begins) - extend slightly past top layer width
          extension_width = ballast_top_width + 8; // 4mm extra on each side
          translate([CurveRad - extension_width/2, -4, 0])
            square([extension_width, 12]);
          
          // Extension at end edge (after the curve ends) - extend slightly past top layer width
          rotate([0, 0, CurveSegAng])
            translate([CurveRad - extension_width/2, -8, 0])
              square([extension_width, 24]);
        }
      }
    }
    
    // Remove inner stepped edge only at top level where track projection cuts away surface
    // This prevents a thin wall on the inside radius at the top of the ballast
	translate([0, 0, ballast_thickness / 2]) {
      rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad) {
        translate([CurveRad - 80/2, 0, 0])
          square([80/2 - ballast_top_width/2 + 0.196, ballast_thickness / 2 + 1]);
      }
    }
    
    // Remove outer stepped edge at the tangential ends of the plate (start and end)
    // Cut at start
    translate([CurveRad + ballast_top_width/2, -5, ballast_thickness / 2])
      cube([80/2 - ballast_top_width/2 + 0.5, 5, ballast_thickness / 2 + 1]);
    
    // Cut at end
    rotate([0, 0, CurveSegAng])
      translate([CurveRad + ballast_top_width/2, -8, ballast_thickness / 2])
        cube([80/2 - ballast_top_width/2 + 0.5, 16, ballast_thickness / 2 + 1]);
        
    // Add cutout geometry on underside of ballast
    // Single rectangular strip at start and end for stud-locking
    // Span almost full width with 0.5mm padding on each side to fit on 1x10 LEGO plate
    
    // Cutout at the start
    rotate([0, 0, 0]) {
      translate([CurveRad - (80 - 2.4)/2, tangential_inset - 2.4, -0.1])
        cube([80 - 2.4, 4.8, cutout_depth]);
    }
    
    // Cutout at the end
    rotate([0, 0, CurveSegAng]) {
      translate([CurveRad - (80 - 2.4)/2, -tangential_inset - 2.4, -0.1])
        cube([80 - 2.4, 4.8, cutout_depth]);
    }
    
    // Cutouts between sleepers for two rows of studs (16mm tangential width)
    // cutout_tangential_width = 16; // Width for 2-wide LEGO plate (2 studs)
    // if (temp > 2) {
    //   for (i = [2:temp - 3]) {
    //     // Position at midpoint between sleepers (skip first two and last two to avoid endpoints)
    //     mid_angle = (i + 0.5) * b;
    //     rotate([0, 0, mid_angle]) {
    //       translate([CurveRad - cutout_radial_width/2, -cutout_tangential_width/2, -0.1])
    //         cube([cutout_radial_width, cutout_tangential_width, cutout_depth]);
    //     }
    //   }
    // }
    
    // Project sleepers down to remove material from bottom half (only between rails)
    // Skip this when generating with track, as they'll be fused together
    if (!with_track) {
      intersection() {
        // Limit to the area between the rails
        rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad) {
          translate([CurveRad - TrakGage/2, -TrakGage/2, 0])
            square([TrakGage, TrakGage]);
        }
        
        // Project sleepers
        translate([0, 0, -10]) {
          linear_extrude(height = ballast_thickness / 2 + 10) {
            projection(cut = false) {
              // Project all sleepers from above
              if (temp > 1) {
                for (i = [1:temp - 1]) {
                  rotate([0, 0, (i * b)]) 
                    translate([CurveRad - 0.25 - 7.75, 0, -ballast_offset_z]) 
                      barreau();
                }
              }
            }
          }
        }
      }
    }
  }
  
  // Plate-based antistuds protruding from bottom (hollow tubes for LEGO compatibility)
  // Skip if ballast buddy is being generated (buddy has its own antistuds)
  if (!generate_ballast_buddy) {

    // At the start - positioned for 1x10 LEGO plate (9 antistuds between 10 studs)
    rotate([0, 0, 0]) {
      for (x_pos = [-32, -24, -16, -8, 0, 8, 16, 24, 32]) {
        translate([CurveRad + x_pos, tangential_inset, -0.1])
          difference() {
            cylinder(d=3.2, h=3.3, $fn=24);
            translate([0, 0, -0.01])
              cylinder(d=1.5, h=1.6, $fn=24);
          }
      }
    }
    
    // At the end
    rotate([0, 0, CurveSegAng]) {
      for (x_pos = [-32, -24, -16, -8, 0, 8, 16, 24, 32]) {
        translate([CurveRad + x_pos, -tangential_inset, -0.1])
          difference() {
            cylinder(d=3.2, h=3.3, $fn=24);
            translate([0, 0, -0.01])
              cylinder(d=1.5, h=1.6, $fn=24);
          }
      }
    }
  }
  
  // Antistuds in cutouts between sleepers (one row down the middle with brick-style antistuds)
//   if (temp > 2) {
//     for (i = [2:temp - 3]) {
//       mid_angle = (i + 0.5) * b;
//       rotate([0, 0, mid_angle]) {
//         for (x_pos = [-28, -20, -12, -4, 4, 12, 20, 28]) {
//           translate([CurveRad + x_pos, 0, -0.1])
//             difference() {
//               cylinder(d=6.4, h=1.6, $fn=24);
//               translate([0, 0, -0.01])
//                 cylinder(d=4.8, h=1.62, $fn=24);
//             }
//         }
//       }
//     }
//   }
  
  // Add studs on top of ballast plate along outer edge
  // Calculate outer radius position (outer edge of ballast)
  outer_radius = CurveRad + 80/2 - 4; // Position 4mm from outer edge
  
  // Calculate number of studs based on arc length at outer radius
  arc_length = outer_radius * CurveSegAng * 3.14159 / 180;
  num_studs = floor(arc_length / 8); // 8mm spacing between studs
  stud_angle_spacing = CurveSegAng / num_studs;
  
  // Calculate angle inset based on physical distance (4mm from edge)
  // This ensures consistent behavior across different radii and segment angles
  inset_distance = 4; // mm from edge
  angle_inset = inset_distance / outer_radius * 180 / 3.14159;
  
  // Place studs along the outer curve at the top of the bottom half
  for (i = [0:num_studs - 1]) {
    stud_angle = angle_inset + i * stud_angle_spacing;
    rotate([0, 0, stud_angle]) {
      translate([outer_radius, 0, ballast_thickness / 2]) {
        cylinder(d=4.8, h=1.8, $fn=32);
      }
    }
  }
  
  // Add studs on top of ballast plate along inner edge
  // Calculate inner radius position (inner edge of ballast)
  inner_radius = CurveRad - 80/2 + 4; // Position 4mm from inner edge
  
  // Calculate number of studs based on arc length at inner radius
  arc_length_inner = inner_radius * CurveSegAng * 3.14159 / 180;
  num_studs_inner = floor(arc_length_inner / 8); // 8mm spacing between studs
  stud_angle_spacing_inner = CurveSegAng / num_studs_inner;
  
  // Calculate angle inset based on physical distance (4mm from edge)
  angle_inset_inner = inset_distance / inner_radius * 180 / 3.14159;
  
  // Place studs along the inner curve at the top of the bottom half
  for (i = [0:num_studs_inner - 1]) {
    stud_angle_inner = angle_inset_inner + i * stud_angle_spacing_inner;
    rotate([0, 0, stud_angle_inner]) {
      translate([inner_radius, 0, ballast_thickness / 2]) {
        cylinder(d=4.8, h=1.8, $fn=32);
      }
    }
  }
  
  // Add studs on top level of ballast plate between sleepers (outer edge only)
  // Calculate dynamically based on available space with proper inset
  outer_top_radius = CurveRad + ballast_top_width/2 - 4; // Position 4mm from outer edge
  
  // Place studs dynamically between each pair of sleepers on the outer edge
  for (i = [1:temp]) {
    sleeper_angle = i * b;
    prev_sleeper_angle = (i - 1) * b;
    
    // Calculate arc length between sleepers at outer top radius
    arc_between_sleepers_outer = outer_top_radius * b * 3.14159 / 180;
    
    // Calculate number of studs that fit with proper clearance to prevent overhang
    // Need 6mm sleeper clearance + 2.4mm stud radius = 8.4mm per side
    available_length_outer = arc_between_sleepers_outer - 16.8; // 8.4mm margin on each side
    // Number of studs: we need 4.8mm for first stud, then 8mm for each additional
    num_studs_between_outer = max(0, floor((available_length_outer + 3.2) / 8));
    
    if (num_studs_between_outer > 0) {
      // Center the studs in the arc between sleepers
      mid_angle_outer = (prev_sleeper_angle + sleeper_angle) / 2;
      // Calculate the angular span between stud centers (not including stud radius)
      total_angle_span_outer = (num_studs_between_outer - 1) * 8 / outer_top_radius * 180 / 3.14159;
      stud_spacing_angle_outer = 8 / outer_top_radius * 180 / 3.14159;
      
      for (j = [0:num_studs_between_outer - 1]) {
        stud_angle = mid_angle_outer - total_angle_span_outer / 2 + j * stud_spacing_angle_outer;
        
        rotate([0, 0, stud_angle]) {
          translate([outer_top_radius, 0, ballast_thickness]) {
            cylinder(d=4.8, h=1.8, $fn=32);
          }
        }
      }
    }
  }
  }
  
  // Add studs on top level of ballast plate between sleepers (inner edge)
  // Calculate dynamically based on available space, with inset to prevent overhang
  inner_top_radius = CurveRad - ballast_top_width/2 + 4; // Position 4mm from inner edge
  
  // Place studs dynamically between each pair of sleepers on the inner edge
  for (i = [1:temp]) {
    sleeper_angle = i * b;
    prev_sleeper_angle = (i - 1) * b;
    
    // Calculate arc length between sleepers at inner top radius
    arc_between_sleepers = inner_top_radius * b * 3.14159 / 180;
    
    // Calculate number of studs that fit with proper clearance to prevent overhang
    // Need 6mm sleeper clearance + 2.4mm stud radius = 8.4mm per side
    available_length = arc_between_sleepers - 16.8; // 8.4mm margin on each side
    // Number of studs: we need 4.8mm for first stud, then 8mm for each additional
    num_studs_between = max(0, floor((available_length + 3.2) / 8));
    
    if (num_studs_between > 0) {
      // Center the studs in the arc between sleepers
      mid_angle_inner = (prev_sleeper_angle + sleeper_angle) / 2;
      // Calculate the angular span between stud centers (not including stud radius)
      total_angle_span_inner = (num_studs_between - 1) * 8 / inner_top_radius * 180 / 3.14159;
      stud_spacing_angle = 8 / inner_top_radius * 180 / 3.14159;
      
      for (j = [0:num_studs_between - 1]) {
        stud_angle = mid_angle_inner - total_angle_span_inner / 2 + j * stud_spacing_angle;
        
        rotate([0, 0, stud_angle]) {
          translate([inner_top_radius, 0, ballast_thickness]) {
            cylinder(d=4.8, h=1.8, $fn=32);
          }
        }
      }
    }
  }
  
  // Add studs on the ballast plate between the rails (between sleepers)
  // Dynamically place 1 or 2 rows based on available tangential space
  for (i = [1:temp]) {
    sleeper_angle = i * b;
    prev_sleeper_angle = (i - 1) * b;
    mid_angle = (prev_sleeper_angle + sleeper_angle) / 2;
    
    // Calculate tangential arc length at this radius
    tangential_arc_length = CurveRad * b * 3.14159 / 180;
    
    // Determine if we have space for 2 rows (need at least 32mm for 2 rows with proper spacing)
    use_two_rows = tangential_arc_length >= 32;
    
    // Place studs in grid between rails
    // Radial positions: -12, -4, 4, 12 (4 positions at 8mm intervals)
    for (x_offset = (use_two_rows ? [-4, 4] : [0])) {
      for (y_offset = [-12, -4, 4, 12]) {
        // Calculate angle offset for tangential position
        tangential_offset_angle = x_offset / CurveRad * 180 / 3.14159;
        stud_angle = mid_angle + tangential_offset_angle;
        
        rotate([0, 0, stud_angle]) {
          translate([CurveRad + y_offset, 0, ballast_thickness]) {
            cylinder(d=4.8, h=1.8, $fn=32);
          }
        }
      }
    }
  }
}

// ============================================================================
// Ballast Buddy Module
// ============================================================================
// Creates an extra bottom layer for the ballast plate
// Parameters:
//   CurveRad: Radius of the curve (matches the track radius)
//   CurveSegAng: Angle of the curved segment in degrees
//   temp: Number of sleeper positions
//   b: Angle between each sleeper
module BallastBuddy(CurveRad, CurveSegAng, temp, b, with_track = false) {
  ballast_bottom_width = 96; // Bottom layer width
  
  color("Red") {
    // Bottom layer geometry
    difference() {
      translate([0, 0, -ballast_thickness / 4]) {
        rotate_extrude(angle = CurveSegAng, convexity = 10, $fn = 9*CurveRad) {
          translate([CurveRad - ballast_bottom_width/2, 0, 0])
            square([ballast_bottom_width, ballast_thickness / 4]);
        }
      }
      
      // Add inlaid text embossing on bottom of buddy when both ballast and track are generated
      if (with_track) {
        // Cut text showing the radius on the inside
        rotate([0, 0, CurveSegAng/2]) {
          translate([CurveRad - 30, 0, -ballast_thickness/4 - 0.1])
            rotate([0, 0, -90])
              mirror([1, 0, 0])
                linear_extrude(height = 1.0)
                  text(str("R", round(CurveRad/8)), size=8, font="Liberation Sans:style=Bold", halign="center", valign="center");
        }
        // Cut brand name text on the outside
        rotate([0, 0, CurveSegAng/2]) {
          translate([CurveRad + 28, 0, -ballast_thickness/4 - 0.1])
            rotate([0, 0, -90])
              mirror([1, 0, 0])
                linear_extrude(height = 1.0)
                  text(str(name, "-TRACKS"), size=6, font="Liberation Sans:style=Bold", halign="center", valign="center");
        }
      }
    }
    
    // Add studs on outer edge of bottom layer (96mm width level)
    translate([0, 0, -ballast_thickness / 4]) {
      outer_bottom_radius = CurveRad + ballast_bottom_width/2 - 4; // 4mm inset from edge
      
      // Calculate total arc length and number of studs
      total_arc_length = outer_bottom_radius * CurveSegAng * 3.14159 / 180;
      available_arc = total_arc_length - 8;
      num_studs = floor(available_arc / 8) + 1;
      
      if (num_studs > 1) {
        // Calculate dynamic spacing to fit perfectly from start to end
        stud_spacing_arc = available_arc / (num_studs - 1);
        start_angle = 4 / outer_bottom_radius * 180 / 3.14159;
        for (i = [0:num_studs-1]) {
          stud_angle = start_angle + (i * stud_spacing_arc) / outer_bottom_radius * 180 / 3.14159;
          
          rotate([0, 0, stud_angle]) {
            translate([outer_bottom_radius, 0, ballast_thickness / 4]) {
              cylinder(d=4.8, h=1.8, $fn=32);
            }
          }
        }
      }
    }
    
    // Add studs on inner edge of bottom layer (96mm width level)
    translate([0, 0, -ballast_thickness / 4]) {
      inner_bottom_radius = CurveRad - ballast_bottom_width/2 + 4; // 4mm inset from edge
      
      // Calculate total arc length and number of studs
      total_arc_length = inner_bottom_radius * CurveSegAng * 3.14159 / 180;
      available_arc = total_arc_length - 8;
      num_studs = floor(available_arc / 8) + 1;
      
      if (num_studs > 1) {
        // Calculate dynamic spacing to fit perfectly from start to end
        stud_spacing_arc = available_arc / (num_studs - 1);
        start_angle = 4 / inner_bottom_radius * 180 / 3.14159;
        for (i = [0:num_studs-1]) {
          stud_angle = start_angle + (i * stud_spacing_arc) / inner_bottom_radius * 180 / 3.14159;
          
          rotate([0, 0, stud_angle]) {
            translate([inner_bottom_radius, 0, ballast_thickness / 4]) {
              cylinder(d=4.8, h=1.8, $fn=32);
            }
          }
        }
      }
    }
  }
}

// ============================================================================
// Main Module
// ============================================================================
// Assembles the complete curved track section
// Parameters:
//   CurveRad: Radius of the curve (gets multiplied by 8)
//   CurveSegAng: Angle of the curved segment in degrees
//   barreau: Module reference for creating sleepers
module main(CurveRad, CurveSegAng, barreau) {
  // Pre-calculate sleeper positions for ballast buddy
  temp = round(CurveRad * 8 * CurveSegAng / diverse);
  b = CurveSegAng / temp;
  
  translate([-CurveRad * 8, 0, 0]) intersection() {
      union() {
        if (generate_ballast_buddy) {
          color("Red")
            translate([0, 0, ballast_offset_z])
              BallastBuddy(CurveRad*8, CurveSegAng, temp, b, generate_ballast);
        }


        // Generate ballast plate if enabled (spans full track length)
        if (generate_ballast) {
          color("Gray")
            translate([0, 0, ballast_offset_z])
              BallastPlate(CurveRad*8, CurveSegAng, generate_track && generate_ballast, generate_ballast_buddy);
        }
        
        // Generate track components if enabled
        if (generate_track) {
          color("DarkSlateGray") {
          // Create the curved rails and trim the ends
          difference() {
          // Create the curved rails
          translate([0, 0, 3.2]) CurvedRail(CurveRad * 8, CurveSegAng);
          // Trim the start of the curve
          rotate([0, 0, 0]) translate([CurveRad * 8 - 0.25 - 40, 0, 0]) cube([80, 4, 20]);
          // Trim the end of the curve
          rotate([0, 0, CurveSegAng]) translate([CurveRad * 8 - 0.25 + 40, 0, 0]) rotate([0, 0, 180]) cube([80, 4, 20]);
        }
        // Add the end pads (connection endpoints)
        difference() {
          // Add endpoint at the start of the curve
          rotate([0, 0, 0]) translate([CurveRad * 8 - 0.25 - 24, 4, 0]) full_endpoint();
          // Add text label showing radius and length (only in simplified mode)
          if (!full)
            translate([CurveRad * 8 - 0.25, 11, 0]) linear_extrude(2) text(str("R", CurveRad, " L", CurveSegAng), size=4, font="Helvetica:style=Bold", halign="center", valign="center");
        }
        // Add endpoint at the end of the curve
        rotate([0, 0, CurveSegAng]) translate([CurveRad * 8 - 0.25 + 24.5, -4, 0]) rotate([0, 0, 180]) full_endpoint();
        // Calculate and display arc length (in console)
        echo((CurveSegAng * 2 * 3.14 * CurveRad * 8 + 64) / 360);
        // Distribute sleepers along the curve
        {
          // Calculate number of sleepers based on curve parameters
          temp = round(CurveRad * 8 * CurveSegAng / diverse);

          // Calculate angle between each sleeper
          b = CurveSegAng / temp;
          // Place sleepers at regular intervals along the curve
          if (temp > 1)
            for (i = [1:temp - 1]) {
              // Rotate and position each sleeper
              rotate([0, 0, (i * b)]) translate([CurveRad * 8 - 0.25 - 7.75, 0, 0]) barreau(generate_ballast && generate_track);
            }
        }
        // Add fill geometry under rails when both track and ballast are generated together
        if (generate_track && generate_ballast) {
          color("DarkSlateGray") {
            // Inset from endpoints by 1.25 degrees on each side
            rotate([0, 0, 1.25]) {
              rotate_extrude(angle=max(0, CurveSegAng - 2.5), convexity=10, $fn=9 * CurveRad * 8) { 
                // Create a solid rectangle filling the space between the rails
                // positioned so top aligns with top of ballast at z=3.2
                // Height matches ballast plate thickness (6.4mm)
                // Width matches top ballast plate (64mm)
                translate([-32 + CurveRad * 8, -2.3, 0]) square([64, 5.4]);
              }
            }
          }
        }
        } // End of color for track
        
        } // End of generate_track conditional
      }
    }
}

// ============================================================================
// Example Track Sections (commented out)
// ============================================================================
// Uncomment any of these lines to generate different track configurations
// Format: main(Radius, Angle)
// R = Radius value, L = Length (angle)

//%translate([-384,0,0]) rotate([0,0,0]) main(24,45);//R24 L45
//#%translate([-320,0,0]) rotate([0,0,0]) main(32,SegAng);
//translate([-256,0,0]) rotate([0,0,0]) main(40,22.5);//R40 L22.5
//%translate([-256,0,0]) rotate([0,0,0]) main(40,36.87);//R40 for switch
//#%translate([-192,0,0]) rotate([0,0,0]) main(48,SegAng);
//translate([-128,0,0]) rotate([0,0,0]) main(56,18);//R56 L18
//%translate([-64,32*8,0]) rotate([0,0,21])mirror([1,0,0]) main(56,21);//R56 for switch
//translate([-128,0,0]) mirror([0,0,0]) main(248-16,8);

// ============================================================================
// Active Track Generation
// ============================================================================
// This line generates the track using the parameters set at the top of the file
translate([0, 0, 0]) rotate([0, 0, 0]) main(Radius, SegAng);
//#%translate([64,0,0]) rotate([0,0,0]) main(80,SegAng);
//%translate([128,0,0]) rotate([0,0,0]) main(88,11.25);//R88 L11.25
//#%translate([192,0,0]) rotate([0,0,0]) main(96,SegAng);
//%translate([0,0,0]) rotate([0,0,0]) main(104,11.25);//R104 L11.25
//#%translate([320,0,0]) rotate([0,0,0]) main(112,SegAng);
//%translate([384,0,0]) rotate([0,0,0]) main(120,11.25);//R120 L11.25
