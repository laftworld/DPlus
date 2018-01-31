from pyspark import SparkContext, SparkConf

cfg = SparkConf().setMaster("local").setAppName("WordCount")
sc = SparkContext(conf=cfg)

txt = sc.textFile("/example/data/gutenberg/ulysses.txt")
words = txt.flatMap(lambda txt: txt.split(" "))
counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)
result = counts.sortBy(lambda c: c[1])
result.saveAsTextFile("/wordcount_output")

# spark-submit spark_wordcount.py
