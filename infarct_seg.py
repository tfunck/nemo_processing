import numpy as np
import pyminc.volumes.factory as pyminc
from mpl_toolkits.mplot3d import Axes3D
import sys
import scipy.misc 
import scipy.ndimage
import re
import anisotropic_diffusion as ad
import os
import matplotlib.pyplot as plt
from math import sqrt, log

flair_fn=sys.argv[1]
flair_contra_fn=sys.argv[2]
t1_fn=sys.argv[3]
brain_mask_fn=sys.argv[4]

flair = pyminc.volumeFromFile(flair_fn)
flair_contra_mnc = pyminc.volumeFromFile(flair_contra_fn)
t1 = pyminc.volumeFromFile(t1_fn)
brain_mask = pyminc.volumeFromFile(brain_mask_fn)


#maxima=[ float(np.sum(infarct.data[z,:,:])) for z in range(infarct.sizes[0]) ]  
z=25 # maxima.index( np.max(maxima) )
#print(z)

flair_array = flair.data[z,:,:]
flair_contra = flair_contra_mnc.data[z,:,:]
t1_array = t1.data[z,:,:]
brain_mask_array = brain_mask.data[z,:,:]
#infarct_array = infarct.data[z,:,:]

flair_smooth = ad.anisodiff(flair_array,niter=20,kappa=20,gamma=0.1,step=(1.,1.),option=1,ploton=False)
flair_contra_smooth = flair_contra #ad.anisodiff(flair_contra,niter=20,kappa=20,gamma=0.1,step=(1.,1.),option=1,ploton=False)
t1_smooth = ad.anisodiff(t1_array,niter=20,kappa=20,gamma=0.1,step=(1.,1.),option=1,ploton=False)

t1_smooth[ (brain_mask_array != 1)  ] =0
flair_smooth[ (brain_mask_array != 1)]=0
flair_contra_smooth[ (brain_mask_array != 1)]=0

flair_smooth_fn=os.path.basename(re.sub('.mnc','_smooth.png',flair_fn))
t1_smooth_fn=os.path.basename(re.sub('.mnc','_smooth.png',t1_fn))
flair_array_fn=os.path.basename(re.sub('.mnc','.png',flair_fn))
flair_contra_smooth_fn=os.path.basename(re.sub('.mnc','.png',flair_contra_fn))
print(flair_array_fn)
print(t1_smooth_fn)
print(flair_smooth_fn)
print(flair_contra_smooth_fn)
scipy.misc.imsave(flair_array_fn, flair_array)
scipy.misc.imsave(flair_smooth_fn, flair_smooth)
scipy.misc.imsave(flair_contra_smooth_fn, flair_contra_smooth)
scipy.misc.imsave(t1_smooth_fn, t1_smooth)
from math import log
from sklearn.svm import SVR
from sklearn import linear_model
X = np.array(t1_smooth.flatten().reshape(-1,1))
Y = np.array(flair_smooth.flatten().reshape(-1,1))
#Q = np.array(flair_contra_smooth.flatten().reshape(-1,1))
idx= (Y > 5) & (X > 5) 
X2=X[idx]
Y2=Y[idx]
Q2=Q[idx]
X2=X2.reshape(-1,1)
Y2=Y2.reshape(-1,1)
Q2=Q2.reshape(-1,1)
# Create linear regression object
regr = linear_model.LinearRegression()
#regr = SVR(kernel='rbf', C=1e3, gamma=0.1)
# Train the model using the training sets
X3=np.concatenate([X2,np.power(X2,2)], axis=1)
regr.fit(X3, Y2)
Z=regr.predict(np.concatenate([X,np.power(X,2)],axis=1))
R=Y-Z
print X.shape, R.shape, Y2.shape, Z.shape
resid_array=R.reshape(flair_smooth.shape)
flair_contra_smooth[ flair_contra_smooth < 20 ] = 1
resid_array = resid_array / flair_contra_smooth
print 'Coefficients: \n', regr.coef_
#print(np.max(infarct_array))
fig = plt.figure()
#ax = fig.add_subplot(111, projection='3d')
#ax.scatter(X,Q,Y, color='b', alpha=0.25)
#ax.scatter(X,Q,Z, color='r', alpha=0.5)

plt.scatter(X,Z, color='r', alpha=0.5)
plt.scatter(X,Y, color='b', alpha=0.25)
fig.savefig('xy_scatter.png', format='png')

scipy.misc.imsave('resid.png', resid_array)
