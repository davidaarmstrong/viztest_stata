webuse census13, clear
egen z_mr = std(mrgrate)
egen z_dr = std(dvcrate)
egen z_ma = std(medage)
egen z_pop = std(pop)
label var z_mr "Marriage Rate"
label var z_ma "Median Age"
label var z_dr "Divorce Rate"
label var z_pop "Population"
reg brate z_mr z_dr z_pop c.z_ma##c.z_ma
test z_dr = z_pop
viztest, inc0
coefplot, drop(_cons) sort(., by(b)) level(95 82) xline(0) ///
  xtitle("Coefficient Estimates" "95% and 82% Confidence Intervals")
