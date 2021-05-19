*setup
cd "/Users/michaelganslmeier/Dropbox/covidVaccine/8sub/1_NATURE/UPDATE/REPOSITORY"

****************************************************************
****************************************************************

*FIGURE A1
*load dataset
clear all
use "data/vaccine_countrylevel.dta", replace
keep iso3 time total_vaccinations_per_hundred country AE EMDE department

*harmonize dates
replace time =td(16dec2020) if time==.
encode iso3, gen (code)
drop iso3
tsset code time
tsfill, full

*carryforward to fill gaps
sort code  time
by code: carryforward total_vaccinations_per_hundred, gen (c_)
* replace missing with zero
* replace c_=0 if c_==.
keep code time c_ department EMDE AE
by code: carryforward EMDE, gen(EMDE2)
drop EMDE
rename EMDE2 EMDE
by code: carryforward AE, gen(AE2)
drop AE
rename AE2 AE
by code: carryforward department, gen(department2)
drop department
rename department2 department
tabulate department, generate(reg)
rename reg1 AFR
rename reg2 APD
rename reg3 EUR
rename reg4 MCD
rename reg5 WHD

foreach v in AE EMDE {
	bys time: egen `v'_c=median(c_) if `v'==1 
	bys time: egen `v'_25_c=pctile(c_) if `v'==1, p(25)
	bys time: egen `v'_75_c=pctile(c_) if `v'==1, p(75) 
}
keep time *_c
collapse (max) *_c, by (time)
keep if time>=td(01jan2021)

grstyle init
grstyle set nogrid
twoway rarea EMDE_75_c EMDE_25_c time, color(blue*.25) ///
    || rarea AE_75_c AE_25_c time, color(gs8) /// 
    || line EMDE_c time, lc(blue) lw(medium)  /// 
    || line AE_c time, lc(black) lw(medium) /// 
    ||, legend(order(4 3) lab(3 "EMDE") lab(4 AE) pos(9) ring(0) rows(2)) title("Vaccine Rollout") subtitle("(vaccinations per 100 population, median and IQ-range)") tlabel(#8) xtitle("") graphregion(color(white))

****************************************************************
****************************************************************

*load dataset
clear all
use "data/final.dta", replace

*define variables
global dependent "case_pop ntl_pop aod550_pop mobility"
global cont "l.case_pop l.ntl_pop l.aod550_pop l.mobility"

****************

* FIGURE A3
local path "res/extended/FIGUREA3.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	forval lag = 1/30{
		if("`dep'" == "case_pop"){
			reghdfe D.`dep' L`lag'.peopleVacc100 					  $cont c.rid#i.DATE, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else if("`dep'" == "ntl_pop"){
			reghdfe D.`dep' L`lag'.peopleVacc100  					  $cont c.rid#i.DATE if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else{
			reghdfe D.`dep' L`lag'.peopleVacc100  					  $cont c.rid#i.DATE, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
	}
	
}

****************

