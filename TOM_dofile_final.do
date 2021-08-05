clear
drop _all
set more off


*****DATASET*****

use TOM_data

*******************************
****GRAPHING OPTIONS***********
*******************************


grstyle init

grstyle set plain


***************LIST OF VARIABLES*************

global perlist extraversion agreeableness conscientiousness neuroticism openness
global belieflist pextraversion pagreeableness pconscientiousness pneuroticism popenness
global facetlist Assertiveness Activity Altruism Compliance Order Selfdiscipline Anxiety Depression Aesthetics Ideas


*** OTHER PLAYER REAL PERSONALITY TRAIT & IQ

***The real personality measure of the partner (or other player) as reported by them

foreach i in $perlist {
vlookup otherplayerid, gen(r`i') key(id) value(`i')
}


global rlist rextraversion ragreeableness rconscientiousness rneuroticism ropenness


***The real IQ of the partner (or other player) i.e the partner's actual performance in the raven test

vlookup otherplayerid, gen(rcorrectRaven) key(id) value(correctRaven)



*******STANDARDIZE OWN PERSONALITY AND BELIEFS ABOUT PARTNER'S PERSONALITY*****
foreach i in $perlist {
egen `i'_z = std(`i')
}


foreach i in $belieflist {
egen `i'_z = std(`i')
}

foreach i in $rlist {
egen `i'_z = std(`i')
}

foreach i in $facetlist {
egen `i'_z = std(`i')
}

******************STANDARDIZING OTHER VARIABLES********************

foreach i in contribution PGGbelief moneyrequest moneybelief correctRaven correctEyes age Ravenbelief riskavr OwnRavenbelief rcorrectRaven {
egen `i'_z = std(`i')
}


********OTHER VARIABLES***************
gen level = 20 - moneyrequest
gen levelbelief = 20 - moneybelief

***Perceived differences in personality. absolute difference between own personality and beliefs about partner's personality 

foreach i in $perlist{
gen absdiff`i' = abs(`i' - p`i')
}
global absdifflist absdiffextraversion absdiffagreeableness absdiffconscientiousness absdiffneuroticism absdiffopenness


 
foreach i in $absdifflist {
egen `i'_z = std(`i')
}


***absolute difference between beliefs about partner's personality and partner's actual or true personality


foreach i in $perlist{
gen rdiff`i' = abs(p`i' - r`i')
}
 
global rdifflist rdiffextraversion rdiffagreeableness rdiffconscientiousness rdiffneuroticism rdiffopenness
 
 
foreach i in $rdifflist {
egen `i'_z = std(`i')
}

*** difference between personality belief and real personality of partner i.e degree of overestimation by the player


foreach i in $perlist{
gen realdiff`i' = p`i' - r`i'
} 
global realdifflist realdiffextraversion realdiffagreeableness realdiffconscientiousness realdiffneuroticism realdiffopenness
 
 
foreach i in $realdifflist {
egen `i'_z = std(`i')
}
  
gen realdiffIQ = Ravenbelief - rcorrectRaven //degree of overstatement in IQ belief


egen realdiffIQ_z = std(realdiffIQ)

gen rdiffIQ = abs(Ravenbelief - rcorrectRaven) // inaccuracy in IQ belief


egen rdiffIQ_z = std(rdiffIQ)

 

egen m_ext = median(extraversion)
gen highext = 1 if extraversion >=m_ext
replace highext = 0 if extraversion <m_ext


******Dummy for variable*******

gen female = 1 if gender == 2
replace female = 0 if gender!=2

**************LABEL VARIABLES**********************


label variable extraversion "Own Extraversion"
label variable neuroticism "Own Neuroticism"
label variable pextraversion "Extraversion Belief"
label variable pneuroticism "Neuroticism Belief"
label variable correctRaven "Own IQ"
label variable Ravenbelief "IQ Belief"
label variable correctEyes "Eyes Test Score"
label variable age "Age"
label variable female "Female"
label variable riskavr "Risk Aversion"
label variable language "Non-native English speaker"
label variable absdiffextraversion "Perceived diff Extraversion"
label variable absdiffneuroticism "Perceived diff Neuroticism"
label variable OwnRavenbelief "Own IQ Belief"
label variable level "Level Chosen"
label variable levelbelief "Level Belief"
label variable contribution "Own Contribution in PGG"
label variable PGGbelief "Contribution Belief"


*******BALANCE TEST*********************

iebaltab extraversion neuroticism correctEyes age female correctRaven riskavr language, grpvar(Treatment) ///
savetex(BalanceTest) ///
replace ftest rowvarlabel onerow pboth tblnonote format(%4.3f) star(0.1 0.05 0.01) 


********************SUMMARY STATISTICS****************

sutex extraversion neuroticism pextraversion pneuroticism absdiffextraversion absdiffneuroticism level levelbelief contribution PGGbelief correctRaven Ravenbelief correctEyes age riskavr female language, lab nobs key(descstat1)  replace ///
file(descstat1.tex)  minmax  title ("Summary Statistics")

***********************FIGURES******************************

