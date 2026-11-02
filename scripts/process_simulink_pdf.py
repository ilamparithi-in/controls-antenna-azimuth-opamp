import os
import pymupdf
import numpy as np
from PIL import Image

pdf_path = r'C:/Users/parim/.gemini/antigravity/brain/6aa269f2-fe10-4588-a9b3-13fa4bd0be73/.user_uploaded/media_1793585448132_3c59f9ac.pdf'
out_pages_dir = r'd:/Nextcloud/Projects/Sem5_CS_Group5/figures/extracted_pdf_pages'
out_fig_dir = r'd:/Nextcloud/Projects/Sem5_CS_Group5/figures'

os.makedirs(out_pages_dir, exist_ok=True)
os.makedirs(out_fig_dir, exist_ok=True)

doc = pymupdf.open(pdf_path)
print(f"Total pages in PDF: {len(doc)}")

# 1. Extract high quality individual page images (300 DPI)
extract_dpi = 300
zoom = extract_dpi / 72.0
mat = pymupdf.Matrix(zoom, zoom)

for i, page in enumerate(doc):
    pix = page.get_pixmap(matrix=mat, alpha=False)
    page_img_path = os.path.join(out_pages_dir, f"page_{i+1:02d}.png")
    pix.save(page_img_path)
    print(f"Saved: {page_img_path} ({pix.width}x{pix.height})")

# 2. Rearrange / stitch the 5x3 grid into the complete Simulink model diagram
# Column step = 720.0 pt, Row step = 540.0 pt
# 5 columns (c = 0..4), 3 rows (r = 0..2)
cols = 5
rows = 3
col_step = 720.0
row_step = 540.0
page_w = 792.0
page_h = 612.0

# Render canvas at 300 DPI (scale = 300/72 = 4.16666667)
stitch_scale = 300.0 / 72.0
canvas_w = int(round((cols * col_step + (page_w - col_step)) * stitch_scale))
canvas_h = int(round((rows * row_step + (page_h - row_step)) * stitch_scale))

print(f"\nAssembling canvas: {canvas_w} x {canvas_h} at {extract_dpi} DPI")
canvas = Image.new("RGBA", (canvas_w, canvas_h), (255, 255, 255, 255))

for r in range(rows):
    for c in range(cols):
        page_idx = r * cols + c
        page = doc[page_idx]
        
        # Check if page is blank
        if len(page.get_drawings()) <= 1 and len(page.get_text().strip()) == 0:
            print(f"Skipping blank page {page_idx+1} at grid (col={c}, row={r})")
            continue
            
        mat = pymupdf.Matrix(stitch_scale, stitch_scale)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        
        arr = np.frombuffer(pix.samples, dtype=np.uint8).reshape((pix.height, pix.width, 3))
        
        # Pure white background to transparent
        is_white = (arr[:, :, 0] > 250) & (arr[:, :, 1] > 250) & (arr[:, :, 2] > 250)
        rgba = np.zeros((pix.height, pix.width, 4), dtype=np.uint8)
        rgba[:, :, :3] = arr
        rgba[:, :, 3] = np.where(is_white, 0, 255)
        
        tile = Image.fromarray(rgba, mode="RGBA")
        
        dest_x = int(round(c * col_step * stitch_scale))
        dest_y = int(round(r * row_step * stitch_scale))
        
        print(f"Compositing page {page_idx+1} at grid ({c}, {r}) -> pixel ({dest_x}, {dest_y})")
        canvas.alpha_composite(tile, (dest_x, dest_y))

# Crop whitespace to content bounding box
print("\nCropping whitespace around diagram...")
gray = canvas.convert("L")
arr_gray = np.array(gray)
non_white = np.where(arr_gray < 250)
ymin, ymax = non_white[0].min(), non_white[0].max()
xmin, xmax = non_white[1].min(), non_white[1].max()

# Add margin
margin = 50
xmin = max(0, xmin - margin)
ymin = max(0, ymin - margin)
xmax = min(canvas_w - 1, xmax + margin)
ymax = min(canvas_h - 1, ymax + margin)

cropped_full = canvas.crop((xmin, ymin, xmax + 1, ymax + 1)).convert("RGB")
full_png_path = os.path.join(out_fig_dir, "azimuth_with_variable_gain_simulink.png")
cropped_full.save(full_png_path, quality=95)
print(f"Saved full-resolution Simulink diagram: {full_png_path} ({cropped_full.width}x{cropped_full.height})")

# Generate standard/medium resolution version (e.g. 2500 px wide for Word/reports)
med_w = 2500
med_h = int(round(med_w * cropped_full.height / cropped_full.width))
med_img = cropped_full.resize((med_w, med_h), Image.Resampling.LANCZOS)
med_png_path = os.path.join(out_fig_dir, "azimuth_with_variable_gain_simulink_medium.png")
med_img.save(med_png_path, quality=95)
print(f"Saved medium-resolution Simulink diagram: {med_png_path} ({med_w}x{med_h})")

# 3. Create cropped vector PDF
# Bounding box in PDF points:
pt_xmin = xmin / stitch_scale
pt_ymin = ymin / stitch_scale
pt_xmax = (xmax + 1) / stitch_scale
pt_ymax = (ymax + 1) / stitch_scale
crop_w = pt_xmax - pt_xmin
crop_h = pt_ymax - pt_ymin

vec_doc = pymupdf.open()
vec_page = vec_doc.new_page(width=crop_w, height=crop_h)

for r in range(rows):
    for c in range(cols):
        page_idx = r * cols + c
        page = doc[page_idx]
        if len(page.get_drawings()) <= 1 and len(page.get_text().strip()) == 0:
            continue
        dest_rect = pymupdf.Rect(
            c * col_step - pt_xmin,
            r * row_step - pt_ymin,
            c * col_step + page_w - pt_xmin,
            r * row_step + page_h - pt_ymin
        )
        vec_page.show_pdf_page(dest_rect, doc, page_idx)

vec_pdf_path = os.path.join(out_fig_dir, "azimuth_with_variable_gain_simulink.pdf")
vec_doc.save(vec_pdf_path)
print(f"Saved vector PDF: {vec_pdf_path} ({crop_w:.1f} x {crop_h:.1f} pt)")
print("\nAll tasks completed successfully!")
