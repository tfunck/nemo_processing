import matlab.engine
import sys

def ChaCoCalc(DamageFileName,StrSave, Coreg2MNI=[],CalcSpace=[],atlassize=[],NumWorkers=1,dispMask=[],coregOnly=[]):
    eng = matlab.engine.start_matlab()
    print 'DamageFileName'
    print DamageFileName
    print 'Coreg2MNI'
    print Coreg2MNI
    try :
        eng.ChaCoCalc(DamageFileName,Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly)
    except matlab.engine.MatlabExecutionError :
        pass

def myassign(a,i):
    try:
        a[i]
    except IndexError:
        return('')
    return(a[i])

def main(args=None):
    if args is None:
        args=sys.argv
    
    DamageFileName=myassign(args, 1)
    StrSave=myassign(args,2)
    Coreg2MNI=myassign(args,3)
    CalcSpace=myassign(args,4)
    atlassize=myassign(args,5)
    NumWorkers=1 #myassign(args,5)
    dispMask=myassign(args,6)
    coregOnly=myassign(args,7)
    ChaCoCalc(DamageFileName, Coreg2MNI,CalcSpace,atlassize,StrSave,NumWorkers,dispMask,coregOnly)


if __name__ == "__main__":
        main()

