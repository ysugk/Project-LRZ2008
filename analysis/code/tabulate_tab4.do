clear all
set more off

cd "~/Projects/Replication/LRZ2008"
use "analysis/input/prepared"
tsset gvkey fyear

qui reg logsale fyear, nocons
predict logsaler, r

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

foreach v in logsaler mtb prof tang cfvol indblev divpayer {
	forvalues j = 1/8 {
		gen lag`j'_`v' = L`j'.`v'
	}
}

by gvkey: drop if _n == 1

foreach v of varlist lag*_* {
	drop if missing(`v')
}

foreach v of varlist initblev initmlev lag*_* {
	egen `v'_std = std(`v')
}

global control "lag*_logsaler_std lag*_mtb_std lag*_prof_std lag*_tang_std lag*_indblev_std lag*_cfvol_std lag*_divpayer_std"

/* Book leverage equations */

qui reghdfe blev initblev_std $control, a(cyear) cl(gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")

bshort = b[1, (1, 2, 10, 18, 26, 34, 42, 50)]
Vshort = V[(1, 2, 10, 18, 26, 34, 42, 50), (1, 2, 10, 18, 26, 34, 42, 50)]
st_matrix("bshort", bshort)
st_matrix("Vshort", Vshort)

b2 = b[1, 2..57]
V2 = V[2..57, 2..57]

v1 = sum(V2[1..8, 1..8])
v2 = sum(V2[9..16, 9..16])
v3 = sum(V2[17..24, 17..24])
v4 = sum(V2[25..32, 25..32])
v5 = sum(V2[33..40, 33..40])
v6 = sum(V2[41..48, 41..48])
v7 = sum(V2[49..56, 49..56])

Vlong = diag((v1, v2, v3, v4, v5, v6 ,v7))

blong = rowshape(b2, 7)
blong = rowsum(blong)
blong = rowshape(blong, 1)
st_matrix("blong", blong)
st_matrix("Vlong", Vlong)
end

mat colnames bshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat rownames Vshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat colnames Vshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"

ereturn post bshort Vshort, obs(`nobs')
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"
eststo est1

mat colnames blong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat rownames Vlong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat colnames Vlong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"

ereturn post blong Vlong
eststo est2

* Market Leverage Equation
qui reghdfe mlev initmlev_std $control, a(cyear) cl(gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %3.2f e(r2_a)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")

bshort = b[1, (1, 2, 10, 18, 26, 34, 42, 50)]
Vshort = V[(1, 2, 10, 18, 26, 34, 42, 50), (1, 2, 10, 18, 26, 34, 42, 50)]
st_matrix("bshort", bshort)
st_matrix("Vshort", Vshort)

b2 = b[1, 2..57]
V2 = V[2..57, 2..57]

v1 = sum(V2[1..8, 1..8])
v2 = sum(V2[9..16, 9..16])
v3 = sum(V2[17..24, 17..24])
v4 = sum(V2[25..32, 25..32])
v5 = sum(V2[33..40, 33..40])
v6 = sum(V2[41..48, 41..48])
v7 = sum(V2[49..56, 49..56])

Vlong = diag((v1, v2, v3, v4, v5, v6 ,v7))

blong = rowshape(b2, 7)
blong = rowsum(blong)
blong = rowshape(blong, 1)
st_matrix("blong", blong)
st_matrix("Vlong", Vlong)
end

mat colnames bshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat rownames Vshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat colnames Vshort = "initlev" "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"

ereturn post bshort Vshort, obs(`nobs')
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"
eststo est3

mat colnames blong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat rownames Vlong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"
mat colnames Vlong = "lag1_logsaler_std" "lag1_mtb_std" "lag1_prof_std" "lag1_tang_std" "lag1_indblev_std" "lag1_cfvol_std" "lag1_divpayer_std"

ereturn post blong Vlong
eststo est4

esttab est1 est2 est3 est4 using "analysis/output/tab/tab4.tex", replace b(%3.2f) t(%3.2f) booktabs nostar nonotes nomtitles nonumbers stats(yearfixed r2_ N, fmt(%10.0fc) label("Year fixed effects" "Adj. $ R^2$" "Obs.")) msign("$-$") ///
keep(initlev lag1*) ///
order(initlev) ///
coeflabel(initlev "Initial leverage" lag1_logsaler_std "Log(Sales)" lag1_mtb_std "Market-to-book" lag1_prof_std "Profitability" lag1_tang_std "Tangibility" lag1_cfvol_std "Cash flow vol." lag1_indblev_std "Industry median lev." lag1_divpayer_std "Dividend payer") ///
posthead(" & \multicolumn{2}{c}{Book Leverage} & \multicolumn{2}{c}{Market Leverage} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}" "Variable & Short Run & Long Run & Short Run & Long Run \\ \midrule") ///
prefoot("\\")
