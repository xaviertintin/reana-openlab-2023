combined_content=""
for ((i=1; i<=2000; i++))
do
    content=$(<"/data/benchmark/$i/timestamp1.txt")
    combined_content="$combined_content$content\n"
    content=$(<"/data/benchmark/$i/timestamp3.txt")
    combined_content="$combined_content$content\n"
    rm /data/benchmark/$i/timestamp*.txt
done

# Save combined content to output file
echo -e "$combined_content" > "/data/benchmark/extracted.txt"