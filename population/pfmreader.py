import sys
import re
from struct import *
import numpy as np

class reader():
  @staticmethod
  def open(path):
  # Enable/disable debug output
    debug = False
    with open(path,"rb") as f:
      # Line 1: PF=>RGB (3 channels), Pf=>Greyscale (1 channel)
      type=f.readline().decode('latin-1')
      if "PF" in type:
        channels=3
      elif "Pf" in type:
        channels=1
      else:
        print("ERROR: Not a valid PFM file",file=sys.stderr)
        sys.exit(1)
      if(debug):
        print("DEBUG: channels={0}".format(channels))

      # Line 2: width height
      line=f.readline().decode('latin-1')
      width,height=re.findall('\d+',line)
      width=int(width)
      height=int(height)
      if(debug):
        print("DEBUG: width={0}, height={1}".format(width,height))

      # Line 3: +ve number means big endian, negative means little endian
      line=f.readline().decode('latin-1')
      BigEndian=True
      if "-" in line:
        BigEndian=False
      if(debug):
        print("DEBUG: BigEndian={0}".format(BigEndian))

      # Slurp all binary data
      samples = width*height*channels;
      buffer  = f.read(samples*4)

      # Unpack floats with appropriate endianness
      if BigEndian:
        fmt=">"
      else:
        fmt="<"
      fmt= fmt + str(samples) + "f"
      img = unpack(fmt,buffer)
      img=np.array(img,dtype=int).reshape((height,width))
      return img[::-1]