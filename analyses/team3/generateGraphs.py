#!/usr/bin/env python
# coding: utf-8

# In[5]:

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.ticker as ticker
import matplotlib.pyplot as plt
import matplotlib.dates as md
from matplotlib.ticker import MultipleLocator
import itertools
#import plotly.graph_objects as go

get_ipython().run_line_magic('matplotlib', 'inline')



def transformSeriesFirstStep(df):
    df1 = pd.DataFrame(df)
    df1.reset_index(inplace=True)
    df1['year'] = 2022
    df1['forecasted'] = 'Y'
    return df1

def transformDF(df):
    df['day'] = 1
    df['Time Period'] = pd.to_datetime(df[['year','month', 'day']])
    return df

def dataTransformation(df, dateColumn, columnForAnalysis, isDollars):
    if 'year' in df.columns:
        pass
    else:
        df['year'] = df[dateColumn].dt.year
        df['month'] = df[dateColumn].dt.month

    #generate zeros for graph so gaps can be shown 
    years=[2019,2020,2021]
    months = range(1,13)    #for some reason range() isn't working
    result = itertools.product(years, months)
    zerosDF = pd.DataFrame(result, columns=['year', 'month'])
    zerosDF = zerosDF[:-3] #remove bottom rows because dates don't go that far

    
    if (isDollars.upper() == "YES"): #if the data is money, sum the amount
        dfGroupByFYMonth = df.groupby(['year','month']).sum()
    else: #if unit is not money, then it represents number of people, so return a count
        dfGroupByFYMonth = df.groupby(['year','month']).count()
        
    dfGroupByFYMonth = dfGroupByFYMonth.merge(zerosDF, how="outer", on=['month','year'])
    dfGroupByFYMonth[columnForAnalysis] = dfGroupByFYMonth[columnForAnalysis].fillna(0)
    dfGroupByFYMonthAvg2022 = dfGroupByFYMonth.groupby(['month']).mean()[columnForAnalysis]
    dfGroupByFYMonthMin2022 = dfGroupByFYMonth.groupby(['month']).min()[columnForAnalysis]
    dfGroupByFYMonthMax2022 = dfGroupByFYMonth.groupby(['month']).max()[columnForAnalysis]

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

    dfGroupByFYMonth = dfGroupByFYMonth[['year','month',columnForAnalysis,'Time Period', 'forecasted']]
   
    
    
    return [dfGroupByFYMonth, dfGroupByFYMonthMax2022, dfGroupByFYMonthMin2022]

def generateIndividualGraph(graphTitle, actualsDF, MinProjectionDF, MaxProjectionDF, columnForAnalysis, yAxisName):
    sns.set(rc={'figure.figsize':(10,8), "xtick.bottom" : True, "ytick.left" : True})
    ax = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = actualsDF, style = 'forecasted', color = '#5D5177')
    ax1 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = MinProjectionDF, alpha  = 0.1, color = '#5D5177')
    ax2 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = MaxProjectionDF, alpha  = 0.1, color = '#5D5177')
    
    ax.set(ylabel=yAxisName)
    ax.yaxis.set_major_formatter(ticker.StrMethodFormatter('{x:,.0f}'))
    ax.set_title(graphTitle, fontsize=20)
    ax.set_facecolor(color='#eeedf1')
    
    ax.xaxis.set_major_formatter(md.DateFormatter('%m-%Y'))
    ax.xaxis.set_major_locator(locator=md.MonthLocator(bymonth=(6, 12)))
    ax.tick_params(axis = 'x', which = 'major', length = 10)
    plt.setp(ax.xaxis.get_majorticklabels(), rotation = 60)
    
    ax.xaxis.set_minor_locator(md.MonthLocator())
    ax.tick_params(axis = 'x', which = 'minor', length = 5)
    ax.grid(True)
    
    
    
    plt.legend(labels=["Actuals","Forecasted Values"], bbox_to_anchor=(1.05, 1))
    try:
        ax.fill_between(x = MinProjectionDF['Time Period'], y1 = MinProjectionDF[columnForAnalysis], y2 = MaxProjectionDF[columnForAnalysis], color="#410A45", alpha=0.08)
    except:
        print("cannot fill in")
    else:
        ax.fill_between(x = MinProjectionDF['Time Period'], y1 = MinProjectionDF[columnForAnalysis], y2 = MaxProjectionDF[columnForAnalysis], color="#410A45", alpha=0.08) 
        #print("this is a test for else")
    finally:
        plt.show() 
        #print("this is a test for finally")


