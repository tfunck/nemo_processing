from nilearn import plotting #nilearn has plotting functions
import nibabel as nib #nibabel is for input/output of brain volumes
import numpy as np  #numpy is for doing things with arrays
from sys import argv #use argv to read command line arguments
import pandas as pd #read and manage data frames
from os.path import splitext, exists #utility functions for doing stuff with files
from glob import glob #glob lets you search for files

df = pd.read_csv(argv[1])

example_fn = glob('sub*lesion-negative*nii.gz')[0] 
example_img = nib.load(example_fn)
dimensions = example_img.shape

#split the spreadsheet (i.e. dataframe) by heatmaps number
for heat_map_number, heatmap_df in df.groupby('heatmaps'):
    
    #create a new 3d array
    volume = np.zeros(dimensions)
    n = 0
    
    #iterate over the heat map numbers
    for i, row in heatmap_df.iterrows():
        patient = row['Patient']
   
        # use 'glob' to find lesion file
        fn = glob('sub*'+patient+'*lesion-negative*nii.gz') + glob('sub*'+patient_lower+'*lesion-negative*nii.gz')
  	
        # glob returns a list, so make sure it's not an empty list
   	if fn == [] : 
            continue
    	else : 
            fn=fn[0]

        img = nib.load(fn) #load image info
        volume += img.get_data() #get data from image
        n += 1

    # divide the summed lesion maps by the number of lesions
    volume /= n

    heat_map = nib.Nifti1Image(volume,example_img.affine)

    #plot 
    output_file = f'heat_map_{heat_map_number}.png'
    plotting.plot_glass_brain(heat_map, black_bg=True, colorbar=True, vmax=100., display_mode='lyrz',output_file=output_file )
