clear all
set more off

cd "~/Projects/Replication/LRZ2008"

use "build/output/data"
save "analysis/input/data", replace

destring gvkey sic, replace
duplicates drop gvkey fyear, force
tsset gvkey fyear

* Basic filter
drop if missing(at)

* Drop financial firms
drop if sic >= 6000 & sic <= 6999

* Define variables
gen sic2 = int(sic/100)
gen ffind = .
replace ffind = 1 if sic >= 100 & sic <= 999
replace ffind = 2 if sic >= 1000 & sic <= 1299
replace ffind = 3 if sic >= 1300 & sic <= 1399
replace ffind = 4 if sic >= 1400 & sic <= 1499
replace ffind = 5 if sic >= 1500 & sic <= 1799
replace ffind = 6 if sic >= 2000 & sic <= 2099
replace ffind = 7 if sic >= 2100 & sic <= 2199
replace ffind = 8 if sic >= 2200 & sic <= 2299
replace ffind = 9 if sic >= 2300 & sic <= 2399
replace ffind = 10 if sic >= 2400 & sic <= 2499

replace ffind = 11 if sic >= 2500 & sic <= 2599
replace ffind = 12 if sic >= 2600 & sic <= 2661
replace ffind = 13 if sic >= 2700 & sic <= 2799
replace ffind = 14 if sic >= 2800 & sic <= 2899
replace ffind = 15 if sic >= 2900 & sic <= 2999
replace ffind = 16 if sic >= 3000 & sic <= 3099
replace ffind = 17 if sic >= 3100 & sic <= 3199
replace ffind = 18 if sic >= 3200 & sic <= 3299
replace ffind = 19 if sic >= 3300 & sic <= 3399
replace ffind = 20 if sic >= 3400 & sic <= 3499

replace ffind = 21 if sic >= 3500 & sic <= 3599
replace ffind = 22 if sic >= 3600 & sic <= 3699
replace ffind = 23 if sic >= 3700 & sic <= 3799
replace ffind = 24 if sic >= 3800 & sic <= 3879
replace ffind = 25 if sic >= 3900 & sic <= 3999
replace ffind = 26 if sic >= 4000 & sic <= 4799
replace ffind = 27 if sic >= 4800 & sic <= 4829
replace ffind = 28 if sic >= 4830 & sic <= 4899
replace ffind = 29 if sic >= 4900 & sic <= 4949
replace ffind = 30 if sic >= 4950 & sic <= 4959

replace ffind = 31 if sic >= 4960 & sic <= 4969
replace ffind = 32 if sic >= 4970 & sic <= 4979
replace ffind = 33 if sic >= 5000 & sic <= 5199
replace ffind = 34 if sic >= 5200 & sic <= 5999
replace ffind = 35 if sic >= 6000 & sic <= 6999
replace ffind = 36 if sic >= 7000 & sic <= 8999
replace ffind = 37 if sic >= 9000 & sic <= 9999
replace ffind = 38 if !missing(sic) & missing(ffind)

g cyear = year(datadate)
la var cyear "calender year"
g dt = dlc + dltt
la var dt "total debt"
g blev = dt / at
la var blev "Book leverage"
g size = log(at/(gdpdeflator/100))
la var size "firm size"
g logsale = log(sale/(gdpdeflator/100))
la var logsale "Log(Sales)"
g prof = oibdp / at
la var prof "Profitability"
g ocf = oibdp / at
la var ocf "operating income over total asssets"
tsegen cfvol = rowsd(L(1/10).ocf, 3)
la var cfvol "Cash flow vol."
g me = prcc_f * cshpri
la var me "market equity"
g mlev = dt/(dt + me)
la var mlev "Market leverage"
g mtb = (me + dt + pstkl - txditc)/at
la var mtb "Market-to-book"
g collat = (invt + ppent)/at
la var collat "collateral"
g zscore = (3.3 * pi + sale + 1.4 * re + 1.2 * (act - lct))/at
la var zscore "Z-Score"
g tang = ppent/at
la var tang "Tangibility"
g intang = intan/at
la var intang "Intangible assets"
g ndi = (dt - L.dt) / L.at 
la var ndi "net debt issuance"
g nei = (csho - L.csho * (L.ajex/ajex)) * 0.5 * (prcc_f + L.prcc_f * (ajex/L.ajex)) / L.at
la var nei "net equity issuance"
g divpayer = .
replace divpayer = 1 if dvc > 0
replace divpayer = 0 if dvc == 0
la var divpayer "Dividend payer"

* Apply same filter
replace blev = . if blev < 0
replace blev = . if blev > 1
replace mlev = . if mlev < 0
replace mlev = . if mlev > 1

preserve
collapse (median) indblev = blev, by(fyear ffind)
la var indblev "Median industry book leverage"
tempfile indblev
save `indblev', replace
restore

merge m:1 fyear ffind using `indblev'
drop _merge

keep if fyear >= 1965 & fyear <= 2003
bysort gvkey: gen survivor = _N >= 20
la var survivor "survivor dummy"

winsor2 mtb prof tang intang cfvol ndi nei, c(1 99) replace trim

keep gvkey fyear cyear datadate sic2 ffind blev indblev size logsale prof ocf cfvol me mlev mtb collat zscore tang intang ndi nei survivor divpayer

save "analysis/input/prepared", replace
