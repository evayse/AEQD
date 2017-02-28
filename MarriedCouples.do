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

* Statistiques descriptives
describe
summarize Contracepting PreviousContracepting PreviousBirthInd Children Wed Religious Wage WageM  Hage Sterilizing
xtdescribe

gen cs = 1 if Contracepting ==1 
replace cs = 0 if Contracepting == 0
replace cs = 0 if Sterilizing == 1

gen Lcs = L.cs
replace Lcs = PreviousContracepting if Sterilizing = 0 

sort Cnum Year

* Modèle probit à effets aléatoires
xtprobit cs i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM Hage


* Modèle de Mundlak
mundlak cs PreviousBirthInd Children Wed/*
*/ Religious Wage WageM Hage


* Modèle dynamiques à effets aléatoires avec conditions initiales exogènes
xtprobit Contracepting PreviousContracepting i.PreviousBirthInd Children i.Wed/*
*/ i.Religious Wage WageM Hage



* Modèle d'Heckman
sort Cnum Year
bys Cnum : gen tper=_n
xtset Cnum tper

bys Cnum: gen Wage2 = Wage^2
bys Cnum: gen Hage2 = Hage^2
bys Cnum: gen Children2 = Children^2
bys Cnum: gen WageM2 = WageM^2


gen Lcs = L.cs

redprob cs Lcs PreviousBirthInd Children Wed/*
*/ Religious Wage WageM (PreviousBirthInd Children Wed/*
*/ Religious Wage WageM  Hage Wage2 Hage2 WageM2 Children2), /*
*/ i(Cnum) t(tper) quadrat(24) 
