cd ~/Projects/Replication/LRZ2008/analysis/code/
stata-se -b do prepare_data.do
stata-se -b do draw_figure1.do
stata-se -b do draw_figure2.do
stata-se -b do draw_figure3.do
stata-se -b do tabulate_tab1.do
stata-se -b do tabulate_tab2.do
Rscript run_variance-decomposition.R
stata-se -b do tabulate_tab3.do
stata-se -b do tabulate_tab4.do
stata-se -b do tabulate_tab5.do
stata-se -b do tabulate_tab6.do
