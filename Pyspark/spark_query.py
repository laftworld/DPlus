# load building.csv 
csv = sc.textFile("/HdiSamples/HdiSamples/SensorSampleData/building/building.csv")
csv.printSchema()
csv.show(truncate=False)

building_csv = spark.read.csv("/HdiSamples/HdiSamples/SensorSampleData/building/building.csv", header=True, inferSchema=True)
building_csv.printSchema()
building_csv.show()

building_data = building_csv.select("BuildingID", "BuildingAge", "HVACproduct")
building_data.show()

from pyspark.sql.types import *
from pyspark.sql.functions import *

# load HVAC.csv
schma = StructType([
    StructField("Date", StringType(), False),
    StructField("Time", StringType(), False),
    StructField("TargetTemp", IntegerType(), False),
    StructField("ActualTemp", StringType(), False),
    StructField("System", IntegerType(), False),
    StructField("SystemAge", IntegerType(), False),
    StructField("BuildingID", IntegerType(), False),
])
hvac_csv = spark.read.csv("/HdiSamples/HdiSamples/SensorSampleData/hvac/HVAC.csv", schema=schma, header=True)
hvac_csv.printSchema()

hvac_data = hvac_csv.select("BuildingID", "ActualTemp", "TargetTemp").filter(col("ActualTemp") > col("TargetTemp"))
hvac_data.show()

# join 
hot_buildings = building_data.join(hvac_data, "BuildingID")
hot_buildings.show()

# spark SQL
hot_buildings.createOrReplaceTempView("tmpHotBuildings")
spark.sql("SELECT HVACproduct, COUNT(*) AS installations FROM tmpHotBuildings GROUP BY HVACproduct").show()

# save table
building_csv.write.saveAsTable("building")
building_df = spark.sql("SELECT * FROM building")
building_df.show()

# Query Hive Table
spark.sql("SHOW TABLES").show()