{smcl}
{* *! version 1.0  4 Jan 2024}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Help viztest (if installed)" "help viztest"}{...}
{viewerjumpto "Syntax" "viztest##syntax"}{...}
{viewerjumpto "Description" "viztest##description"}{...}
{viewerjumpto "Remarks" "viztest##remarks"}{...}
{viewerjumpto "Examples" "viztest##examples"}{...}
{viewerjumpto "Authors and Support" "viztest##author"}{...}
{viewerjumpto "References" "viztest##references"}{...}
{title:Title}
{phang}
{bf:viztest} {hline 2} Calculate acceptable inferential confidence intervals for visual testing. 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:viztest, }
[{it:lev1(#)} {it:lev2(#)} {it:incr(#)} {it:a(#)} {it:easythresh(#)} {it:adjust(string)} {it:inc0} {it:remc} {it:usemargins} {it:saving(string)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt lev1(#)}}  A real value in the range (0,1) giving the confidence level that marks the lower bound of the grid search for acceptable inferential confidence level(s).  The default is .25.

{synopt:{opt lev2(#)}}  A real value in the range (0,1) giving the confidence level that marks the upper bound of the grid search for acceptable inferential confidence level(s).  The default is .99.

{synopt:{opt incr(#)}}  A real value in the range (0,1) giving the step size of the grid search.  The algorithm will search from {cmd:lev1} to {cmd:lev2} in increments of {cmd:incr} to find the optimal inferential confidence level(s).  The default is 0.01.

{synopt:{opt a(#)}} The p-value used to mark significance of the pairwise tests.  The default is 0.05.  

{synopt:{opt adjust(string)}} A string giving the multiplicity adjustment to use in the calculation of the pairwise test p-values.  Possible values are: "bonferroni", "holm", "hochberg", "hommel", "bh", "by", "none".  The default is "none". 

{synopt:{opt inc0}} If {cmd:inc0} is issued as an argument, inferential confidence intervals will also include all tests of the parameters relative to zero - the univariate null hypothesis test. By default, zero is not included in the test. 

{synopt:{opt remc}} If {cmd:remc} is issued, the last estimate will be removed from the analysis.  Generally, this is the model constant, but, for example, in {cmd:margins}, the last estimate will not be the constant, so this option should not be invoked in that situation. 

{synopt:{opt usemargins}} If {cmd:usemargins} is issued, {cmd:viztest} will use {it:r(b)} and {it:r(V)} returned from {cmd:margins} as the estimates and varainces rather than {it:e(b)} and {it:e(V)} returned from the model. 

{synopt:{opt saving(string)}} A string giving the stem of a filename.  If specified, two files will be created.  *_results.dta will hold the results of the grid search over all the levels.  *_miss.dta will hold information about the pairwise tests that were not appropriately captured by the inferential confidence intervals, if any. 

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}{cmd:viztest} will use the algorithm proposed by Armstrong and Poirier (2024) to find the optimal inferential confidence level(s) that permit visual testing.  


{marker examples}{...}
{title:{bf:Examples}}

    {help viztest##regress_ex:Linear Regression Example}
        {help viztest##regress_ex_me:Margins after Linear Regression Example}
    {help viztest##logit_ex:Logistic Regression Example}
        {help viztest##logit_coef:Plotting Logistic Regression Coefficients}
        {help viztest##logit_coef:Plotting Logistic Regression Marginal Effects}
    {help viztest##descriptive:Means by Survey Wave (from article Supplementary Material)}
    {help viztest##logit_inter:Predicted Probabilities from Interactions in Logistic Regression (from article Supplementary Material)}

{title:Setup}

{pstd}

{p}You can install the package from github as follows: 

{phang2}{cmd:. net install viztest, from("https://raw.githubusercontent.com/davidaarmstrong/viztest_stata/main/") force}

{p}The viztest package interfaces with output from both modeling functions and margins.   The simplest way to use viztest is to estimate a model and then run the function.  Consider an example using the census13 data. We can use Andrew Gelman's idea of standardizing these variables by two standard deviations. For these examples and more formatted in a more aesthetically pleasing manner and with figures, see the {browse "https://github.com/davidaarmstrong/viztest_stata":GitHub Repository Readme Page}. 

{marker regress_ex}{...}
{title:Regression Example}

{pstd}

{p}First, we can load the data and standardize the continuous variables.  The standardizing is not critical, but does aid comparison.

    {cmd:. webuse census13, clear}
    {cmd:. egen z_mr = std(mrgrate), sd(.5)}
    {cmd:. egen z_dr = std(dvcrate), sd(.5)}
    {cmd:. egen z_ma = std(medage), sd(.5)}
    {cmd:. egen z_pop = std(pop), sd(.5)}


{p}Next, we can estimate the regression model

    {cmd:. reg brate z_mr z_dr z_pop c.z_ma##c.z_ma}

{result}
          Source |       SS           df       MS      Number of obs   =        50
    -------------+----------------------------------   F(5, 44)        =     75.80
           Model |  37807.3612         5  7561.47224   Prob > F        =    0.0000
        Residual |  4389.45878        44  99.7604268   R-squared       =    0.8960
    -------------+----------------------------------   Adj R-squared   =    0.8842
           Total |    42196.82        49  861.159592   Root MSE        =     9.988
    
    -------------------------------------------------------------------------------
            brate | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
    --------------+----------------------------------------------------------------
             z_mr |  -6.954256   4.676084    -1.49   0.144    -16.37828    2.469773
             z_dr |   14.13249   4.798832     2.94   0.005     4.461081     23.8039
            z_pop |   .2499421   3.067509     0.08   0.935    -5.932215    6.432099
             z_ma |  -47.69396   3.171616   -15.04   0.000    -54.08593   -41.30199
                  |
    c.z_ma#c.z_ma |   17.26094   2.927897     5.90   0.000     11.36015    23.16172
                  |
            _cons |   163.7111   1.584228   103.34   0.000     160.5183    166.9039
    -------------------------------------------------------------------------------
{reset} 
{p}The point of our paper is that there are potentially some confidence intervals in the output such that whether they overlap does not correspond with whether there is a significant difference between the two estimates. For example looking at the estimates for z_dr and z_pop.  Their confidence intervals overlap, but are they statistically different from each other?  We cannot answer that question without doing the appropriate test: 

    {cmd:. test z_dr = z_pop}
{result}
     ( 1)  z_dr - z_pop = 0
    
           F(  1,    44) =    6.22
                Prob > F =    0.0165
{reset}
{p}Here, we see that there is a significant difference.  We could then ask {cmd:viztest} to provide the appropriate confidence level such that the overlaps (or lack thereof) represent the significance of the difference between estimates. 

    {cmd:. viztest, inc0}
{result}
    Optimal Levels: 
     
    Smallest Level: .65
    Middle Level: .77
    Largest Level: .91
    Easiest Level: .82
     
    No missed tests!
{reset}
{p}The output here shows us that any confidence level between 65% and 91% will correspond with the pairwise tests, but that the one that will make these differences easiest to apprehend visually is the 82% level.  One way we could use this information is to simply print the regerssion output with 82% confidence intervals. 

    {cmd:. reg brate z_mr z_dr z_pop c.z_ma##c.z_ma, level(82)}
{result}
          Source |       SS           df       MS      Number of obs   =        50
    -------------+----------------------------------   F(5, 44)        =     75.80
           Model |  37807.3612         5  7561.47224   Prob > F        =    0.0000
        Residual |  4389.45878        44  99.7604268   R-squared       =    0.8960
    -------------+----------------------------------   Adj R-squared   =    0.8842
           Total |    42196.82        49  861.159592   Root MSE        =     9.988
    
    -------------------------------------------------------------------------------
            brate | Coefficient  Std. err.      t    P>|t|     [82% conf. interval]
    --------------+----------------------------------------------------------------
             z_mr |  -6.954256   4.676084    -1.49   0.144    -13.32503   -.5834802
             z_dr |   14.13249   4.798832     2.94   0.005     7.594482     20.6705
            z_pop |   .2499421   3.067509     0.08   0.935    -3.929283    4.429167
             z_ma |  -47.69396   3.171616   -15.04   0.000    -52.01502    -43.3729
                  |
    c.z_ma#c.z_ma |   17.26094   2.927897     5.90   0.000     13.27192    21.24995
                  |
            _cons |   163.7111   1.584228   103.34   0.000     161.5527    165.8694
    -------------------------------------------------------------------------------
{reset}
{p}In the output above, you can see now that the intervals for z_dr and z_pop do not overlap.   Some reviewers may complain that "These intervals are too narrow".  If we were using the intervals themselves to do the testing, that may be true.  However, we are doing the appropriate tests at the 95% level and are simply using 82% intervals to capture the relevant differences (or lack thereof) based on these 95% tests.  By decoupling the testing from the calculation of the confidence intervals, as long as their overlaps correspond with the test results (as they do in this case), they cannot be _too_ narrow because the goal of the intervals here is to allow pairwise testing of the coefficients, which is what they do.  

{marker regress_ex_me}{...}
{title:Viztest on the marginal effects}

{p}In the output above, we are probably making some comparisons that are not meaningful.  Since median age (z_ma) is represented with a quadratic polynomial, we should probably not be testing each coefficient in the polynomial term agains everything else.  Instead, we should test something like the average marginal effect (i.e., the average first derivative of the term with respect to the outcome).  We can also do this by calculating the marginal effects with {cmd:margins} and then calling {cmd:viztest} with the argument {cmd:usemargins} on the result. 

    {cmd:. margins, dydx(*)}
{result}
    Average marginal effects                                    Number of obs = 50
    Model VCE: OLS
    
    Expression: Linear prediction, predict()
    dy/dx wrt:  z_mr z_dr z_pop z_ma
    
    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   std. err.      t    P>|t|     [95% conf. interval]
    -------------+----------------------------------------------------------------
            z_mr |  -6.954256   4.676084    -1.49   0.144    -16.37828    2.469773
            z_dr |   14.13249   4.798832     2.94   0.005     4.461081     23.8039
           z_pop |   .2499421   3.067509     0.08   0.935    -5.932215    6.432099
            z_ma |  -47.69396   3.171616   -15.04   0.000    -54.08593   -41.30199
    ------------------------------------------------------------------------------
{reset}
{p}To use {cmd:viztest}, we need to make sure to use the {cmd:usemargins} argument: 

    {cmd:. viztest, inc0 usemargins}
{result}
    Optimal Levels: 
     
    Smallest Level: .65
    Middle Level: .77
    Largest Level: .91
    Easiest Level: .82
     
    No missed tests!
{reset}
{p}As it turns out, the results are the same here.  You could use this by making the {cmd:marginsplot} using the prescribed 82% confidence intervals. 

    {cmd:. marginsplot, level(82) recast(scatter)}

{marker logit_ex}{...}
{title:Logistic Regression Example}

{pstd}

{p}In the linear regression model, the marginal effects (i.e., the partial first derivatives) are often the same as the coefficients themselves,though this wasn't the case above where we used a quadratic polynomial.  In non-linear GLMs, like the logistic regression model, this is not the case.  The marginal effects depend on the functional form of the error distribution and all other parameter estimates/variables in the model.  To  demonstrate how {cmd:viztest} works in this situation, consider the following example. 

{p}First, we can grab some example data from the web and then run a logistic regression.  

    {cmd:. webuse lbw}
    {cmd:. egen z_age = std(age), sd(.5)}
    {cmd:. egen z_lwt = std(lwt), sd(.5)}
    {cmd:. logit low z_age z_lwt i.race smoke ptl ht ui, nolog}
{result}
    Logistic regression                                     Number of obs =    189
                                                            LR chi2(8)    =  33.22
                                                            Prob > chi2   = 0.0001
    Log likelihood = -100.724                               Pseudo R2     = 0.1416
    
    ------------------------------------------------------------------------------
             low | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
    -------------+----------------------------------------------------------------
           z_age |  -.2871916   .3862781    -0.74   0.457    -1.044283    .4698996
           z_lwt |  -.9264771   .4235196    -2.19   0.029     -1.75656    -.096394
                 |
            race |
          Black  |   1.262647   .5264101     2.40   0.016     .2309024    2.294392
          Other  |   .8620792   .4391532     1.96   0.050     .0013548    1.722804
                 |
           smoke |   .9233448   .4008266     2.30   0.021      .137739    1.708951
             ptl |   .5418366    .346249     1.56   0.118     -.136799    1.220472
              ht |   1.832518   .6916292     2.65   0.008     .4769494    3.188086
              ui |   .7585135   .4593768     1.65   0.099    -.1418484    1.658875
           _cons |  -2.135417   .4020014    -5.31   0.000    -2.923325   -1.347508
    ------------------------------------------------------------------------------
{reset}

{marker logit_coef}{...}
{ul:Plotting Coefficients}

{p}We could use {cmd:viztest} to find the optimal confidence level for visual comparison of the model parameters themselves. 
    {cmd:. viztest, lev1(.25) lev2(.99) incr(.01) a(.05) inc0 remc}
{result} 
    Optimal Levels: 
     
    Smallest Level: .75
    Middle Level: .76
    Largest Level: .78
    Easiest Level: .76
     
     
    Missed Tests (n=2 of 36)
     
                         1                 2                 3                 4
        +-------------------------------------------------------------------------+
      1 |           LARGER           SMALLER           PW TEST           CI TEST  |
      2 |           ------           -------           -------           -------  |
      3 |            lowui              zero     Insignificant   Not overlapping  |
      4 |           lowptl              zero     Insignificant   Not overlapping  |
        +-------------------------------------------------------------------------+
{reset}
{p}In the example above, we see that any level between 75% and 78% would work, but the 76% confidence intervals will make it easiest to apprehend the differences visually.  Further, we see that of the 36 pairwise tests (8 coefficients plus 0, where with {it:m} stimuli, the number of pairwise comparisons is {it:m(m-1)/2}), we get two of the pairwise tests wrong - the tests of ui and ptl against zero.  Otherwise, the (lack of)difference is perfectly represented by the 76% confidence intervals.

{p}There are a couple of different ways to deal with this issue.  First, would be to simply present the 76% confidence intervals and in the  note to the table or figure, identify the places where the confidence interval (non-)overlaps are not consistent the pairwise tests.  In this  case, A) the tests that are missed are really univariate tests relative to zero and B) we know that the 95% confidence intervals operationalize the two-tailed test against a point null (like zero). Since both of those are true, you could also print the 95% intervals that would appropriately capture all the tests against zero while also printing the 76% intervals that would capture all pairwise tests. 

{p}Plotting both intervals is a bit trickier.  The reason is that you need to save both results in an easy-to-plot format.  There may be other, more efficient ways of doing this, but this one works. 

{p}First, we return the logistic regression results to focus. 

    {cmd:. quietly logit}

{p}Next, we save the results table and keep the estimates and the confidence bounds.  These start out as the first, fifth and sixth rows of {cmd:r(table)}, but are the first, fifth and sixth columns after we transpose it.

    {cmd:. mat tabo = r(table)'}
    {cmd:. mat tabo = tabo[....,1], tabo[....,5], tabo[....,6]}

{p}Next, we can make the 76% confidence intervals by calling {cmd:logit} again with the appropraite argument.

    {cmd:. quietly logit, level(76)}

{p}We do the same here to keep the lower and upper confidence intervals (note, the estimates have not changed, so we don't need to save thos again).  We save these as a different object.

    {cmd:. mat tabi = r(table)'}
    {cmd:. mat tabi = tabi[....,5], tabi[....,6]}

{p}Next, we can pull the results together

    {cmd:. mat out = tabo, tabi}

{p}In newer versions of Stata, we can create a new frame to store the results.  In most cases, we could put the results in our existing data without a problem.

    {cmd:. frame create res}
    {cmd:. frame change res}

{p}We can now place the matrix resutls as data in the new frame.

    {cmd:. svmat out, names(out)}

{p}We can rename all the variables so they are a bit more intuitive

    {cmd:. rename out1 estimate}
    {cmd:. rename out2 lwr95}
    {cmd:. rename out3 upr95}
    {cmd:. rename out4 lwr76}
    {cmd:. rename out5 upr76}

{p}If some coefficients (like those for a reference group) are set to zero, they will not have a 95% confidence interval.  To remove these coefficients, we can simply drop any observation with a missing upper 95% confidence bound. 

    {cmd:. drop if lwr95 == .}

{p}We can now generate a variable to plot on the x-axis.  This can just be consecutive integers starting at 1.  

    {cmd:. gen obs = _n}

{p}If a constant is present, we can remove the constant by removing the last row of the results.  Note, if there is no constant present, this will remove a real estimate.

    {cmd:. quietly des}
    {cmd:. drop in `r(N)'}

{p}Finally, we could make a graph using the data}

{phang}{cmd:. twoway  (rcapsym lwr95 upr95 obs, lwidth(medium) msymbol(none) lcolor(gs8)) || (rcapsym lwr76 upr76 obs, lwidth(vthick) msymbol(none) lcolor(black)) || (scatter estimate obs, mcolor(white) mfcolor(white) msymbol(circle)),  xlabel(1 "Age" 2 "Weight" 3 "Race: Black" 4 "Race: Other" 5 "Smoke During Pregnancy" 6 "Premature Labor History" 7 "Hyptertension History" 8 "Uterine Irritability", angle(45)) legend(order(2 "Inferential (76%)" 1 "Original (95%)") position(12) cols(2)) xtitle("Parameter") ytitle("Coefficient")}

{p}If you made a new frame for the results, you can change back to the default frame and drop (if you want) the frame containing the results we plotted. 

    {cmd:. frame change default}
    {cmd:. frame drop res}

{marker logit_margins}
{ul:Viztest on Margins result}

{p}If you would rather use {cmd:viztest} on the first derivatives (continuous variables) or first differences (categorical variables specified with the i. construct), you could do this as well by calling the appropriate {cmd:margins} command and then proceeding in a similar fashion as above.  First, we could estimate {cmd:viztest} on the results of {cmd:margins}.  

    {cmd:. margins, dydx(*)}
{result}
    Average marginal effects                                   Number of obs = 189
    Model VCE: OIM
    
    Expression: Pr(low), predict()
    dy/dx wrt:  z_age z_lwt 2.race 3.race smoke ptl ht ui
    
    ------------------------------------------------------------------------------
                 |            Delta-method
                 |      dy/dx   std. err.      z    P>|z|     [95% conf. interval]
    -------------+----------------------------------------------------------------
           z_age |  -.0512013   .0686149    -0.75   0.456    -.1856841    .0832815
           z_lwt |  -.1651749   .0723684    -2.28   0.022    -.3070144   -.0233354
                 |
            race |
          Black  |   .2326941   .0995698     2.34   0.019     .0375409    .4278473
          Other  |   .1511004   .0760619     1.99   0.047     .0020217     .300179
                 |
           smoke |   .1646164   .0681744     2.41   0.016     .0309971    .2982358
             ptl |   .0966001   .0602536     1.60   0.109    -.0214948    .2146951
              ht |   .3267063   .1148706     2.84   0.004     .1015641    .5518485
              ui |   .1352299   .0797297     1.70   0.090    -.0210375    .2914972
    ------------------------------------------------------------------------------
    Note: dy/dx for factor levels is the discrete change from the base level.
{reset}

    {cmd:. viztest, lev1(.25) lev2(.99) incr(.01) a(.05) inc0 usemargins}
{result}
    Optimal Levels: 
     
    Smallest Level: .75
    Middle Level: .76
    Largest Level: .78
    Easiest Level: .77
     
     
    Missed Tests (n=1 of 36)
     
                         1                 2                 3                 4
        +-------------------------------------------------------------------------+
      1 |           LARGER           SMALLER           PW TEST           CI TEST  |
      2 |           ------           -------           -------           -------  |
      3 |              ptl              zero     Insignificant   Not overlapping  |
        +-------------------------------------------------------------------------+
{reset}
{p}The best confidence level to use here is 77% and in doing so, one test is missed - the pre-term labor history is not significantly different from zero, but it's 77% confidence interval does not overlap zero.  We could, then, also present the 95% intervals to capture this discrepancy.  We follow the same procedure as above to capture both sets of confidence intervals: 

{p} First, calculate margins with default 95% confidence intervals

    {cmd:. quietly margins, dydx(*)}

{p}Next, save the results and keep the estimates and confidence bounds. 

    {cmd:. mat tabo = r(table)'}
    {cmd:. mat tabo = tabo[....,1], tabo[....,5], tabo[....,6]}

{p}Calculate the 77% confidence intervals with another call to {cmd:margins}

    {cmd:. quietly margins, dydx(*) level(77)}

{p}Keep the lower and upper bounds from the estimates table

    {cmd:. mat tabi = r(table)'}
    {cmd:. mat tabi = tabi[....,5], tabi[....,6]}

{p}Combine the results. 

    {cmd:. mat out = tabo, tabi}

{p}Create a new frame in which to store the results (this part is optional)

    {cmd:. frame create res}
    {cmd:. frame change res}

{p}Place the matrix results in the new frame

    {cmd:. svmat out, names(out)}

{p}Rename all the variables to something more intuitive

    {cmd:. rename out1 estimate}
    {cmd:. rename out2 lwr95}
    {cmd:. rename out3 upr95}
    {cmd:. rename out4 lwr77}
    {cmd:. rename out5 upr77}

{p}Drop observations without confidence intervals

    {cmd:. drop if lwr95 == .}

{p}Generate a variable against which to plot the results

    {cmd:. gen obs = _n}

{p}Make the graph.

{phang}{cmd:. twoway  (rcapsym lwr95 upr95 obs, lwidth(medium) msymbol(none) lcolor(gs8)) ||(rcapsym lwr77 upr77 obs, lwidth(vthick) msymbol(none) lcolor(black)) || (scatter estimate obs, mcolor(white) mfcolor(white) msymbol(circle)), xlabel(1 "Age" 2 "Weight" 3 "Race: Black" 4 "Race: Other" 5 "Smoke During Pregnancy" 6 "Premature Labor History" 7 "Hyptertension History" 8 "Uterine Irritability", angle(45))legend(order(2 "Inferential (77%)" 1 "Original (95%)") position(12) cols(2))xtitle("Parameters") ytitle("Pr(Low Birth Weight)")}

{p}If you created a new frame, change back to the default frame and drop the temporary one we created. 

    {cmd:. frame change default}
    {cmd:. frame drop res}

{marker descriptive}{...}
{title:Descriptive Statistics}

{p}The first example from Armstrong and Poirier's supplementary material has to do with plotting means and confidence intervals over time.  We use data from Gibson (2024). 

    {cmd:. use "https://github.com/davidaarmstrong/viztest_stata/raw/refs/heads/main/data/gibson_dat.dta", clear"}

{p}In this case, we are using a regression to calculate the means and their confidence intervals.  

    {cmd:. quietly reg agree1 i.WAVE [pw=WEIGHT]}

{p}We use {cmd:margins} to calculate the mean in each wave of the survey from the regression analysis in the previous step. 

    {cmd:. margins WAVE}
{result}
    Adjusted predictions                                     Number of obs = 5,103
    Model VCE: Robust
    
    Expression: Linear prediction, predict()
    
    --------------------------------------------------------------------------------
                   |            Delta-method
                   |     Margin   std. err.      t    P>|t|     [95% conf. interval]
    ---------------+----------------------------------------------------------------
              WAVE |
        July 2020  |   .1412726   .0152265     9.28   0.000     .1114222     .171123
    December 2020  |   .0845361   .0114693     7.37   0.000     .0620515    .1070208
       March 2021  |   .1125555   .0117481     9.58   0.000     .0895242    .1355869
        July 2022  |   .1890228   .0153233    12.34   0.000     .1589825     .219063
    --------------------------------------------------------------------------------
{reset}
{p}We can then use {cmd:viztest} to find the appropriate inferential confidence intervals. 

    {cmd:. viztest, a(.025) usemargins incr(.001)}

{p}In the command above, we use {cmd:a(.025)} to do a two-tailed test at the 0.05 level and {cmd:usemargins} to ensure we take the result from margins rather than the regression.  

{result}
    Optimal Levels: 
     
    Smallest Level: .773
    Middle Level: .826
    Largest Level: .881
    Easiest Level: .834
     
    No missed tests!
{reset}
{p}Next, we estimate {cmd:margins} again to get the estimates and default 95% confidence intervals for plotting

    {cmd:. quietly margins WAVE}

{p} We then follow the same procedure outlined above to save the estimates and 95% confidence intervals, calculate the 84% intervals and save all those results in a new frame. 

    {cmd:. mat tabo = r(table)'}
    {cmd:. mat tabo = tabo[....,1], tabo[....,5], tabo[....,6]}
    {cmd:. quietly margins WAVE, level(84)}
    {cmd:. mat tabi = r(table)'}
    {cmd:. mat tabi = tabi[....,5], tabi[....,6]}
    {cmd:. mat out = tabo, tabi}
    {cmd:. frame create res}
    {cmd:. frame change res}
    {cmd:. svmat out, names(out)}
    {cmd:. rename out1 estimate}
    {cmd:. rename out2 lwr95}
    {cmd:. rename out3 upr95}
    {cmd:. rename out4 lwr84}
    {cmd:. rename out5 upr84}

{p} We can then use those results to make a plot: 

    {cmd:. gen obs = _n}
{phang}{cmd:. twoway  (rcapsym lwr95 upr95 obs, lwidth(medium) msymbol(none) lcolor(gs8)) || (rcapsym lwr84 upr84 obs, lwidth(vthick) msymbol(none) lcolor(black)) ||  (scatter estimate obs, mcolor(white) mfcolor(white) msymbol(circle)),  xlabel(1 "July 2020" 2 "December 2020" 3 "March 2021" 4 "July 2022") legend(order(2 "Inferential (84%)" 1 "Original (95%)") position(12) cols(2))  xtitle("Wave") ytitle("Proportion Agreeing")}

{p} Finally, we can return to the default frame and drop the frame we created to hold these results. 

    {cmd:. frame change default}
    {cmd:. frame drop res}

{marker logit_inter}{...}
{title:Logistic Regression Model Interactions}

{p} The second replication in the paper's supplementary materials uses data from Iyengar and Westwood (2015).  We can load the data as follows: 

    {cmd:. use "https://github.com/davidaarmstrong/viztest_stata/raw/refs/heads/main/data/iw_dat.dta", clear"}

{p} We can estimate the regression model with the interaction between participant party ID and the treatment variable identifying the qualifications of the 

    {cmd:. quietly logit partisanSelection i.participantPID2##i.mostQualifiedPerson}

{p} In this case, we have three different sets of estimates we care about - {cmd:mostQualifiedPerson == 1} (the two candidates are equally qualified), {cmd:mostQualifiedPerson == 2} (the republican is more qualified) and {cmd:mostQualifiedPerson == 3} (the democrat is more qualified).  We can estimate viztest on each of these sets differently.  Theoreatically, we could use different confidence levels for each group, though if a common inferential confidence level exists it might be best to use that one. 

    {cmd:. quietly margins participantPID2, at(mostQualifiedPerson = 1)}
    {cmd:. viztest, a(.025) lev1(.5) lev2(.95) incr(.001) usemargins}
{result}
    Optimal Levels: 
     
    Smallest Level: .581
    Middle Level: .731
    Largest Level: .883
    Easiest Level: .765
     
    No missed tests!
{reset}

    {cmd:. quietly margins participantPID2, at(mostQualifiedPerson = 2)}
    {cmd:. viztest, a(.025) lev1(.5) lev2(.95) incr(.001) usemargins}

{result}
    Optimal Levels: 
     
    Smallest Level: .818
    Middle Level: .843
    Largest Level: .87
    Easiest Level: .845
     
    No missed tests!
{reset}

    {cmd:. quietly margins participantPID2, at(mostQualifiedPerson = 3)}
    {cmd:. viztest, a(.025) lev1(.5) lev2(.95) incr(.001) usemargins}

{result}
    Optimal Levels: 
     
    Smallest Level: .5
    Middle Level: .673
    Largest Level: .848
    Easiest Level: .678
     
    No missed tests!
{reset}
{p} The three different sets of inferential confidence levels are (.581, .883), (.818, .870) and (0.500, 0.848).  Any number in the interval (.818, .848) would work.  We use the 84% confidence level because it is one that has been suggested by previous research and it happens to work for all stimuli in this case. We can then make the estimates for all three groups at once. 

    {cmd:. quietly margins participantPID2, at(mostQualifiedPerson = (1 2 3))}

{p} We use the same procedure described above to save the estimates, default 95% confidence intervals as well as the 84% confidence intervals for plotting. 

    {cmd:. mat tabo = r(table)'}
    {cmd:. mat tabo = tabo[....,1], tabo[....,5], tabo[....,6]}
    {cmd:. quietly margins participantPID2, at(mostQualifiedPerson = (1 2 3)) level(84)}
    {cmd:. mat tabi = r(table)'}
    {cmd:. mat tabi = tabi[....,5], tabi[....,6]}
    {cmd:. mat out = tabo, tabi}
    {cmd:. frame create res}
    {cmd:. frame change res}
    {cmd:. svmat out, names(out)}
    {cmd:. rename out1 estimate}
    {cmd:. rename out2 lwr95}
    {cmd:. rename out3 upr95}
    {cmd:. rename out4 lwr84}
    {cmd:. rename out5 upr84}

{p} Now we can make the graph. We make the variable {it:mqp} to correspond with the output from {cmd:margins}. 

    {cmd:. gen mqp = .}
    {cmd:. replace mqp = 1 in 1/5}
    {cmd:. replace mqp = 2 in 6/10}
    {cmd:. replace mqp = 3 in 11/15}
    {cmd:. label def mqp 1 "Equally Qualified" 2 "R More Qualified" 3 "D More Qualified"}
    {cmd:. label val mqp mqp}

{p} We generate party id ({it:pid}) to correspond with the output from {cmd:margins} as well. 

    {cmd:. gen pid = .}

{p} For democrats:

    {cmd:. foreach i of num 2 7 12 {c -(}}
    {cmd:.   replace pid = 1 in `i'}
    {cmd:. {c )-}}

{p} For leaning democrats: 

    {cmd:. foreach i of num 3 8 13 {c -(}}
    {cmd:.   replace pid = 2 in `i'}
    {cmd:. {c )-}}

{p} For independents: 

    {cmd:. foreach i of num 1 6 11 {c -(}}
    {cmd:.   replace pid = 3 in `i'}
    {cmd:. {c )-}}

{p} For leaning republicans: 

    {cmd:. foreach i of num 4 9* 14 {c -(}}
    {cmd:.   replace pid = 4 in `i'}
    {cmd:. {c )-}}

{p} For republicans: 

    {cmd:. foreach i of num 5 10 15 {c -(}}
    {cmd:.   replace pid = 5 in `i'}
    {cmd:. {c )-}}

{p} Now we can define the labels for the {it:pid} variable.

    {cmd:. label def pid 1 "D" 2 "LD" 3 "I" 4 "LR" 5 "R"}
    {cmd:. label val pid pid}

{p} Finally, we can make the graph

{phang}{cmd:. twoway (pcspike pid lwr95 pid upr95, lwidth(medium) lcolor(gs8)) ||  (pcspike pid lwr84 pid upr84, lwidth(vthick) lcolor(black)) ||  (scatter pid estimate, mcolor(white) mfcolor(white) msymbol(circle)),  by(mqp, cols(3) compact note(""))  legend(order(2 "Inferential (84%)" 1 "Original (95%)") position(12) cols(2))  xtitle("Predict Pr(Choose Republican)") ytitle("") ylabel(1 "D" 2 "LD" 3 "I" 4 "LR" 5 "R")}

{p} Finally, we can change frames and delete our temorary frame. 

    {cmd:. frame change default}
    {cmd:. frame drop res}

{reset}
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
Armstrong, David A., II and William Poirier.  Forthcoming.  Decoupling Visualization and Testing when Presenting Confidence Intervals. {it:Political Analysis} doi:10.1017/pan.2024.24

{marker bretz10}{...}
{phang}
Bretz, Frank, Torsten Hothorn and Peter Westfall.  2010.  {it: Multiple Comparisons Using R}.  Boca Raton, FL: CRC Press.

{marker gibson24}{...}
{phang}
Gibson, James.  2024.  Losing legitimacy: the challenges of the dobbs ruling to conventional legitimacy theory. {it:American Journal of Political Science.}

{marker iyengar15}{...}
{phang}
Iyengar, S., and S. J. Westwood.  2015.  Fear and loathing across party lines: new evidence on group polarization. {it:American Journal of Political Science} 59 (3): 690–707.

{marker payton03}{...}
{phang}
Payton, Mark E., Matthew H. Greenstone, and Nathaniel Schenker. 2003. Overlapping confidence intervals or standard error intervals: What do they mean in terms of statistical significance? {it:Journal of Insect Science} 3(1): 34.

{p}
