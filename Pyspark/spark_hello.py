txt = sc.textFile("/example/data/gutenberg/davinci.txt")
txt.count()
txt.first()

filtered_txt = txt.filter(lambda txt: "Leonardo" in txt)
filtered_txt.count()
filtered_txt.collect()
