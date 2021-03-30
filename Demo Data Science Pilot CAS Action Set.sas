/*****************************************************************************/
/*  Create a default CAS session and create SAS librefs for existing caslibs */
/*  so that they are visible in the SAS Studio Libraries tree.               */
/*****************************************************************************/

cas; 
caslib _all_ assign;

/* Generate  DATA step creates the reference data table mycas.dmagecr */
/* in your CAS session, keeping only the age, amount, coapp, duration, */
/* foreign, job, and good_bad variables */

data casuser.dmagecr;
   set sampsio.dmagecr;
   keep age amount coapp duration foreign job good_bad;
   call streaminit(12345);
   r = rand("Uniform");
   if r < 0.1 then
      do;
         age = .;
         amount = .;
      end;
   else if r < 0.2 then
      do;
         duration = .;
      end;
run;

/* The following statements run the analyzeMissingPatterns action to analyze */
/* the missing patterns in the input variables. The action outputs a data    */
/* table that contains the mutual information of the variables among         */
/* themselves and versus the target variable. It outputs the results of the  */
/* analysis in an output data table named miss_pattern_out.                  */
proc cas;
   loadactionset "dataSciencePilot";
   dataSciencePilot.analyzeMissingPatterns
                            / table     = "DMAGECR"
                              casOut    = {name    = "MISS_PATTERN_OUT",
                                           replace = True}
                              inputs    = {{name   = "age"},
                                           {name   = "amount"},
                                           {name   = "coapp"},
                                           {name   = "duration"},
                                           {name   = "foreign"},
                                           {name   = "job"}}
                              nominals  = {"coapp",  "foreign", "job"}
                              ;
   run;
   fetch / table = "MISS_PATTERN_OUT";
   run;
quit;

/* reload the complete dmagecr dataset */
data casuser.dmagecr;
   set sampsio.dmagecr;
run;

/* The following statements run the dsAutoMl action to automatically explore effective machine learning pipelines */
/* The sampleSize parameter controls the total number of machine learning pipelines to construct, execute, and    */
/* rank. The default policy settings are used for the explorationPolicy, screenPolicy, and selectionPolicy        */
/* parameters. In contrast, the transformationPolicy parameter activates only the missing, cardinality, and       */
/* skewness data-quality issues by default. This means that feature transformation and generation pipelines that  */
/* are expected to alleviate these data-quality issues are executed by default. The transformationPolicy parameter*/
/* in this example activates all data-quality issues except interaction (polynomial). The action produces four    */
/* CAS output tables. The transformation_out table contains metadata about the feature transformation and         */
/* generation pipelines. The feature_out table contains metadata about the generated features. The pipeline_out   */
/* table contains metadata about the best-performing pipelines out of all the explored and executed pipelines.    */
/* You can control the number of best-performing pipelines by using the topKPipelines parameter. The saveState    */
/* controls the types and number of analytic store scoring objects that are generated for the best-performing     */
/* pipelines. */
proc cas;
   loadactionset "dataSciencePilot";
   dataSciencePilot.dsAutoMl
                            / table                  = "DMAGECR"
                              target                 = "good_bad"
                              event                  = "good"
                              explorationPolicy      = {}
                              screenPolicy           = {}
                              selectionPolicy        = {}
                              transformationPolicy   = {missing = True,
                                                        cardinality = True,
                                                        entropy = True,
                                                        iqv = True,
                                                        skewness = True,
                                                        kurtosis = True,
                                                        Outlier = True
                                                       }
                              modelTypes             = {"decisionTree"}
                              objective              = "AUC"
                              sampleSize             = 20
                              topKPipelines          = 20
                              kFolds                 = 5
                              transformationOut      = {name    = "TRANSFORMATION_OUT",
                                                        replace = True}
                              featureOut             = {name    = "FEATURE_OUT",
                                                        replace = True}
                              pipelineOut            = {name    = "PIPELINE_OUT",
                                                        replace = True}
                              saveState              = {modelNamePrefix = "DSAUTOML",
                                                        topk            = 2,
                                                        replace         = True}
                              ;
   run;
quit;
proc cas;
   fetch / table = "PIPELINE_OUT";
   run;
quit;
proc cas;
   fetch / table = "FEATURE_OUT";
   run;
quit;
proc cas;
   fetch / table = "TRANSFORMATION_OUT";
   run;
quit;