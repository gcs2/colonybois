"""Deterministic original mottled skin inputs, no image generation or external art.

Run before Godot. A 1K color texture and conservative tangent-space normal map
are material experiments; they are not a sculpt bake or production UV atlas.
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

OUT = Path(__file__).resolve().parent
rng = np.random.default_rng(7184)
size = 1024
noise = np.zeros((size, size), np.float32)
for frequency, amplitude in [(6,.45),(18,.25),(55,.15),(190,.10),(512,.05)]:
    layer = Image.fromarray((rng.random((frequency, frequency))*255).astype('uint8'))
    noise += np.asarray(layer.resize((size,size), Image.Resampling.BICUBIC),dtype=np.float32)/255*amplitude
base = np.array([134,104,146])[None,None,:]
color = np.clip(base + (noise[:,:,None]-.5)*55,0,255)
# Broad pigment islands, kept subordinate to silhouette and eyes.
pigment = Image.new('L',(size,size))
from PIL import ImageDraw
draw=ImageDraw.Draw(pigment)
for _ in range(65):
    x,y=rng.integers(0,size,2); r=int(rng.integers(4,16))
    draw.ellipse((int(x-r),int(y-r*.62),int(x+r),int(y+r*.62)),fill=int(rng.integers(80,160)))
mask=np.asarray(pigment.filter(ImageFilter.GaussianBlur(1.4)),dtype=np.float32)/255
color=color*(1-mask[:,:,None])+np.array([157,185,171])[None,None,:]*mask[:,:,None]
Image.fromarray(color.astype('uint8')).save(OUT/'skin_color.png')
gy,gx=np.gradient(noise)
normal=np.stack((-gx*1.5,-gy*1.5,np.ones_like(gx)),axis=2)
normal/=np.linalg.norm(normal,axis=2)[:,:,None]
Image.fromarray(((normal*.5+.5)*255).astype('uint8')).save(OUT/'skin_normal.png')
print('Generated two 1024 x 1024 original procedural skin maps.')

