for ((i=1; i<=8000; i++))
do
    sed "s/<NUMBER>/$i/g" submit-first-job.yaml > "Jobs-Kueue/submit-first-job-$i.yaml"
done