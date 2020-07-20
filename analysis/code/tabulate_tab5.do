clear all
set more off

cd "~/Projects/Replication/LRZ2008"
use "analysis/input/prepared"

tsset gvkey fyear
global control "L.logsale L.mtb L.prof L.tang L.indblev L.cfvol L.divpayer"

qui reg blev $control i.cyear, vce(cluster gvkey)
mat b1 = e(b)
mat b1 = b1[1, 1..7]
local r2_ : di %4.3f e(r2_a)
eststo est1
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

qui xtregar blev $control, fe
mat b2 = e(b)
mat b2 = b2[1, 1..7]
local rho_ : di %4.3f e(rho_ar)
eststo est2
estadd local rho_ "`rho_'"
estadd local yearfixed "Yes"

mata
b1 = st_matrix("b1")
b2 = st_matrix("b2")
b3 = 100 :* (b2 :- b1) :/ b1
st_matrix("b3", b3)
end

matrix colnames b3 = $control

ereturn post b3
eststo est3

eststo
qui reg mlev $control i.cyear, vce(cluster gvkey)
mat b1 = e(b)
mat b1 = b1[1, 1..7]
local r2_ : di %4.3f e(r2_a)
eststo est4
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

qui xtregar blev $control, fe
mat b2 = e(b)
mat b2 = b2[1, 1..7]
local rho_ : di %4.3f e(rho_ar)
eststo est5
estadd local rho_ "`rho_'"
estadd local yearfixed "Yes"

mata
b1 = st_matrix("b1")
b2 = st_matrix("b2")
b3 = 100 :* (b2 :- b1) :/ b1
st_matrix("b3", b3)
end

matrix colnames b3 = $control

ereturn post b3
eststo est6

esttab est1 est2 est3 est4 est5 est6 using "analysis/output/tab/tab5.tex", replace b(%4.3f) t(2) booktabs nomtitles nonumbers msign("$-$") nostar nonotes ///
stats(yearfixed r2_ rho_ N, fmt(%10.0fc) label("Year fixed effects" "Adj. $ R^2$" "AR(1)" "Obs.")) ///
keep($control) ///
coeflabel(L.logsale "Log(Sales)" L.mtb "Market-to-book" L.prof "Profitability" L.tang "Tangibility" L.cfvol "Cash flow vol." L.indblev "Industry median lev." L.divpayer "Dividend payer") ///
posthead(" & \multicolumn{3}{c}{Book Leverage} & \multicolumn{3}{c}{Market Leverage} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-7}" "Variable & Pooled OLS & Firm FE & \% Change & Pooled OLS & Firm FE & \% Change \\ \midrule") ///
prefoot("\\")
