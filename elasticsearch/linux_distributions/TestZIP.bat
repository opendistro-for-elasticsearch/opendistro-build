set S3_PACKAGE=odfe
set PACKAGE=opendistroforelasticsearch
FOR /F "tokens=*" %%a in ('.\elasticsearch\bin\version-info --od') do SET OD_VERSION=%%a
#set OD_VERSION=python .\elasticsearch\bin\version-info --od
echo %OD_VERSION%
FOR /F "tokens=*" %%a in ('python .\elasticsearch\bin\version-info --od') do SET OD_VERSION=%%a
echo %OD_VERSION%
#set OD_VERSION=<python .\elasticsearch\bin\version-info --od
#echo %OD_VERSION%
echo downloading zip from S3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/ode-windows-zip/%S3_PACKAGE%-%OD_VERSION%.zip .\
echo unzipping %S3_PACKAGE%-%OD_VERSION%.zip
unzip .\%S3_PACKAGE%-%OD_VERSION%.zip
echo running es
nohup .\%PACKAGE%-%OD_VERSION%\bin\elasticsearch.bat &
echo Waiting for 30s
ping -n 30 127.0.0.1 >.\out.txt
echo running tests
cd ../odfe-test/odfe-test
dir
pytest

