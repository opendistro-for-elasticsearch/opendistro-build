echo "Fetching kNN library"
FILE=/usr/lib/libKNNIndexV1_7_3_6.so
if [ -f "$FILE" ]
then
    echo "$FILE exist: removing $FILE"
    sudo rm $FILE
fi
FILE=/libKNNIndexV1_7_3_6.zip
if [ -f "$FILE" ]
then
    echo "$FILE exist: removing $FILE"
    sudo rm $FILE
fi
wget https://d3g5vo6xdbdb9a.cloudfront.net/downloads/k-NN-lib/libKNNIndexV1_7_3_6.zip \
&& unzip libKNNIndexV1_7_3_6.zip \
&& mv libKNNIndexV1_7_3_6.so /usr/lib \
&& rm libKNNIndexV1_7_3_6.zip