*****FIGURE LEVEL CHOSEN
**The Distribution of level-k strategy chosen in the 11-20 money request game
gr bar (count) if Treatment==0, over(level, label(labsize(large))) ytitle("Frequency", size(vlarge)) b1title(Level-k Strategy, size(vlarge)) blabel(bar, size(large)) yscale(range(0 55) titlegap(1)) bar(1, color(ebblue)) ylabel(,labsize(large))
graph export level_control.png, replace
gr bar (count) if Treatment==1, over(level, label(labsize(large))) ytitle("Frequency", size(vlarge)) b1title(Level-k Strategy, size(vlarge)) blabel(bar, size(large)) yscale(range(0 55) titlegap(1)) bar(1, color(dkorange)) ylabel(,labsize(large))
graph export level_treatment.png, replace

kdensity level if Treatment == 1, lc(dkorange) plot(kdensity level if Treatment == 0, lc(ebblue)) ///
	legend(label(1 "Treatment") label(2 "Control") rows(1) size(vlarge)) xtitle(Level-k Strategy, size(vlarge)) ytitle(,size(vlarge)) note(,size(medium)) ylabel(,labsize(large)) xlabel(,labsize(large))
graph export kernel_level.png, replace


*****FIGURE LEVEL BELIEFS
*The Distribution of the player's beliefs about partner's level-k strategy in the 11-20 money request game
gr bar (count) if Treatment==0, over(levelbelief, label(labsize(large))) ytitle("Frequency", size(vlarge)) b1title(Beliefs about Partner's Level-k Strategy, size(vlarge)) blabel(bar, size(large)) yscale(range(0 45) titlegap(1)) bar(1, color(ebblue)) ylabel(0(10)55,labsize(large))
graph export levelbelief_control.png, replace
gr bar (count) if Treatment==1, over(levelbelief, label(labsize(large))) ytitle("Frequency", size(vlarge)) b1title(Beliefs about Partner's Level-k Strategy, size(vlarge)) blabel(bar, size(large)) yscale(range(0 45) titlegap(1)) bar(1, color(dkorange)) ylabel(0(10)55,labsize(large))
graph export levelbelief_treatment.png, replace

kdensity levelbelief if Treatment == 1, lc(dkorange) plot(kdensity levelbelief if Treatment == 0, lc(ebblue)) ///
	legend(label(1 "Treatment") label(2 "Control") rows(1) size(vlarge)) xtitle(Beliefs about Partner's Level-k Strategy, size(vlarge)) ytitle(,size(vlarge)) note(,size(medium)) ylabel(,labsize(large)) xlabel(,labsize(large))
graph export kernel_levelbelief.png, replace



***TESTS FOR EQUAL MEANS AND DISTRIBUTIONS*****

ttest level, by(Treatment)
ksmirnov level, by(Treatment) exact

ttest contribution, by(Treatment)  // 1% significant, p=0.0005 and t-statistic -3.5254
ttest PGGbelief, by(Treatment)  // 1% significant, p=0.0003 and t-statistic -3.6400

ksmirnov contribution, by(Treatment) exact // reject null of equal distribution with p-value = 0.000
ksmirnov PGGbelief, by(Treatment) exact // reject null of equal distribution with p-value = 0.001


*****Average Contribution and Beliefs about Partner's Contribution in the Public Goods Game
cibar contribution, over1(Treatment) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)14, labsize(large)) ytitle("Average contribution in PGG", size(large)) legend(row(1) size(large) order(1 "Control" 2 "Treatment") )) barcolor(ebblue dkorange)
graph export contribution.png, replace
cibar PGGbelief, over1(Treatment) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)14, labsize(large)) ytitle("Average contribution beliefs in PGG", size(large)) legend(row(1) size(large) order(1 "Control" 2 "Treatment") )) barcolor(ebblue dkorange)
graph export PGGbelief.png, replace


****Distribution of Contribution and Beliefs about Partner's Contribution in the Public Goods Game
	   
twoway (histogram contribution if Treatment==0, frequency color(ebblue)) (histogram contribution if Treatment==1, frequency color(dkorange)), legend(order(1 "Control" 2 "Treatment" ) size(large)) xtitle(Contribution, size(vlarge)) ytitle(Frequency, size(vlarge)) ylabel(,labsize(large)) xlabel(,labsize(large))
graph export contributiondist.png, replace
twoway (histogram PGGbelief if Treatment==0, frequency color(ebblue)) (histogram PGGbelief if Treatment==1, frequency color(dkorange)), legend(order(1 "Control" 2 "Treatment" ) size(large)) xtitle(Contribution Belief, size(vlarge)) ytitle(Frequency, size(vlarge)) ylabel(,labsize(large)) xlabel(,labsize(large))
graph export PGGbeliefdist.png, replace


******EXAMINING ORDER OF PLAY EFFECTS

***note that seq = 0 if PGG is played first, seq = 1 if 11-20 money request games is played first.

ttest contribution if seq==0, by(Treatment) // when PGG is played first, treated subjects contribute significantly more.
ttest contribution if seq==1, by(Treatment) // Not significant. when PGG is played second treated subjects do NOT contibute significantly more.
ttest PGGbelief if seq==0, by(Treatment) // significant
ttest PGGbelief if seq==1, by(Treatment) //significant

***Average contribution in Public Goods Game (PGG) (a) when PGG is played first (Order 1) and (b) when the 11-20 game is played first (Order 2) for treated subjects.

cibar contribution if seq==0, over1(Treatment) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)16, labsize(large)) ytitle("Average contribution in PGG", size(large)) legend(row(1) size(large) order(1 "Control" 2 "Treatment") )) barcolor(ebblue dkorange)
graph export ContributionOrder1.png, replace
cibar contribution if seq==1, over1(Treatment) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)16, labsize(large)) ytitle("Average contribution in PGG", size(large)) legend(row(1) size(large) order(1 "Control" 2 "Treatment") )) barcolor(ebblue dkorange)
graph export ContributionOrder2.png, replace

