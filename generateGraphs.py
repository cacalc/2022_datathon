#!/usr/bin/env python
# coding: utf-8

# In[100]:


import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
#import plotly.graph_objects as go

get_ipython().run_line_magic('matplotlib', 'inline')


# In[101]:


pantryData = pd.read_csv("pantry_anonymized.csv")
pantryData = pantryData[pantryData['unit'] == 'Pounds'] #look at dollars later? maybe not because there's only 100 records
pantryData['assistance_date'] = pd.to_datetime(pantryData['assistance_date'])
pantryData.columns
pantryData['assistance_category'].value_counts()


# In[110]:


def transformSeriesFirstStep(df):
    df1 = pd.DataFrame(df)
    df1.reset_index(inplace=True)
    df1['year'] = 2022
    df1['forecasted'] = 'Y'
    return df1

def transformDF(df):
    df['day'] = 1
    df['Time_Period'] = pd.to_datetime(df[['year','month', 'day']])
    return df

def dataTransformation(df):
    if 'year' in df.columns:
        pass
    
    else:
        df['year'] = df[dateColumn].dt.year
        df['month'] = df[dateColumn].dt.month

    dfGroupByFYMonth = df.groupby(['year','month']).count()

    dfGroupByFYMonthAvg2022 = dfGroupByFYMonth.groupby(['month']).mean()['amount']
    dfGroupByFYMonthMin2022 = dfGroupByFYMonth.groupby(['month']).min()['amount']
    dfGroupByFYMonthMax2022 = dfGroupByFYMonth.groupby(['month']).max()['amount']

    dfGroupByFYMonthMin2022 = transformSeriesFirstStep(dfGroupByFYMonthMin2022)
    dfGroupByFYMonthMax2022 = transformSeriesFirstStep(dfGroupByFYMonthMax2022)
    dfGroupByFYMonthAvg2022 = transformSeriesFirstStep(dfGroupByFYMonthAvg2022)

    dfGroupByFYMonth = dfGroupByFYMonth.reset_index()
    dfGroupByFYMonth['forecasted'] = 'N'
    dfGroupByFYMonth = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)

    dfGroupByFYMonth2 = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)


    dfGroupByFYMonthMin2022 = transformDF(dfGroupByFYMonthMin2022)
    dfGroupByFYMonthMax2022 = transformDF(dfGroupByFYMonthMax2022)
    dfGroupByFYMonth = transformDF(dfGroupByFYMonth)

    dfGroupByFYMonth = dfGroupByFYMonth[['year','month','amount','Time_Period', 'forecasted']]
    
    return [dfGroupByFYMonth, dfGroupByFYMonthMax2022, dfGroupByFYMonthMin2022]

def generateIndividualGraph(yAxisName, graphTitle, actualsDF, MinProjectionDF, MaxProjectionDF):
    sns.set(rc={'figure.figsize':(8,6)})
    ax = sns.lineplot(x = 'Time_Period', y = yAxisName, data = actualsDF, style = 'forecasted')
    ax1 = sns.lineplot(x = 'Time_Period', y = yAxisName, data = MinProjectionDF, alpha  = 0.01)
    ax2 = sns.lineplot(x = 'Time_Period', y = yAxisName, data = MaxProjectionDF, alpha  = 0.01)
    ax.set_title(graphTitle, fontsize=16)
    try:
        ax.fill_between(x = dfGroupByFYMonthMin2022['Time_Period'], y1 = MaxProjectionDF[yAxisName], y2 = MinProjectionDF[yAxisName], color="blue", alpha=0.1)
    except:
        plt.show()
    
    finally:
        plt.show()  


# In[113]:


#generate overall graph first
#then go by column to iterate


