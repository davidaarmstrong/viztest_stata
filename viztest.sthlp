{smcl}
{* *! version 1.0  4 Jan 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install viztest" "ssc install viztest"}{...}
{vieweralsosee "Help viztest (if installed)" "help viztest"}{...}
{viewerjumpto "Syntax" "viztest##syntax"}{...}
{viewerjumpto "Description" "viztest##description"}{...}
{viewerjumpto "Remarks" "viztest##remarks"}{...}
{viewerjumpto "Examples" "viztest##examples"}{...}
{viewerjumpto "Authors and Support" "viztest##author"}{...}
{viewerjumpto "References" "viztest##references"}{...}
{title:Title}
{phang}
{bf:viztest} {hline 2} Find Optimal Visual Testing Confidence Level

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:viztest}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Optional}
{synopt:{opt lev1(#)}}  Lowest value of confidence intervals to search for optimal level.  Default value is .25.  Should be in the range (0,1). 

{synopt:{opt lev2(#)}}  Highest value of confidence intervals to search for optimal level.  Default value is .99. Should be in the range (0,1) and be larger than {it: lev1}. 

{synopt:{opt incr(#)}}  Step by which confidence level is incremented between {it: lev1} and {it: lev2} in search for optimal level. Default value is .01.  Should be in the range (0, {it: lev2}-{it: lev1}), but ideally much closer to zero. 

{synopt:{opt a(#)}}  Type I error rate for individual pairwise tests.  Default value is .05.  Should be in the range (0, 1), though a warning will be printed if it is bigger than .25 since that would be a pretty unusual alpha level. 

{synopt:{opt easythresh(#)}}  Threshold on distance in the computation of cognitive easniess.  Easiness is defined as the non-overlapping distance for significant tests and the degree of overlap for insignificant tests.  These distances are capped at the difference between the largest upper bound and the smallest lower bound multiplied by {it: easythresh}.  Default value is .05.  Should be a number in the range (0,1), but generally much closer to zero.  

{synopt:{opt adjust(str)}}  Method to use for multiplicity adjustment.  Default is "none" in which case no correction is applied.  Should be one of "bonferroni", "holm", "hommel", "hochberg", "bh", "by" or "none". The "bh" option is for Benjamini and Hochberg's (1995, JRSSB) method and "by" is for Benjamini and Yekutieli's (2001, Ann.Stat.) method.  For a discussion of these methods, see Bretz, Hothorn and Westfall (2010) especially sections 2.3 and 2.4.  

{synopt:{opt inc0}}  If specified, single-estimate tests of difference from zero will be included in the search for the optimal level.  

{synopt:{opt remc}}  If specified, the constant will be removed from the search for the optimal level.  This does not change the model in any way (i.e., it does not re-estimate the model omitting the constant) it simply excludes the constant from consideration in the pairwise tests.  

{synopt:{opt usemargins}}  The function operates on any function that produces {it: e(b)} and {it: e(V)}, but it also works on the output from margins.  If both an estimation routine that produces {it: e(b)} and {it: e(V)} and a margins output that produces {it: r(b)} and {it: r(V)} are present, specifying {it: usemargins} will use the margins result rather than the estimation result. 

{synopt:{opt saving(str)}}  Stem of a file name for saving the results.  As many as two files will be created in the working directory.  {it: `saving'}_results has all the confidence levels in the grid search and the corresponding results.  These will also appear in a frame called "levels".  If any tests were missed, then a new frame called "missed" will be created and a new file called {it: `saving'}_miss will be created in the working directory with all the missed tests. 


{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}{bf: viztest} tries to find a confidence level such that overlapping confidence intervals indicate an insignificant difference and non-overlapping intervals indicate a significant difference.  The function returns the level(s) identified as optimal along with the proportion of total tests that are accurately represented by the (non-)overlapping of confidence intervals. If all tests are not accounted for a matrix of tests that are incorrectly represented by the optimal confidence interval.  


{marker remarks}{...}
{title:Remarks}
{pstd}The approach used here is different from the one used in Payton et. al. (2003).  In their article, Payton and colleagues find through simulation that the 84% confidence interval is one such that the probability two confidence intervals for means overlap is .95.  They conclude that testing a difference in means with 84% confidence intervals should have roughly the same inferential properties as a pairwise comparison of means at the 95% level.  

{pstd}In Armstorng and Poirier (2024), we show that the desirable inferential properties of the 84% confidence interval does not extend to the regression context where the 84% intervals can have type I error rates between 5% and 95%.  We propose an algorithm that conducts all relevant pairwise tests to identify which estimates are significant from each other.  We then do a grid search for a confidence level such that insignificant differences have overlapping intervals and significant differences have non-overlapping intervals.  Our approach does not propose a different method for doing pairwise tests; rather, it proposes a different method for using confidence intervals to visualize pairwise tests. 


{pstd}


{marker examples}{...}
{title:Examples}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. regress mpg weight displacement gear_ratio foreign headroom}{p_end}
{phang2}{cmd:. viztest, remc inc0}{p_end}

{marker author}{...}
{title:Authors and support}

{phang}{bf:Author:}{break}
 	Dave Armstrong and William Poirier, {break}
	Western University {break}
	London, ON, Canada
{p_end}
{phang}{bf:Support:} {break}
	{browse "mailto:davearmstrong.ps@gmail.com":davearmstrong.ps@gmail.com}
{p_end}


{marker references}{...}
{title:References}

{marker ap24}{...}
{phang}
Armstrong, David A., II and William Poirier.  2024.  Optimal Confidence Intervals for Visual Testing
{it:Working Paper}

{marker bretz10}{...}
{phang}
Bretz, Frank, Torsten Hothorn and Peter Westfall.  2010.  {it: Multiple Comparisons Using R}.  Boca Raton, FL: CRC Press.

{marker payton03}{...}
{phang}
Payton, Mark E., Matthew H. Greenstone, and Nathaniel Schenker. 2003. Overlapping confidence intervals or standard
error intervals: What do they mean in terms of statistical significance? {it:Journal of Insect Science} 3(1): 34.

{p}
