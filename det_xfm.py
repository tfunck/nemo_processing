from sys import argv
from re import sub
import numpy as np

ar=[]
i=0
for l in open(argv[1],'r').readlines():
    if i >= 6:
        lsplit = sub(';', '', sub('\n','', l)).split(' ')[1:4] 
        l0 = [ float(f) for f in  lsplit  ]
        ar += [l0]
    i+=1

ar = np.array(ar)

print(np.linalg.det(ar), np.linalg.eig(ar)[0][0])
