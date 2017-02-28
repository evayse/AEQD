
cd "/Users/evayse/Dropbox/AEQD"

infile Hed Wed WageM Cnum Year Wage Hage BirthInd NextBirthInd/*
*/ Children CurrentContraception PreviousBirthInd Religious NotContracepting/*
*/ Contracepting Sterilizing AgeChild1 AgeChild2 AgeChild3 AgeChild4 AgeChild5/*
*/ AgeChild6 AgeChild7 AgeChild8 PreviousContraception /*
*/ using "Data.txt"
label data "Spanish Contracepting"
notes: Jesus Carro and Pedro Mira, "A dynamic model of contraceptive choice of Spanish couples", ///
Journal of Applied Econometrics, forthcoming.

label variable Hed "Husband's education, coded as described in the paper"
label variable Wed "Wife's education, coded as described in the paper"
label variable WageM "Wife's age at the moment of marriage"
label variable Cnum "Couple's Number"
label variable Year "Year"
label variable Wage "Wife's age"
label variable Hage "Husband's age"
label variable BirthInd "Current birth indicator"
label variable NextBirthInd "Next period birth indicator"
label variable Children "Number of children"
label variable CurrentContraception "Current contraceptive action: takes value 1 if not contracepting, 2 if contracepting and 3 if sterilizing."
label variable PreviousBirthInd "Previous period birth indicator"
label variable Religious "Religious couple indicator"
label variable NotContracepting "Not contracepting indicator (1 if not contracepting, 0 otherwise)"
label variable Contracepting "Contracepting indicator (1 if contracepting, 0 otherwise)"
label variable Sterilizing "Sterilizing indicator (1 if sterilizing, 0 otherwise)"
label variable AgeChild1 ""
label variable AgeChild2 ""
label variable AgeChild3 ""
label variable AgeChild4 ""
label variable AgeChild5 ""
label variable AgeChild6 ""
label variable AgeChild7 ""
label variable AgeChild8 ""


gen PreviousContracepting = 0
replace PreviousContracepting = 1 if PreviousContraception == 2
label variable PreviousContracepting "Previous Contracepting indicator (1 if contracepting at the previous period, 0 otherwise)"
xtset Cnum Year


// Premier Modèle : Régression logistique simple pour une comparaison ultérieure
logit Contracepting i.Hed i.Wed Wage Hage Children
estimates store logit1

logit Contracepting i.Hed i.Wed Wage Hage Children, cluster(Cnum)
estimates store logitcluster1

// Deuxième Modèle : Régression logistique pour données de panel avec random effect
xtlogit Contracepting PreviousBirthInd Children Wed/*
*/ Religious Wage WageM, i(Cnum)
estimates store logitrd1

// Comparaison entre les deux modèles
estimates table  logit1 logitrd1

// Nouvelle tentative avec d'autres variables
logit Contracepting i.Wed Children
estimates store logit2

logit Contracepting i.Wed Children, cluster(Cnum) robust
estimates store logitcluster2

xtlogit Contracepting i.Wed Children, i(Cnum)
estimates store logitrd2

estimates table  logit2 logitrd2

// Tentative de sélection des variables pertinentes dans le cas d'un logit classique 
// avec une méthode stepwise
stepwise, pe(.1): logit Contracepting Hed Wed WageM Wage Hage Children
estimates store logitstepwise

// Régression logistique pour données de panel avec random effect avec les variables sélectionnées
xtlogit Contracepting Children i.Wed WageM Wage Hage, i(Cnum)
estimates store xtlogitstepwise

// Regression probit avec données de panel avec random effect avec les variables sélectionnées
xtprobit Contracepting LContracepting PreviousBirthInd Children Wed/*
*/ Religious Wage WageM, i(Cnum)
estimates store xtprobitstepwise

// Nouvel essais stepwise avec toutes les variables du modèle cette fois
stepwise, pe(.1): logit Contracepting Hed Wed WageM Wage Hage Children PreviousBirthInd Religious PreviousContraception
estimates store logitstepwise2

xtlogit Contracepting i.PreviousContraception i.PreviousBirthInd Children i.Wed i.Religious Wage WageM, re // C'est le modèle à garder pour estimer l'utilisation de la contraception
estimates store xtlogit_def 
margins, dydx(*) atmeans post
estimates store xtlogit_def_margin

xtprobit Contracepting i.PreviousContraception i.PreviousBirthInd Children i.Wed i.Religious Wage WageM, re // Celuk là aussi
estimates store xtprobit_def
margins, dydx(*) atmeans post
estimates store xtprobit_def_margin

