#!/usr/bin/env python
# coding: utf-8

#################
# Load Packages #
#################

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.ticker as ticker
import matplotlib.pyplot as plt
import matplotlib.dates as md
from matplotlib.ticker import MultipleLocator
import itertools

get_ipython().run_line_magic('matplotlib', 'inline')

# The purpose of this code is to take a 

####################
# Create Functions #
####################

#The original data is aggregated
#These early functions are done to prep the data for graphing
#2022 data is a min/max range by month with an average value

def transformSeriesFirstStep(initialSeries):
    #initialSeries - takes series from Group By, and turns it into dataframe
    #First step of data transformation
    #Makes data dataframe, resets the index, adds column that's forecasted data
    #Output is the new dataframe
    
    df1 = pd.DataFrame(initialSeries)
    df1.reset_index(inplace=True)
    df1['year'] = 2022
    df1['forecasted'] = 'Y'
    return df1

def transformDFAddDate(df):
    #Takes dataframe adds day as first of the month and then creates a date problem
    #This is done to initialSeries and the original data so it can be graph
    #Output is the dataframe
    
    df['day'] = 1
    df['Time Period'] = pd.to_datetime(df[['year','month', 'day']])
    return df

#final data transformation to prep original data and forecasted (2022) data
def dataTransformation(df, dateColumn, columnForAnalysis, isSummed):
    #df - original dataFrame
    #dateColumn - column in the original dataframe with the 
    #isSummed- 'Yes' or 'No' based on whether data should be summed (dollars or pounds) or counted (number of volunteer services)
    
    #make sure in the original dataframe there is a month 
    if 'year' in df.columns:
        pass
    else:  #if 'year' and 'month' are not columns, then create it for the dataframe
        df['year'] = df[dateColumn].dt.year
        df['month'] = df[dateColumn].dt.month

    #these steps create a dataframe that spans the entire timeframe of the original data
    #ex: month year
        #1      2019
        #2      2019
        #...
        #9      2021
    #it gets merged with the original data so gaps (zeros) show up in the graph
    years=[2019,2020,2021]
    months = range(1,13)    #generate month numbers
    cartesianJoinMonthsYears = itertools.product(years, months) 
    zerosDF = pd.DataFrame(cartesianJoinMonthsYears, columns=['year', 'month']) 
    zerosDF = zerosDF[:-3] #remove bottom rows because data doesn't go past Sept 2021
    
    #aggregate data by month and year
    if (isSummed.upper() == "YES"): #if the data is money, sum the amount
        dfGroupByFYMonth = df.groupby(['year','month']).sum() 
    else: #if unit is not money, then it represents number of people, so return a count
        dfGroupByFYMonth = df.groupby(['year','month']).count()
    
    #create dataFrame that has #########
    dfGroupByFYMonth = dfGroupByFYMonth.merge(zerosDF, how="outer", on=['month','year'])
    dfGroupByFYMonth[columnForAnalysis] = dfGroupByFYMonth[columnForAnalysis].fillna(0)
    dfGroupByFYMonth['forecasted'] = 'N'
    dfGroupByFYMonth = dfGroupByFYMonth.reset_index()
    
    #calculate mean, min, max for original data, becomes forecast values
    dfGroupByFYMonthAvg2022 = dfGroupByFYMonth.groupby(['month']).mean()[columnForAnalysis]
    dfGroupByFYMonthMin2022 = dfGroupByFYMonth.groupby(['month']).min()[columnForAnalysis]
    dfGroupByFYMonthMax2022 = dfGroupByFYMonth.groupby(['month']).max()[columnForAnalysis]
    
    #transform aggregated series into dataframes
    dfGroupByFYMonthMin2022 = transformSeriesFirstStep(dfGroupByFYMonthMin2022)
    dfGroupByFYMonthMax2022 = transformSeriesFirstStep(dfGroupByFYMonthMax2022)
    dfGroupByFYMonthAvg2022 = transformSeriesFirstStep(dfGroupByFYMonthAvg2022)
    
    #append actual data with forecasted average data
    dfGroupByFYMonth = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)
    #dfGroupByFYMonth2 = dfGroupByFYMonth.append(dfGroupByFYMonthAvg2022)
    dfGroupByFYMonth = transformDFAddDate(dfGroupByFYMonth)
    
    #don't append min and max ranges because it's used for highlighted region in graph
    dfGroupByFYMonthMin2022 = transformDFAddDate(dfGroupByFYMonthMin2022)
    dfGroupByFYMonthMax2022 = transformDFAddDate(dfGroupByFYMonthMax2022)
    
    #form dataframe for output
    dfGroupByFYMonth = dfGroupByFYMonth[['year','month',columnForAnalysis,'Time Period', 'forecasted']]
   
    return [dfGroupByFYMonth, dfGroupByFYMonthMax2022, dfGroupByFYMonthMin2022]

