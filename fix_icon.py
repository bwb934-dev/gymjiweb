#!/usr/bin/env python3
"""
Create a proper gradient icon that will actually be visible
"""

from PIL import Image, ImageDraw
import math

def create_proper_gradient_icon():
    # Create a 1024x1024 canvas
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    print(f"🎨 Creating proper gradient from center {center}")
    
    # Create a proper radial gradient
    for i in range(center):
        ratio = i / center
        
        # Beautiful sunset to ocean gradient
        base_r, base_g, base_b = 255, 94, 77      # Warm coral
        target_r, target_g, target_b = 0, 119, 190  # Deep ocean blue
        
        r = int(base_r * (1 - ratio) + target_r * ratio)
        g = int(base_g * (1 - ratio) + target_g * ratio)
        b = int(base_b * (1 - ratio) + target_b * ratio)
        
        # Make sure alpha is 255 (fully opaque)
        alpha = 255
        
        print(f"   Radius {i}: RGB({r}, {g}, {b}) Alpha({alpha})")
        
        # Draw the circle with full opacity
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, alpha))
    
    # Add a subtle center highlight
    highlight_radius = 80
    for i in range(highlight_radius):
        ratio = i / highlight_radius
        alpha = int(40 * (1 - ratio))  # Subtle highlight
        r = int(255 * (1 - ratio))
        g = int(255 * (1 - ratio))
        b = int(255 * (1 - ratio))
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, alpha))
    
    return img

if __name__ == "__main__":
    print("🎨 Creating proper gradient icon...")
    
    # Create the proper gradient icon
    icon = create_proper_gradient_icon()
    
    # Save the icon
    output_path = "/Users/budralbakri/Documents/making apps/lazygym/lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    
    print(f"✅ Proper gradient icon saved to: {output_path}")
    
    # Test the new icon
    print("🔍 Testing new icon...")
    center_x, center_y = 512, 512
    center_pixel = icon.getpixel((center_x, center_y))
    edge_pixel = icon.getpixel((50, 50))
    
    print(f"🎨 Center pixel: {center_pixel}")
    print(f"🎨 Edge pixel: {edge_pixel}")
    
    if center_pixel[3] > 0:  # Check alpha channel
        print("✅ Icon has proper opacity!")
    else:
        print("❌ Icon still has transparency issues")
    
    # Save a small test version
    small_img = icon.resize((100, 100), Image.Resampling.LANCZOS)
    small_img.save("/Users/budralbakri/Documents/making apps/lazygym/test_fixed_icon.png")
    print("💾 Saved test version to test_fixed_icon.png")



