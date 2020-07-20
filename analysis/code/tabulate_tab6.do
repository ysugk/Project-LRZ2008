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
global control "L.logsale L.mtb L.prof L.tang L.indblev"

foreach v in $control {
	drop if missing(`v')
}

/***********************************
	Column (a)
************************************/

qui reg D.blev L.blev, vce(cluster gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1, 1] = -b[1, 1]
b[1, 2] = log(0.5)/log(1 - b[1,1])
V[2,2] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" "Half-life"
mat rownames V = "SOA" "Half-life"
mat colnames V = "SOA" "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est1
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

/***********************************
	Column (b)
************************************/

qui reg D.blev L.blev initblev, vce(cluster gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1,1] = -b[1,1]
b[1,2] = b[1,2] :/ b[1,1]
b[1,3] = log(0.5)/log(1 - b[1,1])

F = (b[1,2], I(1))
V[2,2] = (F * V[1..2,1..2] * F') :/ (b[1,1]^2)

V[3,3] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" "initlev" "Half-life"
mat rownames V = "SOA" "initlev" "Half-life"
mat colnames V = "SOA" "initlev" "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est2
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

/***********************************
	Column (c)
************************************/

qui reghdfe D.blev L.blev initblev $control, a(cyear) cl(gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1,1] = -b[1,1]
b[1,2..7] = b[1,2..7] :/ b[1,1]

F = (b[1,2..7]', I(6))
V[2..7, 2..7] = (F * V[1..7, 1..7] * F') :/ (b[1,1]^2)

b[1,8] = log(0.5)/log(1 - b[1,1])
V[8,8] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" "initlev" $control "Half-life"
mat rownames V = "SOA" "initlev" $control "Half-life"
mat colnames V = "SOA" "initlev" $control "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est3
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

/***********************************
	Column (d)
************************************/

qui reghdfe D.blev L.blev, a(gvkey) cl(gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1,1] = -b[1, 1]
b[1,2] = log(0.5)/log(1 - b[1,1])
V[2,2] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" "Half-life"
mat rownames V = "SOA" "Half-life"
mat colnames V = "SOA" "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est4
estadd local r2_ "`r2_'"
estadd local yearfixed "No"

/***********************************
	Column (e)
************************************/

qui reghdfe D.blev L.blev $control, a(gvkey cyear) cl(gvkey)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1,1] = -b[1, 1]
b[1,2..7] = b[1,2..7] :/ b[1,1]

F = (b[1,2..7]', I(6))
V[2..7, 2..7] = (F * V[1..7, 1..7] * F') :/ (b[1,1]^2)

b[1,7] = log(0.5)/log(1 - b[1,1])
V[7,7] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" $control "Half-life"
mat rownames V = "SOA" $control "Half-life"
mat colnames V = "SOA" $control "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est5
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

/***********************************
	Column (f)
************************************/
qui xtdpdsys blev, lags(1)
mat b = e(b)
mat V = e(V)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b[1,1] = -(b[1,1] - 1)

b[1,2] = log(0.5)/log(1 - b[1,1])
V[2,2] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" "Half-life"
mat rownames V = "SOA" "Half-life"
mat colnames V = "SOA" "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est7
estadd local yearfixed "No"

/***********************************
	Column (g)
***********************************/
qui tabulate cyear, g(cyear)

xtabond blev $control cyear1-cyear35, lags(1)
mat b = e(b)
mat V = e(V)
local nobs = e(N)

mata
b = st_matrix("b")
V = st_matrix("V")
b = b[1, (1..6, 40)]
V = V[(1..6, 40), (1..6, 40)]

b[1,1] = -(b[1,1] - 1)
b[1,2..7] = b[1,2..7] :/ b[1,1]

F = (b[1,2..7]', I(6))
V[2..7, 2..7] = (F * V[1..7, 1..7] * F') :/ (b[1,1]^2)

b[1,7] = log(0.5)/log(1 - b[1,1])
V[7,7] = V[1,1] * (log(0.5) / ((1 - b[1,1]) * log(1 - b[1,1])^2))^2

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = "SOA" $control "Half-life"
mat rownames V = "SOA" $control "Half-life"
mat colnames V = "SOA" $control "Half-life"

ereturn post b V, obs(`nobs')
ereturn display
eststo est6
estadd local yearfixed "Yes"

esttab est* using "analysis/output/tab/tab6.tex", replace b(2) t(2) booktabs nomtitles nonumbers msign("$-$") nostar nonotes ///
stats(yearfixed r2_ N, fmt("%10.0fc") label("Year fixed effects" "$ R^{2}$")) order(SOA initlev $control Half-life) ///
coeflabel(initlev "Initial leverage" L.logsale "Log(Sales)" L.mtb "Market-to-book" L.prof "Profitability" L.tang "Tangibility" L.indblev "Industry median lev.") ///
posthead(" & \multicolumn{3}{c}{Pooled OLS} & \multicolumn{2}{c}{Firm Fixed Effects} & \multicolumn{2}{c}{GMM} \\ \cmidrule(lr){2-4} \cmidrule(lr){5-6} \cmidrule(lr){7-8}" "Variable & (a) & (b) & (c) & (d) & (e) & (f) & (g) \\ \midrule") ///
prefoot("\\")
