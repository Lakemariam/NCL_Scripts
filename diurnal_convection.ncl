;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; diurnal_map.ncl
; Lakemariam Worku
; Carl Schreck (cjschrec@ncsu.edu)
; December 2016
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description: Draw maps of rainfall anomalies for each period and panel them
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"

function drawOneTime( \
  io_wks : graphic, \
  i_targetHour : integer, \
  i_res : logical
)

begin

; Find the hours in the time coord that match our target

  fili = addfile("WS12_mjo_positive.nc", "r")
  time = fili->time
  hour = toint( cd_string( time, "%H:%M:%S" ) )
  hourInd = ind( hour.eq.i_targetHour )
   
  print_clock( "Reading " + i_targetHour )
  allData = fili->IRregime(hourInd,:,:)
  print_clock( "Averaging " + i_targetHour )
  avgData = dim_avg_n_Wrap(allData, 0)
  avgData = avgData*100  
 
  printMinMax(avgData,True)
  print_clock( "Plotting " + i_targetHour )

;******************************************************
;	assign resource for targethour
;*****************************************************

  res = i_res
  localHour = i_targetHour + 9
  localHour = where(localHour.ge.24,localHour-24,localHour)
  res@gsnLeftString = sprinti( "%0.2i00 LST", localHour)
  res@gsnRightString = "%"

  retVal =  gsn_csm_contour_map( io_wks, avgData, res)
  return(retVal)
  
end ; drawOneTime
 
 
begin ; main
  print_clock( "Here we go!" )
  
  f = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/ctcbay.nc","r")
  
  lat   = f->lat      ; ditto
  lon   = f->lon      ; ditto

; These are some parameters that could be useful to have up top
  hours = (/15, 18, 21, 0, 3, 6, 9, 12/)

  plotType = "png"
  plotName = "IRWS12_mjo_positive"
  plotDpi  = 300

  print_clock( "Opening the workstation" )

; ...allows png or gif to work
  if( isStrSubset( plotType, "eps" ).or.isStrSubset( plotType, "png" ) ) then
    plotTypeLocal = "eps"
  else
    plotTypeLocal = plotType 
  end if
  wks = gsn_open_wks( plotTypeLocal, plotName )
 
;***********************************************************************************
;  Customize base plot
;***********************************************************************************

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False 
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnFillPalette = "CBR_wet"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = 15.0
  res@cnMaxLevelValF = 90.0
  res@cnLevelSpacingF = 15.0
  res@tmXBLabelFontHeightF    = 0.03
  res@tmYLLabelFontHeightF    = 0.03
  res@mpLandFillColor = "background"
  res@cnLabelMasking = True
  res@lbLabelBarOn = False
  res@cnLineLabelBackgroundColor = "transparent"
  res@mpFillDrawOrder = "predraw"
  res@gsnAddCyclic = False
  res@cnLineLabelsOn = False
  res@gsnMajorLonSpacing = 20
  res@gsnMinorLonSpacing = 10
  res@gsnMajorLatSpacing = 10
  res@gsnMinorLatSpacing = 5
  res@mpGeophysicalLineThicknessF = 1.5
  res@mpNationalLineThicknessF = 1.5
  
; res@mpCenterLonF = 130.
  res@mpMinLatF  = -15.0        ; zoom in on map
  res@mpMaxLatF  = 15.0
  res@mpMinLonF  = 91.25
  res@mpMaxLonF  = 170

;*********************************************************************
;	 Customize panel
;*********************************************************************

  panRes = True
  panRes@gsnPanelYWhiteSpacePercent = 5
  panRes@gsnPanelLabelBar   = True
  panRes@txString = "Diurnal Cycle of IR_WS12 and MJO with standard anomaly > 1.5"
  panRes@txStringFontHeightF = 0.04
  panRes@pmLabelBarWidthF   = 0.4
  panRes@lbLabelFontHeightF = 0.04
  panRes@lbTitlePosition    = "Right"
  panRes@lbTitleDirection   = "Across"
  panRes@lbOrientation      = "Horizontal"
  panRes@lbAutoManage  = True 
  panRes@gsnMaximize = True
  panRes@gsnPanelYF = (/1,.48,-1,.48/)
  panRes@gsnPanelXF = (/-1,-1,.53,.53/)
   

  allPlots = new(dimsizes(hours), graphic)
  do hourCounter = 0, dimsizes(hours)-1
     allPlots(hourCounter)= drawOneTime(wks, hours(hourCounter), res)
  end do

; drawOneTime( wks, hours(hourCounter), res) 
  gsn_panel( wks, allPlots, (/4, 2/), panRes )
  print_clock( "Thank you, come again." )
end; main

