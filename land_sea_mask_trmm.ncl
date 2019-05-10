
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Land Sea MAsk of TRMM
; Lakemariam Worku
; June 2017
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "/home/lworku/NASA_PM/lake/ncl_scripts/sub.cjs_landmask.ncl"
begin
  maskType = "land" ; land, sea, or coast
;  maskType = "coast"
;  maskType = "sea"
  varName = "precip"

  print( "Reading the data" )
  inPath = "/home/data/trmm3b42.mc.nc"
  inFile = addfile( inPath, "r")
  inData = inFile->$varName$(:,{-10:10},{90:170})  

  print( "Masking" )
  maskData = cjs_landmask( inData, maskType )

  print( "Averaging" )
  avgData = dim_avg_n_Wrap( maskData, (/ 1, 2 /) )

  print( "Writing" )
;  outPath = "trmm_mjo_positive_" + maskType + ".nc"
  outPath = "trmm_" + maskType + ".nc"
  system( "rm " + outPath )
  outFile = addfile( outPath, "c" )
; writing the mask data for now for debugging. Later we'll just write avgData
  outFile->$varName$ = avgData
  delete(outFile)

end 
