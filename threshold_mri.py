import os
import nibabel as nib
from nibabel.processing import resample_from_to
from scipy.ndimage import gaussian_filter
from skimage.filters import threshold_otsu
from re import sub
import numpy as np
from sys import argv


img  = nib.load(argv[1])
vol  = img.get_data()
aff = img.affine
sigma = 3.0 * (aff[0,0]+aff[1,1]+aff[2,2])/3.0
vol  = gaussian_filter(vol, sigma)
idx  = vol > threshold_otsu(vol)
vol[ idx ]  = 1
vol[ ~idx ] = 0
nib.Nifti1Image(vol, img.affine).to_filename(argv[2])

