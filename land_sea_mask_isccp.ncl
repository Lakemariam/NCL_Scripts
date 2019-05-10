
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Land Sea Mask of ISCCP
; Lakemariam Worku
; 2018
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "sub.cjs_landmask_isccp.ncl"
begin

;  maskType = "land" ; land, sea, or coast
;  maskType = "coast"
  maskType = "sea"
  varName = "IRregime"

  print( "Reading the data" )
  inPath = "djf_irws3_ph8.nc"
  inFile = addfile( inPath, "r")
  inData = inFile->$varName$(:,{-10:10},{90:170}) ; unlimited time


  print( "Masking" )
  maskData = cjs_landmask( inData, maskType )

  print( "Averaging" )
  avgData = dim_avg_n_Wrap( maskData, (/ 1, 2 /) )

  print( "Writing" )
  outPath = "djf_irws3_ph8_" + maskType + ".nc"
  system( "rm " + outPath )
  outFile = addfile( outPath, "c" )
; writing the mask data for now for debugging. Later we'll just write avgData
  outFile->$varName$ = avgData

  delete(outFile)

end 
