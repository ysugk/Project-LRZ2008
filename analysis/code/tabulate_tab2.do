clear all
set more off

cd "~/Projects/Replication/LRZ2008"
use "analysis/input/prepared"
tsset gvkey fyear

preserve
collapse (firstnm) initblev = blev, by(gvkey)
tempfile initblev
save `initblev', replace
restore

preserve
collapse (firstnm) initmlev = mlev, by(gvkey)
tempfile initmlev
save `initmlev', replace
restore

merge m:1 gvkey using `initblev'
drop _merge

merge m:1 gvkey using `initmlev'
drop _merge

tsset gvkey fyear

foreach v in logsale mtb prof tang cfvol indblev divpayer {
	gen lag1_`v' = L.`v'
}

by gvkey: drop if _n == 1

foreach v of varlist lag1_* {
	drop if missing(`v')
}

foreach v of varlist initblev initmlev lag1_* {
	egen `v'_std = std(`v')
}

global control1 "lag1_logsale_std lag1_mtb_std lag1_prof_std lag1_tang_std"
global control2 "lag1_logsale_std lag1_mtb_std lag1_prof_std lag1_tang_std lag1_indblev_std lag1_cfvol_std lag1_divpayer_std"

* Column 1
qui reghdfe blev initblev_std, noabsorb cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" "_cons"
mat rownames V = "initlev" "_cons"
mat colnames V = "initlev" "_cons"

ereturn post b V, obs(`nobs')
eststo eq1
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

* Column 2
qui reghdfe blev initblev_std $control1, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control1 "_cons"
mat rownames V = "initlev" $control1 "_cons"
mat colnames V = "initlev" $control1 "_cons"

ereturn post b V, obs(`nobs')
eststo eq2
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 3
qui reghdfe blev initblev_std $control2, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control2 "_cons"
mat rownames V = "initlev" $control2 "_cons"
mat colnames V = "initlev" $control2 "_cons"

ereturn post b V, obs(`nobs')
eststo eq3
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 4
qui reghdfe mlev initmlev_std, noabsorb cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" "_cons"
mat rownames V = "initlev" "_cons"
mat colnames V = "initlev" "_cons"

ereturn post b V, obs(`nobs')
eststo eq4
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

* Column 5
qui reghdfe mlev initmlev_std $control1, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control1 "_cons"
mat rownames V = "initlev" $control1 "_cons"
mat colnames V = "initlev" $control1 "_cons"

ereturn post b V, obs(`nobs')
eststo eq5
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 6
qui reghdfe mlev initmlev_std $control2, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control2 "_cons"
mat rownames V = "initlev" $control2 "_cons"
mat colnames V = "initlev" $control2 "_cons"

ereturn post b V, obs(`nobs')
eststo eq6
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

esttab eq1 eq2 eq3 eq4 eq5 eq6 using "analysis/output/tab/tab2a.tex", replace b(2) t(2) booktabs nostar order(initlev) msign("$-$") ///
stats(yearfixed r2_ N, fmt(%10.0fc) label("Year fixed effects" "Adj. $ R^2$" "Obs.")) ///
coeflabel(initlev "Initial leverage" lag1_logsale_std "Log(Sales)" lag1_mtb_std "Market-to-book" lag1_prof_std "Profitability" lag1_tang_std "Tangibility" lag1_cfvol_std "Cash flow vol." lag1_indblev_std "Industry median lev." lag1_divpayer_std "Dividend payer") ///
nonumbers nomtitles nocons nonotes ///
posthead("Variable & \multicolumn{3}{c}{Book Leverage} & \multicolumn{3}{c}{Market Leverage} \\ \midrule") ///
prefoot("\\")

/* Panel B */
keep if survivor == 1

* Column 1
qui reghdfe blev initblev_std, noabsorb cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" "_cons"
mat rownames V = "initlev" "_cons"
mat colnames V = "initlev" "_cons"

ereturn post b V, obs(`nobs')
eststo eq1
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

* Column 2
qui reghdfe blev initblev_std $control1, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control1 "_cons"
mat rownames V = "initlev" $control1 "_cons"
mat colnames V = "initlev" $control1 "_cons"

ereturn post b V, obs(`nobs')
eststo eq2
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 3
qui reghdfe blev initblev_std $control2, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control2 "_cons"
mat rownames V = "initlev" $control2 "_cons"
mat colnames V = "initlev" $control2 "_cons"

ereturn post b V, obs(`nobs')
eststo eq3
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 4
qui reghdfe mlev initmlev_std, noabsorb cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" "_cons"
mat rownames V = "initlev" "_cons"
mat colnames V = "initlev" "_cons"

ereturn post b V, obs(`nobs')
eststo eq4
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

* Column 5
qui reghdfe mlev initmlev_std $control1, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control1 "_cons"
mat rownames V = "initlev" $control1 "_cons"
mat colnames V = "initlev" $control1 "_cons"

ereturn post b V, obs(`nobs')
eststo eq5
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Column 6
qui reghdfe mlev initmlev_std $control2, a(cyear) cl(gvkey)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mat colnames b = "initlev" $control2 "_cons"
mat rownames V = "initlev" $control2 "_cons"
mat colnames V = "initlev" $control2 "_cons"

ereturn post b V, obs(`nobs')
eststo eq6
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

esttab eq1 eq2 eq3 eq4 eq5 eq6 using "analysis/output/tab/tab2b.tex", replace b(2) t(2) booktabs nostar order(initlev) msign("$-$") ///
stats(yearfixed r2_ N, fmt(%10.0fc) label("Year fixed effects" "Adj. $ R^2$" "Obs.")) ///
coeflabel(initlev "Initial leverage" lag1_logsale_std "Log(Sales)" lag1_mtb_std "Market-to-book" lag1_prof_std "Profitability" lag1_tang_std "Tangibility" lag1_cfvol_std "Cash flow vol." lag1_indblev_std "Industry median lev." lag1_divpayer_std "Dividend payer") ///
nonumbers nomtitles nocons nonotes ///
posthead("Variable & \multicolumn{3}{c}{Book Leverage} & \multicolumn{3}{c}{Market Leverage} \\ \midrule") ///
prefoot("\\")
