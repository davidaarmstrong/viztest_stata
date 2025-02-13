quietly mean mr, over(region)
coefplot, sort(., by(b)) level(85) ///
     xtitle("Average Marriage Rate" "85% Inferential Confidence Intervals") ///
	 rename(c.mrgrate@1.region = "Northeast" c.mrgrate@2.region = "North Central" ///
	 c.mrgrate@3.region = "South" c.mrgrate@4.region = "West") 


