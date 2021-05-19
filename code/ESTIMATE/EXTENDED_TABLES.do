*setup working directory
cd "XXX"

*load dataset
clear all
use "data/final.dta", replace

*define variables
global dependent "case_pop ntl_pop aod550_pop mobility"
global cont "l.case_pop l.ntl_pop l.aod550_pop l.mobility"

****************

* TABLE A1
local path "res/extended/TABLEA1.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	if("`dep'" == "case_pop"){
		reghdfe D.`dep' L21.peopleVacc100 					  $cont c.rid#i.DATE, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 10, FULLVACCINE, NO) keep(L21.peopleVacc100 $cont) sortvar($cont) append excel
	}
	else if("`dep'" == "ntl_pop"){
		reghdfe D.`dep' L1.peopleVacc100  					  $cont c.rid#i.DATE if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) keep(L1.peopleVacc100 $cont) sortvar($cont) append excel
	}
	else{
		reghdfe D.`dep' L1.peopleVacc100  					  $cont c.rid#i.DATE, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) keep(L1.peopleVacc100 $cont) sortvar($cont) append excel
		
	}
}

****************

* TABLE A2
local path "res/extended/TABLEA2.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	preserve
	gen diff`dep' = D.`dep'
	su diff`dep', d
	replace diff`dep' = `r(p99)' if diff`dep'>`r(p99)'
	
	if("`dep'" == "case_pop"){
		reghdfe diff`dep' L21.peopleVacc100 					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 21, FULLVACCINE, NO) sortvar($cont) append excel
	}
	else if("`dep'" == "ntl_pop"){
		reghdfe diff`dep' L1.peopleVacc100  					  $cont if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) sortvar($cont) append excel
	}
	else{
		reghdfe diff`dep' L1.peopleVacc100  					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) sortvar($cont) append excel
		
	}
	restore
}

****************

* TABLE A3
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"

local path "res/extended/TABLEA3.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			
			if("`dep'" == "case_pop"){

				ivreghdfe D.`dep' (l21.peopleVacc100 = l21.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 21, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "ntl_pop"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont if D.ntl_pop<2, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}

			restore
		}
	}
}

****************

* TABLE A4
global LOCALIV "lnhoscapita"
global GLOBALIV "procure150"

local path "res/extended/TABLEA4.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			
			if("`dep'" == "case_pop"){

				ivreghdfe D.`dep' (l21.peopleVacc100 = l21.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 21, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "ntl_pop"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont if D.ntl_pop<2, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}

			restore
		}
	}
}

****************

* TABLE A5
global LOCALIV "lnhoscapita"
global GLOBALIV "procure120"

local path "res/extended/TABLEA5.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			
			if("`dep'" == "case_pop"){

				ivreghdfe D.`dep' (l21.peopleVacc100 = l21.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 21, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "ntl_pop"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont if D.ntl_pop<2, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}
			else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX)					
			}

			restore
		}
	}
}

****************

* TABLE A6
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"
global IVcontrol "generalPol"

local path "res/extended/TABLEA6.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			foreach ivcont in $IVcontrol{
			
				preserve
				gen `globterm'_`locterm1' = `globterm'*`locterm1'
				gen IA_`locterm1'_`ivcont' = `locterm1'*`ivcont'
				
			
				if("`dep'" == "case_pop"){

					ivreghdfe D.`dep' (l21.peopleVacc100 = l21.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont', ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
					addtext(LAG, 21, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
					
				}
				else if("`dep'" == "ntl_pop"){
					
					ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont' if D.ntl_pop<2, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
					addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
					
				}
				else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
					
					ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont', ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
					addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
					
				}

				restore
			}
		}
	}
}

****************

* TABLE A7
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"

local path "res/extended/TABLEA7.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			gen IA_`locterm1'_general180Pol = `locterm1'*general180Pol
			gen IA_`locterm1'_cas180 = `locterm1'*cas180
			gen IA_`locterm1'_mobil180 = `locterm1'*mobil180
			
			if("`dep'" == "case_pop"){

				ivreghdfe D.`dep' (l21.peopleVacc100 = l21.`globterm'_`locterm1') $cont IA_`locterm1'_*, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
				addtext(LAG, 21, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
				
			}
			else if("`dep'" == "ntl_pop"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont IA_`locterm1'_* if D.ntl_pop<2, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
				
			}
			else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
				
				ivreghdfe D.`dep' (l1.peopleVacc100 = L1.f10.`globterm'_`locterm1') $cont IA_`locterm1'_*, ///
				absorb(i.DATE#i.country i.rid) cluster(COUDATE)
				outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
				addtext(LAG, 1, GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
				FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
				
			}
			restore
			
		}
	}
}

****************

* TABLE A8: created manually

****************

* TABLE A9: created manually
