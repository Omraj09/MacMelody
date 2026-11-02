#!/usr/bin/env python3
import os
import subprocess
from PIL import Image, ImageDraw, ImageFilter

src_path = "/Users/omrajsawant/.gemini/antigravity/brain/02aed140-9a01-4252-9dea-2782747246e9/.user_uploaded/media_1793611372234_f32b8eeb.jpg"
im = Image.open(src_path).convert("RGBA")

# Clean the tiny watermark in the bottom-right corner (region 920..1024, 920..1024)
# Sample the surrounding background color around (900, 900)
bg_color = im.getpixel((900, 900))
draw = ImageDraw.Draw(im)
draw.rectangle([920, 920, 1024, 1024], fill=bg_color)

# Save cleaned master
master_path = "Packaging/AppIcon-Master.png"
im.save(master_path, "PNG")
print("Saved master logo to", master_path)

iconset_dir = "Packaging/AppIcon.iconset"
os.makedirs(iconset_dir, exist_ok=True)

# Function to render macOS standard squircle icon with soft drop shadow and specular rim
def create_macos_icon(pixels):
    size = pixels
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # 10% standard margin for squircle
    inset = int(size * 0.1)
    card_w = size - inset * 2
    card_h = size - inset * 2
    
    # Resample the logo to fit nicely in the squircle
    logo_resized = im.resize((card_w, card_h), Image.Resampling.LANCZOS)
    
    # Create squircle rounded rectangle mask
    radius = int(card_w * 0.225)
    mask = Image.new("L", (card_w, card_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, card_w, card_h], radius=radius, fill=255)
    
    # Create soft shadow behind squircle
    shadow_pad = int(size * 0.05)
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    s_inset_y = inset + int(size * 0.02)
    s_draw.rounded_rectangle(
        [inset, s_inset_y, inset + card_w, s_inset_y + card_h],
        radius=radius,
        fill=(0, 0, 0, 140)
    )
    blur_r = max(1, int(size * 0.035))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur_r))
    
    # Paste shadow onto out
    out.paste(shadow, (0, 0), shadow)
    
    # Paste squircle masked logo
    out.paste(logo_resized, (inset, inset), mask)
    
    # Specular border
    border_img = Image.new("RGBA", (card_w, card_h), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border_img)
    b_width = max(1, int(size * 0.002))
    b_draw.rounded_rectangle([0, 0, card_w - 1, card_h - 1], radius=radius, outline=(255, 255, 255, 45), width=b_width)
    out.paste(border_img, (inset, inset), border_img)
    
    return out

sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for s, filename in sizes:
    rendered = create_macos_icon(s)
    rendered.save(os.path.join(iconset_dir, filename), "PNG")

print("Generated iconset PNGs.")
# Run iconutil
subprocess.check_call(["iconutil", "-c", "icns", iconset_dir, "-o", "Packaging/AppIcon.icns"])
print("Generated Packaging/AppIcon.icns successfully.")
