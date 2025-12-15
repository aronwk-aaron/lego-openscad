#!/usr/bin/env python3
"""
Batch STL Generator for Model Train Tracks (R24-R120)
Generates optimized files for smaller 3D printers
"""

import subprocess
import sys
from pathlib import Path

# Standard radius range (in studs)
RADII = [24, 32, 40, 48, 56, 64, 72, 80, 88, 96, 104, 112, 120]

# Optimized for smaller 3D printers
# Smaller radii get larger angles, larger radii get smaller angles
# This keeps print bed size reasonable while maintaining good proportions
ANGLE_MAP = {
    24: 22.5,    # Standard angle for smallest radius
    32: 22.5,    # Keep smaller radii at 22.5
    40: 18,      # Step down at R40
    48: 18,
    56: 18,
    64: 15,      # Step down at R64
    72: 15,
    80: 15,
    88: 15,
    96: 11.25,   # Step down at R96 for larger radii
    104: 11.25,
    112: 11.25,
    120: 11.25,
}

# Diverse settings: parametric curve
# V-shaped with minimum at R64 (500), peaks at R24 and R104+ (1800)
# Uses quadratic formula centered at R64
def calculate_diverse(radius):
    """
    Parametric diverse calculation:
    - Quadratic curve with vertex at R64 (minimum: 500)
    - Peaks at R24 and R104+: 1800
    - Caps at 1800 for large radii
    """
    # Quadratic: diverse = a * (radius - 64)^2 + 500
    # Where a = 0.8125 to hit 1800 at radius 24 and 104
    a = 0.8125
    vertex = 64
    minimum = 500
    maximum = 1800
    
    diverse = a * (radius - vertex) ** 2 + minimum
    return min(int(diverse), maximum)

# Generate the diverse map using the parametric function
DIVERSE_MAP = {radius: calculate_diverse(radius) for radius in RADII}

def run_generator(radius: int, angle: float, diverse: int, output_dir: Path = None, verbose: bool = False):
    """Run the STL generator for a specific radius"""
    cmd = [
        "python3",
        "generate_stls.py",
        "-r", str(radius),
        "-a", str(angle),
        "-d", str(diverse),
    ]
    
    if output_dir:
        cmd.extend(["-o", str(output_dir)])
    
    if verbose:
        cmd.append("-v")
    
    if verbose:
        print(f"\n{'='*70}")
        print(f"Generating R{radius}: angle={angle}°, diverse={diverse}")
        print(f"{'='*70}")
    else:
        print(f"Generating R{radius}... ", end="", flush=True)
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=not verbose,
            text=True,
            timeout=600  # 10 minute timeout
        )
        
        if result.returncode == 0:
            print("✓" if not verbose else "")
            return True
        else:
            print("✗" if not verbose else "")
            print(f"Error: {result.stderr}", file=sys.stderr)
            return False
    
    except subprocess.TimeoutExpired:
        print("✗ (timeout)" if not verbose else "")
        print(f"Error: Timeout for R{radius}", file=sys.stderr)
        return False
    except Exception as e:
        print("✗ (error)" if not verbose else "")
        print(f"Error generating R{radius}: {e}", file=sys.stderr)
        return False


def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Batch generate track STLs from R24 to R120",
        epilog="""
Generates optimized files for smaller 3D printers with:
- Variable angles: larger angles for small radii, smaller for large radii
- Optimized diverse: balanced sleeper density for each radius
- All 4 configurations per radius: ballast_and_buddy, ballast, track_ballast_and_buddy, track_and_ballast

Example: python3 batch_generate.py -v
        """
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "-o", "--output-dir",
        type=Path,
        default=Path.cwd(),
        help="Output directory (default: current directory)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be generated without actually generating"
    )
    
    args = parser.parse_args()
    
    if args.dry_run:
        print("Dry run - would generate:")
        print(f"{'Radius':<10} {'Angle':<10} {'Diverse':<10} {'Configs':<30}")
        print("-" * 70)
        for radius in RADII:
            angle = ANGLE_MAP[radius]
            diverse = DIVERSE_MAP[radius]
            configs = "ballast_and_buddy, ballast, track_ballast_and_buddy, track_and_ballast"
            print(f"R{radius:<9} {angle:<10.2f} {diverse:<10} {configs}")
        print(f"\nTotal: {len(RADII)} radii × 4 configs = {len(RADII) * 4} STL files")
        return
    
    print(f"Batch generating track STLs (R24-R120)")
    print(f"Output directory: {args.output_dir.resolve()}")
    print(f"Total radii: {len(RADII)}")
    print(f"Total files: {len(RADII) * 4}\n")
    
    success_count = 0
    failed_radii = []
    
    for radius in RADII:
        angle = ANGLE_MAP[radius]
        diverse = DIVERSE_MAP[radius]
        
        if run_generator(radius, angle, diverse, args.output_dir, args.verbose):
            success_count += 1
        else:
            failed_radii.append(radius)
    
    # Summary
    total_files = len(RADII) * 4
    successful_files = success_count * 4
    
    print(f"\n{'='*70}")
    print(f"Batch Generation Complete")
    print(f"{'='*70}")
    print(f"Radii processed: {success_count}/{len(RADII)}")
    print(f"Files generated: {successful_files}/{total_files}")
    print(f"Output directory: {args.output_dir.resolve()}")
    
    if failed_radii:
        print(f"\nFailed radii: {', '.join([f'R{r}' for r in failed_radii])}")
        sys.exit(1)
    else:
        print("All files generated successfully! ✓")


if __name__ == "__main__":
    main()
