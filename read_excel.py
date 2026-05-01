import pandas as pd
import json

df = pd.read_excel('Category_Hirerchy.xlsx')
cols = df.columns
data = {}
for c in cols:
    cat = c if 'Unnamed' not in c else df[c][0]
    vals = [str(x) for x in df[c].dropna().tolist()]
    if 'Unnamed' in c:
        vals = vals[1:]
    data[str(cat)] = vals

print(json.dumps(data, indent=2))
