/*
	DMAS Timed Assessment 29th April 2021 - Evening Session
	Pediaditis Georgios
*/

libname Pow "/folders/myfolders/FinalData";

*	Question 1;
proc glm data=pow.power;
	class winner equipment sex;
	model Wilks=winner equipment sex averagetime age liquidconsumed bodyweightkg bestsquatkg bestbenchkg bestdeadliftkg gymcost displacement;
run;


*	Question 2;
proc glmselect data=pow.power;
	class winner equipment sex;
	model Wilks=winner equipment sex averagetime age liquidconsumed 
				bodyweightkg bestsquatkg bestbenchkg bestdeadliftkg 
				gymcost displacement/selection=backward select=SBC showpvalues;
run;

/*
Our selected model contains the following explonatory variables
Sex BodyweightKg BestSquatKg BestBenchKg BestDeadliftKg

The lower SBC values are achived in the final model.
We can see that our model has a really god R(adj)-Sq 0.921
We can also see the overal significance of our model F 971.01 p-value <.0001
Since its less than 0.05 its statistical significant 
*/


*	Question 3;
proc ttest data=pow.power plots(shownull)=interval;
	class Winner;
	var bodyweightkg;
run;


*	Question 4;
/*
There is not enough evidence to reject that they are equal regardless of variance
since p-value ~ 0.46 for both methods (Pooled and Satterthwaite)

Our assumptions are:
1.observations independent
	we assume from the study that its true
2.population has normal distribution
	from the qqplots we can see that its a valid hypothesis 
3.groups have equal variance
	Since Equality of Variances has a p-value <0.0001 we reject the null hypothesis
	about equality and we assume that they are not equal

*/


*	Question 5;

proc sql;
	select count(*) into:nmales
	from pow.power
	where sex eq 'M';
quit;

data power2;
	set pow.power;
	where Sex eq 'M';
run;

proc sgplot data=power2;
	vbox GymCOST/category=equipment;
	format GymCost dollar.;
	title "&nmales males";
	yaxis label="Gym Cost($)";
	xaxis label="Equipment type";
run;


*	Question 6;
proc sql; 
	create table summed as
	select equipment,bestsquatkg, bestbenchkg, bestdeadliftkg,
	(bestsquatkg+ bestbenchkg+ bestdeadliftkg) as sum
	from pow.power;
	
	
	select equipment,avg(sum) as average
	from summed
	group by equipment;
quit;

*	Question 7;

proc contents data=pow.power ;
	
run;

proc sql;
	create table maximum as
	select max(age) as max_age
	from pow.power;
quit;

/*
Maximum age is 84.5
*/


*	Question 8;
proc format; 
	value agef 	low-<30="A"
				30-<50="B"
				50-high="C";
run;

data pow.power;
	set pow.power;
	format age agef.;
run;
	
	
*	Question 9;
%let varNames= Averagetime age liquidconsumed bodyweightkg bestsquatkg bestBenchkg bestdeadliftkg gymcost displacement;

ods output spearmancorr=work.spearman hoeffdingcorr=work.hoeffding;
proc corr data=pow.power spearman hoeffding;
	var wilks;
	with &varNames;
run;

proc sort data=work.spearman;
	by variable;
run;

proc sort data=work.hoeffding;
	by variable;
run;

data work.coefficients;
	merge work.spearman(rename=(wilks=scoef pwilks=spvalue))
	work.hoeffding(rename=(wilks=hcoef pwilks=hpvalue));
	by variable;
	scoef_abs=abs(scoef);
	hcoef_abs=abs(hcoef);
run;

proc rank data=work.coefficients out=coefficients_rank;
	var scoef_abs hcoef_abs;
	ranks ranksp rankho;
run;

proc print data=work.coefficients_rank;
	var variable ranksp rankho scoef spvalue hcoef hpvalue;
run;


proc sgplot data=work.coefficients_rank;
	scatter y=ranksp x=rankho/datalabel=variable;
run;


*	Question 10;

/*
Since coefficients are ranked and plotted Spearman on y-axis and hoeffding 
in x axis the variables with potential non-linear relationship would be on the
bottom right corner since we want the  spearman rank low and hoeffding high for 
an indication of non-linear relationship. We should examine Displacement since
it has a low spearman and high hoeffding.
*/