**generating dummy for order of play for Treatment group
gen seqTreatment =0 if Treatment==1 & seq==0
replace seqTreatment =1 if Treatment==1 & seq==1

**generating dummy for order of play Control group
gen seqControl =0 if Treatment==0 & seq==0
replace seqControl =1 if Treatment==0 & seq==1


****Average contribution in Public Goods Game (PGG) for different orders of play of the two games for (a) Control and (b) Treatment groups.

ttest contribution, by(seqTreatment) //One tailed test is significant. average in order 1 is 13.25 and that in order 2 is 11.37
ttest contribution, by(seqControl) // not significant. average in order 1 is 9.74 and that in order 2 is 9.16

cibar contribution, over1(seqControl) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)16, labsize(large)) ytitle("Average contribution in PGG", size(large)) legend(row(1) size(large) order(1 "Order 1" 2 "Order 2") )) barcolor(emerald cranberry) 
graph export seqControl.png, replace
cibar contribution, over1(seqTreatment) level(95) graphopts(note("95% confidence intervals", size(large)) ylabel(6(2)16, labsize(large)) ytitle("Average contribution in PGG", size(large)) legend(row(1) size(large) order(1 "Order 1" 2 "Order 2") )) barcolor(emerald cranberry)
graph export seqTreatment.png, replace

****Comparing average earnings

ttest Profit1, by(Treatment) // average earnings in PGG for T is 26.3 EP and in C it is 24.9. 2-sided Null of no difference is rejected at 5% significance level with p-value 0.0210 and t statistic -2.3189  
ttest Profit1 if Treatment==1, by(highext) // average earnings in PGG for Treatment group only is higher for extraverts (27 EP) than intoverts (25.5 EP). Two sided null of no difference is rejected at 10% significance levl with p-value 0.0715 and t statistic -1.8137.
ttest Profit1 if Treatment==0, by(highext) // average earnings in PGG for Control group NOT significantly different for extraverts (24.9 EP) and introverts (24.8 EP)

ttest Profit2, by(Treatment) //No significant difference
ttest Profit2 if Treatment==1, by(highext) //No significant difference than intoverts (25.5 EP). Two sided null of no difference is rejected at 10% significance levl with p-value 0.0715 and t statistic -1.8137.
ttest Profit2 if Treatment==0, by(highext)//No significant difference


*****************************************************
**********PERSONALITY BELIEFS***********************
****************************************************

eststo r1a:reg pextraversion_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rextraversion_z, vce (cluster groupid)
eststo r1b:reg pextraversion_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rextraversion_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r1c:reg pneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rneuroticism_z, vce (cluster groupid)
eststo r1d:reg pneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rneuroticism_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)

