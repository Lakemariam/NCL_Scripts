;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sub.cjs_landmask.ncl
; Carl Schreck (cjschrec@ncsu.edu)
; Lakemariam Y. Worku
; 2018
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description: Apply a landsea mask to input data using the mask found at:
; https://www.ghrsst.org/products-and-services/tools/navo-ghrsst-pp-land-sea-mask/
; Takes a while to read the mask.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

undef ( "cjs_landmask" )
function cjs_landmask( \
  i_inData    : numeric, \
  i_keepType  : string \ ; land, sea, coast
)
begin ; cjs_landmask

  ; These are some parameters that could be useful to have up top
  if( .not.isatt( i_keepType, "maskPath" ) ) then
    maskPath = "/home/carl/data/geography/lsmask-world8-var.dist5.5.nc"
  else
    maskPath = i_keepType@maskPath
  end if

  print( "Reading the mask file" )
  maskFile = addfile( maskPath, "r" )
  maskData_byte = maskFile->dst
  maskData = toint( maskData_byte )
  copy_VarMeta( maskData_byte, maskData )
  ; open ocean was missing, let's make it 50 (max distance to land)
  maskData = where( ismissing( maskData ), 50, maskData ) 

  print( "Regridding the mask" )
  if( max( i_inData&lon ).gt.180 ) then
    maskData = lonFlip( maskData )
  end if

  opt = True
  loResMaskData = area_hi2lores_Wrap( maskData&lon, maskData&lat, maskData,  \
      True, 1, i_inData&lon, i_inData&lat, opt )
  
  print( "Finding which points to keep" )
  if( i_keepType.eq."sea" ) then
    keepMask_2d = loResMaskData.ge.50
  else if( i_keepType.eq."land" ) then
    keepMask_2d = loResMaskData.le.6
  else if( i_keepType.eq."coast" ) then
    keepMask_2d = ( loResMaskData.gt.6 ).and.( loResMaskData.lt.50 )
  else

;  else if( i_keepType.eq."land" ) then
;    keepMask_2d = loResMaskData.le.0
;  else if( i_keepType.eq."coast" ) then
;    keepMask_2d = ( loResMaskData.gt.0 ).and.( loResMaskData.lt.50 )
;  else
    print( "WARNING: Bad keepType in cjs_landmask: " + i_keepType )
    exit
  end if
  end if
  end if

  print( "Change mask dimensions to match data" )
  nDims = dimsizes( dimsizes(i_inData) )
  if( nDims.eq.2 ) then
    keepMask = keepMask_2d
  else
    keepMask = conform( i_inData, keepMask_2d, (/ nDims-2, nDims-1 /) )
  end if

  retVal = where( keepMask, i_inData, i_inData@_FillValue )
  copy_VarMeta( i_inData, retVal )

  return(retVal)
end; cjs_landmask


