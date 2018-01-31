# streaming 01
from pyspark.streaming import StreamingContext

ssc = StreamingContext(sc, 1)
ssc.checkpoint("/chkpnt")

stream_txt = ssc.textFileStream("/stream")

words = stream_txt.flatMap(lambda line: line.split(" "))
pairs = words.map(lambda word: (word, 1))
words_count = pairs.reduceByKeyAndWindow(lambda a, b: a + b, lambda x, y: x - y, 60, 10)

words_count.pprint(num=20)
ssc.start()

ssc.stop()


# streaming 02
from pyspark.sql.types import *
from pyspark.sql.functions import *

input_path = "/structstream/"

json_schema = StructType([
    StructField("device", StringType(), False),
    StructField("status", StringType(), False)
])

file_df = spark.readStream.schema(json_schema).option("maxFilePerTrigger", 1).json(input_path)
count_df = file_df.filter("status == 'error'").groupBy("device").count()
query = count_df.writeStream.format("memory").queryName("counts").outputMode("complete").start()

# %%sql 
# select * from counts