esttab  r1a r1b r1c r1d using table1.tex, varwidth(25) nobaselevels replace  se(3) b(4) noconstant booktabs nogaps star(* 0.10 ** 0.05 *** 0.01) title("Impact of own personality and partner's true personality on beliefs about partner's personality")nomtitle mgroup("\shortstack{Extraversion\\Belief}""\shortstack{Neuroticism\\Belief}", pattern(1 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(extraversion_z "Own Extraversion" neuroticism_z "Own Neuroticism" 1.Treatment "Treatment" 1.Treatment#c.extraversion_z "OwnExtraversion $\times$ Treatment" 1.Treatment#c.neuroticism_z "OwnNeuroticism $\times$ Treatment" rextraversion_z "Partner's Extraversion" rneuroticism_z "Partner's Neuroticism" 1.Treatment#c.rextraversion_z "PartnerExtraversion $\times$ Treatment" 1.Treatment#c.rneuroticism_z "PartnerNeuroticism $\times$ Treatment" 1.Treatment#c.correctEyes_z "\shortstack{Eyes Test Score\\ $\times$ Treatment}" 1.Treatment#c.correctRaven_z "Own IQ $\times$ Treatment" 1.Treatment#c.age "Age $\times$ Treatment" 1.Treatment#1.female "Female $\times$ Treatment" 1.Treatment#c.riskavr_z "\shortstack{Risk Aversion\\ $\times$ Treatment}" correctRaven_z "Own IQ"  correctEyes_z "\shortstack{Eyes Test\\Score}" age "Age" 1.female "Female" riskavr_z "Risk Aversion") order( 1.Treatment#c.extraversion_z  1.Treatment#c.neuroticism_z 1.Treatment#c.rextraversion_z  1.Treatment#c.rneuroticism_z extraversion_z neuroticism_z rextraversion_z  rneuroticism_z 1.Treatment )indicate( "Controls  = *1.Treatment#c.correctEyes_z* *1.Treatment#c.correctRaven_z* *1.Treatment#c.age* *1.Treatment#1.female* *1.Treatment#c.riskavr_z* *correctRaven_z* *correctEyes_z*  *1.female* *age* *riskavr_z*" )



***RELATIONSHIP BETWEEN OWN EXTRAVERSION AND EXTRAVERSION BELIEFS

twoway (scatter pextraversion_z extraversion_z, msym(oh) mcolor(teal%80) jitter(3)) ///
       (lfit pextraversion_z extraversion_z if Treatment ==0, lcolor(ebblue) lwidth(1))(lfit pextraversion_z extraversion_z if Treatment==1, lcolor(dkorange) lwidth(1)), ///
       legend(order(2 "Control" 3 "Treatment") size(large)) xtitle("Own Extraversion (Stadardised Values)", size(large)) ytitle("Extraversion Beliefs" "(Standardised Values)", size(large) ) ylabel(,labsize(large)) xlabel(,labsize(large)) 

graph export beliefs_projection.png, replace

*****INTERACTION PLOT

univar extraversion_z //(min -2.61 and max 2.001 amd median is 0)
reg pextraversion_z c.extraversion_z##Treatment c.neuroticism_z##Treatment c.rextraversion_z##Treatment, vce(cluster groupid)
margins, dydx(Treatment) at(extraversion_z=(-2.5(.5)2.0)) vsquish //to get the difference between treatment and control at different values of own extraversion
marginsplot, plot1opts(mcolor(emerald) lcolor(navy)) ciopts(lcolor(emerald)) yline(0, lcolor(cranberry)) title("Average Marginal Effects of Treatment with 95% CIs", size(large)) xtitle("Own Extraversion (Standardised Values)", size(large)) ytitle(,size(large)) ylabel(,labsize(large)) xlabel(,labsize(large))
graph export interaction_extraversion.png, replace

**********OVERESTIMATION AND INACCURACY OF PERSONALITY BELIEFS*************


eststo r2a:reg realdiffextraversion_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rextraversion_z Treatment##c.correctEyes_z, vce (cluster groupid)
eststo r2b:reg realdiffextraversion_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rextraversion_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r2c:reg rdiffextraversion_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rextraversion_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r2d:reg realdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rneuroticism_z Treatment##c.correctEyes_z, vce (cluster groupid)
eststo r2e:reg realdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rneuroticism_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r2f:reg rdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.rneuroticism_z Treatment##c.correctEyes_z Treatment##c.correctRaven_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)


esttab r2a r2b r2c r2d r2e r2f using table2.tex, varwidth(25) nobaselevels replace  se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Overestimation and Inaccuracy of personality beliefs")nomtitle mgroup("\shortstack{Overestimation of\\Extraversion Belief}" "\shortstack{Inaccuracy of\\Extraversion\\ Belief}" "\shortstack{Overestimation of\\Neuroticism Belief}" "\shortstack{Inaccuracy of\\Neuroticism\\ Belief}", pattern(1 0 1 1 0 1 ) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(extraversion_z "Own Extraversion" neuroticism_z "Own Neuroticism" rextraversion_z "Partner's Extraversion" rneuroticism_z "Partner's Neuroticism" 1.Treatment "Treatment" 1.Treatment#c.extraversion_z "OwnExtraversion $\times$ Treatment" 1.Treatment#c.neuroticism_z "OwnNeuroticism $\times$ Treatment" 1.Treatment#c.rextraversion_z "PartnerExtraversion $\times$ Treatment" 1.Treatment#c.rneuroticism_z "PartnerNeuroticism $\times$ Treatment" 1.Treatment#c.correctEyes_z "Eyes Test Score $\times$ Treatment" 1.Treatment#c.correctRaven_z "Own IQ $\times$ Treatment" 1.Treatment#c.age "Age $\times$ Treatment" 1.Treatment#1.female "Female $\times$ Treatment" 1.Treatment#c.riskavr_z "\shortstack{Risk Aversion\\ $\times$ Treatment}" correctRaven_z "Own IQ"  correctEyes_z "Eyes Test Score" age "Age" 1.female "Female" riskavr_z "Risk Aversion") order(1.Treatment#c.extraversion_z  1.Treatment#c.neuroticism_z 1.Treatment#c.rextraversion_z  1.Treatment#c.rneuroticism_z 1.Treatment#c.correctEyes_z   extraversion_z neuroticism_z   rextraversion_z rneuroticism_z correctEyes_z 1.Treatment   )indicate( "Controls = *1.Treatment#c.correctRaven_z* *1.Treatment#c.age* *1.Treatment#1.female* *1.Treatment#c.riskavr_z* *correctRaven_z*  *1.female* *age* *riskavr_z*" )

**********OVERESTIMATION AND INACCURACY OF IQ BELIEFS*************


eststo r3a:reg Ravenbelief_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z, vce (cluster groupid)
eststo r3b:reg Ravenbelief_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r3c:reg realdiffIQ_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z, vce (cluster groupid)
eststo r3d:reg realdiffIQ_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)
eststo r3e:reg rdiffIQ_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z, vce (cluster groupid)
eststo r3f:reg rdiffIQ_z Treatment##c.OwnRavenbelief_z Treatment##c.rcorrectRaven_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z, vce (cluster groupid)


esttab r3a r3b r3c r3d r3e r3f  using table3.tex, varwidth(25) nobaselevels replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about own cognitive ability on beliefs about partner's cognitive ability")nomtitle mgroup("\shortstack{IQ\\Belief}""\shortstack{Overestimation of\\IQ Belief}" "\shortstack{Inaccuracy of\\IQ Belief}", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(OwnRavenbelief_z "Own IQ belief" rcorrectRaven_z "Partner's IQ"  1.Treatment "Treatment" 1.Treatment#c.OwnRavenbelief_z "Own IQ Belief $\times$ Treatment" 1.Treatment#c.rcorrectRaven_z "Partner's IQ $\times$ Treatment" 1.Treatment#c.correctEyes_z "Eyes Test Score $\times$ Treatment" 1.Treatment#c.correctRaven_z "Own IQ $\times$ Treatment" 1.Treatment#c.age "Age $\times$ Treatment" 1.Treatment#1.female "Female $\times$ Treatment" 1.Treatment#c.riskavr_z "\shortstack{Risk Aversion\\ $\times$ Treatment}" correctRaven_z "Own IQ"  correctEyes_z "Eyes Test Score" age "Age" 1.female "Female" riskavr_z "Risk Aversion" ) order(1.Treatment#c.OwnRavenbelief_z 1.Treatment#c.rcorrectRaven_z OwnRavenbelief_z rcorrectRaven_z 1.Treatment 1.Treatment#c.correctRaven_z 1.Treatment#c.correctEyes_z  correctRaven_z correctEyes_z)indicate("Controls =  *1.Treatment#c.age* *1.Treatment#1.female* *1.Treatment#c.riskavr_z* *1.female* *age* *riskavr_z*")

****CORRELATION BETWEEN PERSONALITY BELIEFS AND PARTNER'S TRUE PERSONALITY*****


pwcorr pextraversion rextraversion if Treatment==1, sig star(.05) //significant
pwcorr pneuroticism rneuroticism if Treatment==1, sig star(.05) //insignificant
pwcorr pagreeableness ragreeableness if Treatment==1, sig star(.05) //insignificant
pwcorr pconscientiousness rconscientiousness if Treatment==1, sig star(.05) //insignificant
pwcorr popenness ropenness if Treatment==1, sig star(.05) //insignificant




*****************************************************
**********11-20 money request game***********************
****************************************************
eststo r4a:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z, vce (cluster groupid)
eststo r4b:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z, vce (cluster groupid)
eststo r4c:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z Treatment##seq Treatment##c.Ravenbelief_z, vce (cluster groupid)
eststo r4d:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z, vce (cluster groupid)
eststo r4e:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z, vce (cluster groupid)
eststo r4f:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.neuroticism_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z Treatment##seq Treatment##c.Ravenbelief_z, vce (cluster groupid)


esttab r4a r4b r4c r4d r4e r4f using result4.tex, varwidth(25) nobaselevels replace se(3) b(4) noconstant booktabs nogaps star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on level-k strategy chosen")nomtitle mgroup("\shortstack{Level\\Belief}""\shortstack{Level\\Chosen}", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(1.Treatment#c.absdiffextraversion_z "DiffExtraversion $\times$ Treatment" 1.Treatment#c.absdiffneuroticism_z "DiffNeuroticism $\times$ Treatment" absdiffextraversion_z "DiffExtraversion" absdiffneuroticism_z "DiffNeuroticism" 1.Treatment "Treatment" 1.Treatment#c.extraversion_z "Own Extraversion $\times$ Treatment" 1.Treatment#c.neuroticism_z "Own Neuroticism $\times$ Treatment" extraversion_z "Own Extraversion" pextraversion_z "Extraversion Belief" neuroticism_z "Own Neuroticism" pneuroticism_z "Neuroticism Belief" 1.Treatment#c.correctRaven_z "Own IQ $\times$ Treatment" 1.Treatment#c.correctEyes_z "Eyes Test Score $\times$ Treatment" correctRaven_z "Own IQ" correctEyes_z "Eyes Test Score" 1.Treatment#c.age "Age $\times$ Treatment" age "Age" 1.Treatment#1.female "Female $\times$ Treatment" 1.female "Female" 1.Treatment#c.riskavr_z "\shortstack{Risk Aversion\\ $\times$ Treatment}" riskavr_z "Risk Aversion" 1.Treatment#1.seq "Order $\times$ Treatment" 1.seq "Order" 1.Treatment#c.Ravenbelief_z "IQ Belief $\times$ Treatment" Ravenbelief_z "IQ Belief") order(1.Treatment#c.absdiffextraversion_z 1.Treatment#c.absdiffneuroticism_z absdiffextraversion_z absdiffneuroticism_z 1.Treatment 1.Treatment#c.extraversion_z 1.Treatment#c.neuroticism_z extraversion_z neuroticism_z  1.Treatment#c.correctEyes_z 1.Treatment#c.correctRaven_z 1.Treatment#c.Ravenbelief_z    1.Treatment#1.female   1.Treatment#1.seq  correctEyes_z correctRaven_z Ravenbelief_z 1.female 1.seq) indicate("Controls = *1.Treatment#c.age* *age* *1.Treatment#c.riskavr_z* *riskavr_z* ")
 
 
***Including personality beliefs

eststo r4ae:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z, vce (cluster groupid)
eststo r4be:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.pextraversion_z Treatment##c.neuroticism_z Treatment##c.pneuroticism_z, vce (cluster groupid)
eststo r4ce:reg levelbelief Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.pextraversion_z Treatment##c.neuroticism_z Treatment##c.pneuroticism_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z Treatment##seq Treatment##c.Ravenbelief_z, vce (cluster groupid)
eststo r4de:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z, vce (cluster groupid)
eststo r4ee:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.pextraversion_z Treatment##c.neuroticism_z Treatment##c.pneuroticism_z, vce (cluster groupid)
eststo r4fe:reg level Treatment##c.absdiffextraversion_z Treatment##c.absdiffneuroticism_z Treatment##c.extraversion_z Treatment##c.pextraversion_z Treatment##c.neuroticism_z Treatment##c.pneuroticism_z Treatment##c.correctRaven_z Treatment##c.correctEyes_z Treatment##c.age Treatment##female Treatment##c.riskavr_z Treatment##seq Treatment##c.Ravenbelief_z, vce (cluster groupid)


esttab r4ae r4be r4ce r4de r4ee r4fe using result4e.tex, varwidth(25) nobaselevels replace se(3) b(4) noconstant booktabs nogaps star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on level-k strategy chosen")nomtitle mgroup("\shortstack{Level\\Belief}""\shortstack{Level\\Chosen}", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(1.Treatment#c.absdiffextraversion_z "DiffExtraversion $\times$ Treatment" 1.Treatment#c.absdiffneuroticism_z "DiffNeuroticism $\times$ Treatment" absdiffextraversion_z "DiffExtraversion" absdiffneuroticism_z "DiffNeuroticism" 1.Treatment "Treatment" 1.Treatment#c.extraversion_z "Own Extraversion $\times$ Treatment" 1.Treatment#c.pextraversion_z "Extraversion Belief $\times$ Treatment" 1.Treatment#c.neuroticism_z "Own Neuroticism $\times$ Treatment" 1.Treatment#c.pneuroticism_z "Neuroticism Belief $\times$ Treatment" extraversion_z "Own Extraversion" pextraversion_z "Extraversion Belief" neuroticism_z "Own Neuroticism" pneuroticism_z "Neuroticism Belief" 1.Treatment#c.correctRaven_z "Own IQ $\times$ Treatment" 1.Treatment#c.correctEyes_z "Eyes Test Score $\times$ Treatment" correctRaven_z "Own IQ" correctEyes_z "Eyes Test Score" 1.Treatment#c.age "Age $\times$ Treatment" age "Age" 1.Treatment#1.female "Female $\times$ Treatment" 1.female "Female" 1.Treatment#c.riskavr_z "\shortstack{Risk Aversion\\ $\times$ Treatment}" riskavr_z "Risk Aversion" 1.Treatment#1.seq "Order $\times$ Treatment" 1.seq "Order" 1.Treatment#c.Ravenbelief_z "IQ Belief $\times$ Treatment" Ravenbelief_z "IQ Belief") order(1.Treatment#c.absdiffextraversion_z 1.Treatment#c.absdiffneuroticism_z absdiffextraversion_z absdiffneuroticism_z 1.Treatment 1.Treatment#c.extraversion_z  1.Treatment#c.neuroticism_z extraversion_z neuroticism_z 1.Treatment#c.pextraversion_z 1.Treatment#c.pneuroticism_z  pextraversion_z  pneuroticism_z  1.Treatment#c.correctEyes_z 1.Treatment#c.correctRaven_z 1.Treatment#c.Ravenbelief_z    1.Treatment#1.female   1.Treatment#1.seq  correctEyes_z correctRaven_z Ravenbelief_z 1.female 1.seq) indicate("Controls = *1.Treatment#c.age* *age* *1.Treatment#c.riskavr_z* *riskavr_z* ")
  
 
 
reg level Treatment##c.absdiffextraversion_z, vce (cluster groupid)
margins, dydx(absdiffextraversion_z) at(Treatment=(0 1)) vsquish
marginsplot, plot1opts(mcolor(emerald) lcolor(midblue)) ciopts(lcolor(emerald)) yline(0) title("Average Marginal Effects of Perceived Difference" "in Extraversion with 95% CIs", size(large)) xtitle(,size(large)) ytitle("Level",size(vlarge)) ylabel(,labsize(vlarge)) xlabel(,labsize(vlarge))
graph export levelk_treatment.png, replace



**Number of people who best-reponded (i.e asked 1 less than what they believed the partner would) to their own beliefs

gen bestresponse =1 if moneybelief - moneyrequest==1
replace bestresponse =0 if moneybelief - moneyrequest!=1

tab bestresponse Treatment //90 out of 168 in Treatment and 94 out of 170 in Control



****Best response for Treatment based on beliefs is level 2
*****Best reponse for Control based on beliefs is level 2


gen best = 1 if level==2 & Treatment==1
replace best =1 if level==2 & Treatment==0
replace best =0 if best==.

ttest best, by(Treatment) //not significant

******PROBABIBILITY OF BEST RESPONDING********

probit best absdiffextraversion_z absdiffneuroticism_z if Treatment==0, robust
eststo r7a:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z extraversion_z neuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==0, robust
eststo r7b:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z if Treatment==1, robust
eststo r7c:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z extraversion_z neuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==1, robust
eststo r7d:margins, dydx(*) post noatlegend


esttab r7a r7b r7c r7d using table7.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on the probability of choosing the best response - Probit Model")mtitle("Pr(Level=2)" "Pr(Level=2)""Pr(Level=2)""Pr(Level=2)") mgroup("Control""Treatment", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(absdiffextraversion_z "DiffExtraversion"  absdiffneuroticism_z "DiffNeuroticism" extraversion_z "Own Extraversion" neuroticism_z "Own Neuroticism" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief" correctEyes_z "Eyes Test Score" riskavr_z "Risk Aversion")indicate("Controls = *age* *female* *riskavr_z* *seq*")

******Probit with personality beliefs


probit best absdiffextraversion_z absdiffneuroticism_z if Treatment==0, robust
eststo r7a:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z extraversion_z  neuroticism_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==0, robust
eststo r7b:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z if Treatment==1, robust
eststo r7c:margins, dydx(*) post noatlegend
probit best absdiffextraversion_z absdiffneuroticism_z extraversion_z  neuroticism_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==1, robust
eststo r7d:margins, dydx(*) post noatlegend


esttab r7a r7b r7c r7d using table7.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on the probability of choosing the best response - Probit Model")mtitle("Pr(Level=2)" "Pr(Level=2)""Pr(Level=2)""Pr(Level=2)") mgroup("Control""Treatment", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(absdiffextraversion_z "DiffExtraversion"  absdiffneuroticism_z "DiffNeuroticism" extraversion_z "Own Extraversion"  neuroticism_z "Own Neuroticism" pextraversion_z "Extraversion Belief" pneuroticism_z "Neuroticism Belief" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief" correctEyes_z "Eyes Test Score" riskavr_z "Risk Aversion")indicate("Controls = *age* *female* *riskavr_z* *seq*")




