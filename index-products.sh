PRODUCTS_JSON_FILE="/workspace/search_with_machine_learning_course/opensearch/bbuy_products.json"
PRODUCTS_LOGSTASH_FILE="/workspace/search_with_machine_learning_course/logstash/index-bbuy.logstash"

LOGSTASH_HOME="/workspace/logstash/logstash-7.13.2"
LOGS_DIR="/workspace/logs"

echo "Deleting Product Index"
rm /workspace/logstash/logstash-7.13.2/products_data/plugins/inputs/file/.sincedb_*
curl -k -X DELETE -u admin  "https://localhost:9200/bbuy_products"

echo "Creating index settings and mappings"
echo " Product file: $PRODUCTS_JSON_FILE"
curl -k -X PUT -u admin  "https://localhost:9200/bbuy_products" -H 'Content-Type: application/json' -d "@$PRODUCTS_JSON_FILE"

echo ""
echo "Writing logs to $LOGS_DIR"
mkdir -p $LOGS_DIR

echo "Indexing"
echo " Product Logstash file: $PRODUCTS_LOGSTASH_FILE"

echo "Running Logstash found in $LOGSTASH_HOME"
cd "$LOGSTASH_HOME"
echo "Launching Logstash indexing in the background via nohup.  See product_indexing.log and queries_indexing.log for log output"
echo " Cleaning up any old indexing information by deleting products_data.  If this is the first time you are running this, you might see an error."
rm -rf "$LOGSTASH_HOME/products_data"
nohup bin/logstash --pipeline.workers 1 --path.data ./products_data -f "$PRODUCTS_LOGSTASH_FILE" > "$LOGS_DIR/product_indexing.log" &

