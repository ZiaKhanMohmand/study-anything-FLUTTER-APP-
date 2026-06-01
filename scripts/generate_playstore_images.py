from PIL import Image, ImageDraw, ImageFont
import os

out_dir = os.path.join(os.path.dirname(__file__), '..', 'playstore', 'assets')
os.makedirs(out_dir, exist_ok=True)

# Simple utility to draw centered text
def draw_centered_text(draw, text, font, box, fill=(255,255,255)):
    w, h = draw.textsize(text, font=font)
    x = box[0] + (box[2]-box[0]-w)/2
    y = box[1] + (box[3]-box[1]-h)/2
    draw.text((x,y), text, font=font, fill=fill)

# Try to load a default font
try:
    font_large = ImageFont.truetype("arial.ttf", 72)
    font_medium = ImageFont.truetype("arial.ttf", 42)
except Exception:
    font_large = ImageFont.load_default()
    font_medium = ImageFont.load_default()

# Create 3 phone screenshots (1080x1920)
screens = [
    (1080, 1920, 'Study Anything', 'Summaries & Quizzes'),
    (1080, 1920, 'AI Summaries', 'Instant article summaries'),
    (1080, 1920, 'Practice Quizzes', 'Learn by testing yourself')
]

for i, (w, h, title, subtitle) in enumerate(screens, start=1):
    img = Image.new('RGB', (w,h), color=(30, 120, 230))
    draw = ImageDraw.Draw(img)
    # Top area
    draw_centered_text(draw, title, font_large, (0, 200, w, 500))
    draw_centered_text(draw, subtitle, font_medium, (0, 520, w, 620))
    # Placeholder card
    card_w, card_h = int(w*0.9), int(h*0.45)
    card_x = (w-card_w)//2
    card_y = int(h*0.4)
    draw.rectangle([card_x, card_y, card_x+card_w, card_y+card_h], fill=(255,255,255))
    draw_centered_text(draw, 'Screenshot Placeholder', font_medium, (card_x, card_y, card_x+card_w, card_y+card_h), fill=(0,0,0))
    path = os.path.join(out_dir, f'screenshot_placeholder_{i}.png')
    img.save(path, format='PNG')

# Create feature graphic (1024x500)
fg_w, fg_h = 1024, 500
fg = Image.new('RGB', (fg_w, fg_h), color=(240,90,40))
fg_draw = ImageDraw.Draw(fg)
try:
    title_font = ImageFont.truetype("arial.ttf", 56)
except Exception:
    title_font = ImageFont.load_default()
fg_draw.text((40, 140), 'Study Anything', font=title_font, fill=(255,255,255))
fg_draw.text((40, 220), 'AI summaries, quizzes & flashcards', font=font_medium, fill=(255,255,255))
fg_path = os.path.join(out_dir, 'feature_graphic.png')
fg.save(fg_path, format='PNG')

print('Created placeholders in', out_dir)
