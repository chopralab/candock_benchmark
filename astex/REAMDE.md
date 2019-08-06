# CANDOCK Benchmarking scripts for the Astex coreset

## Getting started

These scripts assume you have installed **CANDOCK** properly and have defined the variable *$MCANDOCK_LOCATION* to the location of the module path created by the installation.

First, you must *export* the location of **this** directory as the variable *ROOT_DIR*. It must be an absolute directory e.g:

```bash
export ROOT_DIR=/path/to/this/location/candock_benchmark/pdbbind_core
```

Then, untar the file `structures.tgz`

```bash
cd $ROOT_DIR
tar xf structures.tgz
```

This will create a directory called *structures* in the current directory.

## Create the seeds database

Now, run the script *make_seeds_database.sh* in the docking folder of the scripts directory. If you are running this command on a computing cluster, the script `submit_comp.sh` is provided for your convenience. This can be done with the following commands.

```bash
number_of_jobs_to_launch=20
bash $ROOT_DIR/scripts/submit_comp.sh docking/make_seeds_database.sh $number_of_jobs_to_launch -l nodes=1:ppn=4,walltime=1:00:00
```

 Note that the syntax for `submit_comp.sh` is
 
 **submit_comp.sh** *command_in_scripts_directory* *number_of_jobs_to_submit* *additional_qsub_arguments*. 

The *additional_qsub_arguments* is optional and should be customized for your unique computing environment.

## Link the seeds

Once all the jobs have finished and you have checked the output to see if any jobs have not completed successfully, you must run the following commands to complete the docking for a top percent of XXX. Note that we have run top percent values of 0.005, 0.01, 0.02, 0.05, 0.10, 0.20, 0.50, and 1.00, therefore summary and other scripts assume you have run these values and you must edit these files if this is not the case. You must submit new jobs for all top percent values.

```bash
mkdir -p docking/rigid
cd docking/rigid
number_of_jobs_to_launch=20
bash $ROOT_DIR/scripts/submit_docking.sh docking/dock_rigid.sh XXX $number_of_jobs_to_launch -l nodes=1:ppn=1,walltime=1:00:00
```

Note that the syntax for `submit_docking.sh` is
 
**submit_docking.sh** *command_in_scripts_directory* *number_of_jobs_to_submit* *top percent value to run* *additional_qsub_arguments*. 

## Rescore the poses and get summary data

Once you have obtained docking results for all of the top percent values, you must run the three summary scripts located in the *$ROOT_DIR/scripts/summary_scripts* directory. These scripts must be run in the same directory as was used for the docking (e.g. `rigid`). In parallel, you must run the `submit_all_new_scores.sh` script to obtain scores for all 96 scoring functions mentioned in the paper. This script must be run in the same directory as before. Example commands are given below:

```bash
# we are in the 'rigid' directory as before
$ROOT_DIR/scripts/summary_scripts/make_model_lst.sh
$ROOT_DIR/scripts/summary_scripts/make_score_lst.sh
$ROOT_DIR/scripts/submit_comp.sh summary_scripts/make_rmsds_lst.sh 20 -l nodes=1:ppn=4,walltime=1:00:00
$ROOT_DIR/scripts/rescoring/submit_all_new_scores.sh
```

Once all the jobs have completed, do the following:

```bash
$ROOT_DIR/scripts/rescoring/combine_scoring_csv.pl
```

## Combine the summaries together

Now, you can run the `make_csv_scoring_combined.pl` script to generate the summary CSV.

```bash
$ROOT_DIR/scripts/make_csv_scoring_combined.pl > rigid.csv
```

The above (after the generation of the seeds database) must be performed for all types of docking (flexible, semi-rigid, *insert your own type here*).
