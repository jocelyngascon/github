/* The dataSciencePilot action set consists of actions that implement a policy-based,
configurable, and scalable approach to automating data science worflows.
This CAS action set can be used to automate and end-to-ed workflow or to automate steps
in the workflow suh as data preparation, feature preprocessingn feature engineering, feature 
selection, and hyperparameter tuning */

/* Connect to CAS and our CASLIBs */
cas; 
caslib _all_ assign;

/* Create reference to hmeq table */
data casuser.hmeq; 
	set public.hmeq;
run; 

/* Define Policies */
%let exPo = {cardinality = {lowMediumCutoff = 40}}; /* Exploration Policy */
%let scPo = {missingPercentThreshold=35}; /* Screen Policy */
%let trPo = {entropy = True, iqv = True,  kurtosis = True, Outlier = True}; /* Transformation Policy */
%let sePo = {topk=10}; /* Selection Policy */

/*Map Variables*/
%let tar = "BAD";
%let tbl = "hmeq";

/* Build and import models using dsAutoMl Action */
proc cas;
	loadactionset "dataSciencePilot";
	dataSciencePilot.dsAutoMl
		/	table 					= &tbl
			target 					= &tar
			kfolds 					= 5
			explorationPolicy		= &exPo
			screenPolicy  			= &scPo
            transformationPolicy   	= &trPo
			selectionPolicy 		= &sePo
			modelTypes				= {"DECISIONTREE", "GRADBOOST"}
			objective				= "ASE" 
			transformationOut     	= {name = "TRANSFORMATION_OUT_ML", replace = True}
            featureOut             	= {name = "FEATURE_OUT_ML", replace = True}
			pipelineOut           	= {name = "PIPELINE_OUT_ML", replace = True}
			saveState              	= {modelNamePrefix = "ASTORE_OUT_ML", replace = True, topK=1}
		; 
	run;
quit;

/* Using our model on new data */
proc astore;
	score data=casuser.hmeq copyvar=BAD out=casuser.hmeq_Feat1 rstore=CASUSER.ASTORE_OUT_ML_FM_;
	score data=casuser.hmeq_Feat1 copyvar=BAD out=casuser.hmeq_NEW_SCORED1 rstore=CASUSER.ASTORE_OUT_ML_GRADBOOST_1;
run;

/* Register models */

%mm_get_project_id(projectNm=%str(HMEQ_Pipeline), projectLoc=%str(DMRepository), 
	idvar=myProjID);
%mm_import_astore_model(locationID=%str(&myprojID), 
	modelname=%str(SAS_DS_Feats), modeldesc=%str(), 
	rstore=CASUSER.ASTORE_OUT_ML_FM_);

%mm_get_project_id(projectNm=%str(HMEQ_Pipeline), projectLoc=%str(DMRepository), 
	idvar=myProjID);
%mm_import_astore_model(locationID=%str(&myprojID), 
	modelname=%str(SAS_DS_GradBoost), modeldesc=%str(), 
	scoredata=CASUSER.HMEQ_NEW_SCORED1, nBins=20 , cutStep=20 , maxIters=50 , 
	target=BAD , event=1, targetLevel=binary, eventProbVar=P_BAD1, 
	nonEventProbVar=P_BAD0, nonEvent=0, samplePct=30, sampleSeed=1234, 
	rstore=CASUSER.ASTORE_OUT_ML_GRADBOOST_1);
