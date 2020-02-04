set S3_PACKAGE=odfe
set PACKAGE=opendistroforelasticsearch
set OD_VERSION=.\elasticsearch\bin\version-info.py --od
echo %OD_VERSION%
echo unzipping %S3_PACKAGE%-%OD_VERSION%.zip
unzip .\%S3_PACKAGE%-%OD_VERSION%.zip
dir
echo running es
nohup .\%PACKAGE%-%OD_VERSION%\bin\elasticsearch.bat &

echo Waiting for 30s
ping -n 30 127.0.0.1 >.\out.txt
echo running tests
cd ../odfe-test/odfe-test
dir
pytest

