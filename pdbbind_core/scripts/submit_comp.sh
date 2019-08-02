#!/usr/bin/env bash

program=$1
shift

number=$1
shift

echo qsub -d . $ROOT_DIR/scripts/$program $@
my_depend=`qsub -d . $ROOT_DIR/scripts/$program $@`

for i in `seq 1 $number`
do
    my_depend=`qsub -d . $ROOT_DIR/scripts/$program -W depend=after:$my_depend $@`
done

