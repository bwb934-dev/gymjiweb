#!/usr/bin/env python3
"""
Test what's actually in the current icon file
"""

from PIL import Image
import os

def test_current_icon():
    icon_path = "/Users/budralbakri/Documents/making apps/lazygym/lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    
    if not os.path.exists(icon_path):
        print("❌ Icon file not found!")
        return
    
    # Open the current icon
    img = Image.open(icon_path)
    print(f"📱 Current icon size: {img.size}")
    print(f"📱 Current icon mode: {img.mode}")
    
    # Check if it has transparency
    if img.mode == 'RGBA':
        print("✅ Icon has transparency")
    else:
        print("❌ Icon has no transparency")
    
    # Get some pixel samples to see what colors are there
    width, height = img.size
    center_x, center_y = width // 2, height // 2
    
    # Sample center pixel
    center_pixel = img.getpixel((center_x, center_y))
    print(f"🎨 Center pixel: {center_pixel}")
    
    # Sample edge pixel
    edge_pixel = img.getpixel((50, 50))
    print(f"🎨 Edge pixel: {edge_pixel}")
    
    # Check if it's all one color (might be the old barbell)
    sample_pixels = [
        img.getpixel((100, 100)),
        img.getpixel((200, 200)),
        img.getpixel((300, 300)),
        img.getpixel((400, 400)),
        img.getpixel((500, 500))
    ]
    
    print(f"🎨 Sample pixels: {sample_pixels}")
    
    # Check if all pixels are the same (indicating a solid color)
    if len(set(sample_pixels)) == 1:
        print("⚠️  All sample pixels are the same color - might be a solid color icon")
    else:
        print("✅ Icon has color variation - gradient should be visible")
    
    # Save a small version to see what it looks like
    small_img = img.resize((100, 100), Image.Resampling.LANCZOS)
    small_img.save("/Users/budralbakri/Documents/making apps/lazygym/test_icon_small.png")
    print("💾 Saved small test version to test_icon_small.png")

if __name__ == "__main__":
    print("🔍 Testing current icon...")
    test_current_icon()



