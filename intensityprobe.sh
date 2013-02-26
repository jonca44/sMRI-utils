#!/bin/bash

#Surveys a dataset's max, min, mean, and quartile-divided intensity values for gray matter and CSF (native) and the thresholds values FreeSurfer set for these to determine WM and GM surfaces.  Intended for use in adjusting parameters for mris_make_surfaces to optimize coverage of GM and WM.

#Author: Warren Winter

#Date: 08/02/2012

##############################################

echo "List the subjects' subject IDs, separated by spaces:"
read subjsinput
echo $subjsinput | tr ' ' '\n' > subjsinput_ip.txt

echo "How do you want to identify the output file?  (provide, e.g., the name of the dataset)" ; read dataset
mkdir ${dataset}_intensity_distribution ; mkdir ${dataset}_intensity_distribution/surface_parameters

##############################################

#identify data of interest
while read line
do
#identify the parameters FreeSurfer set for delineating WM and GM surfaces
echo "${line}:" >> ./${dataset}_intensity_distribution/${dataset}_allsurfaceparameters.txt
echo " " >> ./${dataset}_intensity_distribution/${dataset}_allsurfaceparameters.txt
awk '/MIN_GRAY_AT_WHITE_BORDER/,/MIN_GRAY_AT_CSF_BORDER/' ${line}/scripts/recon-all.log >> ./${dataset}_intensity_distribution/${dataset}_allsurfaceparameters.txt
awk '/MIN_GRAY_AT_WHITE_BORDER/,/MIN_GRAY_AT_CSF_BORDER/' ${line}/scripts/recon-all.log >> ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_allsurfaceparameters.txt

#identify the peak and valley native intensities for CSF and GM that FreeSurfer found at the end of Normalization2 (autorecon2)
awk '/Normalization2/,/BFS/' ${line}/scripts/recon-all.log > ./${dataset}_intensity_distribution/tempfornativegmcsf.txt
sed '/^$/d' ./${dataset}_intensity_distribution/tempfornativegmcsf.txt > ./${dataset}_intensity_distribution/y.txt
mv ./${dataset}_intensity_distribution/y.txt ./${dataset}_intensity_distribution/tempfornativegmcsf.txt

cat ./${dataset}_intensity_distribution/tempfornativegmcsf.txt | awk -F"gm peak at" '{print $2}' | awk -F"(" '{print $1}' | tr -d ' (_' > ./${dataset}_intensity_distribution/individualGMvalues.txt
sed '/^$/d' ./${dataset}_intensity_distribution/individualGMvalues.txt > ./${dataset}_intensity_distribution/y.txt
head -n 1 ./${dataset}_intensity_distribution/y.txt > ./${dataset}_intensity_distribution/z.txt
rm ./${dataset}_intensity_distribution/y.txt ; mv ./${dataset}_intensity_distribution/z.txt ./${dataset}_intensity_distribution/individualGMvalues.txt
echo "$line	GMpeaks	`cat ./${dataset}_intensity_distribution/individualGMvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_GMpeaks.txt
echo "`cat ./${dataset}_intensity_distribution/individualGMvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_GMpeaks_unidentified.txt

cat ./${dataset}_intensity_distribution/tempfornativegmcsf.txt | awk -F"valley at" '{print $2}' | awk -F"(" '{print $1}' | tr -d ' (_' > ./${dataset}_intensity_distribution/individualGMvalues.txt
sed '/^$/d' ./${dataset}_intensity_distribution/individualGMvalues.txt > ./${dataset}_intensity_distribution/y.txt
head -n 1 ./${dataset}_intensity_distribution/y.txt > ./${dataset}_intensity_distribution/z.txt
rm ./${dataset}_intensity_distribution/y.txt ; mv ./${dataset}_intensity_distribution/z.txt ./${dataset}_intensity_distribution/individualGMvalues.txt
echo "$line	GMvalleys	`cat ./${dataset}_intensity_distribution/individualGMvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_GMvalleys.txt
echo "`cat ./${dataset}_intensity_distribution/individualGMvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_GMvalleys_unidentified.txt

cat ./${dataset}_intensity_distribution/tempfornativegmcsf.txt | awk -F"csf peak at" '{print $2}' | awk -F"," '{print $1}' | tr -d ' ,_' > ./${dataset}_intensity_distribution/individualCSFvalues.txt
sed '/^$/d' ./${dataset}_intensity_distribution/individualCSFvalues.txt > ./${dataset}_intensity_distribution/y.txt
head -n 1 ./${dataset}_intensity_distribution/y.txt > ./${dataset}_intensity_distribution/z.txt
rm ./${dataset}_intensity_distribution/y.txt ; mv ./${dataset}_intensity_distribution/z.txt ./${dataset}_intensity_distribution/individualCSFvalues.txt
echo "$line	CSFpeaks	`cat ./${dataset}_intensity_distribution/individualCSFvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_CSFpeaks.txt
echo "`cat ./${dataset}_intensity_distribution/individualCSFvalues.txt`" >> ./${dataset}_intensity_distribution/${dataset}_CSFpeaks_unidentified.txt

