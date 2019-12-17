#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -l naccesspolicy=singleuser
#PBS -v ROOT_DIR,MCANDOCK_LOCATION
#PBS -d .

if [[ -z $ROOT_DIR || -z $MCANDOCK_LOCATION ]]
then
    echo "You must define \$ROOT_DIR and \$MCANDOCK_LOCATION."
    echo "Be sure to *export* these variables!"
    exit
fi

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

module load gcc/5.2.0

for m in `cat $ROOT_DIR/all.lst`
do
    file_name=scores.vina

    for i in "${top_percent[@]}"; do

        if [[ -e ${m}/$i/$file_name ]]
        then
            continue
        fi 

        if [[ ! -d ${m}/$i ]]
        then
            echo "$m $i was not run!"
            continue
        fi

        if [[ ! -s ${m}/$i/LIGAND.pdb ]]
        then
            echo "$m $i does not exist!"
            continue
        fi

        if [[ ! -s ${m}/$i/score.lst ]]
        then
            touch $m/$i/$file_name
            continue
        fi

        echo "$m $i"
            /scratch/brown/finej/candock/build/src/cd_calc_posexscore \
            --receptor ${m}/$i/LIGAND.pdb --ncpu 1 \
            > ${m}/$i/$file_name 2> /dev/null
    
    done
done
