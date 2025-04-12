import os
from pathlib import Path
import cairosvg

# Android mipmap sizes (in dp)
sizes = {
    'mipmap-mdpi': 48,      # 1x
    'mipmap-hdpi': 72,      # 1.5x
    'mipmap-xhdpi': 96,     # 2x
    'mipmap-xxhdpi': 144,   # 3x
    'mipmap-xxxhdpi': 192,  # 4x
    'mipmap-anydpi-v26': 108  # Adaptive icon
}

# Create output directories
for size in sizes.keys():
    Path(f'android/app/src/main/res/{size}').mkdir(parents=True, exist_ok=True)

# Convert SVG to PNG for each size
for size_name, size in sizes.items():
    output_file = f'android/app/src/main/res/{size_name}/ic_launcher_foreground.png'
    try:
        cairosvg.svg2png(
            url='assets/icons/app_icon.svg',
            write_to=output_file,
            output_width=size,
            output_height=size
        )
        print(f"Generated {size_name} icon ({size}x{size}px)")
    except Exception as e:
        print(f"Error generating {size_name} icon: {str(e)}")

print("\nIcons generation completed!") 