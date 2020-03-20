echo "Fetching kNN lib"
wget https://d3g5vo6xdbdb9a.cloudfront.net/downloads/k-NN-lib/libKNNIndex1_7_3_6.zip \
&& unzip libKNNIndex1_7_3_6.zip \
&& sudo mv libKNNIndexV1_7_3_6.so /usr/lib \
&& rm libKNNIndex1_7_3_6.zip
