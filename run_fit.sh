#fasttext supervised -input output.fasttext.train -output model1 -verbose 1
#fasttext test model1.bin output.fasttext.test
#fasttext test model1.bin output.fasttext.test 5


fasttext supervised -input output.fasttext.train -output model2 -epoch 25 -lr 1.0 -wordNgrams 2 -verbose 1
fasttext test model2.bin output.fasttext.test

#fasttext supervised -input output.fasttext.train -output model3 -autotune-validation output.fasttext.test -autotune-duration 1200 -verbose 3
#fasttext test model3.bin output.fasttext.test
#fasttext test model3.bin output.fasttext.test 5
#fasttext dump model3.bin args
