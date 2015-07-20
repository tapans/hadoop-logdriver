--- Load up the logdriver utilities
REGISTER /usr/lib/logdriver/hadoop-deploy/logdriver-core-hdeploy.jar

--- Create an alias to the load function
DEFINE bmLoad com.rim.logdriver.pig.BoomLoadFunc();

/*
The path for most Boom files processed using this method will be
/service/<DC>/<SVC>/logs/YYYYMMDD/<HH>/<COMPONENT>/data/*.bm
*/

raw_lines = LOAD '/service/$DC/$SVC/logs/$DATE/*/$COMPONENT/data/*.bm' USING bmLoad AS (
     timestamp: long, 
     message: chararray,
     eventId: long,
     createTime: long, 
     blockNumber: long, 
     lineNumber: long
);

/*
Filter to only keep log lines that catch an exception. (assuming exception logs have the keyword "CAUGHT: " followed by exception name)
Furthermore, only keep exception name
*/

exceptions = FOREACH raw_lines GENERATE REGEX_EXTRACT(message, '(CAUGHT:) (\\S+)', 2) AS exceptionName;

/*
Group exceptions and get count of each
*/

groupedExceptions = GROUP exceptions by exceptionName;
results = FOREACH groupedExceptions GENERATE group as exceptionName, COUNT(exceptions.exceptionName) as count;

DUMP results;
STORE results INTO '$OUT'; 

