{smcl}
{* *! version 1.0  4 Jan 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help postvt (if installed)" "help postvt"}{...}
{viewerjumpto "Syntax" "postvt##syntax"}{...}
{viewerjumpto "Description" "postvt##description"}{...}
{viewerjumpto "Remarks" "postvt##remarks"}{...}
{viewerjumpto "Examples" "postvt##examples"}{...}
{viewerjumpto "Authors and Support" "postvt##author"}{...}
{viewerjumpto "References" "postvt##references"}{...}
{title:Title}
{phang}
{bf:postvt} {hline 2} Post results to be used with viztest

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:postvt}
{it:est} {it:vars}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt est}}  Vector of model estimates, will be transposed to be a row vector if necessary. 

{synopt:{opt vars}}  Vector or matrix of sampling variances of the estimates.  If a matrix, it will be used as-is, though must be square and of the same rows and columns as est. If it is a vector, it should be the same length as est and will be used on the diagonal of a diagonal variance-covariance matrix. 


{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}{bf: postvt} is a utility function that will post a vector of estimates and their sampling variability so they can be captured appropriately by the viztest function, which expects entries in e(b) and e(V). 

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
