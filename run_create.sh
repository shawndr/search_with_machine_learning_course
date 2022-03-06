python3 week3/createContentTrainingData.py --output output.fasttext --min_products 200 --max_category_level 2
sort -R output.fasttext  > output.fasttext.shuffled
head -10000 output.fasttext.shuffled > output.fasttext.train
tail -10000 output.fasttext.shuffled > output.fasttext.test

