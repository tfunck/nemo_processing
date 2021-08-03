civet_dir="/data1/projects/stroke_pic/civet/"
results_dir="/data1/projects/stroke_pic/results/base/"
remote_pic_dir="/data1/projects/stroke_pic/remote-pic_nat/"
infarct_dir="/data1/projects/stroke_pic/infarct_nat/"
out_dir="/data1/projects/stroke_pic/remote-pic_nat/"
pet_dir="/data1/projects/stroke_pic/pet/"


for f in `ls ${pet_dir}/GPI_*_pet.mnc`; do
    name=`echo $f | awk '{split($0,a,"_"); print a[3]}'  `
    sess=`echo $f | awk '{split($0,a,"_"); print a[4]}'  `
    echo $name $sess
    sub_civet=`ls -d $civet_dir"GPI_"${name}*${sess}*/`
    remote_pic="remote-pic_nat/GPI_${name}_${sess}_remote-pic_nat.mnc"
    infarct="${infarct_dir}/GPI_${name}_${sess}_infarct_nat.mnc"
    mid_surf="results/base/srv/GPI_${name}_${sess}_mid_surface_nat.obj"
    t1_nat=`ls $sub_civet/native/*_t1.mnc`
    labels="natives/GPI_${name}_${sess}_labels.mnc"
    #Display -gray $t1_nat $infarct -label $remote_pic -label $mid_surf

    #if [[ $sess == "F" ]]; then
    #    remote_pic_i="remote-pic_nat/GPI_${name}_I_remote-pic_nat.mnc"
    #    sub_civet_i=`ls -d $civet_dir"GPI_"${name}*_I*/`
    #    t1_nat_i=`ls ${sub_civet_i}/native/*_I_t1.mnc`
    #    Display  -gray $t1_nat -label $remote_pic #-label $mid_surf
    #fi
done
