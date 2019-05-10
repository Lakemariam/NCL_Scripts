;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                            
; This script will plot time series analysis                  
; for diurnal cycle in a 3-hourly bases                      
;
;         Lakemariam Y. Worku
;           Carl Schreck 
;              2018
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
   
; 9 hour is added to change UTC time to local standard time in Maritime Continent
; But if only want to use UTC time use only locHour = utcHour 

   utcHour = toint(cd_string(time, "%H:%M:%S"))
   locHour = utcHour + 9          
;   locHour = utcHour
   locHour = where( locHour.ge.24, locHour-24, locHour )
   HourInd = ind( (locHour.eq.targetHour).or.(locHour.eq.targetHour-24) )
;  print(cd_string(time,""))
 
;  computing time average
   print_clock( "Reading " + targetHour)
   allData = f->$varname$(HourInd)   ;time unlimited

;  print_clock( "Averaging" + targetHour)
   avgData = dim_avg_n_Wrap(allData,0) 
;   avgData = avgData*100  

   print(targetHour + " " + avgData + " " + dimsizes(HourInd))
    
   return(avgData) 

end

begin

; read variable and hours

   f1 = (/"trmmDJF_land.nc","trmmDJF_coast.nc","trmmDJF_sea.nc"/)
   f2 = (/"IRWS12_DJFland.nc","IRWS12_DJFcoast.nc","IRWS12_DJFsea.nc"/) 
   f3 = (/"IRWS3_DJFland.nc","IRWS3_DJFcoast.nc","IRWS3_DJFsea.nc"/)  
   f4 = (/"trmmJJA_land.nc","trmmJJA_coast.nc","trmmJJA_sea.nc"/)
   f5 = (/"IRWS12_JJAland.nc","IRWS12_JJAcoast.nc","IRWS12_JJAsea.nc"/)
   f6 = (/"IRWS3_JJAland.nc","IRWS3_JJAcoast.nc","IRWS3_JJAsea.nc"/)
   
   hours = (/0,3,6,9,12,15,18,21,24/)
   dimHour = dimsizes(hours)

  dimName1 = dimsizes(f1)
  xData = new((/dimName1,dimHour/),float)
  do n=0,dimHour-1
     do a=0, dimName1-1
       xData(a,n) = OneTime(hours(n),f1(a),"precip")
    end do
  end do
   

   dimName2 = dimsizes(f2)
   yData = new((/dimName2,dimHour/),float)
   do n=0,dimHour-1
     do b=0, dimName2-1 
        yData(b,n) = OneTime(hours(n),f2(b),"IRregime")
     end do
   end do

  dimName3 = dimsizes(f3)
  zData = new((/dimName3,dimHour/),float)
  do n=0,dimHour-1
     do c=0, dimName3-1 
       zData(c,n) = OneTime(hours(n),f3(c),"IRregime")
    end do
  end do

   dimName4 = dimsizes(f4)
   sData = new((/dimName4,dimHour/),float)
   do n=0,dimHour-1
     do d=0, dimName4-1
        sData(d,n) = OneTime(hours(n),f4(d),"precip")
     end do
   end do

   dimName5 = dimsizes(f5)
   tData = new((/dimName5,dimHour/),float)
   do n=0,dimHour-1
     do e=0, dimName5-1
        tData(e,n) = OneTime(hours(n),f5(e),"IRregime")
      end do
   end do

  dimName6 = dimsizes(f6)
  uData = new((/dimName6,dimHour/),float)
  do n=0,dimHour-1
     do g=0, dimName6-1
       uData(g,n) = OneTime(hours(n),f6(g),"IRregime")
    end do
  end do

;....................... Open Workstation 
 
  wks = gsn_open_wks("png","TS_SW_TRMMIRWS_New")
  plotDpi = 300

;***************************************************************
;      Resource Setting for f1
;***************************************************************

  res1 = True
  res1@gsnFrame = False
  res1@gsnDraw = False
  res1@gsnLeftString = "TMPA"
  res1@gsnRightString = "mm/hr"
  res1@gsnCenterString = "DJF"
  res1@tiYAxisString = "Precipitation"; (*100)"
