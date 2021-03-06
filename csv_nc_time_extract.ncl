;******************************************************************************
;
;   Lakemariam Y. Worku - 2019
;
;******************************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "/home/carl/lib/array/is_in_common.ncl"

begin

; Read standard anomaly dates from CSV file using asciiread

        inFile = "djf_trmm_ph8.csv"
        my_table = asciiread(inFile,-1,"string")

        delim = "-"
        csv_year = toint(str_get_field(my_table, 1, delim))
        csv_month = toint(str_get_field(my_table, 2, delim))
        csv_day = toint(str_get_field(my_table, 3, delim))

        csv_time = sprinti("%0.4i", csv_year) + "" + sprinti("%0.2i", csv_month) + "" + sprinti("%0.2i", csv_day)
        csv_ntim = dimsizes(csv_time)
        print(csv_ntim)

;        print(csv_time)

; Read trmm data and its dimension

        f = addfile("/home/carl/data/trmm/fullres/trmm3b42.mc.nc", "r")
        precip = f->precip
        time = f->time
        lat  = f->lat
        lon  = f->lon
        
        utc_date = cd_calendar(time,0)
        nc_year = toint(utc_date(:,0))
	nc_month = toint(utc_date(:,1))
	nc_day = toint(utc_date(:,2))
        
        nc_time = sprinti("%0.4i", nc_year) + "" + sprinti("%0.2i", nc_month) + "" + sprinti("%0.2i", nc_day)
      
        nc_ntim = dimsizes(nc_time)
	print(nc_ntim)

;	print(cd_string(time,""))

; Write new netCDF file that has a time dimension similar to CSV file
        
        ncInd = common_ind( nc_time, csv_time ) 
        outFile = "djf_trmm_ph8.nc"
        system("rm -f " + outFile)
        fout = addfile(outFile, "c")
        fout->precip = precip(ncInd,:,:)
end














