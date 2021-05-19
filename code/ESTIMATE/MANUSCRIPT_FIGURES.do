*setup working directory
cd "XXX"

*load dataset
clear all
use "data/final.dta", replace

*define variables
global dependent "case_pop ntl_pop aod550_pop mobility"
global cont "l.case_pop l.ntl_pop l.aod550_pop l.mobility"

****************

* FIGURE 1: ESTIMATES
local path "res/manuscript/FIGURE1.txt"
capture noisily rm `path'

foreach dep in $dependent{
	forval lag = 1/30{
		if("`dep'" == "case_pop"){
			reghdfe D.`dep' L`lag'.peopleVacc100 					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else if("`dep'" == "ntl_pop"){
			reghdfe D.`dep' L`lag'.peopleVacc100  					  $cont if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else{
			reghdfe D.`dep' L`lag'.peopleVacc100  					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
	}
}

****************

* FIGURE 2
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"

local path "res/manuscript/FIGURE2.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			
			forval lag = 1/30{
				if("`dep'" == "case_pop"){

					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = l`lag'.`globterm'_`locterm1') $cont, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX)					
				}
				else if("`dep'" == "ntl_pop"){
					
					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont if D.ntl_pop<2, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX)					
				}
				else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
					
					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX)					
				}
			}
			restore
		}
	}
}

