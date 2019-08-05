#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION,CANDOCK_top_percent
#PBS -d .

export module_to_run=link_fragments

if [[ -z $ROOT_DIR || -z $MCANDOCK_LOCATION || -z $CANDOCK_top_percent ]]
then
    echo "You must define \$ROOT_DIR, \$MCANDOCK_LOCATION, and \$CANDOCK_top_percent"
    echo "Be sure to *export* these variables!"
    exit
fi

for j in `cat $ROOT_DIR/all.lst`
do

    protein_name=${j}

    export CANDOCK_verbose=1
    export CANDOCK_benchmark=1
	export CANDOCK_iterative=1
	export CANDOCK_max_iter=10

    export CANDOCK_receptor=$ROOT_DIR/structures/$j/${protein_name}.pdb

    if [[ -s $ROOT_DIR/structures/$j/${protein_name}_fixed.pdb ]]
    then
        export CANDOCK_receptor=$ROOT_DIR/structures/$j/${protein_name}_fixed.pdb
    fi
 
    export CANDOCK_centroid=$ROOT_DIR/structures/$j/site.cen
    export CANDOCK_prep=$ROOT_DIR/structures/$j/prepared_ligands.pdb
    export CANDOCK_seeds=$ROOT_DIR/structures/$j/seeds.txt
    export CANDOCK_seeds_pdb=$ROOT_DIR/structures/$j/seeds.pdb
    export CANDOCK_top_seeds_dir=$ROOT_DIR/seeds_database/$protein_name
    export CANDOCK_docked_dir=$CANDOCK_top_percent
	export CANDOCK_gaff_heme=$ROOT_DIR/ic6.dat

    if [[ -d $protein_name/$CANDOCK_docked_dir ]]
    then
        continue
    fi

    mkdir -p $protein_name/$CANDOCK_docked_dir
    echo "$protein_name/$CANDOCK_docked_dir"

    $MCANDOCK_LOCATION/link_fragments.sh > /tmp/${PBS_JOBID}_output.log 2> /tmp/${PBS_JOBID}_errors.log
    mv /tmp/${PBS_JOBID}_output.log $protein_name/$CANDOCK_docked_dir/output.log
    mv /tmp/${PBS_JOBID}_errors.log $protein_name/$CANDOCK_docked_dir/errors.log
done

