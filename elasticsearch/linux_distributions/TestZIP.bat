set S3_PACKAGE=odfe
set PACKAGE=opendistroforelasticsearch
#cd .\elasticsearch\bin\
#FOR /F "tokens=*" %%g IN ('python version-info --od') do SET OD_VERSION=%%g
#cd ..\..
#echo downloading zip from S3
#aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/ode-windows-zip/%S3_PACKAGE%-%OD_VERSION%.zip .\
#dir
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
