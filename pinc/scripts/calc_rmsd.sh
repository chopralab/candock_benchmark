#!/usr/bin/env bash
#PBS -l nodes=1:ppn=20
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION
#PBS -d .

export module_to_run=cacrystal_rmsd

if [[ ! -z $PBS_ENVIRONMENT ]]
then
    ncpu=${PBS_NUM_PPN}
fi

for j in `cat $ROOT_DIR/all.lst`
do

    mkdir -p $j
    cd $j

    for compound in `cat $ROOT_DIR/structures/$j/compounds.lst`
    do
        prep=$ROOT_DIR/structures/$j/prepared_ligands.pdb
        unique=`uuidgen`

        perl $ROOT_DIR/scripts/extract_to_pdb.pl $compound $prep > /tmp/${unique}.pdb
        echo $unique

        for i in `seq 1 5`
        do
            for top_percent in 0.005 0.01 0.02 0.05 0.10 0.20
            do
                if [[ -e protein$i/$top_percent/${compound}.rmsds ]]
                then
                    continue
                fi

                if [[ ! -s protein$i/$top_percent/${compound}.pdb ]]
                then
                    echo "protein$i/$top_percent/${compound}.pdb does not exist!"
                    continue
                fi

                echo "$j $i $top_percent $compound"

                $MCANDOCK_LOCATION/cacrystal_rmsd.sh /tmp/${unique}.pdb protein$i/$top_percent/${compound}.pdb > protein$i/$top_percent/${compound}.rmsds
                sed -i '1d;$d' protein$i/$top_percent/${compound}.rmsds
            done
        done

        rm /tmp/${unique}.pdb

    done

    cd ..
done

