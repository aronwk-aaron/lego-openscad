// LEGO-compatible mesh/grid for interlocking studs
// Standard LEGO dimensions

// Parameters
// Distance between stud centers (mm)
stud_spacing = 8;
// Size of square holes (mm)
hole_size = 5;
// Thickness of the mesh plate
mesh_thickness = 0.25;
// Number of rows
mesh_rows = 30;
// Number of columns
mesh_cols = 30;
// Use hexagonal grid instead of rectangular
hexagonal_grid = true;
// Use round holes instead of square (true = round, false = square)
round_holes = true;

// Calculated dimensions for rectangular grid
total_width = mesh_cols * stud_spacing;
total_length = mesh_rows * stud_spacing;

// Hexagonal grid calculations
hex_row_spacing = stud_spacing * sqrt(3) / 2;

module lego_mesh() {
    if (hexagonal_grid) {
        lego_mesh_hexagonal();
    } else {
        lego_mesh_rectangular();
    }
}

module lego_mesh_rectangular() {
    difference() {
        // Base plate
        cube([total_width, total_length, mesh_thickness]);
        
        // Create holes for studs
        for (row = [0:mesh_rows-1]) {
            for (col = [0:mesh_cols-1]) {
                translate([
                    stud_spacing/2 + col * stud_spacing,
                    stud_spacing/2 + row * stud_spacing,
                    -0.1
                ]) {
                    if (round_holes) {
                        cylinder(d=hole_size, h=mesh_thickness+0.2, $fn=32);
                    } else {
                        translate([-hole_size/2, -hole_size/2, 0])
                        cube([hole_size, hole_size, mesh_thickness+0.2]);
                    }
                }
            }
        }
    }
}

module lego_mesh_hexagonal() {
    // Calculate total dimensions for hexagonal grid
    hex_total_width = (mesh_cols + 0.5) * stud_spacing;
    hex_total_length = mesh_rows * hex_row_spacing + stud_spacing;
    
    difference() {
        // Base plate
        cube([hex_total_width, hex_total_length, mesh_thickness]);
        
        // Create holes in hexagonal pattern (extended beyond edges)
        for (row = [-1:mesh_rows]) {
            for (col = [-1:mesh_cols]) {
                // Offset every other row by half a spacing horizontally
                x_offset = (row % 2) * stud_spacing / 2;
                x_pos = col * stud_spacing + stud_spacing / 2 + x_offset;
                y_pos = row * hex_row_spacing + stud_spacing / 2;
                
                translate([x_pos, y_pos, -0.1]) {
                    if (round_holes) {
                        cylinder(d=hole_size, h=mesh_thickness+0.2, $fn=32);
                    } else {
                        translate([-hole_size/2, -hole_size/2, 0])
                        cube([hole_size, hole_size, mesh_thickness+0.2]);
                    }
                }
            }
        }
    }
}

// Render the mesh
lego_mesh();
