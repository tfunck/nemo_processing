echo "" > failed.txt
for f in "sub-NS-001-cf-060" "sub-NS-001-gd-062" "sub-NS-001-jb-059" "sub-NS-002-ah-015" "sub-NS-002-aj-037" "sub-NS-002-as-013" "sub-NS-002-gs-063" "sub-NS-002-mf-051" "sub-NS-002-mk-012"  "sub-NS-004-gf-33" "sub-NS-004-mo-047" "sub-NS-004-ng-034"  "sub-NS-004-ns-044" "sub-NS-005-ae-038" "sub-NS-005-jmi-052"  "sub-NS-005-mb-041"  ; do
    echo $f 
    norm=`ls bids/${f}/_ses-01/anat/Normalized/wa${f}*_T1w.nii`
    if [[ -f  $norm ]]; then
        register $norm ../APPIAN/Atlas/MNI152/mni_icbm152_t1_tal_nlin_asym_09c.mnc
    fi
    
    echo "Pass(1)/Fail(0):"
    read pass

    if [[ "$pass" == "0" ]]; then
         echo "$f" >> failed.txt
    fi

done
