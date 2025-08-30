
from PIL import Image, ImageDraw, ImageFont
import os

# Create 1024x1024 icon
img = Image.new('RGB', (1024, 1024), (0, 0, 0))
draw = ImageDraw.Draw(img)

# Calculator body
calculator_rect = (112, 82, 912, 942)
draw.rounded_rectangle(calculator_rect, radius=80, fill=(51, 51, 51))

# Screen
screen_rect = (192, 162, 832, 482)
draw.rounded_rectangle(screen_rect, radius=32, fill=(179, 204, 153))

# Screen border
draw.rounded_rectangle(screen_rect, radius=32, outline=(0, 0, 0), width=12)

# Try to use a monospace font, fallback to default
try:
    font_large = ImageFont.truetype('/System/Library/Fonts/Courier.ttc', 72)
    font_small = ImageFont.truetype('/System/Library/Fonts/Courier.ttc', 48)
except:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

# Draw text on screen
draw.text((512, 270), 'DRUG', fill=(0, 0, 0), font=font_large, anchor='mm')
draw.text((512, 370), 'WARS', fill=(0, 0, 0), font=font_large, anchor='mm')

# Draw button grid (simplified)
button_start_y = 540
for row in range(4):
    for col in range(5):
        x = 192 + col * 128
        y = button_start_y + row * 80
        draw.ellipse([x, y, x + 96, y + 64], fill=(38, 38, 38))
        draw.ellipse([x, y, x + 96, y + 64], outline=(0, 0, 0), width=4)

# Save
img.save('app_icon_1024.png')
print('Icon generated: app_icon_1024.png')
