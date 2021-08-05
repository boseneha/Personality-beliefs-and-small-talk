clear
drop _all
set more off


*****DATASET*****

use TOM_data_chat

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



***************STANDARDISING LANGUAGE CAHARCTERISTICS******

foreach i in number_of_tokens conc valence arousal dominance aoa humor {
egen `i'_z = std(`i')
}

foreach i in opnumber_of_tokens opconc opvalence oparousal opdominance opaoa ophumor  {
egen `i'_z = std(`i')
}


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

**************************************************
************CHAT ANALYSIS*************************
**************************************************


***PARTNER LANGUAGE
eststo rl1a:reg pextraversion_z opnumber_of_tokens_z, vce(cluster groupid)
eststo rl1b:reg pextraversion_z opnumber_of_tokens_z opvalence_z oparousal_z opdominance_z, vce(cluster groupid)
eststo rl1c:reg pextraversion_z opnumber_of_tokens_z opvalence_z oparousal_z opdominance_z age female correctEyes_z correctRaven_z Ravenbelief_z  language firstspeaker, vce(cluster groupid)
eststo rl1d:reg pneuroticism_z opnumber_of_tokens_z, vce(cluster groupid)
eststo rl1e:reg pneuroticism_z opnumber_of_tokens_z opvalence_z oparousal_z opdominance_z, vce(cluster groupid)
eststo rl1f:reg pneuroticism_z opnumber_of_tokens_z opvalence_z oparousal_z opdominance_z age female correctEyes_z correctRaven_z Ravenbelief_z  language firstspeaker, vce(cluster groupid)

esttab rl1a rl1b rl1c rl1d rl1e rl1f using tablel1.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Impact of number of words and emotional content of the text spoken by the partner on beliefs about partner's personality")nomtitle mgroup("\shortstack{Extraversion\\Belief}""\shortstack{Neuroticism\\Belief}", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(opnumber_of_tokens_z "Number of Words" opvalence_z "Valence" oparousal_z "Arousal" opdominance_z "Dominance"  correctRaven_z "Own IQ"  age "Age" female "Female" correctEyes_z "Eyes Test Score" Ravenbelief_z "IQ Belief"  language "Non-Native Speaker" firstspeaker "First Speaker") order (opnumber_of_tokens_z  opvalence_z oparousal_z opdominance_z correctRaven_z correctEyes_z  age  female Ravenbelief_z  language firstspeaker )


****OWN LANGUAGE
eststo l2a:reg extraversion_z number_of_tokens_z, vce(cluster groupid)
eststo l2b:reg extraversion_z number_of_tokens_z valence_z arousal_z dominance_z, vce(cluster groupid)
eststo l2c:reg extraversion_z number_of_tokens_z valence_z arousal_z dominance_z age female correctEyes_z correctRaven_z language firstspeaker, vce(cluster groupid)
eststo l2d:reg neuroticism_z number_of_tokens_z, vce(cluster groupid)
eststo l2e:reg neuroticism_z number_of_tokens_z valence_z arousal_z dominance_z, vce(cluster groupid)
eststo l2f:reg neuroticism_z number_of_tokens_z valence_z arousal_z dominance_z age female correctEyes_z correctRaven_z language firstspeaker, vce(cluster groupid)


esttab l2a l2b l2c l2d l2e l2f using resultl2.tex, replace se(3) b(4) noconstant booktabs star(* 0.10 ** 0.05 *** 0.01) title("Relationship between number of words an emotional content of text spoken by the subject and the subject's own personality")nomtitle mgroup("Own Extraversion" "Own Neuroticism", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) coeflabel(number_of_tokens_z "Own Number of Words" valence_z "Own Valence" arousal_z "Own Arousal" dominance_z "Own Dominance" correctRaven_z "Own IQ"  age "Age" female "Female" correctEyes_z "Eyes Test Score" language "Non-Native Speaker" firstspeaker "First Speaker") order (number_of_tokens_z valence_z arousal_z dominance_z correctRaven_z correctEyes_z  age  female language firstspeaker )


pwcorr opnumber_of_tokens pextraversion, sig //r=0.2744 with p-value 0.0003
pwcorr number_of_tokens extraversion, sig // r=0.1439 with p-value 0.0628