logit best absdiffextraversion_z absdiffneuroticism_z if Treatment==0, robust
eststo r8a:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z extraversion_z neuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==0, robust
eststo r8b:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z if Treatment==1, robust
eststo r8c:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z extraversion_z neuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==1, robust
eststo r8d:margins, dydx(*) post noatlegend


esttab r8a r8b r8c r8d using table8.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on the probability of choosing the best response - Logit Model")mtitle("Pr(Level=2)" "Pr(Level=2)""Pr(Level=2)""Pr(Level=2)") mgroup("Control""Treatment", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(absdiffextraversion_z "DiffExtraversion"  absdiffneuroticism_z "DiffNeuroticism" extraversion_z "Own Extraversion" neuroticism_z "Own Neuroticism" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief" correctEyes_z "Eyes Test Score" riskavr_z "Risk Aversion")indicate("Controls = *age* *female* *riskavr_z* *seq*")




****Logit with personality beleifs


logit best absdiffextraversion_z absdiffneuroticism_z if Treatment==0, robust
eststo r8a:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z extraversion_z  neuroticism_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==0, robust
eststo r8b:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z if Treatment==1, robust
eststo r8c:margins, dydx(*) post noatlegend
logit best absdiffextraversion_z absdiffneuroticism_z extraversion_z  neuroticism_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z seq if Treatment==1, robust
eststo r8d:margins, dydx(*) post noatlegend


esttab r8a r8b r8c r8d using table8.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of (absolute) difference between own personality and beliefs about partner's personality on the probability of choosing the best response - Logit Model")mtitle("Pr(Level=2)" "Pr(Level=2)""Pr(Level=2)""Pr(Level=2)") mgroup("Control""Treatment", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))coeflabel(absdiffextraversion_z "DiffExtraversion"  absdiffneuroticism_z "DiffNeuroticism" extraversion_z "Own Extraversion"  neuroticism_z "Own Neuroticism" pextraversion_z "Extraversion Belief" pneuroticism_z "Neuroticism Belief" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief" correctEyes_z "Eyes Test Score" riskavr_z "Risk Aversion")indicate("Controls = *age* *female* *riskavr_z* *seq*")





univar absdiffextraversion_z //min is -1.28, max is 3.44, median is -0.19, 75th percentile is 0.53 25th percentile is -0.74
probit best c.absdiffextraversion_z##Treatment , robust
margins, dydx(Treatment) at (absdiffextraversion_z=(-1.5(.5)2.5)) vsquish 
marginsplot, plot1opts(mcolor(emerald) lcolor(midblue)) ciopts(lcolor(emerald)) yline(0) title("Average Marginal Effects of Treatment with 95% CIs", size(large)) xtitle("Perceived Difference in Extraversion (Standardised Values)", size(large)) ytitle("Pr(Level=2)", size(vlarge)) xsize(5.75) ylabel(,labsize(vlarge)) xlabel(,labsize(vlarge)) // measures the difference between control and treatment at different values of perceived extraversion difference

