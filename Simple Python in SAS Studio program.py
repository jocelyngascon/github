from datetime import date
year = date.today().year
print("Bonjour à notre session du " + str(date.today()) + "qui est bel et bien en " +str(year))    

df=SAS.sd2df("sashelp.class")
print(df)

df['year']= 2022
SAS.df2sd(df,"WORK.DEMO2")