def generateIndividualGraph(graphTitle, graphSize, actualsDF, MinProjectionDF, MaxProjectionDF, columnForAnalysis, yAxisName):
    #graph title - title for graph
    #graphSize - set different sizes for graph
    #actualsDF - original DF
    #MinProjectionDF
    #MaxProjectionDF
    #columnForAnalysis
    #yAxisName - name for display on y Axis
    
    sns.set(rc={'figure.figsize':(graphSize[0],graphSize[1]), "xtick.bottom" : True, "ytick.left" : True})
    ax = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = actualsDF, style = 'forecasted', color = '#5D5177')
    
    #create thin lines around min/max range
    ax1 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = MinProjectionDF, alpha  = 0.1, color = '#5D5177')
    ax2 = sns.lineplot(x = 'Time Period', y = columnForAnalysis, data = MaxProjectionDF, alpha  = 0.1, color = '#5D5177')
    
    ax.set(ylabel=yAxisName)
    ax.yaxis.set_major_formatter(ticker.StrMethodFormatter('{x:,.0f}'))
    ax.set_title(graphTitle, fontsize=20)
    ax.set_facecolor(color='#eeedf1')
    
    #create tick marks and grid
    ax.xaxis.set_major_formatter(md.DateFormatter('%m-%Y'))
    ax.xaxis.set_major_locator(locator=md.MonthLocator(bymonth=(6, 12)))
    ax.tick_params(axis = 'x', which = 'major', length = 10)
    plt.setp(ax.xaxis.get_majorticklabels(), rotation = 60)
    ax.xaxis.set_minor_locator(md.MonthLocator())
    ax.tick_params(axis = 'x', which = 'minor', length = 5)
    ax.grid(True)
    
    plt.legend(labels=["Actuals","Forecasted Values"], bbox_to_anchor=(1.05, 1)) #create legend
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


#generate overall graph first
#then go by column to iterate

def generateGraphSet(dataFrameNameForTitle, df, dateColumn, specialColumnForCategory, listOfCategories, columnForAnalysis, yAxisNameForGraph, isSummed):
    #dataFrameNameForTitle - name for head graph
    #df - dataFrame for analysis
    #dateColumn - column to use for graphs
    #specialColumn - column to use for separate graphs
            
    #listOfCategories = df[specialColumnForCategory].unique() #create list for iteration
    #is dollars - knows to sum data
    
    dfGroupByFYMonth = dataTransformation(df, dateColumn, columnForAnalysis, isSummed)[0]
    dfGroupByFYMonthMax2022 = dataTransformation(df, dateColumn,columnForAnalysis, isSummed)[1]
    dfGroupByFYMonthMin2022 = dataTransformation(df, dateColumn, columnForAnalysis, isSummed)[2]
    
    #generate graph for full dataset
    graphTitleVar = dataFrameNameForTitle + ' Over Time'
    generateIndividualGraph(columnForAnalysis = columnForAnalysis, graphTitle = graphTitleVar, graphSize = [10,8], actualsDF = dfGroupByFYMonth, 
            MaxProjectionDF = dfGroupByFYMonthMax2022, MinProjectionDF = dfGroupByFYMonthMin2022, yAxisName = yAxisNameForGraph)
    
    for subcategory in listOfCategories:
        dfSubCat = df[df[specialColumnForCategory] == subcategory]
        
        dfGroupByFYMonthSubcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isSummed)[0]
        dfGroupByFYMonthMax2022Subcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isSummed)[1]
        dfGroupByFYMonthMin2022Subcat = dataTransformation(dfSubCat, dateColumn, columnForAnalysis, isSummed)[2] 
        
        subcategoryGraphTitle = dataFrameNameForTitle + ' Over Time Subcategory:' + '\n' + subcategory 
        generateIndividualGraph(graphTitle = subcategoryGraphTitle, columnForAnalysis = columnForAnalysis, graphSize = [10,4],
                yAxisName = yAxisNameForGraph, actualsDF = dfGroupByFYMonthSubcat,
                MinProjectionDF = dfGroupByFYMonthMin2022Subcat, MaxProjectionDF = dfGroupByFYMonthMax2022Subcat)