def generateGraphSet(df, dateColumn, specialColumnForCategory, listOfCategories, yAxisNameForGraph):
    #df - dataFrame for analysis
    #dateColumn - column to use for graphs
    #specialColumn - column to use for separate graphs
            
    #listOfCategories = df[specialColumnForCategory].unique() #create list for iteration
    
    dfGroupByFYMonth = dataTransformation(df)[0]
    dfGroupByFYMonthMax2022 = dataTransformation(df)[1]
    dfGroupByFYMonthMin2022 = dataTransformation(df)[2]  
    generateIndividualGraph(yAxisNameForGraph, 'test', dfGroupByFYMonth, dfGroupByFYMonthMax2022, dfGroupByFYMonthMin2022)
    print(df.columns)
    
    for subcategory in listOfCategories:
        dfSubCat = df[df[specialColumnForCategory] == subcategory]

        dfGroupByFYMonthSubcat = dataTransformation(dfSubCat)[0]
        dfGroupByFYMonthMax2022Subcat = dataTransformation(dfSubCat)[1]
        dfGroupByFYMonthMin2022Subcat = dataTransformation(dfSubCat)[2]  
        generateIndividualGraph(yAxisNameForGraph, subcategory, dfGroupByFYMonthSubcat, dfGroupByFYMonthMin2022Subcat, dfGroupByFYMonthMax2022Subcat)
        #print(dfGroupByFYMonthSubcat)


# In[114]:


generateGraphSet(pantryData,'assistance_date','assistance_category', 
                 ['Food Pantry: Holiday Baskets','Food Pantry: Food Pantry Poundage'],
                 'amount')


# In[33]:


dateColumn = 'assistance_date'
df = pantryData
df['year'] = df[dateColumn].dt.year
df['month'] = df[dateColumn].dt.month

dfGroupByFYMonth = df.groupby(['year','month']).count()

dfGroupByFYMonthAvg2022 = dfGroupByFYMonth.groupby(['month']).mean()['amount']
dfGroupByFYMonthMin2022 = dfGroupByFYMonth.groupby(['month']).min()['amount']
dfGroupByFYMonthMax2022 = dfGroupByFYMonth.groupby(['month']).max()['amount']
    
dfGroupByFYMonthMin2022 = transformSeriesFirstStep(dfGroupByFYMonthMin2022)
dfGroupByFYMonthMax2022 = transformSeriesFirstStep(dfGroupByFYMonthMax2022)
dfGroupByFYMonthAvg2022 = transformSeriesFirstStep(dfGroupByFYMonthAvg2022)

dfGroupByFYMonth = dfGroupByFYMonth.reset_index()
dfGroupByFYMonth['forecasted'] = 'N'
dfGroupByFYMonth = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)

dfGroupByFYMonth2 = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)


dfGroupByFYMonthMin2022 = transformDF(dfGroupByFYMonthMin2022)
dfGroupByFYMonthMax2022 = transformDF(dfGroupByFYMonthMax2022)
dfGroupByFYMonth = transformDF(dfGroupByFYMonth)

dfGroupByFYMonth = dfGroupByFYMonth[['year','month','amount','Time_Period', 'forecasted']]


# In[31]:


sns.set(rc={'figure.figsize':(8,6)})
ax = sns.lineplot(x = 'Time_Period', y = 'amount', data = dfGroupByFYMonth, style = 'forecasted')
ax1 = sns.lineplot(x = 'Time_Period', y = 'amount', data = dfGroupByFYMonthMax2022,alpha  = 0.01)
ax2 = sns.lineplot(x = 'Time_Period', y = 'amount', data = dfGroupByFYMonthMin2022, alpha  = 0.01)
ax.fill_between(x = dfGroupByFYMonthMin2022['Time_Period'], y1 = dfGroupByFYMonthMin2022['amount'], y2 = dfGroupByFYMonthMax2022['amount'], color="blue", alpha=0.1)
ax.set_title("Number food pantry visits plot by Month", fontsize=16)
plt.show()    


# In[35]:


generateIndividualGraph('amount', "Number food pantry visits plot by Month")


# In[ ]:





# In[ ]:




