#!/usr/bin/env bash
#PBS -l nodes=1:ppn=20
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION,CANDOCK_top_percent
#PBS -d .

export module_to_run=link_fragments

for j in `cat $ROOT_DIR/all.lst`
do

    mkdir -p $j
    cd $j

    for i in `seq 1 5`
    do
        export CANDOCK_receptor=$ROOT_DIR/structures/$j/protein${i}.pdb
        export CANDOCK_centroid=$ROOT_DIR/structures/$j/protein${i}.cen

        export CANDOCK_prep=$ROOT_DIR/structures/$j/prepared_ligands.pdb
        export CANDOCK_seeds=$ROOT_DIR/structures/$j/seeds.txt
        export CANDOCK_seeds_pdb=$ROOT_DIR/structures/$j/seeds.pdb

        export CANDOCK_top_seeds_dir=$ROOT_DIR/seeds_database/$j/protein$i

        export CANDOCK_docked_dir=$CANDOCK_top_percent

        export CANDOCK_max_possible_conf=2000

        mkdir -p protein$i/$CANDOCK_docked_dir
        if [[ -e protein$i/$CANDOCK_docked_dir/lock ]]
        then
            continue
        fi

        touch protein$i/$CANDOCK_docked_dir/lock
        echo "$j $i $CANDOCK_top_percent"

        $MCANDOCK_LOCATION/link_fragments.sh > protein$i/$CANDOCK_docked_dir/output.log 2> protein$i/$CANDOCK_docked_dir/errors.log

        echo "DONE" >> protein$i/$CANDOCK_docked_dir/lock
    done

    cd ..
done

