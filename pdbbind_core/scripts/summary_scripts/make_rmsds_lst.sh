#!/usr/bin/env bash

if [[ -z $ROOT_DIR || -z $MCANDOCK_LOCATION ]]
then
    echo "You must define \$ROOT_DIR and \$MCANDOCK_LOCATION."
    echo "Be sure to *export* these variables!"
    exit
fi

top_percent=(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00)

if [[ ! -z $PBS_ENVIRONMENT ]]
then
    ncpu=${PBS_NUM_PPN}
fi

for m in `cat $ROOT_DIR/core.lst`
do

   for i in "${top_percent[@]}"; do

       if [[ -e ${m}_pocket/$i/rmsds.lst ]]
       then
           continue
       fi 

       if [[ ! -d ${m}_pocket/$i/ ]]
       then
           echo "$m $i was not run!"
           continue
       fi

       if [[ ! -s ${m}_pocket/$i/${m}_ligand.pdb ]]
       then
           echo "$m $i does not exist!"
           continue
       fi

       original_file=$ROOT_DIR/structures/$m/prepared_ligands.pdb

       if [[ -s $ROOT_DIR/structures/$m/prepared_ligands_fixed.pdb ]]
       then
           original_file=$ROOT_DIR/structures/$m/prepared_ligands_fixed.pdb
       fi

       echo "$m $i"
       $MCANDOCK_LOCATION/cacrystal_rmsd.sh $original_file ${m}_pocket/$i/${m}_ligand.pdb $ncpu > ${m}_pocket/$i/rmsds.lst
       sed -i '1d;$d' ${m}_pocket/$i/rmsds.lst
   done;
done

