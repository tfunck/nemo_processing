import os
import sys
import re
from ChaCoCalc import ChaCoCalc
from scipy.io import loadmat
from sys import exit
import pandas as pd
import pyminc.volumes.factory as pyminc
import numpy as np
from glob import glob

clobber=True

in_dir = "/data1/projects/stroke_pic/bids/sub-NS*/*/anat/"  # "/data1/projects/stroke_pic/infarct_mni/" # sys.argv[1]
#civet_dir = "/data1/projects/stroke_pic/civet/"  #sys.argv[2]
aal_fn = "/data1/projects/NeMo/aal/aal2_1mm.mnc" #sys.argv[3]
out_dir= "/data1/projects/stroke_pic/ChaCoCalc/" #sys.argv[4]
remote_dir="/data1/projects/stroke_pic/remote-pic_mni/"

t1_list     = glob(in_dir+'sub*_T1w.nii')
lesion_list = glob(in_dir+'sub*_lesion-negative_T1w-coreg.nii')

print("Calculate ChaCo matrix for each subject")
mat_files=[]
#NOTE infarct masks in mni space should be 1mm step
#for sub in subjects:
#to_check_list = [ 'sub-NS-001-cj', 'sub-NS-003-at', 'sub-NS-005-RDI', 'sub-NS-005-jm' ]
#new_sub_list = ['sub-NS-A-J-9002', 'sub-NS-C-L-9054', 'sub-NS-DHA-9032', 'sub-NS-F-B-9023', 'sub-NS-G-G-9040', 'sub-NS-GUD-9001', 'sub-NS-I-C-9028', 'sub-NS-J-B-9036', 'sub-NS-JGC-9003', 'sub-NS-J-M-9008', 'sub-NS-J-P-9043', 'sub-NS-K-T-9042', 'sub-NS-MLC-9024', 'sub-NS-MTM-9035', 'sub-NS-O-D-9014', 'sub-NS-P-M-9007', 'sub-NS-R-D-9049', 'sub-NS-R-W-9006', 'sub-NS-S-D-9018'  ] 
new_sub_list=[ "sub-NS-001-cf-060",        "sub-NS-001-gd-062",        "sub-NS-001-jb-059",        "sub-NS-002-ah-015",        "sub-NS-002-aj-037",        "sub-NS-002-as-013",        "sub-NS-002-gs-063",        "sub-NS-002-mf-051",        "sub-NS-002-mk-012",        "sub-NS-004-gf-33",        "sub-NS-004-mo-047",        "sub-NS-004-ng-034",        "sub-NS-004-ns-044",        "sub-NS-005-ae-038",        "sub-NS-005-jmi-052",        "sub-NS-005-mb-041"] 

#some of the subjects in new_sub_list had bad infarct masks or failed registration. some need to be rerun
new_sub_list=["sub-NS-001-gd-062", "sub-NS-005-jmi", "sub-NS-005-mb", "sub-NS-005-ae-038", "sub-NS-004-mo-047", "sub-NS-002-mk-012", "sub-NS-001-jb-059", "sub-NS-002-gs-063" ]

#subjects that weren't properly normalized
new_sub_list=[ "sub-NS-005-jmi", "sub-NS-005-mb", "sub-NS-004-mo-047" ]
for t1 in t1_list:
    #if not name in to_check_list : continue
    name = os.path.basename(t1).split('_')[0]
    if not name in new_sub_list : continue
    ses = os.path.basename(t1).split('_')[1]
    name_full='_'.join(os.path.basename(t1).split('_')[0:3])
    print('name_ull', name_full)
    lesion = [ f for f in lesion_list if name in f   ]
    #lesion = [ f for f in lesion_list if name_full in f   ]
    if lesion != []: lesion=lesion[0]
    else: 
        print 'Could not find lesion file'
        continue
    sub_out_dir = out_dir + os.sep + name + os.sep + ses #os.path.splitext(sub)[0]
    if not os.path.exists(sub_out_dir):  os.makedirs(sub_out_dir)
    ChaCoMat = sub_out_dir + os.sep + "ChaCo116_MNI.mat"
    mat_files.append(ChaCoMat)
    print 'name full: ', name_full
    print 't1: ', t1 
    print 'lesion ', lesion
    
    if not os.path.exists( ChaCoMat ) or clobber:
        try :
            print("Run ChaCoCalc")
            ChaCoCalc(lesion, sub_out_dir, [t1, 't1'], 'MNI')
        except RuntimeError :
            pass
        
