#!/bin/bash 
#Batch processes multiple recon-all jobs, takes user input about where to start the pipeline
#Note: Local custom settings:
#	- Uses an xopts.txt file created in SUBJECTS_DIR
#	- Uses a 2011 brain atlas that is not the default in FreeSurfer 5.0.
#	- Disables labeling of white matter segmentation abnormalities
#Author: Warren Winter
#Date: 02/25/2013


##########

function reconall_position_select() {
	echo '
	Choose one of the following options:
	
	(1) recon-all from raw image data using just one T1 acquisition,
	(2) recon-all after adding control points,
	(3) recon-all after editing brainmask.mgz because of a bad skull strip,
	(4) recon-all after editing wm.mgz, or
	(5) recon-all after editing brainmask.mgz because of a bad skull strip and wm.mgz as well.
	
	This prompt will repeat after each subject is entered.  To close out of the prompt loop, hit Control+C.
	
	'
	read choice

	if [ $choice -eq 1 ]; then 
		echo "Enter subject ID.  " ; read subjid ; echo "Enter path to the subject's first .dcm or .nii file for his/her T1 MPRAGE RMS scan" ; read dcmpath ; echo "Starting a full recon-all for subject number $subjid" ; gnome-terminal --tab --title="recon-all; subjid: $subjid" -e "/bin/bash -c 'chb-fsstable ; mosbatch recon-all -i $dcmpath -subjid $subjid ; cp xopts.txt ${subjid}/scripts/expert.opts ; mosbatch recon-all -expert ${subjid}/scripts/expert.opts -xopts-overwrite -s $subjid -mprage -all -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
	elif [ $choice -eq 2 ]; then
		echo "Enter subject ID.  " ; read subjid ; echo "Starting recon-all from -autorecon2-cp to the end for subject number $subjid" ; gnome-terminal --tab --title="-autorecon2-cp -autorecon3; subjid: $subjid" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjid}/scripts/expert.opts ; mosbatch recon-all -expert ${subjid}/scripts/expert.opts -xopts-overwrite -s $subjid -autorecon2-cp -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
	elif [ $choice -eq 3 ]; then 
		echo "Enter subject ID.  " ; read subjid ; echo "Starting recon-all from -autorecon2 to the end for subject number $subjid" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjid" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjid}/scripts/expert.opts ; mosbatch recon-all -expert ${subjid}/scripts/expert.opts -xopts-overwrite -s $subjid -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
	elif [ $choice -eq 4 ]; then 
		echo "Enter subject ID.  " ; read subjid ; echo "Starting recon-all from -autorecon2-wm to the end for subject number $subjid" ; gnome-terminal --tab --title="-autorecon2-wm -autorecon3; subjid: $subjid" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjid}/scripts/expert.opts ; mosbatch recon-all -expert ${subjid}/scripts/expert.opts -xopts-overwrite -s $subjid -autorecon2-wm -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
	elif [ $choice -eq 5 ]; then 
		echo "Enter subject ID.  " ; read subjid ; echo "Starting recon-all from -autorecon2 to the end for subject number $subjid" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjid" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjid}/scripts/expert.opts ; mosbatch recon-all -expert ${subjid}/scripts/expert.opts -xopts-overwrite -s $subjid -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
	fi
}

echo "Reprocess multiple subjects from the same point in the recon-all stream? (yes/no)"
read multisubjs
if [ $multisubjs == "yes" ] || [ $multisubjs == "Yes" ] || [ $multisubjs == "y" ] || [ $multisubjs == "Y" ]; then
	echo '
	Choose one of the following options:
	
	(1) recon-all after adding control points,
	(2) recon-all after editing brainmask.mgz because of a bad skull strip,
	(3) recon-all after editing wm.mgz, or
	(4) recon-all after editing brainmask.mgz because of a bad skull strip and wm.mgz as well.
	
	This prompt will repeat after each subject is entered.  To close out of the prompt loop, hit Control+C.
	
	'
	read choice

	if ! [[ $choice =~ ^[1-4]+$ ]]; then
		echo "Not a valid option.  Enter either 1, 2, 3, or 4"
		read choice
	fi

	echo "List the subjects' subject IDs, separated by spaces:"
	read subjsinput
	
	echo $subjsinput | tr ' ' '\n' > subjsinput_ra.txt
	cat subjsinput_ra.txt | while read subjinput
	do
		if [ $choice -eq 1 ]; then 
			echo "Starting recon-all from -autorecon2-cp to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-cp -autorecon3; subjinput: $subjinput" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjinput}/scripts/expert.opts ; mosbatch recon-all -expert ${subjinput}/scripts/expert.opts -xopts-overwrite -s $subjinput -autorecon2-cp -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
		elif [ $choice -eq 2 ]; then 
			echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjinput: $subjinput" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjinput}/scripts/expert.opts ; mosbatch recon-all -expert ${subjinput}/scripts/expert.opts -xopts-overwrite -s $subjinput -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
		elif [ $choice -eq 3 ]; then 
			echo "Starting recon-all from -autorecon2-wm to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-wm -autorecon3; subjinput: $subjinput" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjinput}/scripts/expert.opts ; mosbatch recon-all -expert ${subjinput}/scripts/expert.opts -xopts-overwrite -s $subjinput -autorecon2-wm -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
		elif [ $choice -eq 4 ]; then 
			echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjinput: $subjinput" -e "/bin/bash -c 'chb-fsstable ; cp xopts.txt ${subjinput}/scripts/expert.opts ; mosbatch recon-all -expert ${subjinput}/scripts/expert.opts -xopts-overwrite -s $subjinput -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /chb/sheridanlab/software/etc -nowmsa'"
		fi
	done
	rm subjsinput_ra.txt
else
	a=1
	while [ $a -gt 0 ]
	do
		subjid=
		choice=
		dcmpath=
		reconall_position_select
	done
fi