done < subjsinput_ip.txt

##############################################

#clean up and merge
rm ./${dataset}_intensity_distribution/individual*values.txt ; cat ./${dataset}_intensity_distribution/${dataset}_GMpeaks.txt ./${dataset}_intensity_distribution/${dataset}_GMvalleys.txt ./${dataset}_intensity_distribution/${dataset}_CSFpeaks.txt > ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues.txt

##############################################

#create a list of files containing all identified max and min intensity values
echo "./${dataset}_intensity_distribution/${dataset}_GMpeaks_unidentified.txt" >> ./${dataset}_intensity_distribution/${dataset}_unidentifiednativetissuelist.txt ; echo "./${dataset}_intensity_distribution/${dataset}_GMvalleys_unidentified.txt" >> ./${dataset}_intensity_distribution/${dataset}_unidentifiednativetissuelist.txt ; echo "./${dataset}_intensity_distribution/${dataset}_CSFpeaks_unidentified.txt" >> ./${dataset}_intensity_distribution/${dataset}_unidentifiednativetissuelist.txt

##############################################

#generate min, max, mean, and upper and lower quartile statistics for different tissues' intensity values
while read line
do
echo "$line" | cut -d"_" -f4 >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
cat $line | grep -Ev "0|^$" > ./${dataset}_intensity_distribution/all_non_null_values.txt
mean=`cat ./${dataset}_intensity_distribution/all_non_null_values.txt | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf sum/NR}'`
min=`cat ./${dataset}_intensity_distribution/all_non_null_values.txt | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf min}'`
max=`cat ./${dataset}_intensity_distribution/all_non_null_values.txt | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf max}'`
echo "Mean: $mean , Min: $min , Max: $max" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt

cat ./${dataset}_intensity_distribution/all_non_null_values.txt | sort -n > "$line.sort"
number=`cat "$line.sort" | wc -l | awk '{print $1}'`
quartile=0.25
qpos=`echo $number $quartile | awk '{printf "%d", $1 * $2 + 0.5}'`
q1=`head -n $qpos "$line.sort" | tail -n 1`
q1=`echo "$q1" | awk '{printf("%d\n",$1 + 0.5)}'`
quartile=0.75
qpos=`echo $number $quartile | awk '{printf "%d", $1 * $2 + 0.5}'`
q3=`head -n $qpos "$line.sort" | tail -n 1`
q3=`echo "$q3" | awk '{printf("%d\n",$1 + 0.5)}'`
rm "$line.sort"

echo "Q1: $q1 , Q3: $q3" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
echo "$line Q1: $q1 x $line Q3: $q3 x" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats_temp.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
sed '/^$/d' ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt > x.txt
mv x.txt ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt

done < ./${dataset}_intensity_distribution/${dataset}_unidentifiednativetissuelist.txt

echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt

#create a list of types of tissue values
echo "GMpeaks" >> ./${dataset}_intensity_distribution/tissuevaluetypes.txt ; echo "GMvalleys" >> ./${dataset}_intensity_distribution/tissuevaluetypes.txt ; echo "CSFpeaks" >> ./${dataset}_intensity_distribution/tissuevaluetypes.txt

##############################################

#identify subjects whose tissues' native intesity values are outliers in the dataset
while read line
do
echo "$line" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
while read line2
do
q1=`cat ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats_temp.txt | awk -F"${line}_unidentified.txt Q1:" '{print $2}' | awk -F"x" '{print $1}' | tr -d [:alpha:] | tr -d ' '`
q3=`cat ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats_temp.txt | awk -F"${line}_unidentified.txt Q3:" '{print $2}' | awk -F"x" '{print $1}' | tr -d [:alpha:] | tr -d ' '`

echo "$q1" > u.txt
sed '/^$/d' u.txt > v.txt
mv v.txt u.txt
q1=`head -n 1 u.txt`
rm u.txt
echo "$q3" > v.txt
sed '/^$/d' v.txt > w.txt
mv w.txt v.txt
q3=`head -n 1 v.txt`
rm v.txt

