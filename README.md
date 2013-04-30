sMRI-utils
==========

These are some scripts that have come in handy for structural MRI data processing with FreeSurfer.  They have made my work easier and I hope you'll benefit from them, too.


- organizedcm.sh -- uses FreeSurfer's mri_probedicom tool to parse DICOM headers and sort files into a directory structure that reflects their metadata.

- probeintensity.sh -- an exploratory tool for looking at within-dataset statistics for different brain tissue types' intensity values and the decisions FreeSurfer has made to set boundaries between tissue classes.

- batch-reconall.sh -- launch several distributed (via MOSIX) FreeSurfer recon-all jobs, and navigate a foolproof menu of options.

