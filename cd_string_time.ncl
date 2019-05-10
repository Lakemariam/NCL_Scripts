;************************************************************************
;	         Carl J. Schreck 
;             Lakemariam Y. Worku
;                      2019
;	    convert time human readable time format
;
;************************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

begin

	f = addfile("trmm3b42.nc", "r")
	t = f->time

	print(cd_string(t,""))
end

