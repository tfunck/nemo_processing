fn_list=""

for f in "sub-NS-001-cf-060" "sub-NS-001-gd-062" "sub-NS-001-jb-059" "sub-NS-002-ah-015" "sub-NS-002-aj-037" "sub-NS-002-as-013" "sub-NS-002-gs-063" "sub-NS-002-mf-051" "sub-NS-002-mk-012"  "sub-NS-004-gf-33" "sub-NS-004-mo-047" "sub-NS-004-ng-034"  "sub-NS-004-ns-044" "sub-NS-005-ae-038" "sub-NS-005-jmi-052"  "sub-NS-005-mb-041"  ; do

    fn=`ls bids/${f}/_ses-01/anat/Normalized/wasub*nii`
    fn_list="$fn $fn_list"
done
up $fn_list
