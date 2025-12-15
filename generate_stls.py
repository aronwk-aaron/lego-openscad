#!/usr/bin/env python3
"""
OpenSCAD Curve Track STL Generator
Programmatically generates STL files for different track configurations
"""

import subprocess
import argparse
import sys
from pathlib import Path
from typing import List, Tuple
import shutil

# Define the available configurations
CONFIGURATIONS = {
    "ballast_and_buddy": {
        "generate_track": "false",
        "generate_ballast": "true",
        "generate_ballast_buddy": "true",
    },
    "ballast": {
        "generate_track": "false",
        "generate_ballast": "true",
        "generate_ballast_buddy": "false",
    },
    "track_ballast_and_buddy": {
        "generate_track": "true",
        "generate_ballast": "true",
        "generate_ballast_buddy": "true",
    },
    "track_and_ballast": {
        "generate_track": "true",
        "generate_ballast": "true",
        "generate_ballast_buddy": "false",
    },
}

def check_openscad():
    """Check if OpenSCAD is installed and available"""
    result = subprocess.run(
        ["which", "openscad"],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print("Error: OpenSCAD is not installed or not in PATH", file=sys.stderr)
        print("Please install OpenSCAD from https://openscad.org/", file=sys.stderr)
        sys.exit(1)


def generate_scad_params(radius: int, angle: float, config: str, diverse: int = None) -> str:
    """Generate OpenSCAD parameters for the given configuration"""
    params = CONFIGURATIONS.get(config)
    if not params:
        raise ValueError(f"Unknown configuration: {config}")
    
    param_list = [
        f"-D 'Radius={radius}'",
        f"-D 'SegAng={angle}'",
        f"-D 'generate_track={params['generate_track']}'",
        f"-D 'generate_ballast={params['generate_ballast']}'",
        f"-D 'generate_ballast_buddy={params['generate_ballast_buddy']}'",
    ]
    
    # Add diverse parameter if specified
    if diverse is not None:
        param_list.append(f"-D 'diverse={diverse}'")
    
    param_str = " ".join(param_list)
    return param_str


def generate_stl(
    scad_file: Path,
    output_file: Path,
    radius: int,
    angle: float,
    config: str,
    verbose: bool = False,
    diverse: int = None
) -> bool:
    """Generate a single STL file from the OpenSCAD file"""
    
    params = generate_scad_params(radius, angle, config, diverse)
    
    cmd = f"openscad {params} -o '{output_file}' '{scad_file}'"
    
    if verbose:
        print(f"Generating: {output_file.name}")
        print(f"Command: {cmd}")
    
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout per file
        )
        
        if result.returncode != 0:
            print(f"Error generating {output_file.name}:", file=sys.stderr)
            print(result.stderr, file=sys.stderr)
            return False
        
        if verbose:
            print(f"✓ Successfully generated {output_file.name}")
        
        return True
    
    except subprocess.TimeoutExpired:
        print(f"Error: Timeout generating {output_file.name}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Error generating {output_file.name}: {e}", file=sys.stderr)
        return False


def generate_all_configs(
    scad_file: Path,
    output_dir: Path,
    radius: int,
    angle: float,
    verbose: bool = False,
    diverse: int = None
) -> Tuple[int, int]:
    """Generate all configuration variants for the given radius and angle"""
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    success_count = 0
    total_count = 0
    
    for config in CONFIGURATIONS.keys():
        total_count += 1
        output_file = output_dir / f"r{radius}_{config}.stl"
        
        if generate_stl(scad_file, output_file, radius, angle, config, verbose, diverse):
            success_count += 1
        else:
            print(f"Failed to generate {output_file.name}", file=sys.stderr)
    
    return success_count, total_count


def main():
    parser = argparse.ArgumentParser(
        description="Generate STL files for OpenSCAD track curves",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate all configs for radius 40 with 22.5 degree angle
  python3 generate_stls.py -r 40 -a 22.5
  
  # Generate with verbose output
  python3 generate_stls.py -r 40 -a 22.5 -v
  
  # Generate multiple radii
  python3 generate_stls.py -r 24 32 40 56
  
  # Generate single configuration
  python3 generate_stls.py -r 40 -a 22.5 -c ballast_only
        """
    )
    
    parser.add_argument(
        "-r", "--radius",
        type=int,
        nargs="+",
        required=True,
        help="Curve radius in studs (can specify multiple)"
    )
    parser.add_argument(
        "-a", "--angle",
        type=float,
        default=22.5,
        help="Segment angle in degrees (default: 22.5)"
    )
    parser.add_argument(
        "-c", "--config",
        choices=list(CONFIGURATIONS.keys()),
        help="Specific configuration to generate (if not specified, generates all)"
    )
    parser.add_argument(
        "-o", "--output-dir",
        type=Path,
        default=Path.cwd(),
        help="Output directory for STL files (default: current directory)"
    )
    parser.add_argument(
        "-s", "--scad-file",
        type=Path,
        default=Path(__file__).parent / "curves.scad",
        help="Path to curves.scad file"
    )
    parser.add_argument(
        "-d", "--diverse",
        type=int,
        default=None,
        help="Sleeper density control (higher = fewer sleepers, default: 1800)"
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output"
    )
    
    args = parser.parse_args()
    
    # Validate paths
    if not args.scad_file.exists():
        print(f"Error: SCAD file not found: {args.scad_file}", file=sys.stderr)
        sys.exit(1)
    
    # Check OpenSCAD availability
    check_openscad()
    
    # Generate files
    total_success = 0
    total_generated = 0
    
    for radius in args.radius:
        if args.verbose:
            print(f"\n{'='*60}")
            print(f"Generating STL files for R{radius}, {args.angle}°")
            print(f"{'='*60}")
        
        if args.config:
            # Generate single config
            output_file = args.output_dir / f"r{radius}_{args.config}.stl"
            if generate_stl(
                args.scad_file,
                output_file,
                radius,
                args.angle,
                args.config,
                args.verbose,
                args.diverse
            ):
                total_success += 1
            total_generated += 1
        else:
            # Generate all configs
            success, total = generate_all_configs(
                args.scad_file,
                args.output_dir,
                radius,
                args.angle,
                args.verbose,
                args.diverse
            )
            total_success += success
            total_generated += total
    
    # Summary
    print(f"\n{'='*60}")
    print(f"Generation Complete: {total_success}/{total_generated} files successfully generated")
    print(f"Output directory: {args.output_dir.resolve()}")
    print(f"{'='*60}")
    
    if total_success < total_generated:
        sys.exit(1)


if __name__ == "__main__":
    main()
