# CANDOCK Benchmarking scripts for the PDBBind coreset

These scripts assume you have installed **CANDOCK** properly and have defined the variable *$MCANDOCK_LOCATION* to the location of the module path created by the installation.

First, you must *export* the location of **this** directory as the variable *ROOT_DIR*. It must be an absolute directory e.g:

```bash
export ROOT_DIR=/path/to/this/location/candock_benchmark/pdbbind_core
```

Then, untar the file structures.tgz

```bash
tar xf structures.tgz
```

This will create a directory called *structures* in the current directory.

## Create the seeds database

Now, run the script *make_seeds_database.sh* in the docking folder of the scripts directory. If you are running this command on a computing cluster, the script `submit_comp.sh` is provided for your convience. This can be done with the follow:

```bash
number_of_jobs_to_launch=20
bash scripts/submit_comp.sh docking/make_seeds_database.sh $number_of_jobs_to_launch -l nodes=1:ppn=4,walltime=10:00:00 -v ROOT_DIR=$ROOT_DIR,MCANDOCK_LOCATION=$MCANDOCK_LOCATION
```

## Link the seeds

Once all the jobs have finished and you have checked the output to see if any jobs have not completed successfully, you must run the following commands to complete the docking for a top percent of XXX. Note that we have run top percent values of 0.005, 0.01, 0.02, 0.05, 0.10, 0.20, 0.50, and 1.00. You must submit new jobs for all top percent values.

```bash
mkdir docking
cd docking
mkdir rigid
cd rigid
$ROOT_DIR/scripts/submit_comp.sh docking/dock_rigid.sh \
    $number_of_jobs_to_launch \
    -l nodes=1:ppn=4,walltime=10:00:00 \
    -v ROOT_DIR=$ROOT_DIR,MCANDOCK_LOCATION=$MCANDOCK_LOCATION,CANDOCK_top_percent=XXX
```

## Rescore the poses and get summary data

Once you have obtained docking results for all of the top percent values, you must run the three summary scripts located in the *$ROOT_DIR/scripts/summary_scripts* directory. These scripts must be run in the same directory as was used for the docking (e.g. `rigid`). In parallel, you must run the `submit_all_new_scores.sh` script to obtain scores for all 96 scoring functions mentioned in the paper. This script must be run in the same directory as before. Example commands are given below:

```bash
# we are in the 'rigid' directory as before
$ROOT_DIR/scripts/fixing/fix_fixed.sh # For MSE structures
$ROOT_DIR/scripts/rescoring/submit_all_new_scores.sh
$ROOT_DIR/scripts/summary_scripts/make_model_lst.sh
$ROOT_DIR/scripts/summary_scripts/make_score_lst.sh
$ROOT_DIR/scripts/submit_comp.sh summary_scripts/make_rmsds_lst.sh 20 -l nodes=1:ppn=4,walltime=10:00:00 -v ROOT_DIR=$ROOT_DIR,MCANDOCK_LOCATION=$MCANDOCK_LOCATION
```

Once all the jobs have completed, do the following:

```bash
$ROOT_DIR/scripts/rescoring/combine_scoring_csv.pl
$ROOT_DIR/scripts/rescoring/combine_scoring_csv_cumulative.pl
```

## Combine the summaries together

Now, you can run the `make_csv_scoring_combined.pl` script to generate the summary CSV.

```bash
$ROOT_DIR/scripts/make_csv_scoring_combined.pl > rigid.csv
```

The above (after the generation of the seeds database) must be performed for all types of docking (flexible, semi-rigid, *insert your own type here*).

