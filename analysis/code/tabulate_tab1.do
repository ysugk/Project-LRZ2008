clear all
set more off

cd "~/Projects/Replication/LRZ2008"
use "analysis/input/prepared"

qui estpost tabstat blev mlev logsale mtb prof tang cfvol indblev divpayer intang, stat(mean median sd) col(stat)
eststo all

qui estpost tabstat blev mlev logsale mtb prof tang cfvol indblev divpayer intang if survivor == 1, stat(mean median sd) col(stat)
eststo survivor

esttab all survivor using "analysis/output/tab/tab1.tex", replace booktabs cells("mean(fmt(%3.2f)) sd(par(( )) fmt(%3.2f))" "p50(par([ ]) fmt(%3.2f))") nomtitles nonumbers label nonotes msign("$-$") ///
mgroups("All Firms" "Survivors", pattern(1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat("\cmidrule(lr){@span}")) ///
collabels("Mean [Median]" "(\textit{SD})", ///
prefix("\multicolumn{@span}{p{1.5cm}}{\centering ") suffix("}")) ///
stats(N, fmt("%10.0fc") labels("Obs."))

