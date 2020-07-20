clear all
set more off
set graphics off

cd "~/Projects/Replication/LRZ2008"

/* Figure 2: Panel A */
use "analysis/input/prepared", clear

tsset gvkey fyear

foreach year of num 1966/2003 {
	preserve
	qui reghdfe blev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) blev`year' = blev (semean) ste`year' = blev, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 0, 20)
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/2003 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(blev*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(line pupper eventtime if levport == 0, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 0, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 1, con(l)) ///
(line pupper eventtime if levport == 1, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 1, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 2, con(l)) ///
(line pupper eventtime if levport == 2, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 2, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 3, con(l)) ///
(line pupper eventtime if levport == 3, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 3, lp(dash) lc(gs10)), ///
legend(label(1 "Low") label(4 "Medium") label(7 "High") label(10 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 4 7 10)) ///
xtitle("Event Time (Years)") ytitle("Book Leverage") ///
yscale(range(0 0.6)) ylabel(0(0.1)0.6) ///
xscale(range(0 20)) xlabel(0(1)20)

graph export "analysis/output/fig/fig2a.pdf", replace

/* Figure 2: Panel B */
use "analysis/input/prepared", clear
keep if survivor == 1
tsset gvkey fyear

foreach year of num 1966/1984 {
	preserve
	qui reghdfe blev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) blev`year' = blev (semean) ste`year' = blev, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 0, 20)
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/1984 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(blev*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(line pupper eventtime if levport == 0, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 0, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 1, con(l)) ///
(line pupper eventtime if levport == 1, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 1, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 2, con(l)) ///
(line pupper eventtime if levport == 2, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 2, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 3, con(l)) ///
(line pupper eventtime if levport == 3, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 3, lp(dash) lc(gs10)), ///
legend(label(1 "Low") label(4 "Medium") label(7 "High") label(10 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 4 7 10)) ///
xtitle("Event Time (Years)") ytitle("Book Leverage") ///
yscale(range(0 0.6)) ylabel(0(0.1)0.6) ///
xscale(range(0 20)) xlabel(0(1)20)

graph export "analysis/output/fig/fig2b.pdf", replace

/* Figure 2: Panel C */
use "analysis/input/prepared", clear
tsset gvkey fyear

foreach year of num 1966/2003 {
	preserve
	qui reghdfe mlev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) mlev`year' = mlev (semean) ste`year' = mlev, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 0, 20)
	tempfile 
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/2003 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(mlev*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(line pupper eventtime if levport == 0, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 0, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 1, con(l)) ///
(line pupper eventtime if levport == 1, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 1, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 2, con(l)) ///
(line pupper eventtime if levport == 2, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 2, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 3, con(l)) ///
(line pupper eventtime if levport == 3, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 3, lp(dash) lc(gs10)), ///
legend(label(1 "Low") label(4 "Medium") label(7 "High") label(10 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 4 7 10)) ///
xtitle("Event Time (Years)") ytitle("Market Leverage") ///
yscale(range(0 0.6)) ylabel(0(0.1)0.6) ///
xscale(range(0 20)) xlabel(0(1)20)

graph export "analysis/output/fig/fig2c.pdf", replace

/* Figure 2: Panel D */
use "analysis/input/prepared", clear
tsset gvkey fyear
keep if survivor == 1

foreach year of num 1966/1984 {
	preserve
	qui reghdfe mlev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) mlev`year' = mlev (semean) ste`year' = mlev, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 0, 20)
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/1984 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(mlev*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(line pupper eventtime if levport == 0, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 0, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 1, con(l)) ///
(line pupper eventtime if levport == 1, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 1, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 2, con(l)) ///
(line pupper eventtime if levport == 2, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 2, lp(dash) lc(gs10)) ///
///
(scatter p eventtime if levport == 3, con(l)) ///
(line pupper eventtime if levport == 3, lp(dash) lc(gs10)) ///
(line plower eventtime if levport == 3, lp(dash) lc(gs10)), ///
legend(label(1 "Low") label(4 "Medium") label(7 "High") label(10 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 4 7 10)) ///
xtitle("Event Time (Years)") ytitle("Market Leverage") ///
yscale(range(0 0.6)) ylabel(0(0.1)0.6) ///
xscale(range(0 20)) xlabel(0(1)20)

graph export "analysis/output/fig/fig2d.pdf", replace

