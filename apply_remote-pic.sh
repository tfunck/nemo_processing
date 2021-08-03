civet_dir="/data1/projects/stroke_pic/civet/"
results_dir="/data1/projects/stroke_pic/results/base/"
remote_pic_dir="/data1/projects/stroke_pic/remote-pic_mni/"
infarct_dir="/data1/projects/stroke_pic/infarct_nat/"
out_dir="/data1/projects/stroke_pic/remote-pic_nat/"
pet_dir="/data1/projects/stroke_pic/pet/"
stats="stats/remote-pic_stats.csv"


#cd remote-pic_mni; ./resample_to_0.5mm.sh; cd -
#cd remote-pic_nat; ./resample2nat.sh; cd -
#if [[ ! -f $stats || "$1" == "clob" ]]; then

for f in `ls ${remote_pic_dir}/*remote-pic.mnc`; do
    name=`echo $f | awk '{split($0,a,"_"); print a[4]}'  `
    sess=`echo $f | awk '{split($0,a,"_"); print a[5]}'  `

    sub_civet=`ls -d $civet_dir"GPI_"${name}*${sess}*/`
    echo $sub_civet
    classify=`ls $sub_civet/classify/*pve_classify.mnc`
    brainmask=`ls $sub_civet/mask/*brain_mask.mnc`
    f_nat=${out_dir}`basename $f | sed 's/.mnc/_nat.mnc/g'`
    f_contra=`echo $f_nat | sed 's/.mnc/_contra.mnc/g'`
    
    t1_nat=`ls $sub_civet/native/*_t1.mnc`
    t12tal=`ls $sub_civet/transforms/linear/*_t1_tal.xfm`
    echo $name $sess
    echo $classify
    if [[ ! -f $f_nat || ! -f $f_contra ||  "$1" == "clob"  ]]; then
        echo Removing infarct and intersecting with GM
        echo $f
        if [[ ! -d $sub_civet ]]; then
            echo $sub_civet
            echo could not find civet for $name $sess
            exit 1
        fi
        brainmask_nat="mask/GPI_${name}_${sess}_brain_mask_nat.mnc"
        classify_nat="natives/GPI_${name}_${sess}_pve_classify_nat.mnc"
        echo $name $sess
        echo $f_nat
        echo $f_contra
        echo $classify_nat

        infarct="${infarct_dir}/GPI_${name}_${sess}_infarct_nat.mnc"
        infarct_rsl="${infarct_dir}/GPI_${name}_${sess}_infarct_nat_rsl.mnc"
        if [[ ! -f $infarct_rsl || "$1" == "clob"  ]]; then
            mincresample -nearest -clob -step 0.5 0.5 0.5 -nelements 512 480 384 $infarct $infarct_rsl
        fi
        infarct=$infarct_rsl

        t1_rsl="natives/GPI_${name}_${sess}_natives.mnc"
        if [[ ! -f $t1_rsl || "$1" == "clob"  ]]; then
            mincresample -clob -step 0.5 0.5 0.5 -nelements 512 480 384 $t1_nat $t1_rsl
        fi
        t1_nat=$t1_rsl

        if [[ ! -f $classify_nat || ! -f $brainmask_nat || "$1" == "clob" ]]; then
            echo mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat $classify $classify_nat
            mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat $classify $classify_nat
            echo mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat $brainmask $brainmask_nat
            mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat $brainmask $brainmask_nat
        fi

        if [[ ! -f $f_nat || "$1" == "clob" ]]; then
            mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat $f temp1.mnc
            echo minccalc -clob -expr 'if(A[0]==2 && A[2] != 1 && A[3] == 1 && A[0] * A[1] > 0) 1 else 0' $classify_nat temp1.mnc $infarct $brainmask_nat $f_nat
            minccalc -clob -expr 'if( A[0] < 2.4 && A[0] > 1.6 && A[2] != 1 && A[3] * A[0] * A[1] > 0) 1 else 0' $classify_nat temp1.mnc $infarct $brainmask_nat $f_nat
            rm temp1.mnc
        fi

        if [[ ! -f $f_contra || "$1" == "clob" ]]; then
            mincresample -clob -nearest -transform flip_x_dim.xfm -like $f $f temp1.mnc 
            mincresample -clob -nearest -transform $t12tal -invert_transformation -like $t1_nat temp1.mnc temp2.mnc
            minccalc -clob -expr 'if( A[0] < 2.4 && A[0] > 1.6 && A[2] != 1 && A[3] * A[0] * A[1] > 0) 1 else 0' $classify_nat temp2.mnc $infarct $brainmask_nat $f_contra
            rm temp1.mnc temp2.mnc
        fi

        
    fi

    if [[ ! -f `ls natives/GPI_${name}_${sess}_{left,right}_classify_nat.mnc` ||  "$1" == "clob" ]]; then
        mkdir -p mni
        infarct_mni="infarct_mni/GPI_${name}_${sess}_infarct_mni.mnc"
        infarct_mni_500um="infarct_mni/GPI_${name}_${sess}_infarct_mni_500um.mnc"
        mincresample -clob $infarct_mni -nearest -like $classify $infarct_mni_500um
        infarct_mni=$infarct_mni_500um 
        left=mni/GPI_${name}_${sess}_left_classify.mnc
        right=mni/GPI_${name}_${sess}_right_classify.mnc
        if [[ ! -f $left || ! -f $right ||  "$1" == "clob" ]]; then
            echo mincsplit $classify $left $right
            mincsplit $classify $left $right
            echo $left $right
        fi

        if [[ ! -f `ls natives/GPI_${name}_${sess}_{left,right}_classify_nat.mnc` || $1 == "clob" ]]; then
            echo mincmath -clob -mult $left $infarct_mni left_infarct.mnc
            mincmath -clob -mult $left $infarct_mni left_infarct.mnc
            left_sum=`mincstats -quiet -sum left_infarct.mnc`
            echo Left Sum: $left_sum
            if [[ $left_sum -gt 0 ]]; then
                gm_hemisphere=$left
            else
                gm_hemisphere=$right
            fi
        fi
        gm_hemisphere_nat=natives/`basename $gm_hemisphere | sed 's/.mnc/_nat.mnc/'`
        echo GM Hemisphere: $gm_hemisphere 
        if [[ ! -f  $gm_hemisphere_nat || $1 == "clob" ]]; then
            minccalc -unsigned -byte -clob -quiet -expr 'if( A[0] < 2.4 && A[0] > 1.6 && A[1] != 1 && A[2] > 0) 1 else 0' $gm_hemisphere $infarct_mni $brainmask temp.mnc
            mincresample -unsigned -clob -byte -quiet -transformation $t12tal -invert_transformation -like $f_nat temp.mnc  temp2.mnc 
            minccalc -unsigned -byte -clob -quiet -expr 'if(A[0] - A[1] >= 1) 1 else 0' temp2.mnc $f_nat $gm_hemisphere_nat
        fi
        echo GM Hemisphere Native: $gm_hemisphere_nat
        if [[ ! -f $gm_hemisphere_nat ]]; then
            echo Problem!
            exit 1
        fi
        rm left_infarct.mnc temp.mnc temp2.mnc
    fi