xtprobit Contracepting PreviousBirthInd Children Wed/*
*/ Religious Wage WageM, fe // C'est le modèle à garder pour estimer l'utilisation de la contraception

quietly xtprobit cs i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM, vce(cluster Cnum)
estimates store POOLED

quietly xtprobit cs i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM
estimates store RE

estimates table POOLED RE, equations(1) se b(%8.4f) stats(N ll)



gen cs = 1 if Contracepting ==1 
replace cs = 0 if Contracepting == 0
replace cs = 0 if Sterilizing == 1


xtprobit cs i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM, vce(cluster Cnum)

stepwise, pe(.1): logit Contracepting Hed Wed WageM Wage Hage Children PreviousBirthInd Religious
estimates store logitstepwise2


*/

summarize Contracepting PreviousContracepting PreviousBirthInd Children Wed Religious Wage WageM  Hage Sterilizing
xtdescribe

global xlist i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM  Hage



bys Cnum: egen Children_avg = mean(Children) 
bys Cnum: egen Wage_avg = mean(Wage) 
*bys Cnum: egen WageM_avg = mean(WageM)
bys Cnum: egen Hage_avg = mean(Hage)
* bys Cnum: egen Religious_avg = mean(Religious)
bys Cnum: egen PreviousBirthInd_avg = mean(PreviousBirthInd)
* bys Cnum: egen Wed_avg = mean(Wed)
bys Cnum: egen Year1 = min(Year)
* bys Cnum: egen Sterilizing_avg = mean(Sterilizing)

egen first_year = min(Year)
gen sum_var = PreviousBirthInd_avg + Children_avg + Wed_avg + Religious_avg /*
*/+ Wage_avg + WageM_avg + Hage_avg

global moys PreviousBirthInd_avg Children_avg /*
*/ Wage_avg Hage_avg


quietly logit Contracepting $xlist, vce(cluster Cnum)
estimates store POOLED

xtlogit Contracepting LContracepting $xlist, re 
estimates store RE
*quietly xtlogit Contracepting $xlist, fe gradient
*estimates store FE
*estimates table POOLED RE FE, equations(1) se b(%8.4f)

*hausman FE RE, eq(1:1)

sort Cnum Year
bys Cnum: gen Contracepting1=Contracepting[1] 

* WOOLDRIDGE
xtprobit Contracepting $xlist i.PreviousContracepting Contracepting1, i(Cnum) 

*Mundlak
xtprobit Contracepting $xlist $moys i.PreviousContracepting, i(Cnum) 


* CRE Model
xtprobit Contracepting $xlist i.PreviousContracepting, i(Cnum) vce(cluster Cnum) 



bys Cnum: gen nwav=_N
*keep 
if nwav==11
sort Cnum Year
by Cnum: gen tper=_n
xtset Cnum tper

bys Cnum: gen FirstBirth = . if AgeChild1 == -1
replace FirstBirth = Wage - AgeChild1 if AgeChild1 > -1
replace FirstBirth = 1 if FirstBirth > 1

bys Cnum: gen Wage2 = Wage^2
bys Cnum: gen Hage2 = Hage^2
bys Cnum: gen Children2 = Children^2
bys Cnum: gen WageM2 = WageM^2

matrix mat_initial = (.5,.5,.5,.5, .5, .5, .5, .5)


redprob Contracepting LContracepting PreviousBirthInd Children Wed/*
*/ Religious Wage WageM (PreviousBirthInd Children Wed/*
*/ Religious Wage WageM  Hage Wage2 Hage2 WageM2 Children2), /*
*/ i(Cnum) t(tper) quadrat(24) 

/*
« The xtprobit estimates in the next column allow individual-specific 
effects but take the initial condition to be exogenous. »
*/

sort Cnum Year

by Cnum: gen LContracepting = Contracepting[_n-1]

rfper1: Religious rfper1:_cons rfper1:WageM logitlam:_cons atar1:_cons
ltheta:_cons

redpace Contracepting LContracepting PreviousBirthInd Children Wed/*
*/ Religious Wage WageM (PreviousBirthInd Children Wed/*
*/ Religious Wage WageM  Hage Wage2 Hage2 WageM2 Children2), /*
*/ i(Cnum) t(tper) from(mat_initial)


/*
We run a dynamic probit model to estimate the effect of the previous contraception
and the individual characteristics to the actual choice of contraception. 
The standard random effect model, estimated before, is not consistent anymore. 

Two cases have to be dinstinguished. 
First, if the error terms are serially uncorrelated, 
*/










