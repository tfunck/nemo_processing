
for f in `find bids* -name "*_T1w.mnc"`; do

    nii=`echo $f | sed 's/.mnc/.nii/'`
    if [[ ! -f $nii ]]; then
        echo $f
        echo $nii
        mnc2nii $f $nii
    else
        echo Exists: $nii
    fi

done
