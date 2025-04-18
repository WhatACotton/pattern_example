import struct
import sys

def convert_to_valid_bmp(input_file, output_file, width=640, height=480):
    with open(input_file, 'rb') as infile:
        raw_data = infile.read()

    # Calculate padding
    row_size = (width * 3 + 3) & ~3  # Align to 4 bytes
    padding_size = row_size - (width * 3)
    padding = b'\x00' * padding_size

    # Create BMP header
    bmp_header = bytearray()
    bmp_header.extend(b'BM')  # Signature
    file_size = 54 + (height * row_size)  # Total file size
    bmp_header.extend(struct.pack('<I', file_size))  # File size
    bmp_header.extend(struct.pack('<H', 0))  # Reserved1
    bmp_header.extend(struct.pack('<H', 0))  # Reserved2
    bmp_header.extend(struct.pack('<I', 54))  # Offset to pixel data
    bmp_header.extend(struct.pack('<I', 40))  # DIB header size
    bmp_header.extend(struct.pack('<I', width))  # Width
    bmp_header.extend(struct.pack('<I', height))  # Height
    bmp_header.extend(struct.pack('<H', 1))  # Planes
    bmp_header.extend(struct.pack('<H', 24))  # Bits per pixel
    bmp_header.extend(struct.pack('<I', 0))  # Compression
    bmp_header.extend(struct.pack('<I', height * row_size))  # Image size
    bmp_header.extend(struct.pack('<I', 0))  # Horizontal resolution
    bmp_header.extend(struct.pack('<I', 0))  # Vertical resolution
    bmp_header.extend(struct.pack('<I', 0))  # Colors in color table
    bmp_header.extend(struct.pack('<I', 0))  # Important color count

    # Write to new BMP file
    with open(output_file, 'wb') as outfile:
        outfile.write(bmp_header)

        # Write pixel data with padding
        for i in range(height):
            start_index = (height - 1 - i) * 640 * 3  # Change to 640 width
            row_data = raw_data[start_index:start_index + 640 * 3]  # Change to 640 width
            outfile.write(row_data)
            outfile.write(padding)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_bmp.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    convert_to_valid_bmp(input_file, output_file, width=640, height=480)