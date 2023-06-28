import pandas as pd
from datetime import timedelta

# Read the original CSV file
df_week = pd.read_csv('preprocessing/data/fooddeliverytrips_cambridge.csv')
df_weekend = pd.read_csv('preprocessing/data/fooddeliverytrips_cambridge_sat.csv')

df1=df_week.copy()
df1['day'] = 1

df2=df_week.copy()
df2['day'] = 2

df3=df_week.copy()
df3['day'] = 3

df4=df_week.copy()
df4['day'] = 4

df5=df_week.copy()
df5['day'] = 5

df6=df_weekend.copy()
df6['day'] = 6

df7=df_weekend.copy()
df7['day'] = 7

# Concat the data
df_total = pd.concat([df1,df2,df3,df4,df5,df6,df7], ignore_index=True)

# Writedata to a new CSV file
df_total.to_csv('includes/Demand/food_demand_cambridge_week.csv', index=False)

#For fleet sizing we need the weekend first
if True:
    df1=df_weekend.copy()
    df1['day'] = 1

    df2=df_weekend.copy()
    df2['day'] = 2

    df3=df_week.copy()
    df3['day'] = 3

    df4=df_week.copy()
    df4['day'] = 4

    df5=df_week.copy()
    df5['day'] = 5

    df6=df_week.copy()
    df6['day'] = 6

    df7=df_week.copy()
    df7['day'] = 7
    
    df_total_2 = pd.concat([df1,df2,df3,df4,df5,df6,df7], ignore_index=True)
    df_total_2.to_csv('includes/Demand/food_demand_cambridge_week_weekendfirst.csv', index=False)