# In[8]:


#generate overall graph first
#then go by column to iterate


def generateGraphSet(dataFrameNameForTitle, df, dateColumn, specialColumnForCategory, listOfCategories, columnForAnalysis, yAxisNameForGraph, isDollars):
    #dataFrameNameForTitle - name for head graph
    #df - dataFrame for analysis
    #dateColumn - column to use for graphs
    #specialColumn - column to use for separate graphs
            
    #listOfCategories = df[specialColumnForCategory].unique() #create list for iteration
    #is dollars - knows to sum data
    
    dfGroupByFYMonth = dataTransformation(df, dateColumn, columnForAnalysis, isDollars)[0]
    dfGroupByFYMonthMax2022 = dataTransformation(df, dateColumn,columnForAnalysis, isDollars)[1]
    dfGroupByFYMonthMin2022 = dataTransformation(df, dateColumn, columnForAnalysis, isDollars)[2]
    
    #generate graph for full dataset
    graphTitleVar = dataFrameNameForTitle + ' Over Time'
    generateIndividualGraph(columnForAnalysis = columnForAnalysis, graphTitle = graphTitleVar, actualsDF = dfGroupByFYMonth, 
            MaxProjectionDF = dfGroupByFYMonthMax2022, MinProjectionDF = dfGroupByFYMonthMin2022, yAxisName = yAxisNameForGraph)
    
    for subcategory in listOfCategories:
        dfSubCat = df[df[specialColumnForCategory] == subcategory]
        
        dfGroupByFYMonthSubcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isDollars)[0]
        dfGroupByFYMonthMax2022Subcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isDollars)[1]
        dfGroupByFYMonthMin2022Subcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isDollars)[2] 
        
        subcategoryGraphTitle = dataFrameNameForTitle + ' Over Time Subcategory:' + '\n' + subcategory 
        generateIndividualGraph(graphTitle = subcategoryGraphTitle, columnForAnalysis = columnForAnalysis,
                yAxisName = yAxisNameForGraph, actualsDF = dfGroupByFYMonthSubcat,
                MinProjectionDF = dfGroupByFYMonthMin2022Subcat, MaxProjectionDF = dfGroupByFYMonthMax2022Subcat)
        #print(dfGroupByFYMonthSubcat)


# In[ ]:





# In[9]:


"""dateColumn = 'assistance_date'
df = pantryData
df['year'] = df[dateColumn].dt.year
df['month'] = df[dateColumn].dt.month

dfGroupByFYMonth = df.groupby(['year','month']).count()

dfGroupByFYMonthAvg2022 = dfGroupByFYMonth.groupby(['month']).mean()[columnForAnalysis]
dfGroupByFYMonthMin2022 = dfGroupByFYMonth.groupby(['month']).min()[columnForAnalysis]
dfGroupByFYMonthMax2022 = dfGroupByFYMonth.groupby(['month']).max()[columnForAnalysis]
    
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

dfGroupByFYMonth = dfGroupByFYMonth[['year','month',columnForAnalysis,'Time Period', 'forecasted']]
"""


# In[10]:


"""sns.set(rc={'figure.figsize':(8,6)})
ax = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = dfGroupByFYMonth, style = 'forecasted')
ax1 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = dfGroupByFYMonthMax2022,alpha  = 0.01)
ax2 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = dfGroupByFYMonthMin2022, alpha  = 0.01)
ax.fill_between(x = dfGroupByFYMonthMin2022['Time Period'], y1 = dfGroupByFYMonthMin2022[columnForAnalysis], y2 = dfGroupByFYMonthMax2022[columnForAnalysis], color="blue", alpha=0.1)
ax.set_title("Number food pantry visits plot by Month", fontsize=16)
plt.show() """   


# In[11]:


#generateIndividualGraph(columnForAnalysis, "Number food pantry visits plot by Month")


# In[ ]:





# In[ ]:




