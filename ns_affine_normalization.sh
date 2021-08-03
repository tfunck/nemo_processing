mkdir -p affine

atlas=mni_icbm152_t1_tal_nlin_asym_09c.nii
atlas_mask=mni_icbm152_t1_tal_nlin_asym_09c_mask.nii
clobber=${1:-0}

for name in `ls -d bids/sub-NS-*`; do
    echo $name

    sub=`echo $name | sed 's#bids/##g'`

    t1=`find $name -name "sub*space-nat_T1w.nii"`
    if [[ ! -f $t1 ]]; then
        t1=`find $name -name "sub*_T1w.nii"`
    fi

    if [[ ! -f $t1 ]]; then
        echo $sub,t1 
        echo $sub,t1 >> affine/missing.csv
        continue
    fi
    t1_rsl=affine/`basename ${t1%.*}`"_space-mni.nii.gz"
	t1_mask="affine/${sub}_mask.nii.gz"

    lesion=`find $name -name "sub*lesion-negative_T1w-coreg.nii"`
    if [[ ! -f $lesion ]]; then
        echo $sub,lesion 
        echo $sub,lesion >> affine/missing.csv
        continue
    fi

    lesion_rsl=affine/`basename ${lesion%.*}`"_space-mni.nii.gz"

    echo $sub
    echo $t1
    echo $lesion
    echo $clobber clobber
    if [[ ! -f affine/tfm_${sub}Composite.h5 || "$clobber" == "1" ]]; then    
	    python3 threshold_mri.py $t1 $t1_mask		
        echo Hello

        #--masks [$atlas_mask,$t1_mask] \
        antsRegistration --verbose 0 --write-composite-transform 1 --float --collapse-output-transforms 1 --dimensionality 3  \
        --initial-moving-transform [ $atlas, $t1, 0  ] \
        --initialize-transforms-per-stage 0 --interpolation Linear \
        --transform Rigid[ 0.05 ]  --metric Mattes[ $atlas,$t1,  1, 64, Random , 0.3 ] \
        --convergence [  1000x500x500 , 1e-09 , 15 ] --shrink-factors 6x4x2  --smoothing-sigmas 3.0x2.0x1.0vox \
        --transform Affine[ 0.05 ]  --metric Mattes[$atlas, $t1, 1, 64, Random ,0.3 ] \
        --convergence [  1000x500x500 , 1e-09 , 15 ] --shrink-factors 6x4x2   --smoothing-sigmas 3.0x2.0x1.0vox \
        --use-estimate-learning-rate-once 1 --use-histogram-matching 0  \
        --output [ affine/tfm_${sub} , affine/norm_${sub}.nii.gz  , affine/mni_to_${sub}.nii.gz ]
    fi

    antsApplyTransforms -v 1 -t "affine/tfm_${sub}Composite.h5" -r $atlas -i $lesion -o $lesion_rsl
    #echo antsApplyTransforms -t "affine/tfm_${sub}Composite.h5" -r $atlas -i $t1 -o $t1_rsl
    #antsApplyTransforms -v 1 -t "affine/tfm_${sub}Composite.h5" -r $atlas -i $t1 -o $t1_rsl
done
