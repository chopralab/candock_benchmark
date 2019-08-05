#!/usr/bin/env bash

command_name=$1
shift

top_p=$1
shift

number=$1
shift

export CANDOCK_top_percent=$top_p

my_depend=`qsub $command_name $@`

for i in `seq 2 $number`
do
    my_depend=`qsub $command_name -W depend=after:$my_depend $@`
done
