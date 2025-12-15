# OpenSCAD Design Repository

A collection of parametric OpenSCAD models and tools for 3D printing. This workspace contains design files for various projects, including train tracks, mesh structures, and custom components.

Copilot is used to aid in this repo and in designing things

## 📋 Contents

### Design Files
- **curves.scad** - Parametric curved train track generator with customizable radius, angle, and sleeper density
- **straight.scad** - Straight track sections
- **lego_mesh.scad** - LEGO-compatible mesh structures
- **lego_mesh.json** - Mesh data for LEGO components

### Python Tools
- **generate_stls.py** - Individual STL generator with parameter control for any design
- **batch_generate.py** - Batch generator for design variations
- **GENERATOR_README.md** - Detailed CLI documentation

### Output
- **generated_stls/** - Directory for batch-generated STL files
- Various STL exports from designs

## 🚀 Quick Start

### Requirements
- OpenSCAD 2014+ (https://openscad.org/)
- Python 3.6+ (for batch processing scripts)

### Viewing Designs

1. Open any `.scad` file in OpenSCAD
2. Adjust parameters in the "Customizer" panel (if available)
3. Press `F6` to render or `F7` to preview

### Generating STL Files

**Option 1: Using OpenSCAD GUI**
- Open design file → Design → Render (F6) → File → Export as STL

**Option 2: Using Python CLI (for curves.scad)**
```bash
# Generate specific radius
python3 generate_stls.py -r 40

# Batch generate standard variations
python3 batch_generate.py -o ./output
```

See [GENERATOR_README.md](GENERATOR_README.md) for full CLI documentation.

## 📐 Design Projects

### Train Track Generator (curves.scad)

Parametric curved track with customizable:
- **Radius** - Track curve radius in studs (8mm per stud)
- **Angle** - Segment arc angle in degrees
- **Diverse** - Sleeper/tie density control
- **Configurations** - 4 output types per radius

**Four Output Types:**
1. **ballast_and_buddy** - Base plate with reinforcement
2. **ballast** - Base plate only
3. **track_ballast_and_buddy** - Full track assembly with reinforcement
4. **track_and_ballast** - Full track assembly without reinforcement

### CLI Generator Examples

For detailed CLI options, see [GENERATOR_README.md](GENERATOR_README.md)

```bash
# Generate individual radius with all configurations
python3 generate_stls.py -r 40

# Batch generate standard radii (R24-R120)
python3 batch_generate.py -o ./output

# Custom angle and sleeper density
python3 generate_stls.py -r 40 -a 18 -d 2000

# Generate only specific configuration type
python3 generate_stls.py -r 24 32 -c ballast

# Verbose output with dry-run preview
python3 batch_generate.py --dry-run -v
```

## 📊 Curves.scad Parameters

When editing in OpenSCAD or using CLI generators:

| Parameter | Description | Default | Range |
|-----------|-------------|---------|-------|
| Radius | Track radius in studs (8mm) | 40 | 8-120 |
| SegAng | Segment angle in degrees | 22.5 | 5-90 |
| diverse | Sleeper density (↑ = fewer) | 1800 | 100-3000 |
| full | Full or simplified sleepers | true | - |
| generate_track | Include rails & sleepers | true | - |
| generate_ballast | Include base plate | true | - |
| generate_ballast_buddy | Include reinforcement | true | - |
| name | Text to engrave | "ARON" | text |

## 🖨️ 3D Printing Tips

### General Guidelines
- **FDM printers** work best for these designs
- **Layer height:** 0.2mm (standard), 0.1mm (detailed)
- **Nozzle:** 0.4mm for standard, 0.6mm for faster prints
- **Infill:** 20-30% for ballast, 30-50% for track pieces

### Print Settings by Component
- **Ballast base:** 20% infill, grid pattern, raft recommended
- **Track with sleepers:** 40% infill, 0.15mm layers, tree supports
- **Ballast buddy:** 20% infill, raft for good adhesion

### Post-Processing
- Clean supports and raft carefully
- Sand any rough edges
- Test fit before permanent assembly

## 🛠️ Working with OpenSCAD

### Tips & Tricks
- Use the **Customizer** panel (View → Customizer) for interactive parameter changes
- Press **F5** for preview (fast), **F6** for render (slow, more accurate)
- **Ctrl+Shift+C** copies current view parameters for documentation
- Use comments (`//` and `/* */`) liberally for parameter documentation

### Performance
- Render quality ($fn) affects preview speed - lower for faster iteration
- Complex geometry can slow down rendering - save frequently
- Export to STL for 3D viewer performance testing

### Common Issues
- **Z-fighting** (flickering surfaces) - Check for overlapping geometry
- **Non-manifold geometry** - Missing faces or internal holes
- **Render timeout** - Simplify design or reduce render quality

## 🛠️ Troubleshooting

### OpenSCAD Installation
```bash
# Ubuntu/Debian
sudo apt-get install openscad

# macOS
brew install openscad

# Or download from https://openscad.org/
```

### Python Scripts Issues
```bash
# Check Python version
python3 --version

# Verify OpenSCAD is in PATH
which openscad
```

### STL Generation Problems
- **Timeout:** Increase angle or diverse value
- **Artifacts:** Verify OpenSCAD 2014+ installed, regenerate
- **File too large:** Reduce $fn parameters in .scad file

## 📁 Repository Structure

```
openscad/
├── curves.scad              # Train track design
├── straight.scad            # Straight sections
├── lego_mesh.scad           # LEGO mesh generator
├── lego_mesh.json           # Mesh data
├── generate_stls.py         # Single generator script
├── batch_generate.py        # Batch generator script
├── GENERATOR_README.md      # CLI documentation
├── README.md                # This file
├── generated_stls/          # Output folder for batch runs
└── *.stl                    # Exported STL files
```

## 🎨 Customization Workflow

### To Modify a Design
1. Open `.scad` file in OpenSCAD
2. Edit parameters at the top of the file
3. Press **F6** to render changes
4. Export to STL (File → Export as STL)

### To Add Parameters to Customizer
Add variable declarations at the top with ranges:
```scad
// [General]
Radius = 40; // [8:8:120]
SegAng = 22.5; // [5:45]
```

### For Batch Processing
Update `generate_stls.py` or `batch_generate.py` with your parameter sets

## 📊 Current Projects

- **Train Track System** - Parametric curves and straight sections with ballast
- **LEGO Meshes** - Grid and hexagonal patterns compatible with LEGO
- More projects added as needed

## 💡 Usage Workflow

### One-off Renders
1. Open design in OpenSCAD
2. Adjust parameters via Customizer or editor
3. Render (F6)
4. Export STL

### Batch Processing
```bash
python3 batch_generate.py -o ./output
```

### For Development
- Edit `.scad` file
- Test with OpenSCAD GUI
- Verify output STL quality
- Add to batch script if needed

---

**Last Updated:** December 2025
