input_table='sashelp.class'
output_table='work.class_transposed'

# get input data from sas into Pandas Dataframe
dfin = SAS.sd2df(input_table)
print("Input data shape is:",dfin.shape)
dfout = dfin.transpose()

# Use row 0 for column names
dfout.columns=dfout.iloc[0]
# Remove row 0
dfout=dfout[1:]

print("Output data shape is:",dfout.shape)
#write Pandas to Dataframe to SAS
SAS.df2sd(dfout, output_table)
