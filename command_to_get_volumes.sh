echo "sub,ses,task,volume,com" > northstar_volumes.csv ; 
for f in `find bids -name "sub-NS*lesion.mnc"`; do 
    vol=`mincstats -quiet -volume $f -mask $f -mask_range 1,1`; 
    com=`mincstats -quiet -com -world_only $f -mask $f -mask_range 1,1 | sed 's/ /;/g'`; 
    basename $f | awk -v vol=$vol -v com="${com}" '{split($0,ar,"_"); print ar[1]","ar[2]","ar[3]","vol","com }' >> northstar_volumes.csv; 
done
