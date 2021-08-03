
#NS-001-cj NS-R-W-9006
for sub in  NS-003-at NS-005-RDI NS-005-jm ; do 
#for t1 in `find bids/ -name "wasub*_T1w.nii"`; do
    t1="/data1/projects/stroke_pic/bids/sub-${sub}/_ses-01/anat/Normalized/wasub-${sub}*.nii"
    echo $t1
    if [[ `ls $t1` ]]; then
        Display  avg152T1.mnc $t1
    fi
    #register wasub-NS-003-at_ses-01_task-01_space-nat_T1w.mnc
    #Display /data1/projects/stroke_pic/bids/sub-${sub}/_ses-01/anat/Atlased116/*_ses-01_task-01_*Atlas.nii;  
 
done
