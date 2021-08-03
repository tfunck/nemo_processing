import numpy as np
import sys
import pyminc.volumes.factory as pyminc

def main():
    classify = pyminc.volumeFromFile(sys.argv[1])
    infarct = pyminc.volumeFromFile(sys.argv[2])
    idx = classify.data == 3 
    #classify.data[ idx ] = 1 
    #classify.data[ ~idx] = 0
    idx=(classify.data == 3)
    num=np.sum(idx & (infarct.data == 1))
    den=np.sum((classify.data == 3))
    m=num/float(den) 
    print m
    return(m)

if __name__ == "__main__":
    main()