;  res1@tiXAxisString = "Local Standard Time (hour)"

  res1@lbOrientation = "Horizontal"
  res1@xyLineThicknessF = 7.0
  res1@trYMinF = 0.0
  res1@trYMaxF = 0.5
  res1@vpWidthF = 0.8
  res1@vpHeightF = 0.4
  res1@tiXAxisFont = 21
  res1@tiYAxisFont = 21
; res1@pmLegendDisplayMode    = "Always"
  res1@lgPerimOn              = False
  res1@pmLegendOrthogonalPosF = -0.60
  res1@pmLegendParallelPosF = 0.77
  res1@xyLineThicknessF = 4.0
  res1@lgLabelFontHeightF = 0.025
  res1@pmLegendWidthF = 0.25
  res1@pmLegendHeightF = 0.2
  res1@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res1@xyLineColors   = (/"Black","Brown3", "Blue3"/)
; res1@xyMarkLineModes = "Markers"
;  res1@xyMarkers      = (/2,3,4/)
;  res1@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res1@xyDashPatterns = (/0, 2, 12/)
  res1@gsnMaximize = True
  res1@tmXBLabelsOn  = False
  res1@tmXBMajorLengthF        = 0.0
  res1@tmXBLabelFontHeightF = 0.02
  res1@tmXBLabelFontAspectF = 1.5
  res1@tmYLLabelFontHeightF = 0.02
  res1@tmYLLabelFontAspectF = 1.5
  res1@gsnLeftStringFontHeightF = 0.02
  res1@gsnRightStringFontHeightF = 0.02
  res1@tmXBTickStartF = 0.0
  res1@tmXBTickSpacingF = 3.0
  res1@tmXBLabelAngleF = 0.0
  res1@tmLabelAutoStride = True
  res1@tmEqualizeXYSizes = True
  res1@tmXBMode = "Manual"

;***************************************************************
;      Resource Setting for f2
;***************************************************************
  res2 = True 
  res2@gsnFrame = False
  res2@gsnDraw = False
  res2@gsnLeftString = "IR-WS12"
  res2@gsnRightString = "%"
  res2@tiYAxisString = "Frequency"; (*100)"
  res2@lbOrientation = "Horizontal"

  res2@xyLineThicknessF = 7.0
  res2@trYMinF = 0.0
  res2@trYMaxF = 0.5
  res2@vpWidthF = 0.8
  res2@vpHeightF = 0.4
  res2@tiXAxisFont = 21
  res2@tiYAxisFont = 21
; res2@pmLegendDisplayMode    = "Always"
  res2@lgPerimOn              = False
  res2@pmLegendOrthogonalPosF = -0.30
  res2@pmLegendParallelPosF = 0.77
  res2@xyLineThicknessF = 4.0
  res2@lgLabelFontHeightF = 0.025
  res2@pmLegendWidthF = 0.25
  res2@pmLegendHeightF = 0.2
  res2@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res2@xyLineColors   = (/"Black","Brown3", "Blue3"/) 
; res2@xyMarkLineModes = "Markers"
;  res2@xyMarkers      = (/2,3,4/) 
;  res2@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res2@xyDashPatterns = (/0, 2, 12/) 
  res2@gsnMaximize = True
  res2@tmXBLabelsOn  = False
  res2@tmXBMajorLengthF        = 0.0
  res2@tmXBLabelFontHeightF = 0.02
  res2@tmXBLabelFontAspectF = 1.5
  res2@tmYLLabelFontHeightF = 0.02
  res2@tmYLLabelFontAspectF = 1.5
  res2@gsnLeftStringFontHeightF = 0.02
  res2@gsnRightStringFontHeightF = 0.02
  res2@tmXBTickStartF = 0.0
  res2@tmXBTickSpacingF = 3.0
  res2@tmXBLabelAngleF = 0.0
  res2@tmLabelAutoStride = True
  res2@tmEqualizeXYSizes = True
  res2@tmXBMode = "Manual"

