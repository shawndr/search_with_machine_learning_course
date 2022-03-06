import argparse
import os
import random
import xml.etree.ElementTree as ET
from pathlib import Path
import pandas as pd
from nltk.tokenize import RegexpTokenizer
from nltk.stem.snowball import SnowballStemmer

# Try transforming the name strings to lowercase, changing punctuation characters  to spaces, and stemming
def transform_name(product_name, tokenizer=RegexpTokenizer(r'\w+'), stemmer=SnowballStemmer(language='english')):
    product_name = ' '.join([stemmer.stem(tok) for tok in tokenizer.tokenize(product_name)])
    return product_name

# Directory for product data
directory = r'data/pruned_products/'

parser = argparse.ArgumentParser(description='Process some integers.')
general = parser.add_argument_group("general")
general.add_argument("--input", default=directory,  help="The directory containing product data")
general.add_argument("--output", default="output.fasttext", help="the file to output to")

# Consuming all of the product data will take over an hour! But we still want to be able to obtain a representative sample.
general.add_argument("--sample_rate", default=1.0, type=float, help="The rate at which to sample input (default is 1.0)")

# Setting min_products removes infrequent categories and makes the classifier's task easier.
general.add_argument("--min_products", default=0, type=int, help="The minimum number of products per category (default is 0).")

# Setting min_products removes infrequent categories and makes the classifier's task easier.
general.add_argument("--max_category_level", default=100, type=int, help="The maximum category depth to use (default is 100).")

args = parser.parse_args()
output_file = args.output
path = Path(output_file)
output_dir = path.parent
if os.path.isdir(output_dir) == False:
        os.mkdir(output_dir)

if args.input:
    directory = args.input
min_products = args.min_products
sample_rate = args.sample_rate
max_category_level = args.max_category_level

print("Writing results to %s" % output_file)
with open(output_file, 'w') as output:
    for filename in os.listdir(directory):
        if filename.endswith(".xml"):
            print("Processing %s" % filename)
            f = os.path.join(directory, filename)
            tree = ET.parse(f)
            root = tree.getroot()
            for child in root:
                if random.random() > sample_rate:
                    continue
                # Check to make sure category name is valid
                if child.find('name') is not None and child.find('name').text is not None and child.find('categoryPath') is not None and len(child.find('categoryPath')) > 0:
                    # Choose last element in categoryPath as the leaf categoryId with max of max_category_level
                    cat_level = min(max_category_level, len(child.find('categoryPath')) - 1)
                    if child.find('categoryPath')[cat_level][0].text is not None:
                      cat = child.find('categoryPath')[cat_level][0].text
                      # Replace newline chars with spaces so fastText doesn't complain
                      name = child.find('name').text.replace('\n', ' ')
                      output.write("__label__%s %s\n" % (cat, transform_name(name)))

# Track the number of items in each category and only output if above the min
df = pd.read_table(output_file, header=None)[0].str.split(' ', n=1, expand=True)
cat_freq = df[0].value_counts()
df_filtered = df.loc[df[0].isin(cat_freq.index[cat_freq >= min_products])]

print('%d categories, %d have at least %d products, %d filtered' % (len(cat_freq), len(cat_freq[cat_freq >= min_products]), min_products, len(cat_freq[cat_freq < min_products])))
print('%d products filtered to %d products with category support' % (df.shape[0], df_filtered.shape[0]))

print("Re-writing results to %s" % output_file)
with open(output_file, 'w') as output:
    for row in df_filtered.itertuples():
        output.write("%s %s\n" % (row._1, row._2))
