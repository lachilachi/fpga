#!bin/bash

# Configuration
user=hwlabX
psw="pwd"
path_to_local_bitfile=./graphic_output_synth/graphic_output_synth/graphic_output_synth.bit

# Copy the bitfile to the remote location
sshpass -p $psw scp ./graphic_output_synth/graphic_output_synth/graphic_output_synth.bit $user@stu-workstation8:/user/Labs_user/$user

# Run the script on the remote workstation

	
if [ -z $1 ]
then
    sshpass -p $psw ssh $user@stu-workstation8 'bash -s' < load_bitfile.sh
elif [ $1 = "reset" ]
then
    sshpass -p $psw ssh $user@stu-workstation8 'bash -s' < load_bitfile.sh reset
fi



# Alternatively login to the workstation
#sshpass -p $psw ssh $user@stu-workstation8

# Webcam Link http://ida-raspi-webcam/?action=stream