tissuevalue=`cat ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues.txt | grep "$line2	$line" | awk -F$'\t' '{print $3}' | tr -d [:alpha:] | tr -d ' '`
echo "$tissuevalue" > x.txt
sed '/^$/d' x.txt > y.txt
mv y.txt x.txt
tissuevalue=`head -n 1 x.txt`
tissuevalue=`echo "$tissuevalue" | awk '{printf("%d\n",$1 + 0.5)}'`
rm x.txt

compareq1=`echo "$q1 > $tissuevalue" | bc`
compareq3=`echo "$q3 < $tissuevalue" | bc`

if [ -z "$tissuevalue" ]; then
sleep 0.01
emptytissuevalue="1"
else
emptytissuevalue="0"
fi

if [ $emptytissuevalue -eq 1 ]; then
sleep 0.01
elif [[ $compareq1 = 1 ]]; then
echo "LOWER QUARTILE:	$line2	=	$tissuevalue	< $q1" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
elif [[ $compareq3 = 1 ]]; then
echo "UPPER QUARTILE:	$line2	=	$tissuevalue	> $q3" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
else
echo "INTERQUARTILE:	$line2	=	$tissuevalue" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
fi

sed '/^$/d' ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt > z.txt
mv z.txt ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt

done < subjsinput_ip.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats.txt
done < ./${dataset}_intensity_distribution/tissuevaluetypes.txt

##############################################

#create a list of all the surface parameters FreeSurfer set (definitely a more efficient way of coding this)
while read line
do
awk -F"MIN_GRAY_AT_WHITE_BORDER" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MIN_GRAY_AT_WHITE_BORDER.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MAX_BORDER_WHITE" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MAX_BORDER_WHITE.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MIN_BORDER_WHITE" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MIN_BORDER_WHITE.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MAX_CSF" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MAX_CSF.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MAX_GRAY " '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MAX_GRAY.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MAX_GRAY_AT_CSF_BORDER" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MAX_GRAY_AT_CSF_BORDER.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
while read line
do
awk -F"MIN_GRAY_AT_CSF_BORDER" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' (' >> ./${dataset}_intensity_distribution/surface_parameters/${dataset}_MIN_GRAY_AT_CSF_BORDER.txt
done < ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt

##############################################

#make some lists and clean up blank lines
ls ./${dataset}_intensity_distribution/surface_parameters/${dataset}_M*txt -1 > ./${dataset}_intensity_distribution/paramtypetexts.txt
ls ./${dataset}_intensity_distribution/surface_parameters/${dataset}_M*txt -1 | awk -F"meters/${dataset}_" '{print $2}' | awk -F".txt" '{print $1}' > ./${dataset}_intensity_distribution/paramtypes.txt

while read line
do
sed '/^$/d' $line > o.txt
mv o.txt $line
done < ./${dataset}_intensity_distribution/paramtypetexts.txt

##############################################

#generate min, max, mean, and upper and lower quartile statistics for the parameters FreeSurfer set to make surfaces
while read line
do
echo "$line" | awk -F"meters/${dataset}_" '{print $2}' | awk -F".txt" '{print $1}' >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
mean=`cat $line | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf sum/NR}'`
min=`cat $line | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf min}'`
max=`cat $line | awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf max}'`
echo "Mean: $mean , Min: $min , Max: $max" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt

cat "$line" | sort -n > "$line.sort"
number=`cat "$line.sort" | wc -l | awk '{print $1}'`
quartile=0.25
qpos=`echo $number $quartile | awk '{printf "%d", $1 * $2 + 0.5}'`
q1=`head -n $qpos "$line.sort" | tail -n 1`
q1=`echo "$q1" | awk '{printf("%d\n",$1 + 0.5)}'`
quartile=0.75
qpos=`echo $number $quartile | awk '{printf "%d", $1 * $2 + 0.5}'`
q3=`head -n $qpos "$line.sort" | tail -n 1`
q3=`echo "$q3" | awk '{printf("%d\n",$1 + 0.5)}'`
rm "$line.sort"

echo "Q1: $q1 , Q3: $q3" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
echo "$line Q1: $q1 x $line Q3: $q3 x" >> ./${dataset}_intensity_distribution/${dataset}_parameters_stats_temp.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
sed '/^$/d' ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt > x.txt
mv x.txt ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt

done < ./${dataset}_intensity_distribution/paramtypetexts.txt

echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt

##############################################

#identify subjects whose FreeSurfer-set surface parameters are outliers in the dataset
while read line
do
echo "$line" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt

