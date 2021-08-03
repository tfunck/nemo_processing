import pandas as pd
import numpy as np
from glob import glob
#Missing 01, 05, 09, 11 , 12_I, 16, 22, 24, 25,

sub_ids=["01_I", "01_F", "02_F", "02_I", "03_I" , "03_F" , "04_I" , "04_F" , "06_I" , "06_F" , "07_I" , "07_F" , "08_I" , "10_I","10_F" , "12_F" , "13_I" , "13_F" , "14_I" , "14_F" , "15_I" , "15_F" , "17_I" , "17_F" , "18_I" , "19_I","19_F" , "20_I" , "20_F" , "21_I" , "21_F" , "23_I" , "23_F", "26_I" , "26_F", "28_I" , "28_F" , "29_I" , "30_I" , "30_F" , "31_F" , "32_I" , "32_F" , "33_I" , "33_F" , "34_I" , "34_F" ,  "35_I", "35_F" , "38_I", "38_F", "40_I", "40_F", "41_I"]

d1={"CIVET":"civet", "PET":"pet"}
d2={"Infarct":"infarct_mni/", "Remote-PIC":"remote-pic_nat/", "FLAIR":"flair_nat/", "BP":"results/base/tka/"}
colnames= list(d1.keys()) + list(d2.keys())
n=len(colnames)

df=pd.DataFrame( np.zeros([len(sub_ids), n], dtype=int), columns=colnames  ) 
df.index=sub_ids
for i in range(len(sub_ids)):
    sub=sub_ids[i]
    #print(sub)
    for t, path in d1.items():
        fn=path+"/GPI_P"+sub+"*"
        if len(glob(fn)) > 0:
            df[t][i]=1
        #print(fn, df[t][i])

    for t,path in d2.items():
        fn=path+"/GPI_P"+sub+"*.mnc"
        if len(glob(fn)) > 0:
            df[t][i]=1
        #print(fn, df[t][i])

df["Total"]=df.sum(axis=1)
df.to_csv("check_subjects.csv")

print(df[ (df["Total"] < n) & (df["BP"] == 0) ])
