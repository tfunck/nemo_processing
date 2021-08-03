import pandas as pd
from sys import argv

df= pd.read_csv(argv[1]) 
A = pd.isnull(df).sum()
B = df.sum()
indices= (A > 0) | (B == 0)
df = pd.concat([A[indices  > 0], B[indices > 0]], axis=1)
df.columns = ['Number of NaN', 'Sum of ChaCo']
print df
