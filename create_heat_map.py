from nilearn import plotting #nilearn has plotting functions
import nibabel as nib #nibabel is for input/output of brain volumes
import numpy as np  #numpy is for doing things with arrays
from sys import argv #use argv to read command line arguments
import pandas as pd #read and manage data frames
from os.path import splitext, exists #utility functions for doing stuff with files
from glob import glob #glob lets you search for files

df = pd.read_csv(argv[1])
df['lesion_file']=['NA'] * df.shape[0]
nb=no=0
for i, row in df.iterrows() :
    #patient=''.join( row['Patient'].split('-')[1] )
    patient = '-'.join(row['Patient'].split('-')[0:2])
    patient_lower = patient.lower()
    #fn = glob('wasub*'+patient+'*lesion-negative*nii') + glob('wasub*'+patient_lower+'*lesion-negative*nii')
    fn = glob('sub*'+patient+'*lesion-negative*nii.gz') + glob('sub*'+patient_lower+'*lesion-negative*nii.gz')
    print(patient, patient_lower, fn)
    if fn == [] :
        continue
    else : 
        fn=fn[0]
        df['lesion_file'].iloc[i] = fn
    if i == 0 : 
        #Read the first image to get the dimensions
        img = nib.load(fn)
        #Use dimensions to create an empty output matrix
        broca = np.zeros(img.shape)
        other = np.zeros(img.shape)

    img = nib.load(fn) #load image info
    print(row['Broca_affected'])
    if row['Broca_affected'] == 1 :    
        broca += img.get_data() #get data from image
        nb+=1
        img_fn = splitext(fn)[0]+'_broca.png' #file name for saving individual images
        #print("\tbroca", img_fn)
    else :
        temp = img.get_data()
        temp[ np.isnan(temp) ] = 0
        other += temp
        print(np.sum(temp))
        img_fn = splitext(fn)[0]+'_other.png' #file name for saving individual images
        no += 1.
        print("\tother", img_fn)
    
    if not exists(img_fn) :
        # plot individual image
        plotting.plot_glass_brain(img,black_bg=True, display_mode='lyrz',output_file=img_fn) 
#Total number of images
#n = df.shape[0]
print('nb=',nb,'no=',no, df.shape[0])
#Divide by total number of images
broca /= -nb
other /= -no
broca *= 100.
other *= 100.

nib.Nifti1Image(other, img.affine).to_filename('other.nii.gz')

df.to_csv('missing_lesion_files.csv',index=False)
#Create an image (data structure with voxel data & affine matrix)
broca_heat_map = nib.Nifti1Image(broca,img.affine)
other_heat_map = nib.Nifti1Image(other,img.affine)

#Plot 
plotting.plot_glass_brain(other_heat_map, black_bg=True, colorbar=True, vmax=100., display_mode='lyrz',output_file='infarct_heat_map_other.png' )
plotting.plot_glass_brain(broca_heat_map, black_bg=True, colorbar=True, vmax=100., display_mode='lyrz',output_file='infarct_heat_map_broca.png' )
