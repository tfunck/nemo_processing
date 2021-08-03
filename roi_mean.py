import numpy as np
import sys


def main():
    bp=np.loadtxt(sys.argv[1])
    mask=np.loadtxt(sys.argv[2])
    idx=(mask > 0) & (np.isnan(bp) == False) 
    if sum(idx)==0:
        print(np.NaN)
        return(np.NaN)
    m=np.mean(bp[ idx ])
    print m
    return(m)

if __name__ == "__main__":
    main()
