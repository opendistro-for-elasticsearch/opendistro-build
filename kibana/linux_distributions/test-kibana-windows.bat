set PACKAGE=opendistroforelasticsearch-kibana
cd .\kibana\bin\
FOR /F "tokens=*" %%g IN ('python version-info --od') do SET OD_VERSION=%%g
echo %OD_VERSION%
set S3_PACKAGE=odfe-%OD_VERSION%-kibana

cd ..\..
echo downloading zip from S3
aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/ode-windows-zip/%S3_PACKAGE%.zip .\
dir
echo unzipping %S3_PACKAGE%.zip
unzip .\%S3_PACKAGE%.zip
dir
echo running kibana
nohup .\%PACKAGE%\bin\kibana.bat &
echo Waiting for 30s
ping -n 30 127.0.0.1 >.\out.txt
echo running tests
cd ..\KibanaTest
java -cp ".\jars\KibanaTest.jar:.\jars\selenium-java-3.141.59\*:.\jars\lib\*" org.testng.TestNG testng.xml
cd ..\opendistro-build
