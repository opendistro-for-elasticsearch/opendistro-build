set PACKAGE=opendistroforelasticsearch-kibana
cd .\kibana\bin\
::dir
FOR /F "tokens=*" %%g IN ('python .\version-info --od') do SET OD_VERSION=%%g
::echo %OD_VERSION%
set S3_PACKAGE=odfe-%OD_VERSION%-kibana

cd ..\..
::echo downloading zip from S3
::aws s3 cp s3://artifacts.opendistroforelasticsearch.amazon.com/downloads/odfe-windows/ode-windows-zip/%S3_PACKAGE%.zip .\
::echo complete
::dir
echo unzipping %S3_PACKAGE%.zip
unzip .\%S3_PACKAGE%.zip
dir
