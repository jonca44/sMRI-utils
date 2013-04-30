#!/bin/bash 
#Batch processes multiple recon-all jobs, takes user input about where to start the pipeline
#Note: Local custom settings:
#	- Uses 3T atlas for Talairach alignment, 3T-specific NU intensity correction parameters, and MPRAGE-specific intensity normalization parameters
#	- Allows use of T2-weighted images for refinement of pial surfaces
#	- Uses a GCA atlas (made in 2011) that is not default in FreeSurfer 5.2 (uses the 2008 version) but that is better for putamen segmentation
#	- Disables labeling of white matter segmentation abnormalities
#	- IMPORTANT: Change paths to the T1 and T2 DICOM files and to the GCA files
#Author: Warren Winter
#Date: 04/26/2013


##########

echo '
Choose one of the following options:

(1) recon-all from raw image data using just a T1,
(2) recon-all from raw image data using a T1 and a T2,
(3) recon-all after adding control points,
(4) recon-all after editing brainmask.mgz because of a bad skull strip,
(5) recon-all after editing wm.mgz, or
(6) recon-all after editing brainmask.mgz because of a bad skull strip and wm.mgz as well.
	
This prompt will repeat after each subject is entered. To close out of the prompt loop, hit Control+C.

'
read choice

if ! [[ $choice =~ ^[1-4]+$ ]]; then
	echo "Not a valid option. Enter either 1, 2, 3, or 4"
	read choice
fi

if [ $choice != 1 ] & [ $choice != 2 ] ; then
	echo 'Using T2 image to refine pial surfaces? yes/no'
	read T2pial
	
	if [ $T2pial != "yes" ] & [ $T2pial != "no" ]; then
		echo "Not a valid option. Type either yes or no"
		read T2pial
	fi
	
	if [ $T2pial = "yes" ]; then
		T2 = "-T2pial"
	else
		T2 = ""
	fi
fi

echo "List the subjects' subject IDs, separated by spaces:"
read subjsinput
	
echo $subjsinput | tr ' ' '\n' > subjsinput_ra.txt
cat subjsinput_ra.txt | while read subjinput
do
	if [ $choice -eq 1 ]; then
		echo "Starting a full recon-all for subject number $subjinput" ; gnome-terminal --tab --title="recon-all; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -i /XXX/XXXXXX/XXXXXX/${subjinput}/*T1_MPRAGE_RMS/*-1.dcm -subjid $subjinput ; mosbatch recon-all -s $subjinput -3T -mprage -all -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
	elif [ $choice -eq 2 ]; then 
		echo "Starting a full recon-all for subject number $subjinput" ; gnome-terminal --tab --title="recon-all; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -i /XXX/XXXXXX/XXXXXX/${subjinput}/*T1_MPRAGE_RMS/*-1.dcm -T2 /XXX/XXXXXX/XXXXXX/${subjinput}/*T2_SPACE/*-1.dcm -subjid $subjinput ; mosbatch recon-all -s $subjinput -3T -mprage -T2pial -all -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
	elif [ $choice -eq 3 ]; then 
		echo "Starting recon-all from -autorecon2-cp to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-cp -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2-cp -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
	elif [ $choice -eq 4 ]; then 
		echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
	elif [ $choice -eq 5 ]; then 
		echo "Starting recon-all from -autorecon2-wm to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-wm -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2-wm -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
	elif [ $choice -eq 6 ]; then 
		echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXXX/ -nowmsa'"
fi
done

rm subjsinput_ra.txt
