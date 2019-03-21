# -*- coding: UTF-8 -*-
import tkinter as tk
from PIL import Image,ImageTk
from pfmreader import reader
import numpy as np

class mouseParams():
  def __init__(self):
    self.press=False
    self.px=0
    self.py=0
  def pressOn(self,x,y):
    self.press=True
    self.px=x
    self.py=y
  def leave(self):
    self.press=False
    self.px=0
    self.py=0



def mouseScale(event):
  global imgSize
  global imgScale
  imgSize=min(imgSize*2,8)
  frame.updateImage(imgLoc,imgSize)

  if imgSize==4:
    imgScale+=1
    frame.changeImage(imgScale,imgLoc,imgSize)
  # if imgSize==1:
  #   imgScale-=1
  #   frame.changeImage(imgScale,imgLoc)

def mouseMotion(event,mP):
  if not mP.press:
    mP.pressOn(event.x,event.y)

  imgLoc[1]=imgLoc[1]+(mP.py-event.y)
  imgLoc[0]=imgLoc[0]+(mP.px-event.x)


  mP.pressOn(event.x,event.y)
  frame.updateImage(imgLoc,imgSize)

def mouseRelese(event,mP):
  mP.leave()


class Frame(tk.Frame):
  def __init__(self, master=None):
    super().__init__(master, width=winWid, height=winHei)
    self.pack()
    self.dataMarix=reader.open('0.01/0.01.pfm')
    self.pilImage = Frame.data2img(self.dataMarix)
    imgsize=((int)(imgSize*imgSplitSize[1]),(int)(imgSize*imgSplitSize[0]))
    self.tkImage = ImageTk.PhotoImage(image=self.pilImage.resize(imgsize).crop((0, 0, winWid, winHei)))
    self.label = tk.Label(self, image=self.tkImage)
    self.label.bind('<B1-Motion>',lambda e:mouseMotion(e,mP))
    self.label.bind('<ButtonRelease-1>',lambda e:mouseRelese(e,mP))
    self.label.bind('<Double-Button-1>', mouseScale)
    self.label.pack()

  def findSubImg(self): # in same scale
    global imgLoc
    if imgScaleL[imgScale]==0.01:
      self.dataMarix=reader.open('0.01/0.01.pfm')
      self.pilImage = Frame.data2img(self.dataMarix)
    else:
      crtScl=imgScaleL[imgScale]
      xblock=[(int)(imgRealSize[0]/(crtScl*100)*x) for x in np.arange(0,crtScl*100-0.5,0.5)]
      yblock=[(int)(imgRealSize[1]/(crtScl*100)*y) for y in np.arange(0,crtScl*100-0.5,0.5)]
      ix=xblock.index(imgCntCod[0])
      iy=yblock.index(imgCntCod[1])

      tmpLoc=[0,0]
      tmpLoc[0]=imgCntCod[1]+imgLoc[0]*100
      tmpLoc[1]=imgCntCod[0]+imgLoc[1]*100

      if imgLoc[0]+winWid>imgSplitSize[1]:
        imgCntCod[1]=yblock[min(iy+1,len(yblock)-1)]
      elif imgLoc[1]<0:
        imgCntCod[1]=yblock[max(iy-1,0)]

      if imgLoc[1]+winHei>imgSplitSize[0]:
        imgCntCod[0]=xblock[min(ix+1,len(xblock)-1)]
      elif imgLoc[1]<0 or imgLoc[0]<0:
        imgCntCod[0]=xblock[max(ix-1,0)]

      path=str(crtScl)+'/'+str(imgCntCod[0])+'_'+str(imgCntCod[1])+'.pfm'
      print(imgCntCod)
      self.dataMarix=reader.open(path)
      self.pilImage = Frame.data2img(self.dataMarix)
      imgLoc[0]=(int)((tmpLoc[0]-imgCntCod[1])/100)
      imgLoc[1]=(int)((tmpLoc[1]-imgCntCod[0])/100)


  def updateImage(self,imgLoc,imgSize):
    #debuged in 0.04
    if imgLoc[0]+winWid>imgSplitSize[1] or imgLoc[1]+winHei>imgSplitSize[0]\
    or imgLoc[1]<0 or imgLoc[0]<0:
      print('find')
      self.findSubImg()
    imgsize=((int)(imgSize*imgSplitSize[1]),(int)(imgSize*imgSplitSize[0]))
    
    bgnX=(imgLoc[0]-imgCntCod[1]/100)*imgSize
    bgnY=(imgLoc[1]-imgCntCod[0]/100)*imgSize
    imgcorp=(bgnX,bgnY,bgnX+winWid,bgnY+winHei)

    self.tkImage = ImageTk.PhotoImage(image=self.pilImage.resize(imgsize).crop(imgcorp))
    self.label.configure(image=self.tkImage)
    print(imgLoc)

  def changeImage(self,imgScale,imgLoc,imgSize):
    crtScl=imgScaleL[imgScale]
    # global imgSize
    # global imgLoc
    xblock=[(int)(imgRealSize[0]/(crtScl*100)*x) for x in np.arange(0,crtScl*100-0.5,0.5)]
    yblock=[(int)(imgRealSize[1]/(crtScl*100)*y) for y in np.arange(0,crtScl*100-0.5,0.5)]
    tmpLoc=[0,0]
    tmpLoc[0]=imgCntCod[1]+imgLoc[0]*100
    tmpLoc[1]=imgCntCod[0]+imgLoc[1]*100

    for x in xblock:
      if x<(imgLoc[1]+winHei)*100:
        imgCntCod[0]=x
        break
    for y in yblock:
      if y<(imgLoc[0]+winWid)*100:
        imgCntCod[1]=y
        break
    
    path=str(crtScl)+'/'+str(imgCntCod[0])+'_'+str(imgCntCod[1])+'.pfm'
    self.dataMarix=reader.open(path)
    self.pilImage = Frame.data2img(self.dataMarix)
    imgLoc[0]=(int)((tmpLoc[0]-imgCntCod[1])/100)
    imgLoc[1]=(int)((tmpLoc[1]-imgCntCod[0])/100)
    imgSize=1
    self.updateImage(imgLoc,imgSize)


  @staticmethod
  def data2img(data):
    data[data<=0]=1
    logData=np.log2(data)
    normData=logData/11
    g=255-np.uint8(np.multiply(255,normData))
    b=255-np.zeros(g.shape,dtype=np.uint8)
    r=255-np.uint8(np.multiply(255,normData**2))
    Aimg=np.dstack([r,g,b])
    img=Image.fromarray(Aimg.astype('uint8')).convert('RGB')
    return img
  def processEvent(self, event):
    pass

mP=mouseParams()
winWid=600
winHei=300
imgRealSize=(60900,141900)
imgSplitSize=(609,1419)

imgCntCod=[0,0]
global imgSize
imgSize=1
global imgScale
imgScale=0
imgScaleL=[0.01,0.04,0.16,0.64]
global imgLoc
imgLoc=[0,0] # 609 1419
root=tk.Tk()
frame=Frame(root)
root.mainloop()