done
#fi

#echo 'Subject,Session,Hemisphere,nFrames,label,Frame,Mean,StdDev,Max,Min,Vol' > $stats
echo 'Subject,Session,BP.Remote,BP.Proxy,BP.GM,WM.dmg,Remote.PIC.Vol,Infarct.Vol,CT.GM,CT.Remote' > $stats
$name,$sess,$BPremote,$BPproxy,$BPintersection,$RemotePICvolume,$BPGM,$Infarctvolume
for bp in `ls ${results_dir}/tka/*_idSURF_loganplot.mnc`; do
    mkdir -p infarct_surf
    name=`echo $bp | awk '{split($0,a,"_"); print a[3]}'  `
    sess=`echo $bp | awk '{split($0,a,"_"); print a[4]}'  `
    echo $bp
    echo $name $sess
    f_nat=`ls remote-pic_nat/GPI_${name}_${sess}_remote-pic_nat.mnc`
    f_true=`ls remote-pic_nat/GPI_${name}_${sess}_remote-pic_nat.mnc`
    f_contra=`ls remote-pic_nat/GPI_${name}_I_remote-pic_nat_contra.mnc`
    infarct_rsl="${infarct_dir}/GPI_${name}_${sess}_infarct_nat_rsl.mnc"
    infarct="${infarct_dir}/GPI_${name}_${sess}_infarct_nat.mnc"
    t1_nat=`ls natives/GPI_${name}_${sess}*_natives.mnc`
    gm_hemisphere=`ls natives/GPI_${name}_${sess}_{left,right}_classify_nat.mnc`
    classify_nat=`ls natives/GPI_${name}_${sess}_pve_classify_nat.mnc`
    classify_nat_1mm=`echo $classify_nat | sed 's/.mnc/_nat.mnc/g'`
    echo gm hemisphere $gm_hemisphere
    
    if [[ ! -f $f_nat || ! -f $f_contra ]]; then
        echo could not find $f_nat or $f_contra
        continue
    fi
    sub_stats="stats/${name}_${sess}_remote-pic_stats.csv"

    bp_rsl="natives/`basename $bp`"
    #mincresample -quiet -clobber -byte -unsigned  $f_nat -nearest -like $t1_nat temp1.mnc
    #mv temp1.mnc $f_nat
    
    if [[ ! -f $classify_nat_1mm  ||  $2 == "clob" ]]; then
        mincresample -quiet -clobber $classify_nat -like $infarct   $classify_nat_1mm 
    fi

    if [[ ! -f $bp_rsl ||  $2 == "clob" ]]; then
        mincresample -clob $bp -like $f_nat $bp_rsl
    fi
    echo BP $bp_rsl

    dist="results/base/dist/GPI_${name}_${sess}_infarct_mni_defrag_distance-map.txt"
    mid_surf="results/base/srv/GPI_${name}_${sess}_mid_surface_nat.obj"
    infarct_surf="infarct_surf/GPI_${name}_${sess}_infarct.txt"
    proxy_pic="infarct_surf/GPI_${name}_${sess}_proxy_pic.txt"
    intersection="infarct_surf/GPI_${name}_${sess}_intersection.txt"
    remote_pic="infarct_surf/GPI_${name}_${sess}_remote_pic.txt"
    remote_pic_exc="infarct_surf/GPI_${name}_${sess}_remote_pic_exc.txt"
    proxy_pic_exc="infarct_surf/GPI_${name}_${sess}_proxy_pic_exc.txt"
    bp_surf="infarct_surf/GPI_${name}_${sess}_bp.txt"
    thickness=""
    remote_pic_exc_value="infarct_surf/GPI_${name}_${sess}_remote_pic_exc_value.txt"
    proxy_pic_exc_value="infarct_surf/GPI_${name}_${sess}_proxy_pic_exc_value.txt"
    intersection_value="infarct_surf/GPI_${name}_${sess}_intersection_value.txt"
    gm_surf="infarct_surf/GPI_${name}_${sess}_gm_surf.txt"
    thickness=`ls $sub_civet/thickness/*_native_rms_tlaplace_30mm.txt`
    volume_object_evaluate -nearest $f_nat $mid_surf $remote_pic
    volume_object_evaluate -nearest $gm_hemisphere  $mid_surf $gm_surf

    if [[ ! -f $proxy_pic || $2 == "clob" ]]; then
        vertstats_math  -old_style_file -seg -const2 0.001 6 $dist $proxy_pic
    fi

    if [[ ! -f  $intersection || $2 == "clob" ]]; then
        vertstats_math  -old_style_file -mult $proxy_pic $remote_pic $intersection
    fi
    
    if [[ ! -f $proxy_pic_exc || $2 == "clob" ]]; then
        vertstats_math  -old_style_file -sub $proxy_pic $intersection temp.txt
        vertstats_math  -old_style_file -seg -const2 0.9 1.1 temp.txt $proxy_pic_exc
    fi

    if [[ ! -f $bp_surf || $2 == "clob" ]]; then
        volume_object_evaluate -nearest $bp $mid_surf $bp_surf
    fi
    
    if [[ ! -f $sub_stats || "$2" == "clob"  ]]; then
        #echo mincgroupstats -i -g $name -g $sess $bp -v -g 'Infarct' $infarct_rsl -v -g 'Remote' $f_nat -v -g 'Remote.Contra' $f_contra -o $sub_stats 
        #mincgroupstats -i -g $name -g $sess $bp -v -g 'Infarct' $infarct_rsl -v -g 'Remote' $f_nat -v -g 'Remote.Contra' $f_contra -o $sub_stats 
        BPremote=`mincstats -quiet -mean $bp_rsl -mask $f_nat -mask_range 1,1`
        #BPremote=`python roi_mean.py $bp_surf $remote_pic_exc`
        BPproxy=`python roi_mean.py $bp_surf  $proxy_pic_exc`
        CTgm=`python roi_mean.py $thickness $gm_surf` 
        CTremote=`python roi_mean.py $thickness $remote_pic` 
        # BPContra=`mincstats -quiet -mean $bp_rsl -mask $f_contra -mask_range 1,1`
        BPGM=`mincstats -quiet -mean $bp_rsl -mask $gm_hemisphere -mask_range 1,1`
        RemotePICvolume=`mincstats -quiet -sum $f_true`
        Infarctvolume=`mincstats -quiet -sum $infarct_rsl`
        WMdmg=`python wm_dmg.py $classify_nat_1mm $infarct`
        echo $name,$sess,$BPremote,$BPproxy,$BPGM,$WMdmg,$RemotePICvolume,$Infarctvolume,$CTgm,$CTremote
        echo $name,$sess,$BPremote,$BPproxy,$BPGM,$WMdmg,$RemotePICvolume,$Infarctvolume,$CTgm,$CTremote  > $sub_stats
    fi

    cat $sub_stats >> $stats
done

Rscript analyze_remote-pic.R
