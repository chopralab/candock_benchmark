#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION
#PBS -d .

export module_to_run=dock_fragments

for j in `cat $ROOT_DIR/all.lst`
do

    for i in `seq 1 5`
    do
        export CANDOCK_verbose=1
        export CANDOCK_benchmark=1

        export CANDOCK_receptor=$ROOT_DIR/structures/$j/protein${i}.pdb
        export CANDOCK_centroid=$ROOT_DIR/structures/$j/protein${i}.cen

        export CANDOCK_prep=$ROOT_DIR/structures/$j/prepared_ligands.pdb
        export CANDOCK_seeds=$ROOT_DIR/structures/$j/seeds.txt
        export CANDOCK_seeds_pdb=$ROOT_DIR/structures/$j/seeds.pdb

        export CANDOCK_top_seeds_dir=$ROOT_DIR/seeds_database/$j/protein$i

        mkdir -p $CANDOCK_top_seeds_dir
        if [[ -e $CANDOCK_top_seeds_dir/lock ]]
        then
            continue
        fi

        touch $CANDOCK_top_seeds_dir/lock

        echo "$j $i"
        $MCANDOCK_LOCATION/dock_fragments.sh > $CANDOCK_top_seeds_dir/output_2.log 2> $CANDOCK_top_seeds_dir/errors_2.log

        echo "DONE" > $CANDOCK_top_seeds_dir/lock
    done
done
