#!/usr/bin/env python3
"""
Icon Generator for LazyGym Web App
Creates all required icon sizes from the existing app icon
"""

from PIL import Image
import os

def create_icons():
    # Path to your existing app icon (from the Xcode project)
    source_icon_path = "../lazygym/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
    
    if not os.path.exists(source_icon_path):
        print(f"❌ Source icon not found at: {source_icon_path}")
        print("Please make sure you're running this from the lazygym-web directory")
        print("and that the Xcode project is in the parent directory")
        return
    
    # Create icons directory if it doesn't exist
    os.makedirs("icons", exist_ok=True)
    
    # Icon sizes needed for web app
    icon_sizes = [
        (16, "icon-16.png"),
        (32, "icon-32.png"),
        (152, "icon-152.png"),
        (167, "icon-167.png"),
        (180, "icon-180.png"),
        (192, "icon-192.png"),
        (512, "icon-512.png")
    ]
    
    try:
        # Open the source icon
        with Image.open(source_icon_path) as source:
            print(f"✅ Opened source icon: {source.size}")
            
            for size, filename in icon_sizes:
                # Resize the icon
                resized = source.resize((size, size), Image.Resampling.LANCZOS)
                
                # Save the icon
                output_path = filename
                resized.save(output_path)
                print(f"✅ Created {filename} ({size}x{size})")
            
            print("\n🎉 All icons created successfully!")
            print("Your web app is now ready for iOS!")
            
    except Exception as e:
        print(f"❌ Error creating icons: {e}")

if __name__ == "__main__":
    create_icons()
