;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                            
; This script will plot time series analysis                  
; for diurnal cycle in a 3-hourly bases                      
;
;		Lakemariam Y. Worku
;		Carl Schreck                                   
;	           2018                          
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
 function  OneTime(\ 
   targetHour : integer, \
   filename  : string, \
   varname   : string \
) 

begin
   
   f = addfile(filename,"r")
 
   time = f->time
   
; Maritime Continent has local standard time of +9 hour from UTC
; if UTC is used just comment out utcHour + 9 and use the next line
      
   utcHour = toint(cd_string(time, "%H:%M:%S"))
   locHour = utcHour + 9
;   locHour = utcHour
   locHour = where( locHour.ge.24, locHour-24, locHour )
   HourInd = ind( (locHour.eq.targetHour).or.(locHour.eq.targetHour-24) )
 
;  computing time average
   print_clock( "Reading " + targetHour)
   allData = f->$varname$(HourInd)   ;time unlimited

;  print_clock( "Averaging" + targetHour)
   avgData = dim_avg_n_Wrap(allData,0) 

   print(targetHour + " " + avgData + " " + dimsizes(HourInd))
    
   return(avgData) 

end

begin
   
   f = (/"WS12_DJF_fix_land.nc","WS12_DJF_fix_coast.nc","WS12_DJF_fix_sea.nc"/) 
   
   hours = (/0,3,6,9,12,15,18,21,24/)
   dimHour = dimsizes(hours)

   dimName = dimsizes(f)
   yData = new((/dimName,dimHour/),float)
   do n=0,dimHour-1
     do b=0, dimName-1 
        yData(b,n) = OneTime(hours(n),f(b),"IRregime")
     end do
   end do

;....................... Open Workstation 
 
  wks = gsn_open_wks("png","IRWS12_Time_Series_utc")
  plotDpi = 300

;***************************************************************
;      Resource Setting for f2
;***************************************************************
  res = True 
  res@gsnFrame = False
  res@gsnDraw = False
  res@gsnLeftString = "IR-WS12"
  res@gsnRightString = "%"
  res@tiYAxisString = "Frequency"; (*100)"
  res@lbOrientation = "Horizontal"

  res@xyLineThicknessF = 5.0
  res@trYMinF = 0.0
  res@trYMaxF = 0.8
  res@vpWidthF = 0.8
  res@vpHeightF = 0.4
  res@tiXAxisFont = 21
  res@tiYAxisFont = 21
;  res@tmYROn = False
;  res@tmXTOn = False
  res@pmLegendDisplayMode    = "Always"
  res@lgPerimOn              = False
  res@pmLegendOrthogonalPosF = -0.45
  res@pmLegendParallelPosF = 0.77
;  res2@xyLineThicknessF = 2.0
  res@lgLabelFontHeightF = 0.025
  res@pmLegendWidthF = 0.12
  res@pmLegendHeightF = 0.12
  res@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res@xyLineColors   = (/"Black","Brown3", "Blue3"/) 
; res2@xyMarkLineModes = "Markers"
;  res2@xyMarkers      = (/2,3,4/) 
;  res2@xyMarkerColors := (/"Black","Red", "Blue"/)
  res@xyDashPatterns = (/0, 2, 12/) 
  res@gsnMaximize = True
  res@tmXBLabelsOn  = True
  res@tmXBMajorLengthF        = 0.0
  res@tmXBLabelFontHeightF = 0.02
  res@tmXBLabelFontAspectF = 1.5
  res@tmYLLabelFontHeightF = 0.02
  res@tmYLLabelFontAspectF = 1.5
  res@gsnLeftStringFontHeightF = 0.02
  res@gsnRightStringFontHeightF = 0.02
  res@tmXBTickStartF = 0.0
  res@tmXBTickSpacingF = 3.0
  res@tmXBLabelAngleF = 0.0
  res@tmLabelAutoStride = True
  res@tmEqualizeXYSizes = True
  res@tmXBMode = "Manual"


;*************************************************************
; Plot
;*************************************************************

  plot = gsn_csm_xy(wks, hours, yData, res)

; draw the plot

 draw(plot)
 frame(wks)
 delete(wks)

end  