graph export level_prob.png, replace


*********************************************************
*************PGG*****************************************
*********************************************************

*****FIRST STAGE**************



eststo fa:reg pextraversion_z extraversion_z rextraversion_z if Treatment==0 & seq==0, cluster (groupid)
eststo fb:reg pextraversion_z extraversion_z rextraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid)
ivreg2 contribution_z (pextraversion_z=rextraversion_z) extraversion_z if Treatment==1 & seq==0, cluster(groupid) first  savefirst savefprefix(first1)
ivreg2 contribution_z (pextraversion_z=rextraversion_z) extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, cluster(groupid) first savefirst savefprefix(first2)

esttab fa fb first1* first2* using tablef.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("First Stage")mtitle("\shortstack{Extraversion\\Belief}" "\shortstack{Extraversion\\Belief}" "\shortstack{Extraversion\\Belief}" "\shortstack{Extraversion\\Belief}")mgroup("Control""Treatment", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(extraversion_z "Own Extraversion" rextraversion_z "Partner's Extraversion" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score") indicate ("Controls =  *age* *female* *riskavr_z*")

*******IV RESGRESSION

eststo sa:reg PGGbelief_z pextraversion_z  extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==0 & seq==0, cluster (groupid)
eststo sb:reg contribution_z pextraversion_z extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid)  
eststo sc:ivreg2 PGGbelief_z (pextraversion_z =rextraversion_z) extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==1 & seq==0, cluster (groupid)
//weakiv
eststo sd:ivreg2 contribution_z (pextraversion_z=rextraversion_z) extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, ffirst cluster (groupid)  
//weakiv

esttab sa sb sc sd using tableiv.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about partner's personality and own personality on beliefs about partner's contribution and own contribution in Public Goods Game")mtitle("\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" )mgroup("\shortstack{Control\\ OLS}" "\shortstack{Treatment\\ IV}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(pextraversion_z "ExtraversionBelief"   extraversion_z "OwnExtraversion" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score" age "age" female "Female" riskaversion "Risk Aversion" )indicate("Controls =  *age* *female* *riskavr_z")


*******OLS approach



eststo sa1:reg PGGbelief_z pextraversion_z  extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==0 & seq==0, cluster (groupid)
eststo sb1:reg contribution_z pextraversion_z extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid)  
eststo sc1:reg PGGbelief_z pextraversion_z  extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==1 & seq==0, cluster (groupid)
eststo sd1:reg contribution_z pextraversion_z extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, cluster (groupid)  

esttab sa1 sb1 sc1 sd1 using tablePGGOLS.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about partner's personality and own personality on beliefs about partner's contribution and own contribution in Public Goods Game")mtitle("\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" )mgroup("\shortstack{Control\\ OLS}" "\shortstack{Treatment\\ OLS}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(pextraversion_z "ExtraversionBelief"   extraversion_z "OwnExtraversion" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score" age "age" female "Female" riskaversion "Risk Aversion" )indicate("Controls =  *age* *female* *riskavr_z")



****To show that only extraversion beliefs matter, not neuroticism beliefs (for appendix)

eststo ra5a:reg PGGbelief_z pextraversion_z pneuroticism_z if Treatment==0 & seq==0, cluster (groupid)
eststo ra5b:reg PGGbelief_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==0 & seq==0, cluster (groupid)
eststo ra5c:reg contribution_z pextraversion_z pneuroticism_z if Treatment==0 & seq==0, cluster (groupid) 
eststo ra5d:reg contribution_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid) 
eststo ra5e:reg PGGbelief_z pextraversion_z pneuroticism_z  if Treatment==1 & seq==0, cluster (groupid)
eststo ra5f:reg PGGbelief_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==1 & seq==0, cluster (groupid)
eststo ra5g:reg contribution_z pextraversion_z pneuroticism_z if Treatment==1 & seq==0, cluster (groupid) 
eststo ra5h:reg contribution_z pextraversion_z pneuroticism_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, cluster (groupid) 



esttab ra5a ra5b ra5c ra5d ra5e ra5f ra5g ra5h using tablea5.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about partner's personality on beliefs about partner's contribution and own contribution in Public Goods Game")mtitle("\shortstack{Contribution\\Belief}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Own\\Contribution}"  "\shortstack{Contribution\\Belief}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Own\\Contribution}")mgroup("\shortstack{Control\\ Order 1}""\shortstack{Treatment\\ Order 1}", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(pextraversion_z "ExtraversionBelief"   pneuroticism_z "NeurotcisimBelief" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score" age "age" female "Female" riskaversion "Risk Aversion" )indicate("Controls =  *age* *female* *riskavr_z")

