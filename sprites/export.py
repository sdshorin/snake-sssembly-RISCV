#!/usr/bin/python3

# name this dir asserts??

from PIL import Image

CONFIG = {
    "apple.png": [
        {
            # "rotation": 0,
            "output_name": "asset_apple"
         }
    ]
}

ASSETS_IMPORT_FILE = "game_assets.s"

def rgba_to_hex(r, g, b, a):
    return '0x{:02x}{:02x}{:02x}{:02x}'.format(a, r, g, b)


def export_image(image_path, params):
    image = Image.open(image_path)
    if "rotation" in params:
        image = image.rotate(int(params["rotation"]), expand=True)
    image_rgba = image.convert("RGBA")
    width, height = image_rgba.size

    export_content = ""
    export_content += params["output_name"] + ":\n"
    export_content += f".word {width}, {height}\n"

    for y in range(height):
        for x in range(width):
            code = rgba_to_hex(*image_rgba.getpixel((x, y)))
            export_content += code + ", "
        export_content += "\n"
    file_name = params["output_name"] + ".s"
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
