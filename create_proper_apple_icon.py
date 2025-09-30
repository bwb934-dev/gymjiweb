#!/usr/bin/env python3
"""
Create a proper Apple-style app icon with full opacity
"""

from PIL import Image, ImageDraw
import math

def create_proper_apple_icon():
    # Create a 1024x1024 canvas
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    center = size // 2
    
    print(f"🍎 Creating proper Apple-style icon from center {center}")
    
    # Apple-style gradient: iOS Blue to Light Blue
    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            distance = math.sqrt((x - center)**2 + (y - center)**2)
            
            # Normalize distance to 0-1
            max_distance = center
            ratio = min(distance / max_distance, 1.0)
            
            # Apple-style gradient: iOS Blue to Light Blue
            base_r, base_g, base_b = 0, 122, 255      # iOS Blue
            target_r, target_g, target_b = 90, 200, 250  # Light Blue
            
            r = int(base_r * (1 - ratio) + target_r * ratio)
            g = int(base_g * (1 - ratio) + target_g * ratio)
            b = int(base_b * (1 - ratio) + target_b * ratio)
            
            # Set pixel with full opacity
            img.putpixel((x, y), (r, g, b, 255))
    
    # Add Apple-style subtle inner glow
    draw = ImageDraw.Draw(img)
    glow_radius = 150
    for i in range(glow_radius):
        ratio = i / glow_radius
        alpha = int(40 * (1 - ratio))  # Subtle glow
        r = int(255 * (1 - ratio))
        g = int(255 * (1 - ratio))
        b = int(255 * (1 - ratio))
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, alpha))
    
    return img

if __name__ == "__main__":
    print("🍎 Creating proper Apple-style icon...")
    
    # Create the proper Apple-style icon
    icon = create_proper_apple_icon()
    
    # Save the icon
    output_path = "/Users/budralbakri/Documents/making apps/lazygym/lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    
    print(f"✅ Proper Apple-style icon saved to: {output_path}")
    
    # Test the new icon
    print("🔍 Testing proper Apple icon...")
    center_x, center_y = 512, 512
    center_pixel = icon.getpixel((center_x, center_y))
    edge_pixel = icon.getpixel((50, 50))
    
    print(f"🎨 Center pixel: {center_pixel}")
    print(f"🎨 Edge pixel: {edge_pixel}")
    
    if center_pixel[3] > 200:  # Check alpha channel
        print("✅ Icon has proper opacity!")
    else:
        print("❌ Icon still has transparency issues")
    
    # Save a small test version
    small_img = icon.resize((100, 100), Image.Resampling.LANCZOS)
    small_img.save("/Users/budralbakri/Documents/making apps/lazygym/test_proper_apple_icon.png")
    print("💾 Saved test version to test_proper_apple_icon.png")
    
    # Check a few more pixels
    test_pixels = [
        icon.getpixel((100, 100)),
        icon.getpixel((200, 200)),
        icon.getpixel((300, 300)),
        icon.getpixel((400, 400)),
        icon.getpixel((500, 500))
    ]
    print(f"🎨 Test pixels: {test_pixels}")
    
    # Check if we have good color variation
    alphas = [p[3] for p in test_pixels]
    if all(a > 200 for a in alphas):
        print("✅ All test pixels are opaque!")
    else:
        print("❌ Some pixels are still transparent")
        
    # Check if we have color variation
    colors = [(p[0], p[1], p[2]) for p in test_pixels]
    unique_colors = len(set(colors))
    print(f"🎨 Unique colors found: {unique_colors}")
    
    if unique_colors > 1:
        print("✅ Icon has color variation - Apple-style gradient should be visible!")
    else:
        print("❌ Icon appears to be a single color")
    
    print("🍎 Apple-style features:")
    print("   • iOS Blue to Light Blue gradient")
    print("   • Subtle inner glow")
    print("   • Clean, minimal design")
    print("   • Professional Apple-like appearance")
    print("   • Full opacity throughout")