;***************************************************************
;      Resource Setting for f3
;***************************************************************

  res3 = True
  res3@gsnFrame = False
  res3@gsnDraw = False
  res3@gsnLeftString = "IR-WS3"
  res3@gsnRightString = "%"
  res3@tiYAxisString = "Frequency"; (*100)"
  res3@tiXAxisString = "Local Standard Time (hour)"

  res3@xyLineThicknessF = 7.0
  res3@trYMinF = 0.0
  res3@trYMaxF = 0.5
  res3@vpWidthF = 0.8
  res3@vpHeightF = 0.4
  res3@tiXAxisFont = 21
  res3@tiYAxisFont = 21
  res3@pmLegendDisplayMode    = "Always"
  res3@lgPerimOn              = False
  res3@pmLegendOrthogonalPosF = -1.2
  res3@pmLegendParallelPosF = 0.70
  res3@xyLineThicknessF = 4.0
  res3@lgLabelFontHeightF = 0.025
  res3@pmLegendWidthF = 0.25
  res3@pmLegendHeightF = 0.12
  res3@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res3@xyLineColors   = (/"Black","Brown3", "Blue3"/)
;  res3@xyMarkLineModes = "Markers"
;  res3@xyMarkers      = (/2,3,4/)
;  res3@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res3@xyDashPatterns = (/0, 4, 12/)
  res3@gsnMaximize = True
  res3@tmXBLabelsOn  = True
  res3@tmXBMajorLengthF        = 0.0
  res3@tmXBLabelFontHeightF = 0.03
  res3@tmXBLabelFontAspectF = 1.5
  res3@tmYLLabelFontHeightF = 0.03
  res3@tmYLLabelFontAspectF = 1.5
  res3@tmXBTickStartF = 0.0
  res3@tmXBLabelFontHeightF = 0.02
  res3@tmXBLabelFontAspectF = 1.5
  res3@tmYLLabelFontHeightF = 0.02
  res3@tmYLLabelFontAspectF = 1.5
  res3@gsnLeftStringFontHeightF = 0.02
  res3@gsnRightStringFontHeightF = 0.02
  res3@tmXBTickStartF = 0.0
;  res3@tmXBMode = "Explicit"
;  res3@tmXBTickStartF = 0
;  res3@tmXBTickEndF   = 24
  res3@tmXBTickSpacingF = 3.0
  res3@tmXBLabelAngleF = 0.0
  res3@tmLabelAutoStride = True
  res3@tmEqualizeXYSizes = True
  res3@tmXBMode = "Manual"


;***************************************************************
;      Resource Setting for f1
;***************************************************************

  res4 = True
  res4@gsnFrame = False
  res4@gsnDraw = False
  res4@gsnLeftString = "TMPA"
  res4@gsnRightString = "mm/hr"
  res4@gsnCenterString = "JJA"
  res4@tiYAxisString = "Precipitation"; (*100)"
  res4@lbOrientation = "Horizontal"

  res4@xyLineThicknessF = 7.0
  res4@trYMinF = 0.0
  res4@trYMaxF = 0.5
  res4@vpWidthF = 0.8
  res4@vpHeightF = 0.4
  res4@tiXAxisFont = 21
  res4@tiYAxisFont = 21
; res4@pmLegendDisplayMode    = "Always"
  res4@lgPerimOn              = False
  res4@pmLegendOrthogonalPosF = -0.30
  res4@pmLegendParallelPosF = 0.77
  res4@xyLineThicknessF = 4.0
  res4@lgLabelFontHeightF = 0.025
  res4@pmLegendWidthF = 0.25
  res4@pmLegendHeightF = 0.12
  res4@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res4@xyLineColors   = (/"Black","Brown3", "Blue3"/)
;  res4@xyMarkLineModes = "Markers"
;  res4@xyMarkers      = (/2,3,4/)
;  res4@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res4@xyDashPatterns = (/0, 4, 12/)
  res4@gsnMaximize = True
  res4@tmXBLabelsOn  = False
