#!/bin/sh

now="$(date)"
printf "Exporter script started at: %s\n" "$now"

ID=""
domain=""
token=""

if [ -z "$ID" ] || [ -z "$domain" ] || [ -z "$token" ] ;
then
  echo "One or more vars are undefined, please check"
  exit 1
fi

verify=$(curl -s -o /dev/null -w "%{http_code}" 'https://api.dnsimple.com/v2/'$ID'/zones/'$domain'/records?per_page=100&page=1' -H 'Authorization: Bearer '$token'')

if test "$verify" != "200"
then
  echo "did not receive status 200 from webserver, did you provide the correct credentials?"
  echo "exiting..."
  exit 1
fi

record_dir=./records_exports
diff_dir=./diff_exports

# Ensure directory exists
[ -d "$record_dir" ] || mkdir $record_dir
[ -d "$diff_dir" ] || mkdir $diff_dir

# find the newest file
new="$(ls -t $record_dir | head -1)"
if test -z "$new" ; then
        new="first-run-thus-empty"
fi

# only 100 records per page are allowed, we need to fetch the total page numbers
today=`date +%Y-%m-%d_%H:%M`
page_num="$(curl --silent 'https://api.dnsimple.com/v2/'$ID'/zones/'$domain'/records?per_page=100&page=1' -H 'Authorization: Bearer '$token'' -H 'Accepts: application/json' | jq '.pagination.total_pages')"

# now iterate over the total amount of page numbers
for i in `seq 1 $page_num`;
do
  curl --silent 'https://api.dnsimple.com/v2/'$ID'/zones/'$domain'/records?per_page=100&page='$i -H 'Authorization: Bearer '$token'' -H 'Accepts: application/json' | jq '.data[]' >> $record_dir/$today
done

# diff the created and the 2nd newest file in memory
dif=$(diff $record_dir/$new $record_dir/$today)

# Test whether there is a difference between the files
if test -z "$dif" ; then
        echo "No differences"
        touch $diff_dir/no_diff_between_$new-and-$today
else
        echo "Found differences, saving them"
        diff_file=$diff_dir/$new-diffs-$today
        touch $diff_file
        echo "These are the changes between an export of $new and $today \n" >> $diff_file
        echo "< means; this is removed from file $today" >> $diff_file
        echo "> means; this is added from file $today" >> $diff_file
        diff -U10 $record_dir/$new $record_dir/$today >> $diff_file
fi

# cleanup files older than 1 month
# find $record_dir -type f -mtime +32 -exec rm {} \;
# find $diff_dir -type f -mtime +32 -exec rm {} \;

echo "Done"

exit 0
