from PIL import Image, ImageDraw, ImageFont
import os

# Create images directory if it doesn't exist
os.makedirs('images/projects', exist_ok=True)

# List of project names
projects = [
    'unsw-accommodation',
    'ad-monetization',
    'airbnb-pricing',
    'nintendo-stock'
]

# Create a placeholder image for each project
for name in projects:
    # Create a new image with a light blue background
    img = Image.new('RGB', (800, 400), color='#87CEEB')
    draw = ImageDraw.Draw(img)
    
    # Add text to the image
    text = name.replace('-', ' ').title() + '\nProject Image'
    draw.text((400, 200), text, fill='black', anchor='mm')
    
    # Save the image
    img.save(f'images/projects/{name}.jpg')
    print(f'Created {name}.jpg') 