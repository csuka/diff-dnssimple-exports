# Diff DNSSimple records

This script fetches the records of a domain at dnssimple, [using the API](https://developer.dnsimple.com/v2/).

It places the fetched records in a 'records_exports' folder. Then the script diffs the newly created export with the 2nd latest export. 

The diffs are saved in the folder 'diff_exports'.


Requirements
------------

 * `jq` is used for formatting, ensure it is installed

 * A cron should be placed to execute this script, e.g. once a week

 * Place the ID, domain and bearer token in the vars

Exports and diffs older than a month are not deleted, comment out the final area to enable.


Example output
--------------

When diffs are found:

```bash
$ ./exporter.sh
Exporter script started at: Wed Jan 15 11:18:39 CET 2020
Found differences, saving them
Done
$ cat diff_exports/2020-01-12_05:00-diffs-2020-01-19_05:00
These are the changes between an export of 2020-01-12_05:00 and 2020-01-19_05:00
< means; this is removed from file 2020-01-19_05:00
> means; this is added from file 2020-01-19_05:00
--- ./records_exports/2020-01-12_05:00	2020-01-19 05:00:09.715313242 +0000
+++ ./records_exports/2020-01-19_05:00	2020-01-19 05:00:11.767327482 +0000
@@ -1,25 +1,25 @@
 {
   "id": 12345678,
   "zone_id": "example.com",
   "parent_id": null,
   "name": "",
-  "content": "ns1.dnsimple.com admin.dnsimple.com 1476114538 86400 7200 604800 300",
+  "content": "ns1.dnsimple.com admin.dnsimple.com 1476114542 86400 7200 604800 300",
   "ttl": 3600,
   "priority": null,
   "type": "SOA",
   "regions": [
     "global"
   ],
   "system_record": true,
   "created_at": "2016-10-10T15:39:16Z",
-  "updated_at": "2019-12-19T13:10:50Z"
+  "updated_at": "2020-01-15T08:58:18Z"
 }
 {
   "id": 12345678,
   "zone_id": "example.com",
   "parent_id": null,
   "name": "",
   "content": "ns1.dnsimple.com",
   "ttl": 3600,
   "priority": null,
   "type": "NS",
```

When no changes are found:

```bash
$ ./exporter.sh
Exporter script started at: Wed Jan 15 11:17:20 CET 2020
No differences were found
Done
```