;  res4@tmYLLabelsOn = False
  res4@tmXBMajorLengthF        = 0.0
  res4@tmXBLabelFontHeightF = 0.03
  res4@tmXBLabelFontAspectF = 1.5
  res4@tmYLLabelFontHeightF = 0.03
  res4@tmYLLabelFontAspectF = 1.5
  res4@tmXBTickStartF = 0.0
  res4@tmXBLabelFontHeightF = 0.02
  res4@tmXBLabelFontAspectF = 1.5
  res4@tmYLLabelFontHeightF = 0.02
  res4@tmYLLabelFontAspectF = 1.5
  res4@gsnLeftStringFontHeightF = 0.02
  res4@gsnRightStringFontHeightF = 0.02
  res4@tmXBTickStartF = 0.0
  res4@tmXBTickSpacingF = 3.0
  res4@tmXBLabelAngleF = 0.0
  res4@tmLabelAutoStride = True
  res4@tmEqualizeXYSizes = True
  res4@tmXBMode = "Manual"

;***************************************************************
;      Resource Setting for f2
;***************************************************************

  res5 = True
  res5@gsnFrame = False
  res5@gsnDraw = False
  res5@gsnLeftString = "IR-WS12"
  res5@gsnRightString = "%"
  res5@tiYAxisString = "Frequency"; (*100)"
;  res5@tiXAxisString = "Local Standard Time (hour)"
  res5@lbOrientation = "Horizontal"

  res5@xyLineThicknessF = 7.0
  res5@trYMinF = 0.0
  res5@trYMaxF = 0.5
  res5@vpWidthF = 0.8
  res5@vpHeightF = 0.4
  res5@tiXAxisFont = 21
  res5@tiYAxisFont = 21
; res5@pmLegendDisplayMode    = "Always"
  res5@lgPerimOn              = False
  res5@pmLegendOrthogonalPosF = -0.30
  res5@pmLegendParallelPosF = 0.77
  res5@xyLineThicknessF = 4.0
  res5@lgLabelFontHeightF = 0.025
  res5@pmLegendWidthF = 0.25
  res5@pmLegendHeightF = 0.12
  res5@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res5@xyLineColors   = (/"Black","Brown3", "Blue3"/)
;  res5@xyMarkLineModes = "Markers"
;  res5@xyMarkers      = (/2,3,4/)
;  res5@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res5@xyDashPatterns = (/0, 4, 12/)
  res5@gsnMaximize = True
  res5@tmXBLabelsOn  = False
;  res5@tmYLLabelsOn = False
  res5@tmXBMajorLengthF        = 0.0
  res5@tmXBLabelFontHeightF = 0.02
  res5@tmXBLabelFontAspectF = 1.5
  res5@tmYLLabelFontHeightF = 0.02
  res5@tmYLLabelFontAspectF = 1.5
  res5@gsnLeftStringFontHeightF = 0.02
  res5@gsnRightStringFontHeightF = 0.02
  res5@tmXBTickStartF = 0.0
  res5@tmXBTickSpacingF = 3.0
  res5@tmXBLabelAngleF = 0.0
  res5@tmLabelAutoStride = True
  res5@tmEqualizeXYSizes = True
  res5@tmXBMode = "Manual"

;***************************************************************
;      Resource Setting for f3
;***************************************************************

  res6 = True
  res6@gsnFrame = False
  res6@gsnDraw = False
  res6@gsnLeftString = "IR-WS3"
  res6@tiXAxisString = "Local Standard Time (hour)"
  res6@gsnRightString = "%"
  res6@tiYAxisString = "Frequency"; (*100)"

  res6@xyLineThicknessF = 7.0
  res6@trYMinF = 0.0
  res6@trYMaxF = 0.5
  res6@vpWidthF = 0.8
  res6@vpHeightF = 0.4
  res6@tiXAxisFont = 21
  res6@tiYAxisFont = 21
  res6@pmLegendDisplayMode    = "Always"
  res6@lgPerimOn              = False
  res6@pmLegendOrthogonalPosF = -1.2
  res6@pmLegendParallelPosF = 0.70
  res6@xyLineThicknessF = 4.0
  res6@lgLabelFontHeightF = 0.025
  res6@pmLegendWidthF = 0.25
  res6@pmLegendHeightF = 0.12
  res6@xyExplicitLegendLabels = (/"Land","Coast","Ocean"/)
  res6@xyLineColors   = (/"Black","Brown3", "Blue3"/)
