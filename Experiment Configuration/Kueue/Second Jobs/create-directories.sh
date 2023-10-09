for ((i=1; i<=2000; i++))
do
    mkdir -p $i
    sed "s/<NUMBER>/$i/g" submit-second-job.yaml > "$i/submit-second-job-$i.yam
    sed "s/<NUMBER>/$i/g" submit-second-job.sh > "$i/submit-second-job-$i.sh"
    chmod +x $i/submit-second-job-$i.sh
done