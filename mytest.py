from scipy.io import loadmat

def run(A):
    n=len(A)
    print(n)
    if n > 0:
        for x in range(n):
            print(x)
            if len(A[x]) == 116:
                print(A[x])
            if A[x] == 'Mean Results': print(A[x]) 
            run(A[x])


a=loadmat('./ChaCo116_MNI.mat')
#run(a['ChaCoResults'] )
print(a['ChaCoResults']['Mean Results'])