#files=[]
#subjects = [ f for f in files if '.nii' in f ]
#mat_files=[]
d={}
#print("Read ChaCo matlab outputs for each subject")
##for sub, mat_fn in zip(subjects, mat_files):
for t1 in t1_list:
    name = os.path.basename(t1).split('_')[0]
    ses = os.path.basename(t1).split('_')[1]
    name_full='_'.join(os.path.basename(t1).split('_')[0:3])
    #print  out_dir + name + '/_'+ses+'/ChaCo117_MNI.mat'
    mat_fn = glob(out_dir + name + '/'+ses+'/ChaCo116_MNI.mat')
    print mat_fn 
    if mat_fn == [] : continue
    elif len(mat_fn) >1 : print 'Warning: mat_fn not uniquely specified!\n', mat_fn
    mat_fn = mat_fn[0]


    mat = loadmat(mat_fn)
    #result = mat['ChaCoResults'][0][0][1][0]
    l=[]
    for i in range(1,len(mat['ChaCoResults'][0])) : l.append(mat['ChaCoResults'][0][i][1][0]) 
    ll=np.array(l)
    ll=ll[~np.isnan(ll).any(axis=1)]
    print(ll.shape)
    result=np.mean(ll, axis=0)
    d[name_full] = result

dfo = pd.DataFrame(d)
dfo.to_csv('ChaCo_uncorrected.csv')
exit(0)
df= dfo.copy()
#Load AAL atlas
aal = pyminc.volumeFromFile(aal_fn)

print('Find region maximum ChaCo score  ')
if not os.path.exists('ChaCo.csv') or not os.path.exists('max_ChaCo.csv'):
    max_ChaCo = pd.DataFrame([], columns=["Subject", "Session", "ChaCo"])
    for sub in subjects:
        print(sub)
        x=sub.split('_')
        patient=x[1]
        sess=x[2]
        base="I"
        secondary="F"
        if sess == base:
            print(patient, sess)
            name = os.path.splitext(sub)[0]
            infarct_fn = in_dir +os.sep + name+'.mnc'
            name2 = re.sub('_'+base+'_','_'+secondary+'_', name )
            infarct2_fn = in_dir +os.sep + name2+'.mnc'  
            name = '_'.join(name.split('_')[0:3])
 
            print name
            print infarct_fn, infarct2_fn
            #classify_fn = civet_dir + os.sep + name + os.sep + "/classify/" + name + "_pve_classify.mnc"
            #classify = pyminc.volumeFromFile(classify_fn)
            #idx = classify.data == 2
            #gm = np.zeros(classify.data.shape)
            #gm[idx] = 1

            infarct = pyminc.volumeFromFile(infarct_fn)
            #gm_aal = gm * np.array(aal.data)
            gm_aal = np.array(aal.data)
            aal_lookup = list(np.unique(gm_aal))
            aal_lookup.remove(0)

            overlap = infarct.data * gm_aal

            #rm_labels = np.unique([ int(round(x)) for x in np.unique(overlap.flatten()) ])
            #rm_labels = rm_labels - 1
            #df[name].iloc[rm_labels] = 0
            m=df[name].idxmax()
            chaco_max=df[name].max()
            print('max ChaCo idx', chaco_max, m, aal_lookup[m])
            a=pd.DataFrame(np.array([[patient, base, chaco_max]]), columns=["Subject","Session","ChaCo"] )
            a=pd.DataFrame(np.array([[patient, secondary, chaco_max]]), columns=["Subject","Session","ChaCo"] )
            max_ChaCo=max_ChaCo.append(a)
            
            remote_pic_idx = gm_aal == aal_lookup[m]
            overlap[ remote_pic_idx ] = 1
            overlap[ ~remote_pic_idx ] = 0

            remote_pic_fn = remote_dir + os.sep + name + '_remote-pic.mnc'
            remote_pic = pyminc.volumeLikeFile(infarct_fn, remote_pic_fn)
            remote_pic.data = overlap
            remote_pic.writeFile()
            remote_pic.closeVolume()
            if os.path.exists(infarct2_fn) :
                print 'Secondary', infarct2_fn
                name2 = '_'.join(name2.split('_')[0:3])
                infarct2 = pyminc.volumeFromFile(infarct2_fn)
                overlap2 = infarct2.data * gm_aal
                overlap2[ remote_pic_idx ] = 1
                overlap2[ ~remote_pic_idx ] = 0
                remote_pic2_fn = remote_dir + os.sep + name2 + '_remote-pic.mnc'

                print 'Secondary', remote_pic2_fn
                remote_pic2 = pyminc.volumeLikeFile(infarct2_fn, remote_pic2_fn)
                remote_pic2.data = overlap2
                remote_pic2.writeFile()
                remote_pic2.closeVolume()
    max_ChaCo.to_csv('max_ChaCo.csv', index=False)
    df.to_csv('ChaCo.csv')
else:
    df = pd.read_csv('ChaCo.csv')


remote_pic=df.idxmax(axis=0)
print remote_pic

