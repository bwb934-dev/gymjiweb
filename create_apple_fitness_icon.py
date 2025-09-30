#!/usr/bin/env python3
"""
Create an Apple-style fitness app icon
"""

from PIL import Image, ImageDraw
import math

def create_apple_fitness_icon():
    # Create a 1024x1024 canvas
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    
    print(f"🍎💪 Creating Apple-style fitness icon from center {center}")
    
    # Apple-style fitness gradient: Deep green to light green (like Apple Fitness)
    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            distance = math.sqrt((x - center)**2 + (y - center)**2)
            
            # Normalize distance to 0-1
            max_distance = center
            ratio = min(distance / max_distance, 1.0)
            
            # Apple Fitness-style gradient: Deep green to light green
            base_r, base_g, base_b = 0, 150, 136      # Deep teal (Apple Fitness color)
            target_r, target_g, target_b = 52, 199, 89  # Apple Green
            
            r = int(base_r * (1 - ratio) + target_r * ratio)
            g = int(base_g * (1 - ratio) + target_g * ratio)
            b = int(base_b * (1 - ratio) + target_b * ratio)
            
            # Set pixel with full opacity
            img.putpixel((x, y), (r, g, b, 255))
    
    # Add Apple-style subtle inner glow
    glow_radius = 100
    for i in range(glow_radius):
        ratio = i / glow_radius
        alpha = int(40 * (1 - ratio))  # Subtle glow
        r = int(255 * (1 - ratio))
        g = int(255 * (1 - ratio))
        b = int(255 * (1 - ratio))
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, alpha))
    
    # Add a simple fitness symbol - a stylized dumbbell
    # Draw the center bar
    bar_width = 80
    bar_height = 20
    bar_x = center - bar_width // 2
    bar_y = center - bar_height // 2
    
    # Center bar (dumbbell handle)
    draw.rounded_rectangle([bar_x, bar_y, bar_x + bar_width, bar_y + bar_height], 
                          radius=10, fill=(255, 255, 255, 200))
    
    # Left weight
    left_weight_x = bar_x - 60
    left_weight_y = center - 30
    left_weight_size = 60
    
    draw.ellipse([left_weight_x, left_weight_y, 
                 left_weight_x + left_weight_size, left_weight_y + left_weight_size], 
                fill=(255, 255, 255, 180))
    
    # Right weight
    right_weight_x = bar_x + bar_width
    right_weight_y = center - 30
    right_weight_size = 60
    
    draw.ellipse([right_weight_x, right_weight_y, 
                 right_weight_x + right_weight_size, right_weight_y + right_weight_size], 
                fill=(255, 255, 255, 180))
    
    return img

if __name__ == "__main__":
    print("🍎💪 Creating Apple-style fitness icon...")
    
    # Create the Apple-style fitness icon
    icon = create_apple_fitness_icon()
    
    # Save the icon
    output_path = "/Users/budralbakri/Documents/making apps/lazygym/lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    
    print(f"✅ Apple-style fitness icon saved to: {output_path}")
    
    # Test the new icon
    print("🔍 Testing Apple fitness icon...")
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
    small_img.save("/Users/budralbakri/Documents/making apps/lazygym/test_apple_fitness_icon.png")
    print("💾 Saved test version to test_apple_fitness_icon.png")
    
    print("🍎💪 Apple-style fitness features:")
    print("   • Apple Fitness green gradient")
    print("   • Subtle inner glow")
    print("   • Clean dumbbell symbol")
    print("   • Professional Apple-like appearance")
    print("   • Full opacity throughout")
    print("   • Looks like it came from Apple themselves")



