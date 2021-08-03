

flair_list=`find bids -name "*_flair.mnc"`
t1_list=`find bids -name "*_T1w.mnc"`

for f in `ls -d bids/sub-NS-*`; do
    sub0=`basename $f`
    sub=`echo $sub0 | sed 's/sub-NS-//'`
    for ses_fn in `ls -d ${f}/_ses-*`; do
        ses=`basename $ses_fn | sed 's/_//'`
        t1=`ls ${ses_fn}/anat/${sub0}*_space-nat_T1w.mnc`

        lesion=`ls ${ses_fn}/anat/${sub0}*_lesion.mnc`
        lesion_neg=`ls ${ses_fn}/anat/${sub0}*_lesion-negative.mnc`

        lesion_rsl=`echo $lesion | sed 's/.mnc/_T1w-coreg.mnc/'`
        lesion_neg_rsl=`echo $lesion_neg | sed 's/.mnc/_T1w-coreg.mnc/'`

        echo $t1
        echo "Lesion" $lesion
        echo "Lesion Negative" $lesion_neg

        if [[  -f `ls ${ses_fn}/anat/${sub0}*_flair.mnc ` ]]; then
            flair=`ls ${ses_fn}/anat/${sub0}*_flair.mnc`

            flair_rsl=`echo $flair | sed 's/.mnc/_T1w-coreg.mnc/'`
            flair_xfm=`echo $flair | sed 's/.mnc/_T1w-coreg.xfm/'`
            echo "Flair: $flair"
            
            min=`mincstats -quiet -min $t1`

            minccalc -clobber -expr "(A[0] - $min)" $t1 temp.mnc
            #minctracc -clobber -lsq6 -est_translation  $flair temp.mnc $flair_xfma
            if [[ ! -f $flair_xfm ]]; then
                bestlinreg.pl -clobber -lsq6 -nmi $flair temp.mnc $flair_xfm
            fi

            echo "Flair"
            if [[ ! -f $flair_rsl ]]; then
                mincresample -nearest -clobber -transformation $flair_xfm -like $t1 $flair $flair_rsl 
            fi
            
            echo "Lesion"
            if [[ ! -f $lesion_rsl ]]; then
                mincresample -nearest -clobber -transformation $flair_xfm -like $t1 $lesion $lesion_rsl 
            fi

            echo "Lesion Negative"
            if [[ ! -f $lesion_neg_rsl ]]; then
                mincresample -nearest -clobber -transformation $flair_xfm -like $t1 $lesion_neg $lesion_neg_rsl 
            fi
            #register temp.mnc $flair_rsl
        else
            cp $lesion $lesion_rsl
            cp $lesion_neg $lesion_neg_rsl
            echo "Cannot find Flair"
        fi
        mnc2nii -nii $lesion_rsl
        mnc2nii -nii $lesion_neg_rsl
    done 
done