******FACET ANALYSIS

eststo r10a:reg PGGbelief_z pextraversion_z Assertiveness_z Activity_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid) 
eststo r10b:reg contribution_z pextraversion_z Assertiveness_z Activity_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==0, cluster (groupid) 
eststo r10c:ivreg2 PGGbelief_z (pextraversion_z=rextraversion_z) Assertiveness_z Activity_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, cluster (groupid) 
eststo r10d:ivreg2 contribution_z (pextraversion_z=rextraversion_z) Assertiveness_z Activity_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==0, cluster (groupid) 


esttab r10a r10b r10c r10d using table10.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about partner's personality and own personality facets on beliefs about partner's contribution and own contribution in Public Goods Game")mtitle("\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}"  "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}")mgroup("\shortstack{Control\\ OLS}" "\shortstack{Treatment\\ IV}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(pextraversion_z "ExtraversionBelief"   Assertiveness_z "OwnAssertiveness" Activity_z "OwnActivity" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score" age "age" female "Female" riskaversion "Risk Aversion" )indicate("Controls =  *age* *female* *riskavr_z")



****FOR ORDER 2 (for appendix)


eststo oa:reg PGGbelief_z pextraversion_z  extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==0 & seq==1, cluster (groupid)
eststo ob:reg contribution_z pextraversion_z extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==0 & seq==1, cluster (groupid) 
eststo oc:ivreg2 PGGbelief_z (pextraversion_z =rextraversion_z) extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z   if Treatment==1 & seq==1, cluster (groupid)
eststo od:ivreg2 contribution_z (pextraversion_z=rextraversion_z) extraversion_z correctRaven_z Ravenbelief_z correctEyes_z age female riskavr_z if Treatment==1 & seq==1, cluster (groupid) 



esttab oa ob oc od using tableo2.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of beliefs about partner's personality and own personality on beliefs about partner's contribution and own contribution in Public Goods Game - Order 2")mtitle("\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" "\shortstack{Contribution\\Belief}"  "\shortstack{Own\\Contribution}" )mgroup("\shortstack{Control\\ OLS}"  "\shortstack{Treatment\\ IV}", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(pextraversion_z "ExtraversionBelief"   extraversion_z "OwnExtraversion" correctRaven_z "Own IQ" Ravenbelief_z "IQ Belief"  correctEyes_z "Eyes Test Score" age "age" female "Female" riskaversion "Risk Aversion" )indicate("Controls =  *age* *female* *riskavr_z")







*****
