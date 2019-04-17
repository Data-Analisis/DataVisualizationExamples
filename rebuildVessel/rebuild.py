from bpy import context, data, ops
import numpy as np
from mathutils import Vector

[x,y,z,r]=np.genfromtxt('/Users/zf/Documents/Study/DataVisualization/EXP8/1.csv',delimiter=',',unpack=True,dtype=np.double)
ops.curve.primitive_bezier_circle_add(enter_editmode=True)
ops.curve.subdivide(number_cuts=25)

# Cache a reference to the curve.
curve = context.active_object

# Locate the array of bezier points.
bez_points = curve.data.splines[0].bezier_points

for i in range(99):
    bez_points[i].co=Vector((x[i]/100,y[i]/100,z[i]/100));