* FIGURE A4
local path "res/extended/FIGUREA4.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	preserve
	gen diff`dep' = D.`dep'
	su diff`dep', d
	replace diff`dep' = `r(p99)' if diff`dep'>`r(p99)'
	
	forval lag = 1/30{
		if("`dep'" == "case_pop"){
			reghdfe diff`dep' L`lag'.peopleVacc100 					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else if("`dep'" == "ntl_pop"){
			reghdfe diff`dep' L`lag'.peopleVacc100  					  $cont if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
		else{
			reghdfe diff`dep' L`lag'.peopleVacc100  					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, `lag') keep(L`lag'.peopleVacc100) append excel
		}
	}
	restore
}

****************

* FIGURE A5
local path "res/extended/FIGUREA5.txt"
capture noisily rm `path'

levelsof ISO, local(levels) 
foreach l of local levels {
	
	preserve
	keep if ISO != "`l'"
		
	foreach dep in $dependent{
		
		if("`dep'" == "case_pop"){
			reghdfe D.`dep' L21.peopleVacc100 					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, 21, FULLVACCINE, NO, DROP, `l') sortvar($cont) append excel
		}
		else if("`dep'" == "ntl_pop"){
			if("`l'" == "CHL"){
				reghdfe D.`dep' L1.peopleVacc100 $cont if D.ntl_pop<500, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			}
			else{
				reghdfe D.`dep' L1.peopleVacc100 $cont if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			}
			outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO, DROP, `l') sortvar($cont) append excel
		}
		else{
			reghdfe D.`dep' L1.peopleVacc100  					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
			outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO, DROP, `l') sortvar($cont) append excel
			
		}
	}	
	restore
}

****************

* FIGURE A10
global LOCALIV "lnhoscapita"
global GLOBALIV "procure150"

local path "res/extended/FIGUREA10.txt"
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

****************

* FIGURE A11
global LOCALIV "lnhoscapita"
global GLOBALIV "procure120"

local path "res/extended/FIGUREA11.txt"
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

****************

* FIGURE A12
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"
global IVcontrol "generalPol"

local path "res/extended/FIGUREA12.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			foreach ivcont in $IVcontrol{
			
				preserve
				gen `globterm'_`locterm1' = `globterm'*`locterm1'
				gen IA_`locterm1'_`ivcont' = `locterm1'*`ivcont'
				
				forval lag = 1/30{
					if("`dep'" == "case_pop"){

						ivreghdfe D.`dep' (l`lag'.peopleVacc100 = l`lag'.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont', ///
						absorb(i.DATE#i.country i.rid) cluster(COUDATE)
						outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
						addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
						FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
						
					}
					else if("`dep'" == "ntl_pop"){
						
						ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont' if D.ntl_pop<2, ///
						absorb(i.DATE#i.country i.rid) cluster(COUDATE)
						outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
						addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
						FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
						
					}
					else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
						
						ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont IA_`locterm1'_`ivcont', ///
						absorb(i.DATE#i.country i.rid) cluster(COUDATE)
						outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_`ivcont') append excel ///
						addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
						FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, `ivcont')
						
					}
				}
				restore
			}
		}
	}
}

****************

* FIGURE A13
global LOCALIV "lnhoscapita"
global GLOBALIV "procureMIX180"

local path "res/extended/FIGUREA13.txt"
capture noisily rm `path'

foreach dep in $dependent{
	foreach globterm in $GLOBALIV{
		foreach locterm1 in $LOCALIV{
			
			preserve
			gen `globterm'_`locterm1' = `globterm'*`locterm1'
			gen IA_`locterm1'_general180Pol = `locterm1'*general180Pol
			gen IA_`locterm1'_cas180 = `locterm1'*cas180
			gen IA_`locterm1'_mobil180 = `locterm1'*mobil180
			
			forval lag = 1/30{
				if("`dep'" == "case_pop"){

					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = l`lag'.`globterm'_`locterm1') $cont IA_`locterm1'_*, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
					
				}
				else if("`dep'" == "ntl_pop"){
					
					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont IA_`locterm1'_* if D.ntl_pop<2, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
					
				}
				else if("`dep'" == "aod550_pop" | "`dep'" == "mobility"){
					
					ivreghdfe D.`dep' (l`lag'.peopleVacc100 = L`lag'.f10.`globterm'_`locterm1') $cont IA_`locterm1'_*, ///
					absorb(i.DATE#i.country i.rid) cluster(COUDATE)
					outreg2 using `path', bdec(6) sortvar($cont IA_`locterm1'_*) append excel ///
					addtext(LAG, `lag', GLOBALTERM, `globterm', LOCALTERM1, `locterm1', ///
					FSTAT, `e(rkf)', HANSENP, XX, IVCONTROL, MULTIPLE)
					
				}
			}
			restore
			
		}
	}
}



