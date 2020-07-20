clear all
set more off

cd "~/Projects/Replication/LRZ2008"
use "analysis/temp/vardecompose"

qui tostring *, force replace format ("%3.2f")

listtab * using "analysis/output/tab/tab3.tex", rstyle(tabular) replace ///
head("\begin{tabular}{l c c c c c c c c c c c c c c}" ///
"\toprule" ///
"& \multicolumn{7}{c}{Book Leverage} & \multicolumn{7}{c}{Market Leverage} \\" ///
"\cmidrule(lr){2-8} \cmidrule(lr){9-15}" ///
"Variable & (a) & (b) & (c) & (d) & (e) & (f) & (g) & (a) & (b) & (c) & (d) & (e) & (f) & (g) \\" ///
"\midrule") ///
foot("\bottomrule" "\end{tabular}")
