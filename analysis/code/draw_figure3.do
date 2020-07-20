clear all
set more off
set graphics off

cd "~/Projects/Replication/LRZ2008"

/* Figure 3: Panel A */
use "analysis/input/prepared", clear

tsset gvkey fyear

foreach year of num 1966/2003 {
	preserve
	qui reghdfe blev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) ndi`year' = ndi (semean) ste`year' = ndi, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 1, 20)
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/2003 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(ndi*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(scatter p eventtime if levport == 1, con(l)) ///
(scatter p eventtime if levport == 2, con(l)) ///
(scatter p eventtime if levport == 3, con(l)), ///
legend(label(1 "Low") label(2 "Medium") label(3 "High") label(4 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 2 3 4)) ///
xtitle("Event Time (Years)") ytitle("Net Debt Issue / Assets") ///
yscale(range(0 0.06)) ylabel(0(0.01)0.06) ///
xscale(range(1 20)) xlabel(1(1)20)

graph export "analysis/output/fig/fig3a.pdf", replace

/* Figure 3: Panel B */
use "analysis/input/prepared", clear

tsset gvkey fyear

foreach year of num 1966/2003 {
	preserve
	qui reghdfe blev L.size L.prof L.tang L.mtb if fyear == `year', a(ffind) res
	predict res, r
	egen levport = cut(res) if fyear == `year', group(4)
	replace levport = levport[_n - 1] if (gvkey == gvkey[_n - 1]) & missing(levport)
	gen eventtime = fyear - `year'
	collapse (mean) nei`year' = nei (semean) ste`year' = nei, by(eventtime levport)
	drop if missing(levport)
	keep if inrange(eventtime, 1, 20)
	save analysis/temp/levport`year', replace
	restore
}

use "analysis/temp/levport1966", clear

foreach year of num 1967/2003 {
	merge 1:1 eventtime levport using analysis/temp/levport`year'
	drop _merge
}

egen p = rowmean(nei*)
egen ste = rowmean(ste*)
gen pupper = p + ste
gen plower = p - ste

twoway  ///
(scatter p eventtime if levport == 0, con(l)) ///
(scatter p eventtime if levport == 1, con(l)) ///
(scatter p eventtime if levport == 2, con(l)) ///
(scatter p eventtime if levport == 3, con(l)), ///
legend(label(1 "Low") label(2 "Medium") label(3 "High") label(4 "Very High") rows(1) pos(12) size(vsmall)) ///
legend(order(1 2 3 4)) ///
xtitle("Event Time (Years)") ytitle("Net Equity Issue / Assets") ///
yscale(range(0 0.12)) ylabel(0(0.02)0.12) ///
xscale(range(1 20)) xlabel(1(1)20)

graph export "analysis/output/fig/fig3b.pdf", replace
