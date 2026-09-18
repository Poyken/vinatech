import pymupdf

def inspect_image(img_path, label):
    pix = pymupdf.Pixmap(img_path)
    print(f"=== {label}: {img_path} ===")
    print(f"Dimensions: {pix.width}x{pix.height}, channels: {pix.n}")
    # The barcode is in the top right quadrant
    # Let's sample a horizontal slice across the top right barcode area
    # In both images, the label is roughly:
    # Width ~ 1000px, height ~ 1300px
    # Let's find where the barcode bars are.

inspect_image(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762507285.jpg", "OK")
inspect_image(r"C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\fb4aad92-bacd-48da-b765-39d626fc7768\.user_uploaded\media_1789762512623.jpg", "NG")
