*setup working directory
cd "XXX"

*load dataset
clear all
use "data/final.dta", replace

*define variables
global dependent "case_pop ntl_pop aod550_pop mobility"
global cont "l.case_pop l.ntl_pop l.aod550_pop l.mobility"

****************

* TABLE 1
local path "res/manuscript/TABLE1.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	if("`dep'" == "case_pop"){
		reghdfe D.`dep' L21.peopleVacc100 					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 21, FULLVACCINE, NO) sortvar($cont) append excel
	}
	else if("`dep'" == "ntl_pop"){
		reghdfe D.`dep' L1.peopleVacc100  					  $cont if D.ntl_pop<2, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) sortvar($cont) append excel
	}
	else{
		reghdfe D.`dep' L1.peopleVacc100  					  $cont, absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) addtext(LAG, 1, FULLVACCINE, NO) sortvar($cont) append excel
		
	}
}

****************

* TABLE 2
local path "res/manuscript/TABLE2.txt"
capture noisily rm `path'

foreach dep in $dependent{
	
	if("`dep'" == "case_pop"){
		
		reghdfe d.`dep' l7.fullPeopleVacc100 l21.peopleVacc100 $cont if peopleVacc100>f14.fullPeopleVacc100, ///
		absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) sortvar($cont) append excel
		
	}
	else if("`dep'" == "ntl_pop"){
		
		reghdfe d.`dep' l.fullPeopleVacc100 l.peopleVacc100 $cont if peopleVacc100>f14.fullPeopleVacc100 & d.ntl_pop<2, ///
		absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) sortvar($cont) append excel
	}
	else{
		
		reghdfe d.`dep' l.fullPeopleVacc100 l.peopleVacc100 $cont if peopleVacc100>f14.fullPeopleVacc100 & d.ntl_pop<2, ///
		absorb(i.DATE#i.country i.rid) vce(cluster DATE#country)
		outreg2 using `path', bdec(6) sortvar($cont) append excel
		
	}
}

