#!/bin/bash

#Reads DICOM files' metadata and sorts them into a directory structure reflecting their series descriptions and appends each file's series number to its name as a suffix.

#Author: Warren Winter

#Date: 07/12/2012

##############################################

function org_dicoms() {
		subj=$1

		cp -rf $subj ${subj}_organized
		subjorgd="${subj}_organized"

		find ./${subjorgd}/ -type f -name '*' -print0 | xargs -0 rename 's/$/.dcm/'
		find ./${subjorgd}/ -type f -name '*.dcm.dcm' -print0 | xargs -0 rename 's/.dcm.dcm/.dcm/'
		find ./${subjorgd}/ -type f -name 'DICOMDIR.dcm' -print0 | xargs -0 rename 's/.dcm//'
		find ./${subjorgd}/ -type f -name '*.dcm' -exec echo '{}' > ./${subjorgd}/dcmpaths_${subj}.txt \;

		while read line
		do
			if [ -s $line ]
			then
				seriesnumber=$(mri_probedicom --i $line --t 20 11)
				if echo "$seriesnumber" | grep -q "ERROR"
				then
					echo "$line is not actually a DICOM"
				else
					seriesdescription=$(mri_probedicom --i $line --t 8 103E)
					imagenumber=$(mri_probedicom --i $line --t 20 13)
					newdirectory=$(echo "${seriesnumber}_${seriesdescription}" | sed -e "s/ //g")
					dcmnumber=$(basename $line .dcm)
					newfile=$(echo "${dcmnumber}-${imagenumber}.dcm" | sed -e "s/ //g")
					if [ -d ./${subjorgd}/${newdirectory} ]
					then
						mv $line ./${subjorgd}/${newdirectory}/${newfile}
					else
						mkdir ./${subjorgd}/${newdirectory}
						mv $line ./${subjorgd}/${newdirectory}/${newfile}
					fi
				fi
			else
				echo "$line does not exist"
			fi
	
		done < ./${subjorgd}/dcmpaths_${subj}.txt

		rm ./${subjorgd}/dcmpaths_${subj}.txt
		mv $subjorgd ${subj}/${subjorgd}
		           }

export -f org_dicoms

##############################################

a=1
while [ $a -gt 0 ]
do
	echo "Enter subject ID (e.g., 1032).  Ctrl+C to break out of loop."
	
	read subjid

	echo "Organizing ${subjid}'s DICOMs into folders denoted by their scans of origin"

	gnome-terminal --tab --title="Organizing ${subjid}'s DICOMS" -e "/bin/bash -c 'org_dicoms $subjid'"
	
done
