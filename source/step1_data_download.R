

#################################
### installation packages
if(!require("ncdf4")) install.packages("ncdf4") 
if(!require("tidyverse")) install.packages("tidyverse") 
if(!require("reticulate")) install.packages("reticulate")
if(!require("sf")) install.packages("sf")

### or load them
library(ncdf4);library(tidyverse)
library(reticulate);library(sf)


###### install the api
reticulate::conda_install("r-reticulate","cdsapi",pip=TRUE)
# import python CDS-API
# need to specify the path that was given in the previous step!
cdsapi <- import_from_path('cdsapi', 
                           path="C:/Users/jmr32/Anaconda3/envs/r-reticulate/Lib/site-packages")

# for this step there must exist the file .cdsapirc
## if you started with R go the word document!
server = cdsapi$Client() #start the connection


# ##### make the query for data downloading
query2.0 <- reticulate::r_to_py(list(
  variable= c("sea_surface_temperature"), # variables we want sst now.

  product_type= "reanalysis", #reanalysis dataset
  # 'monthly_averaged_reanalysis',
    year= c("1983"), # the years we want
    month= stringr::str_c(1:12)%>% ## which months we want
    stringr::str_pad(2,"left","0"), #format: "01","01", etc.
    day= stringr::str_pad(1:31,2,"left","0"), # days
    time= stringr::str_c(0:23,"00",sep=":")%>% # times
    stringr::str_pad(5,"left","0"),
  # 'time': '00:00',
  format= "netcdf",
  area = "62/-8/54/1" # North, West, South, East ## this needs to change for Daisy, not Scotland anymore.
))
# 
# 
# ### might want to download montly averaged data instead?
# 
# 
# ### make connection to the sever and start the download!
# ### this will take time! hours if we want all days for a couple of years!
server$retrieve("reanalysis-era5-single-levels", ## the data we want, single levels
                # 'reanalysis-era5-single-levels-monthly-means',
                query2.0, ## the query we want
                "test_era5_all_variables_1983.nc") ## name of the dataset, how we want to save things.
# ##### we might get an error the first time that we need to agree to the terms and conditions
# #### go the website in provided with the error message in the console and agree with the terms
# #### https://cds.climate.copernicus.eu/cdsapp/#!/terms/licence-to-use-copernicus-products



######################################################################
############## we can also create a loop for instance for years
# select years to download
years <- c(1983:2020)
years <- as.character(years)
# group_years <- rep(1:7, each=5) ## we can download 3 years at a time or so
# 
# selection_years <- data.frame(years=years,
#                               group=group_years)
############# need to download regional ER5
# we create the query
# for(i in unique(selection_years$group)){
#   print(i)

  # years_select <- selection_years %>%
  #   filter(group == i)
  
  query_temp <- reticulate::r_to_py(list(
    variable= c("sea_surface_temperature"),
    product_type= "monthly_averaged_reanalysis",
    year= c(as.character(years)),
    month= c( '01', '02', '03', "06",'07', '08', '09'),
   
    time= ('00:00'),
    format= "netcdf",
    area = "62/-3/50/12" # North, West, South, East ## update needed
  ))
  
  #query to get the ncdf
  server$retrieve("reanalysis-era5-single-levels-monthly-means",
                  query_temp,
                  paste("era5_reanlysis_montly_means_sst",
                       #i,
                       "1983_2020",".nc",sep=""))
# }








