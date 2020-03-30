echo "Fetching kNN library"
FILE=/usr/lib/libKNNIndexV1_7_3_6.so
if [ -f "$FILE" ]
then
    echo "$FILE exist: removing $FILE"
    sudo rm $FILE
fi
FILE=/libKNNIndex1_7_3_6.zip
if [ -f "$FILE" ]
then
    echo "$FILE exist: removing $FILE"
    sudo rm $FILE
fi
wget https://d3g5vo6xdbdb9a.cloudfront.net/downloads/k-NN-lib/libKNNIndex1_7_3_6.zip \
&& unzip libKNNIndex1_7_3_6.zip \
&& sudo mv libKNNIndexV1_7_3_6.so /usr/lib \
&& rm libKNNIndex1_7_3_6.zip