; res6@xyMarkLineModes = "Markers"
;  res6@xyMarkers      = (/2,3,4/)
;  res6@xyMarkerColors := (/"Black","Red", "Blue"/)
;  res6@xyDashPatterns = (/0, 4, 12/)
  res6@gsnMaximize = True
  res6@tmXBLabelsOn  = True
; res6@tmYLLabelsOn = False
;  res6@tmXBTickStartF = 0
;  res6@tmXBTickEndF   = 24
  res6@tmXBMajorLengthF        = 0.0
  res6@tmXBLabelFontHeightF = 0.02
  res6@tmXBLabelFontAspectF = 1.5
  res6@tmYLLabelFontHeightF = 0.02
  res6@tmYLLabelFontAspectF = 1.5
  res6@gsnLeftStringFontHeightF = 0.02
  res6@gsnRightStringFontHeightF = 0.02
  res6@tmXBMode = "Explicit"
;  res6@tmXBTickStartF = 0.0
  res6@tmXBTickSpacingF = 3.0
  res6@tmXBLabelAngleF = 0.0
  res6@tmLabelAutoStride = True
  res6@tmEqualizeXYSizes = True
  res6@tmXBMode = "Manual"

;*************************************************************
; Panel plot resource  
;*************************************************************

  panRes = True
  panRes@gsnMaximize = True
; panRes@lgLineLabelStrings  = (/"Land","Coast","Sea"/)
; panRes@pmLegendDisplayMode = "Always"
; panRes@lgLineColors  = (/"Black","Red", "Blue"/)
; panRes@lgDashIndexes = (/0,2,12/) 
;  panRes@tiXAxisString = "Local Standard Time (hour)"
  panRes@gsnPanelMainString = "Time-series Analysis of TMPA and ISCCP WS: Winter and Summer"
  panRes@lgItemType         = "Lines"
  panRes@tiXAxisString = "Local Standard Time (hr)"
  panRes@pmLabelBarParallelPosF = 0.015
  panRes@gsnPanelBottom   = 0.02
  panRes@gsnPanelXWhiteSpacePercent = 1.0
  panRes@gsnPanelYWhiteSpacePercent = 1.5
; panRes@gsnPanelRight     = 0.05
; panRes@gsnPanelLeft     = 0.04
  panRes@gsnPanelFigureStrings = (/"a)", "d)", "b)", "e)", "c)", "f)"/)
; panRes@lbPerimOn          = True
; panRes@gsnPaperOrientation = "auto"
; panRes@gsnPanelLabelBar   = True
; panRes@gsnAttachPlotsXAxis = True

;*************************************************************
; Plot
;*************************************************************

  plot1 = gsn_csm_xy(wks, hours, xData, res1)
  plot2 = gsn_csm_xy(wks, hours, yData, res2)
  plot3 = gsn_csm_xy(wks, hours, zData, res3)
  plot4 = gsn_csm_xy(wks, hours, sData, res4)
  plot5 = gsn_csm_xy(wks, hours, tData, res5)
  plot6 = gsn_csm_xy(wks, hours, uData, res6)

;  plots = gsn_attach_plots(plot1,(/plot2,plot3/), panRes, panRes1)
 
  gsn_panel(wks,(/plot1,plot4,plot2,plot5,plot3,plot6/),(/3,2/),panRes)

; draw the plot
  delete(wks)

; draw(plot)
; frame(wks)

end  

