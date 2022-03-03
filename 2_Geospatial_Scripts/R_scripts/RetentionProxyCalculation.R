#Retention Rate Calculation
#Casey Kalman

##load packages ---- 
install.packages("tidyverse")
library(tidyverse)

##Set working directory---replace with file path
setwd("C:/Users/tey5/OneDrive - CDC/Genie-PSNUByIMs-Lesotho-Frozen-2022-02-28")
getwd()

##read in files----replace with file name
#I stared with an PSNU by IM MSD file for Lesotho (start with whatever OU is of interest)
#I selected the years and indicators needed for the retention rate proxy calculation
file<-"Genie_PSNU_IM_Lesotho_Frozen_17bb1c29-e4f5-4dff-b52b-f0c51e4df2c5.txt"
file.exists(file)

rawdata<-read_tsv(file,
                  col_types = cols(operatingunit= "c",
                                   operatingunituid= "c",            
                                   psnu= "c",
                                   pasnuuuid="c",
                                   indicator="c",
                                   standardizeddisaggregatee="c",
                                   fisccal_year="c",
                                   qtr1="n",
                                   qtr2="n",
                                   qtr3="n",
                                   qtr4="n",
                                   cumulative="n"))


##reformat----

#format 1
data_long<-rawdata%>%
  filter(standardizeddisaggregate == "Total Numerator" & psnu!="_Military Lesotho")%>% #selected total numerator and filtered out military records
  select(psnu,psnuuid,indicator,fiscal_year,qtr1,qtr2,qtr3,qtr4)%>% #selected the columns needed for the calculation to simplify the resulting table
  gather('qtr1','qtr2','qtr3','qtr4',key="quarter",value=value)%>% #moved the quarters to their own column
  mutate(period=paste(fiscal_year,quarter))%>% #created a new column that merges the quarter and year to create a unique period column
  group_by(psnuuid,psnu,indicator,period)%>%
  summarise(value=sum(value,na.rm=T))%>% #summarize by psnu, uid, and indicator so we have cumulative values for each psnu and indicator of interest
  spread(indicator,value)%>% #moved indicators to columns for proxy calculation
  mutate(retention_proxy=1+(TX_NET_NEW*4-TX_NEW*4)/(TX_CURR-TX_NET_NEW+TX_NEW*4),
         retention_denom=TX_CURR-TX_NET_NEW+TX_NEW,
         uid=psnuuid) #calculated retention proxy and denominator then changed psnuuid column name for easier joining (optional)

head(data_long)

#format2
data_wide<-data_long%>%
  select(psnuuid,psnu,period,retention_proxy,retention_denom)%>%
  gather('retention_proxy',key='indicator',value=value)%>% #move retention proxy label to a new column and retention proxy value to "value" columns
  mutate(attribute=paste(period,indicator),
         uid=psnuuid)%>%
  select(uid,psnu,attribute,value)%>%
  spread(key=attribute,value=value)


#export -- replace second parameter with desired file name
write_csv(data_long,"Lesotho_retentionRates_long.csv")
write_csv(data_wide,"Lesotho_retentionRates_wide.csv")
