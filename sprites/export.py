#!/usr/bin/python3

# name this dir asserts??

from PIL import Image

CONFIG = {
    "apple.png": [
        {
            # "rotation": 0, # counterclockwise rotation
            "output_name": "asset_apple"
        }
    ],
    "mouse.png": [
        {
            # "rotation": 0,
            "output_name": "asset_mouse"
        }
    ],
    "mushroom.png": [
        {
            # "rotation": 0,
            "output_name": "asset_mushroom"
        }
    ],
    "head.png": [
        {
            # "rotation": 0,
            "output_name": "asset_head_bottom"
        },
        {
            "rotation": 90,
            "output_name": "asset_head_right"
        },
        {
            "rotation": 180,
            "output_name": "asset_head_top"
        },
        {
            "rotation": 270,
            "output_name": "asset_head_left"
        },
    ],
    "body.png": [
        {
            # "rotation": 0,
            "output_name": "asset_body_top_to_bottom"
        },
        {
            "rotation": 90,
            "output_name": "asset_body_left_to_right"
        },
        {
            "rotation": 180,
            "output_name": "asset_body_bottom_to_top"
        },
        {
            "rotation": 270,
            "output_name": "asset_body_right_to_left"
        },
    ],
    "tail.png": [
        {
            # "rotation": 0,
            "output_name": "asset_tail_from_top"
        },
        {
            "rotation": 90,
            "output_name": "asset_tail_from_left"
        },
        {
            "rotation": 180,
            "output_name": "asset_tail_from_bottom"
        },
        {
            "rotation": 270,
            "output_name": "asset_tail_from_right"
        },
    ],
    "snake_rotation_1.png": [
        {
            # "rotation": 0,
            "output_name": "asset_body_top_to_right"
        },
        {
            "rotation": 90,
            "output_name": "asset_body_left_to_top"
        },
        {
            "rotation": 180,
            "output_name": "asset_body_bottom_to_left"
        },
        {
            "rotation": 270,
            "output_name": "asset_body_right_to_bottom"
        },
    ],
    "snake_rotation_2.png": [
        {
            # "rotation": 0,
            "output_name": "asset_body_left_to_bottom"
        },
        {
            "rotation": 90,
            "output_name": "asset_body_bottom_to_right"
        },
        {
            "rotation": 180,
            "output_name": "asset_body_right_to_top"
        },
        {
            "rotation": 270,
            "output_name": "asset_body_top_to_left"
        },
    ],
}

ASSETS_IMPORT_FILE = "game_assets.s"
PNG_SOURCE_DIR = "png_source/"
ASSETS_DIR = "assets/"

def rgba_to_hex(r, g, b, a):
    return '0x{:02x}{:02x}{:02x}{:02x}'.format(a, r, g, b)


def export_image(image_path, params):
    image = Image.open(PNG_SOURCE_DIR + image_path)
    if "rotation" in params:
        image = image.rotate(int(params["rotation"]), expand=True)
    image_rgba = image.convert("RGBA")
    width, height = image_rgba.size

    export_content = ".data\n"
    export_content += params["output_name"] + ":\n"
    export_content += f".word {width}, {height} # width, height\n"
    export_content += f".word {width * 4}, {height * 4} # width, height in bytes\n"

    for y in range(height):
        for x in range(width):
            code = rgba_to_hex(*image_rgba.getpixel((x, y)))
            export_content += code + ", "
        export_content += "\n"
    file_name = ASSETS_DIR + params["output_name"] + ".s"
    with open(file_name, 'w') as f:
        f.write(export_content)
    return file_name

def create_asserts_import(files):
    content = ""
    for file in files:
        content += f'.include "{file}"\n'
    with open(ASSETS_IMPORT_FILE, 'w') as f:
        f.write(content)

def main():
    files = []
    for image_path in CONFIG:
        for export_option in CONFIG[image_path]:
            files.append(export_image(image_path, export_option))
    create_asserts_import(files)


if __name__ == "__main__":
    main()
