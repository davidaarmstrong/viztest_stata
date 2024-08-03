* Choosing the Optimal Confidence Level for Visual Testing
* David A. Armstrong II and William Poirier 
* 
* Requires Stata >= 16 because frames are used to save results.
* Requires the function matsort be installed with:
*     net install matsort.pkg
program viztest
	syntax , [lev1(real .25) lev2(real .99) incr(real .01) a(real .05) easythresh(real .05) adjust(string) inc0 remc usemargins saving(string)]
	if "`adjust'" == "" {
	  local adjust = "none"
	}
	if `lev1' <= 0  | `lev1' >= 1 {
		di "lev1 must be a real value between 0 and 1, exclusive. Please respecify lev1"
		break
	}
	if `lev2' <= 0  | `lev2' >= 1 {
		di "lev1 must be a real value between 0 and 1, exclusive. Please respecify lev2"
		break
	}
	local ldist = `lev2' - `lev1'
	if `incr' >= `ldist' {
		di "incr is intended to be the step increasing moving from lev1 to lev2 and should be much smaller than the distance between lev1 and lev2.  Please respecify incr""
		break
	}
	if `a' > .25 {
		if `a' < 1 { 
			di "The a parameter is the type I error on the individual pairwise tests.  You have specified a type I error rate of `a', are you sure that's right?"
		}
		else{
			di "The a parameter is the type I error on the individual pairwise tests and should be between 0 and 1, exclusive.  Please respecify a." 
			break
		}
	}

	if "`usemargins'" != "" {
		capture local rb = rowsof(r(b))
		if "`rb'" != "" {
			mat tmp = r(b)'
			mat tmpV = r(V)
		} 
		else{
			mat tmp = e(b)'
			mat tmpV = e(V)
		}
	}
	else{
		mat tmp = e(b)'
		mat tmpV = e(V)
	}
	capture mat drop smallV smallV2 smallb
	mat bhat = tmp
	mat V = tmpV
	local ncb = rowsof(bhat)
	forv i = 1/`ncb' {
		local ref = bhat[`i',1]
		if `ref' != 0 {
		mat smallV = (nullmat(smallV) \ V[`i', ....])
		}
	} 
	forv i = 1/`ncb' {
		local ref = bhat[`i',1]
		if `ref' != 0 {
		mat smallV2 = (nullmat(smallV2) , smallV[...., `i'])
		}
	} 
	forv i = 1/`ncb' {
		local ref = bhat[`i',1]
		if `ref' != 0 {
		mat smallb = (nullmat(smallb) \ bhat[`i',....])
		}
	} 
	
	mat bhat = smallb
	mat V = smallV2
	mat bhato = bhat
	mat Vo = V

	capture mat drop smallV smallV2 smallb

	local kv = rowsof(V)
	local kv2 = `kv'
	local k = rowsof(bhat)
	local k2 = `k'
	if "`inc0'" != "" {
		local k2 = `k2' + 1
		local kv2 = `kv2' + 1
		mat zmat = J(1,1,0)
		mat rownames zmat = zero
		mat bhat = bhat \ zmat
		mat zrow = J(1, `kv', 0)
		mat rownames zrow = zero
		mat zcol = J(`kv2', 1, 0)
		mat colnames zcol = zero
		mat V = V \ zrow
		mat V = V , zcol
	}

	local nrt = rowsof(bhat)
	
	mata: rn = st_matrixrowstripe("bhat")
	mata: rnms = J(0,1,"")
	forv i = 1/`nrt'{
		mata: tmprnm = invtokens(rn[`i', ], "")
		mata: tmprnm = regexr(tmprnm, "\.", "")
		mata: rnms = rnms \ tmprnm
	}
	mata: rnms = rnms'
	mata: rnmsl = invtokens(rnms[1, ], " ")
	mata: j = rnmsl[1,1]
	mata: st_local("rnms", j)
	mat myV = J(rowsof(V), colsof(V), 0)
	mat myB = J(rowsof(bhat), colsof(bhat), 0)
	mat rownames myB = `rnms'
	mat rownames myV = `rnms'
	mat colnames myV = `rnms'
	local nr = rowsof(bhat)
	forv i = 1/`nr'{ 
		local bb = bhat[`i',1]
		mat myB[`i',1] = `bb'
		forv j = 1/`nr' {
			local vv = V[`i',`j']
			mat myV[`i',`j'] = `vv'
		}
	}
	mat bhat = myB
	mat V = myV
	local rnb: rownames bhat
	if "`remc'" != "" {
		mat f = J(1,1,0)
		local nwb : word count `rnb'
		tokenize `rnb'
		forv s = 1/`nwb'{
			if regexm("``s''", ".*_cons.*") == 0{
				mat f = f \ bhat[`s', ....]
			}
		}
		local rf = rowsof(f)
		mat f = f[2..`rf', ....]
		mat bhat = f
	}
	
	matsort bhat 1 "down"
	local k = rowsof(bhat)
	local rn : rownames(bhat)
	tokenize `rn'
	mat newV = V[....,"`1'"]
	forval i = 2/`k'{
		mat zz = V[....,"``i''"]
		mat newV = newV, zz
	}
	local newrn : colnames(newV)
	tokenize `newrn'
	mat newV2 = newV["`1'",....]
	forval i = 2/`k'{
		mat zzz = newV["``i''",....]
		mat newV2 = newV2 \ zzz
	}
	mat V = newV2
	
	local np = `k'*(`k'-1)/2
	local resdf = _N-rowsof(tmp)
	mat pairs = J(`np', 2, 0)
	local cl = 1
	matrix D = J(`k', `np', 0)
	local upri = `k' -1
	forval i = 1/`upri' {
		local lwrj = `i' + 1
		forval j = `lwrj'/`k' {
			matrix D[`i', `cl'] = 1
			matrix D[`j', `cl'] = -1
			mat pairs[`cl', 1] = `i'
			mat pairs[`cl', 2] = `j'
			local cl = `cl' + 1
		}
	}

	if "`inc0'" != "" {
		local w0 = .
		local nbh = rowsof(bhat)
		local rnbh : rownames(bhat)
		tokenize `rnbh'
		forval i = 1/`nbh' {
			if("``i''" == "zero"){
				local w0 = `i'
			}
		}
		local lenb = rowsof(bhat)
		** Use `w0' to remove zero values from D, pairs, bhat, V
		if `w0' == 1 {
			mat newBhat = bhat[2..., ]
			mat newV = V[2..., 2...]
			local newk = rowsof(newBhat)
			local newnp = `newk'*(`newk'-1)/2
			mat newpairs = J(`newnp', 2, 0)
			local cl = 1
			matrix newD = J(`newk', `newnp', 0)
			local upri = `newk' -1
			forval i = 1/`upri' {
				local lwrj = `i' + 1
				forval j = `lwrj'/`newk' {
					matrix newD[`i', `cl'] = 1
					matrix newD[`j', `cl'] = -1
					mat newpairs[`cl', 1] = `i'
					mat newpairs[`cl', 2] = `j'
					local cl = `cl' + 1
				}
			}

		}
		if `w0' > 1 & `w0' < `lenb' {
			mat nbtop = bhat[1..`=`w0'-1', ....]
			mat nbbot = bhat[`=`w0'+1'..`lenb', ....]
			mat newBhat = nbtop \ nbbot 
			mat nVtop = V[1..`=`w0'-1', ....]
			mat nVbot = V[`=`w0'+1'..`lenb', ....]
			mat nVtopl = nVtop[...., 1..`=`w0'-1']
			mat nVtopr = nVtop[...., `=`w0'+1'..`lenb']
			mat nVbotl = nVbot[...., 1..`=`w0'-1']
			mat nVbotr = nVbot[...., `=`w0'+1'..`lenb']
			mat newV = nVtopl, nVtopr \ nVbotl, nVbotr
			local newk = rowsof(newBhat)
			local newnp = `newk'*(`newk'-1)/2
			mat newpairs = J(`newnp', 2, 0)
			local cl = 1
			matrix newD = J(`newk', `newnp', 0)
			local upri = `newk' -1
			forval i = 1/`upri' {
				local lwrj = `i' + 1
				forval j = `lwrj'/`newk' {
					matrix newD[`i', `cl'] = 1
					matrix newD[`j', `cl'] = -1
					mat newpairs[`cl', 1] = `i'
					mat newpairs[`cl', 2] = `j'
					local cl = `cl' + 1
				}
			}
			
		}
		if `w0' == `lenb' {
			mat newBhat = bhat[1..`=`lenb'-1', ]
			mat newV = V[1..`=`lenb'-1', 1...`=`lenb'-1']
			local newk = rowsof(newBhat)
			local newnp = `newk'*(`newk'-1)/2
			mat newpairs = J(`newnp', 2, 0)
			local cl = 1
			matrix newD = J(`newk', `newnp', 0)
			local upri = `newk' -1
			forval i = 1/`upri' {
				local lwrj = `i' + 1
				forval j = `lwrj'/`newk' {
					matrix newD[`i', `cl'] = 1
					matrix newD[`j', `cl'] = -1
					mat newpairs[`cl', 1] = `i'
					mat newpairs[`cl', 2] = `j'
					local cl = `cl' + 1
				}
			}
		}
	}
	else{
		mat newD = D
		mat newV = V
		mat newBhat = bhat
		mat newpairs = pairs

	}
	
	
	mata: newD = st_matrix("newD")
	mata: newV = st_matrix("newV")
	mata: newBhat = st_matrix("newBhat")
	mata: newpairs = st_matrix("newpairs")


	local np = rowsof(newpairs)
	mata: diffs = (newBhat'*newD)'
	mata: diffV = newD'*newV*newD
	mata: diffSE = sqrt(diagonal(diffV))
	mata: pvals = ttail(`resdf', diffs:/diffSE)
	mata: pvals = p_adjust(pvals, "`adjust'")
	mata: pwtests = pvals :< `a'
	mata: ones = J(`np', 1, 1)
	mata: st_numscalar("nsig", pwtests'*ones)
	local qtl = 1-(1-`lev1')/2
	mata: LL = newBhat[,1] - invt(`resdf', `qtl'):*sqrt(diagonal(newV))[,1]
	mata: UU = newBhat[,1] + invt(`resdf', `qtl'):*sqrt(diagonal(newV))[,1]
	mata: levs = range(`lev1', `lev2', `incr')
	mata: st_matrix("levs", levs)
	local nlevs = rowsof(levs)
	forval l = 2/`nlevs'  {
		local qtl = 1-(1-levs[`l',1])/2
		mata: LL = LL, newBhat[,1] - invt(`resdf', `qtl'):*sqrt(diagonal(newV))[,1]
		mata: UU = UU, newBhat[,1] + invt(`resdf', `qtl'):*sqrt(diagonal(newV))[,1]
		}
	mata: maxU = colmax(UU)
	mata: minL = colmin(LL)
	mata: L = LL[newpairs[,1], ]
	mata: U = UU[newpairs[,2], ]
	mata: citests = L :>= U
	mata: comptests = citests :== pwtests
	mata: ones = J(`np', 1, 1)
	mata: Lsig = select(L, pwtests)
	mata: Linsig = select(L, 1:-pwtests)
	mata: Usig = select(U, pwtests)
	mata: Uinsig = select(U, 1:-pwtests)
	
	mata: dsig = Lsig - Usig
	mata: dinsig = Uinsig - Linsig
	mata: dsig = replaceneg(dsig)
	mata: dinsig = replaceneg(dinsig)
	mata: dsig = colmin(dsig)
	mata: dinsig = colmin(dinsig)
	mata: easy = dinsig:*dsig
	mata: res = levs, (comptests'*ones):/`np', easy'
	mata: st_matrix("res", res)
	mata: cm = colmax(res)
	mata: st_numscalar("cm", cm[1,2])
	mata: st_numscalar("maxeasy", cm[1,3])

	mat res_s = J(1,3,0)
	local nlev = rowsof(res)
	forval i = 1/`nlev' {
		local psm = res[`i', 2]
		if `psm' == cm {
			mat res_s = res_s \ res[`i',....]
		}
	}
	local nrs = rowsof(res_s)
	mat res_s = res_s[2..`nrs', ....]
	mata: res_s = st_matrix("res_s")
	mata: cms = colmax(res_s)
	mata: st_numscalar("maxeasy", cms[1,3])
	local nrs = rowsof(res_s)
	forval i = 1/`nrs'{
		if res_s[`i',3] == maxeasy {
			local optlev = res_s[`i',1]
		}
	}
	mata: levnum = range(1, `nlevs', 1)
	mata: levcol = (levs :== `optlev')'*levnum
	mata: alltests = pairs, pwtests, citests[,levcol]
	mata: st_matrix("alltests", alltests)
	mat miss = J(1,4,0)
	local nrm = rowsof(alltests)
	forval i = 1/`nrm' {
		if alltests[`i',3] != alltests[`i',4] { 
			mat miss = miss \ alltests[`i',....]
		}
	}
	local nrm = rowsof(miss)
	if `nrm' > 1 {
	mat miss = miss[2..`nrm', ....]
	local nmt = rowsof(miss)
	mata: miss = st_matrix("miss")
	mata: varnames = st_matrixrowstripe("bhat")[,2]
	mata: sigmat = ("Insignificant" \ "Significant")
	mata: olmat = ("Overlapping" \ "Not overlapping")
	mata: miss_tests = varnames[miss[,1],1], varnames[miss[,2],1], sigmat[miss[,3]:+1, 1], olmat[miss[,4]:+1, 1]
	}
	mata: cn_ress = (J(3,1,""), ("Conf. Level" \ "Pr(Same)" \ "Easiness"))
	mata: rn_ress = st_matrixrowstripe("res_s")
	
	di " "
	di "Optimal Levels: "
	di " "
	mata: _matrix_list(res_s, rn_ress, cn_ress)
	if `nrm' > 1{
	di " "
	di "Missed Tests (n=`nmt' of `np')"
	di " "
	mata: cn_miss = ("LARGER" , "SMALLER" , "PW TEST" , "CI TEST" \ "------", "-------", "-------", "-------")
	mata: (cn_miss \ miss_tests)
	}
	else{
		di "No missed tests!"
	}
	if "`saving'" != "" {
	  local resname = "`saving'_results.dta"
	  local missname = "`saving'_miss.dta"
  	frame create levels level pr_same easiness
  	frame change levels 
  	mata: st_addobs(rows(res))
  	mata: st_store(., "level", res[,1])
  	mata: st_store(., "pr_same", res[,2])
  	mata: st_store(., "easiness", res[,3])
  	save "`resname'", replace
  	frame change default
  	if `nr' > 1 {	
  		frame create missed 
  		frame change missed
  		gen str25 bigger = ""
  		gen str25 smaller = ""
  		gen str25 pw_test = ""
  		gen str25 ci_test = ""
  		mata: st_addobs(rows(miss_tests))
  		mata: st_sstore(., "bigger", miss_tests[,1])
  		mata: st_sstore(., "smaller", miss_tests[,2])
  		mata: st_sstore(., "pw_test", miss_tests[,3])
  		mata: st_sstore(., "ci_test", miss_tests[,4])
  		save "`missname'", replace
  		frame change default
  	}
	}
	
end

mata
real matrix cummax(real matrix x) {
 	nc = cols(x)
	nr = rows(x)
	out = x
	for(j=1; j<=nc; j++){
		for(i=1; i<=nr ; i++){
			out[i,j] = max(x[1..i, j])
		}
	} 
	return(out)
 }
real matrix cummin(real matrix x) {
 	nc = cols(x)
	nr = rows(x)
	out = x
	for(j=1; j<=nc; j++){
		for(i=1; i<=nr ; i++){
			out[i,j] = min(x[1..i, j])
		}
	} 
	return(out)
 }
real matrix replaceneg(real matrix x) {
	nrows = rows(x)
	ncols = cols(x)
	out = x
	for (i = 1; i <= nrows; i++) {
		for (j = 1; j <= ncols; j++) {
			if (out[i,j] < 0) {
				out[i,j] = .
			}
		}
	}
	return(out)
}

 real matrix p_adjust(real matrix p, string scalar m){
	methods = ("bonferroni", "holm", "hochberg", "hommel", "bh", "by", "none")
	inmeth = rowsum( m :== methods)
	if(inmeth == 0) {
		di: "Method must be one of bonferroni, holm, hochberg, hommel, bh, by or none, please respecify."
		stata("break")
	}
	n = rows(p)
	ones = J(n, 1, 1)
	if(m == "bonferroni"){
		bon_p = p:*n
		p_adj = rowmin((ones, bon_p))
	}
	if(m == "holm"){
		o = order(p, 1)
		ro = order(o, 1)
		iseq = range(1, rows(p), 1)
		holm_p = cummax((n :+ 1 :- iseq) :*p[o[,1],1])[ro[,1],1]
		p_adj = rowmin((ones, holm_p))
	}
	if(m == "hommel"){
		o = order(p, 1)
		ro = order(o, 1)
		iseq = range(1, rows(p), 1)
		hp = p[o[,1],1]
		q = J(n, 1, min(n :* hp:/ iseq))
		pa = q
		for(j=n-1; j >= 2; j--){
			iseqj = range(1, n-j+1, 1)
			iseq2 = range(n-j+2, n, 1)
			q1 = min(j :* hp[iseq2[,1],1]:/range(2,j,1))
				for(w=1; w <= rows(iseqj); w++){
					q[iseqj[w,1],1] = min((j*hp[iseqj[w,1],1] \ q1))
				}
				for(w=1; w <= rows(iseq2); w++){
					q[iseq2[w,1]] = q[n-j+1]
				}
			pa = rowmax((pa, q))
		}
		p_adj = rowmax((pa, hp))[ro]
	}
	if(m == "hochberg"){
		reviseq = range(rows(p), 1, -1)
		o = order(-p, 1)
		ro = order(o, 1)
		p_adj = rowmin((cummin((n:+ 1:-reviseq):*p[o]), ones))[ro]
	}
	if(m == "bh"){
		reviseq = range(rows(p), 1, -1)
		o = order(-p, 1)
		ro = order(o, 1)
		p_adj = rowmin((cummin((n:/reviseq):*p[o]), ones))[ro]

	}
	if(m == "by"){
		reviseq = range(rows(p), 1, -1)
		o = order(-p, 1)
		ro = order(o, 1)
		q = colsum(1:/range(1, n, 1))
		p_adj = rowmin((ones, cummin(q :* n:/reviseq :* p[o])))[ro]
	}
	if(m == "none" | m == ""){
		p_adj = p
	}
	return(p_adj)
 }
end




