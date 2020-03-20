dpkg-query -W cmake
if [ "$?" -eq "1" ]
then
        exit 1;
fi
dpkg-query -W g++
if [ "$?" -eq "1" ]
then
        exit 1;
fi
dpkg-query -W git
if [ "$?" -eq "1" ]
then
        exit 1;
fi
if [ -z "$JAVA_HOME" ]
then
        echo "set JAVA_HOME to the jdk package"
        exit 1;
fi
echo "============================================================================"
echo "Building library"
sudo git clone https://github.com/nmslib/nmslib.git /usr/share/elasticsearch/nmslib \
&& cd /usr/share/elasticsearch/nmslib \
&& sudo git checkout tags/v1.7.3.6 \
&& cd similarity_search \
&& sudo cmake . \
&& sudo make \
&& sudo git clone https://github.com/opendistro-for-elasticsearch/k-NN.git /usr/share/elasticsearch/k-NN \
&& cd /usr/share/elasticsearch/k-NN \
&& sudo mkdir /tmp/jni \
&& sudo cp jni/src/v1736/* /tmp/jni \
&& cd /tmp/jni \
&& sudo g++ -fPIC -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I/usr/share/elasticsearch/nmslib/similarity_search/include -std=c++11 -shared -o libKNNIndexV1_7_3_6.so com_amazon_opendistroforelasticsearch_knn_index_v1736_KNNIndex.cpp -lNonMetricSpaceLib -L/usr/share/elasticsearch/nmslib/similarity_search/release \
&& sudo mv /tmp/jni/libKNNIndexV1_7_3_6.so /usr/lib/ \
&& sudo rm -rf /usr/share/elasticsearch/nmslib \
&& sudo rm -rf /usr/share/elasticsearch/k-NN \
&& exit 0
