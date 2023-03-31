#!/usr/bin/python3

# name this dir asserts??

from PIL import Image

CONFIG = {
    "apple.png": [
        {
            "rotation": 90,
            "output_name": "apple_90"
         }
    ]
}


def print_rgba_values(image_path):
    image = Image.open(image_path)
    image_rotated = image.rotate(270, expand=True)  # Rotate by 270 degrees to achieve a 90-degree clockwise rotation
    image_rgba = image_rotated.convert("RGBA")

    width, height = image_rgba.size

    for y in range(height):
        for x in range(width):
            pixel = image_rgba.getpixel((x, y))
            print(f"Pixel ({x}, {y}): RGBA{pixel}")

if __name__ == "__main__":
    image_path = "apple.png"
    print_rgba_values(image_path)
