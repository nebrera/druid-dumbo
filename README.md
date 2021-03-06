druid-dumbo, the druid batch config generator
=============================================

When you start to use [batch ingestion](https://github.com/metamx/druid/wiki/Batch-ingestion),
you'll quickly notice, you will need to edit the batch config for each run.

druid-dumbo actually checks your HDFS against your mysql and computes what's missing/outdated.

The easiest way to use dumbo is via environment variables:

 * DRUID_DATASOURCE - set it to your druid datasource 
 * DRUID_MYSQL_HOST - defaults to 'localhost'
 * DRUID_MYSQL_USER - defaults to 'druid'
 * DRUID_MYSQL_PASSWORD - you should really have one ;)
 * DRUID_MYSQL_DB' - defaults to 'druid'
 * DRUID_MYSQL_TABLE - defaults to 'segments'
 * DRUID_S3_BUCKET - the s3 bucket to generate to
 * DRUID_S3_PREFIX - the s3 prefix to generate to
 * DRUID_HDFS_FILEPATTERN - optional, defaults to '/events/*/*/*/*/part*'
 * DRUID_MAX_HOURS_PER_JOB - optional, limit the number of hours to be scheduled per run
 * DRUID_RESCAN - optional, set to 1 to rescan existing S3 segments where the HDFS input is newer

Start by creating an `importer.template` based on `importer.template.example`.

Once you got that, try:

```
DRUIDBASE=fully_qualified_path_to_druid # PLEASE ADJUST
CLASSPATH=`hadoop classpath`:`find $DRUIDBASE/indexer/target/ -name druid-indexer-*-selfcontained.jar`

./dumbo-scan.rb # scan all HDFS and computes min/max using pig
./dumbo-generate.rb # writes a druidimport.conf based on the scan above
java -cp $CLASSPATH com.metamx.druid.indexer.HadoopDruidIndexerMain ./druidimport.conf 
```

Dependencies
------------

You need a working `hadoop` and a working `pig` in your path.


Caveats
-------

Extremly young code, use at your own risk. Also, currently restricted to hourly granularity and JSON in HDFS.


Support us
----------

* Use druid-dumbo, and let us know if you encounter anything that's broken or missing.
  A failing spec is great. A pull request with your fix is even better!
* Spread the word about druid-dumbo on Twitter, Facebook, and elsewhere.
* Work with us at madvertise on awesome stuff like this.
  [Read the job description](http://madvertise.com/career) and send a mail to careers@madvertise.com.
