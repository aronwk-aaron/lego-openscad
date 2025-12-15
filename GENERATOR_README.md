# OpenSCAD Curve Track STL Generator

A Python CLI tool to programmatically generate STL files for OpenSCAD train track curves with different configurations.

## Installation

### Requirements
- Python 3.6+
- OpenSCAD (https://openscad.org/)

### Setup
```bash
# Make the script executable
chmod +x generate_stls.py

# Optionally, add to PATH for global access
sudo ln -s "$(pwd)/generate_stls.py" /usr/local/bin/generate_stls
```

## Usage

### Basic Usage
```bash
# Generate all 4 configurations for radius 40, 22.5° angle
python3 generate_stls.py -r 40

# Generate multiple radii
python3 generate_stls.py -r 24 32 40 56 72 88

# Specify custom output directory
python3 generate_stls.py -r 40 -o ./output
```

### Configurations Generated
Each radius generates 4 STL files:

1. **ballast_and_buddy**: Ballast plate with buddy layer
2. **ballast**: Ballast plate only
3. **track_ballast_and_buddy**: Full track with ballast and buddy layers
4. **track_and_ballast**: Full track with ballast (no buddy)

### Advanced Options
```bash
# Custom angle (default: 22.5°)
python3 generate_stls.py -r 40 -a 36.87

# Generate specific configuration only
python3 generate_stls.py -r 40 -c ballast

# Adjust sleeper density (higher = fewer sleepers, default: 1800)
python3 generate_stls.py -r 40 -d 2000

# Verbose output
python3 generate_stls.py -r 40 -v

# Custom curves.scad location
python3 generate_stls.py -r 40 -s /path/to/curves.scad

# Combine options
python3 generate_stls.py -r 24 32 40 -a 22.5 -o ./output -d 1500 -v
```

### Output Files
Generated STL files follow the naming convention: `r{radius}_{config}.stl`

Example output for radius 40:
```
r40_ballast_and_buddy.stl
r40_ballast.stl
r40_track_ballast_and_buddy.stl
r40_track_and_ballast.stl
```

## Parameters

### Command-line Arguments

| Argument | Short | Description | Default |
|----------|-------|-------------|---------|
| --radius | -r | Curve radius in studs (required, can specify multiple) | - |
| --angle | -a | Segment angle in degrees | 22.5 |
| --config | -c | Specific configuration to generate | all |
| --diverse | -d | Sleeper density (higher = fewer sleepers) | 1800 |
| --output-dir | -o | Output directory for STL files | current directory |
| --scad-file | -s | Path to curves.scad file | ./curves.scad |
| --verbose | -v | Enable verbose output | off |

### Diverse Parameter
Controls the number of sleepers along the curve:
- **Higher values**: Fewer sleepers (sparser)
- **Lower values**: More sleepers (denser)
- **Default**: 1800
- **Typical range**: 1000-3000

## Examples

### Generate common model railway radii
```bash
python3 generate_stls.py -r 24 32 40 48 56 64 72 80 88 96
```

### Generate track sample with custom sleeper density
```bash
python3 generate_stls.py -r 40 -a 22.5 -d 1200 -v
```

### Generate to specific output folder with fewer sleepers
```bash
python3 generate_stls.py -r 40 -o ~/3d_models/tracks/ -d 2500
```

### Generate only ballast pieces with dense sleepers
```bash
python3 generate_stls.py -r 24 32 40 -c ballast -d 900 -o ./ballast_only/
```

### Generate track and ballast with very few sleepers
```bash
python3 generate_stls.py -r 56 -c track_and_ballast -d 3000 -v
```

## Troubleshooting

### OpenSCAD not found
```bash
# Check if OpenSCAD is installed
which openscad

# Install on Ubuntu/Debian
sudo apt-get install openscad

# Install on macOS
brew install openscad
```

### Permission Denied
```bash
chmod +x generate_stls.py
```

### Timeout Error
The script has a 5-minute timeout per file. If you hit this:
- Reduce the angle size
- Lower the model complexity in curves.scad

### Getting Help
```bash
python3 generate_stls.py -h
```
