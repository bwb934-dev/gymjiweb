#!/usr/bin/env python3
"""
Create a final, working gradient icon
"""

from PIL import Image, ImageDraw
import numpy as np

def create_final_gradient_icon():
    # Create a 1024x1024 canvas
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Create a numpy array for the image
    arr = np.array(img)
    center = size // 2
    
    print(f"🎨 Creating final gradient from center {center}")
    
    # Create gradient using numpy for better control
    y, x = np.ogrid[:size, :size]
    distance = np.sqrt((x - center)**2 + (y - center)**2)
    
    # Normalize distance to 0-1
    max_distance = center
    normalized_distance = np.clip(distance / max_distance, 0, 1)
    
    # Create gradient colors
    base_r, base_g, base_b = 255, 94, 77      # Warm coral
    target_r, target_g, target_b = 0, 119, 190  # Deep ocean blue
    
    # Interpolate colors
    r = (base_r * (1 - normalized_distance) + target_r * normalized_distance).astype(np.uint8)
    g = (base_g * (1 - normalized_distance) + target_g * normalized_distance).astype(np.uint8)
    b = (base_b * (1 - normalized_distance) + target_b * normalized_distance).astype(np.uint8)
    
    # Create alpha channel (fully opaque)
    alpha = np.full((size, size), 255, dtype=np.uint8)
    
    # Set the colors
    arr[:, :, 0] = r
    arr[:, :, 1] = g
    arr[:, :, 2] = b
    arr[:, :, 3] = alpha
    
    # Convert back to PIL Image
    img = Image.fromarray(arr, 'RGBA')
    
    # Add a subtle center highlight
    draw = ImageDraw.Draw(img)
    highlight_radius = 80
    for i in range(highlight_radius):
        ratio = i / highlight_radius
        alpha = int(30 * (1 - ratio))  # Subtle highlight
        r = int(255 * (1 - ratio))
        g = int(255 * (1 - ratio))
        b = int(255 * (1 - ratio))
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, alpha))
    
    return img

if __name__ == "__main__":
    print("🎨 Creating final gradient icon...")
    
    # Create the final gradient icon
    icon = create_final_gradient_icon()
    
    # Save the icon
    output_path = "/Users/budralbakri/Documents/making apps/lazygym/lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    
    print(f"✅ Final gradient icon saved to: {output_path}")
    
    # Test the new icon
    print("🔍 Testing final icon...")
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
    small_img.save("/Users/budralbakri/Documents/making apps/lazygym/test_final_icon.png")
    print("💾 Saved test version to test_final_icon.png")
    
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



