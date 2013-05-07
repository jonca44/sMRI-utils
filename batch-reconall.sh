#!/bin/bash 
#Batch processes multiple recon-all jobs, takes user input about where to start the pipeline
#Note: Local custom settings:
#	- Uses 3T-tailored talairach and intensity normalization tailored to MPRAGE scans
#	- Allows use of T2-weighted images for refinement of pial surfaces
#	- Uses a 2011 brain atlas that is not the default in FreeSurfer 5.2
#	- Disables labeling of white matter segmentation abnormalities
#	- IMPORTANT: Assumes a directory structure where /XXX/XXXXXX/XXXXX/<subjid>/<subjid>_organized/*EllisonRMS/ contains the T1 DICOMs, and where /XXX/XXXXXX/XXXXX/<subjid>/<subjid>_organized/*T2_SPACE/ contains the T2 DICOMs
#Author: Warren Winter
#Date: 05/07/2013


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

while ! [[ $choice =~ ^[1-6]+$ ]] || [[ $choice -gt 6 ]] || [[ $choice -lt 1 ]]; do
	read -p "Not a valid option.  Enter an integer from 1 to 6: " choice
done

if [[ $choice -gt 2 ]]; then
	read -p 'Using T2 image to refine pial surfaces? yes/no: ' T2pial
	while [[ $T2pial != "yes" ]] & [[ $T2pial != "no" ]]; do
		read -p "Not a valid option. Type either yes or no: " T2pial
	done
	if [[ $T2pial = "yes" ]]; then
		T2="-T2pial"
	else
		T2=""
	fi
fi

read -p "List the subjects' subject IDs, separated by spaces: " subjsinput
	
echo $subjsinput | tr ' ' '\n' > subjsinput_ra.txt
while read -u 3 subjinput; do
	if [[ $choice -eq 1 ]]; then
		numT1s=`ls /XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*EllisonRMS/*-1.dcm -1 | wc -l`
		if [[ $numT1s -gt 1 ]]; then
			read -p "More than one T1 acquisition series found.  Please enter series number of the acquisition you want to reconstruct (e.g., 15): " T1seriesnum
			T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T1seriesnum}_*EllisonRMS/*-1.dcm"
			while ! ls $T1series ; do
				read -p "Acquisition series not found.  Re-enter series number: " T1seriesnum
				T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T1seriesnum}_*EllisonRMS/*-1.dcm"
			done
		else
			T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*EllisonRMS/*-1.dcm"
		fi
		echo "Starting a full recon-all for subject number $subjinput" ; gnome-terminal --tab --title="recon-all; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -i $T1series -subjid $subjinput ; mosbatch recon-all -s $subjinput -3T -mprage -all -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	elif [[ $choice -eq 2 ]]; then 
		numT1s=`ls /XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*EllisonRMS/*-1.dcm -1 | wc -l`
		numT2s=`ls /XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*T2_SPACE/*-1.dcm -1 | wc -l`
		if [[ $numT1s -gt 1 ]]; then
			read -p "More than one T1 acquisition series found.  Please enter series number of the acquisition you want to reconstruct (e.g., 15): " T1seriesnum
			T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T1seriesnum}_*EllisonRMS/*-1.dcm"
			while ! ls $T1series ; do
				read -p "Acquisition series not found.  Re-enter series number: " T1seriesnum
				T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T1seriesnum}_*EllisonRMS/*-1.dcm"
			done
		else
			T1series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*EllisonRMS/*-1.dcm"
		fi
		if [[ $numT2s -gt 1 ]] ; then
			read -p "More than one T2 acquisition series found.  Please enter series number of the acquisition you want to reconstruct (e.g., 11): " T2seriesnum
			T2series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T2seriesnum}_*T2_SPACE/*-1.dcm"
			while ! ls $T2series ; do
				read -p "Acquisition series not found.  Re-enter series number: " T2seriesnum
				T2series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/${T2seriesnum}_*T2_SPACE/*-1.dcm"
			done
		else
			T2series="/XXX/XXXXXX/XXXXX/${subjinput}/${subjinput}_organized/*T2_SPACE/*-1.dcm"
		fi
		echo "Starting a full recon-all for subject number $subjinput" ; gnome-terminal --tab --title="recon-all; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -i $T1series -T2 $T2series -subjid $subjinput ; mosbatch recon-all -s $subjinput -3T -mprage -T2pial -all -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	elif [[ $choice -eq 3 ]]; then 
		echo "Starting recon-all from -autorecon2-cp to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-cp -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2-cp -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	elif [[ $choice -eq 4 ]]; then 
		echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	elif [[ $choice -eq 5 ]]; then 
		echo "Starting recon-all from -autorecon2-wm to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2-wm -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2-wm -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	elif [[ $choice -eq 6 ]]; then 
		echo "Starting recon-all from -autorecon2 to the end for subject number $subjinput" ; gnome-terminal --tab --title="-autorecon2 -autorecon3; subjid: $subjinput" -e "/bin/bash -c '. chb-fs stable ; mosbatch recon-all -s $subjinput -3T -mprage $T2 -autorecon2 -autorecon3 -gca RB_all_2011-10-25.gca -gca-skull RB_all_withskull_2011-10-25.gca -gca-dir /XXX/XXXXXX/XXXXX -nowmsa'"
	fi
done 3< subjsinput_ra.txt

rm subjsinput_ra.txt
