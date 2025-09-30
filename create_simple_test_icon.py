#!/usr/bin/env python3
"""
Create a simple solid color test icon to debug the icon issue
"""

from PIL import Image, ImageDraw
import os

def create_simple_test_icon():
    # Create a simple solid blue icon
    size = 1024
    img = Image.new('RGB', (size, size), color='#007AFF')  # iOS blue
    draw = ImageDraw.Draw(img)
    
    # Add a simple white circle in the center
    margin = 200
    draw.ellipse([margin, margin, size-margin, size-margin], fill='white')
    
    # Add a simple "L" in the center
    try:
        # Try to use a built-in font
        from PIL import ImageFont
        font_size = 400
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        # Fallback to default font
        font = None
    
    # Calculate text position (centered)
    text = "L"
    if font:
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
    else:
        text_width, text_height = 200, 200
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    draw.text((x, y), text, fill='#007AFF', font=font)
    
    # Save the icon
    output_path = "lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    img.save(output_path, "PNG")
    
    print(f"✅ Created simple test icon: {output_path}")
    print(f"   Size: {img.size}")
    print(f"   Mode: {img.mode}")
    print(f"   Format: PNG")

if __name__ == "__main__":
    create_simple_test_icon()