while read line2
do
q1=`cat ./${dataset}_intensity_distribution/${dataset}_parameters_stats_temp.txt | awk -F"${line}.txt Q1:" '{print $2}' | awk -F"x" '{print $1}' | tr -d [:alpha:] | tr -d ' '`
q3=`cat ./${dataset}_intensity_distribution/${dataset}_parameters_stats_temp.txt | awk -F"${line}.txt Q3:" '{print $2}' | awk -F"x" '{print $1}' | tr -d [:alpha:] | tr -d ' '`

echo "$q1" > u.txt
sed '/^$/d' u.txt > v.txt
mv v.txt u.txt
q1=`head -n 1 u.txt`
rm u.txt
echo "$q3" > v.txt
sed '/^$/d' v.txt > w.txt
mv w.txt v.txt
q3=`head -n 1 v.txt`
rm v.txt

setparams=`cat ${line2}/scripts/recon-all.log | awk -F"$line" '{print $2}' | awk -F"was" '{print $1}' | tr -d [:alpha:] | tr -d ' ('`
echo "$setparams" > x.txt
sed '/^$/d' x.txt > y.txt
mv y.txt x.txt
setparam=`head -n 1 x.txt`
setparam=`echo "$setparam" | awk '{printf("%d\n",$1 + 0.5)}'`
rm x.txt

compareq1=`echo "$q1 > $setparam" | bc`
compareq3=`echo "$q3 < $setparam" | bc`

if [ -z "$setparam" ]; then
sleep 0.01
emptyparam="1"
else
emptyparam="0"
fi

if [ $emptyparam -eq 1 ]; then
sleep 0.01
elif [[ $compareq1 = 1 ]]; then
echo "LOWER QUARTILE:	$line2	=	$setparam	< $q1" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
elif [[ $compareq3 = 1 ]]; then
echo "UPPER QUARTILE:	$line2	=	$setparam	> $q3" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
else
echo "INTERQUARTILE:	$line2	=	$setparam" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
fi

sed '/^$/d' ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt > z.txt
mv z.txt ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt

############################################## This part tailored towards our Wash U data set!  Be careful about retaining it.
#echo "SET NEW PARAMS:	$line2	
#mris_make_surfaces -max_csf 38
#added to ${line2}/scripts/expert.opts" >> ./${dataset}_intensity_distribution/${dataset}_expertoptslog.txt
#echo "mris_make_surfaces -max_csf 38" > ${line2}/scripts/expert.opts 
#
#if [[ "$line" = "MIN_GRAY_AT_CSF_BORDER" ]]; then
#parambelow41=`echo "$setparam < 41" | bc`
#if [[ $parambelow41 = 1 ]]; then
#sleep 0.01
#else
#echo "SET NEW PARAMS:	$line2	
#mris_make_surfaces -min_gray_at_csf_border 40 
#also added to ${line2}/scripts/expert.opts
#BECAUSE $line $setparam is less than 41" >> ./${dataset}_intensity_distribution/${dataset}_expertoptslog.txt
#echo "mris_make_surfaces -max_csf 38 -min_gray_at_csf_border 40" > ${line2}/scripts/expert.opts
#fi
#else
#sleep 0.01
#fi
#
##############################################

done < subjsinput_ip.txt
echo "---------------------------------------" >> ./${dataset}_intensity_distribution/${dataset}_surfaceparameter_stats.txt
done < ./${dataset}_intensity_distribution/paramtypes.txt

##############################################

#cleanup
rm ./${dataset}_intensity_distribution/paramtypetexts.txt
rm ./${dataset}_intensity_distribution/paramtypes.txt
rm ./${dataset}_intensity_distribution/${dataset}_parameters_unidentified.txt
rm ./${dataset}_intensity_distribution/${dataset}_parameters_stats_temp.txt
rm ./${dataset}_intensity_distribution/tempfornativegmcsf.txt
rm ./${dataset}_intensity_distribution/tissuevaluetypes.txt
rm ./${dataset}_intensity_distribution/${dataset}_nativetissuevalues_stats_temp.txt
rm ./${dataset}_intensity_distribution/${dataset}_GMpeaks.txt
rm ./${dataset}_intensity_distribution/${dataset}_GMvalleys.txt
rm ./${dataset}_intensity_distribution/${dataset}_CSFpeaks.txt
rm ./${dataset}_intensity_distribution/${dataset}_GMpeaks_unidentified.txt
rm ./${dataset}_intensity_distribution/${dataset}_GMvalleys_unidentified.txt
rm ./${dataset}_intensity_distribution/${dataset}_CSFpeaks_unidentified.txt
rm ./${dataset}_intensity_distribution/${dataset}_unidentifiednativetissuelist.txt
rm ./${dataset}_intensity_distribution/all_non_null_values.txt
rm ./subjsinput_ip.txt
