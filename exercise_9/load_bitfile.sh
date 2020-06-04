#!/bin/bash
pwd
ls
djtgcfg enum
djtgcfg init -d Nexys3

if [ -z $1 ]
then
    djtgcfg prog -d Nexys3 -i 0 -f graphic_output_synth.bit
elif [ $1 = "reset" ]
then
    djtgcfg erase -d Nexys3 --index 0
fi



