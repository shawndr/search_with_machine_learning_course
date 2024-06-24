LOGSTASH_HOME="/workspace/logstash/logstash-7.13.2"
LOGS_DIR="/workspace/logs"

QUERIES_JSON_FILE="/workspace/search_with_machine_learning_course/opensearch/bbuy_queries.json"
QUERIES_LOGSTASH_FILE="/workspace/search_with_machine_learning_course/logstash/index-bbuy-queries.logstash"

echo "Deleting Queries Index"
curl -k -X DELETE -u admin  "https://localhost:9200/bbuy_queries"

echo "Creating index settings and mappings"
echo " Query file: $QUERIES_JSON_FILE"
curl -k -X PUT -u admin  "https://localhost:9200/bbuy_queries" -H 'Content-Type: application/json' -d "@$QUERIES_JSON_FILE"

echo ""
echo "Writing logs to $LOGS_DIR"
mkdir -p $LOGS_DIR

echo "Indexing"
echo " Query Logstash file: $QUERIES_LOGSTASH_FILE"

echo "Running Logstash found in $LOGSTASH_HOME"
cd "$LOGSTASH_HOME"
echo "Launching Logstash indexing in the background via nohup.  See product_indexing.log and queries_indexing.log for log output"
echo " Cleaning up any old indexing information by deleting query_data.  If this is the first time you are running this, you might see an error."
rm -rf "$LOGSTASH_HOME/query_data"
nohup bin/logstash --pipeline.workers 1 --path.data ./query_data -f "$QUERIES_LOGSTASH_FILE" > "$LOGS_DIR/queries_indexing.log" &

