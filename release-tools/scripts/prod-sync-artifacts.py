#! /usr/bin/python
"""
About:
               Copy the Staging Artifiacts from Release Candidate folder to Production

Prerequisites:
               Need python 3.7 or higher
               AWS credentials for S3
               sudo yum install python-pip
               sudo pip install boto3
               sudo pip install pyyaml

Usage: 
              ./prod-sync-artifacts.py (Validation)
              ./prod-sync-artifacts.py prod-sync (Sync Staging to Production)

"""
import boto3
import os
import sys
import yaml
import hashlib
import requests
import re
from tabulate import tabulate

s3 = boto3.client('s3')

upload_list = []

# Upload artifact to Production
def upload_artifact(rc_bucket,plugin_val,bucket_name,folder_path):
    try:
        copy_source = {
        'Bucket': rc_bucket,
        'Key': plugin_val}
        print("Upload plugin : " + plugin_val)
        artifact_name = plugin_val.split('/')[-1]
        print("Artifact initial name : " + artifact_name) 
        if "-build-" in plugin_val: 
            artifact_name = re.sub('-build-[0-9]*','',artifact_name)
        print("##### Upload in progress #####")
        print("Plugin name : " + plugin_val)
        print("Artifact name : " + artifact_name)
        print("Source bucket :" + rc_bucket)
        print("Destination path : " + folder_path)
        print("Destination bucket name " + bucket_name)
        response = s3.copy_object(CopySource=copy_source, Bucket=bucket_name, 
                Key=folder_path + artifact_name, MetadataDirective="REPLACE")
        if response.get('ResponseMetadata').get('HTTPStatusCode') == 200:
            upload_list.append([artifact_name,"Upload Successful"])
        else:
            upload_list.append([artifact_name,"Upload Failed"])
    except:
        raise

# Check if the ODFE artifact is available
def check_odfe(rc_bucket,odfe_path,artifact_type,odfe_name):
    try:
        response = s3.list_objects_v2(Bucket=rc_bucket, Prefix=odfe_path)
        plugin = []
        for artifact in sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True):
            key = artifact['Key']
            if (odfe_name in key):
                if (key.endswith(artifact_type) or key.endswith(artifact_type + ".sha512")):
                    plugin.append(key)
        return plugin
    except:
        raise


# Check if the Plugin is available
def check_plugin(rc_bucket,plugin_fullpath,plugin_name,plugin_ver,plugin_build,key_word):
    try:
        bld_num = "-build-" + str(plugin_build)
        pltfrm = str(key_word).split('_')[0]
        arch = str(key_word).split('_')[1]
        plugin_type = str(key_word).split('_')[2]
        response = s3.list_objects_v2(Bucket=rc_bucket, Prefix=plugin_fullpath)
        plugin = ""
        for artifact in sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True):
            key = artifact['Key']
            if pltfrm == "noplatform":
                pltfrm = ""
            if arch == "noarch":
                arch = ""
            if (plugin_name in key and plugin_ver in key and 
                    bld_num in key and pltfrm in key and 
                    arch in key):
                if key.endswith(plugin_type):
                    plugin = key
                    break
        return plugin
    except:
        raise

# Check the Production Path
def check_prod_location(bucket_name,folder_path):
    try:
        plugin_folder = folder_path.split('/')[-2]
        prefix = folder_path.replace(plugin_folder+"/",'')
        response = s3.list_objects_v2(Bucket=bucket_name, Delimiter='/', Prefix=prefix)
        if response.get('CommonPrefixes'):
            for plg_path in response.get('CommonPrefixes'):
                if folder_path == plg_path.get('Prefix'):
                    return "Found"
        return "Not Found"
    except:
        raise


# Validate Production Paths and Artifacts and upload to Production Bucket
def main():
    try:
        with open('manifest.yml') as manifest:
            source = yaml.safe_load(manifest)
            run_number = source.get('urls').get('ODFE').get('releases_final_build')
            if run_number is None:
                print("Please provide Release final build number")
                raise
            if len(sys.argv) > 1:
                action = sys.argv[1]
            else:
                action = ""
            odfe_version = source.get('versions').get('ODFE').get('current')
            rc_location = source.get('urls').get('ODFE').get('releases')[5:]
            print("Release candidate location : " + rc_location )
            rc_bucket  = rc_location.split('/')[0]
            print("Release bucket name : " + rc_bucket)
            rc_path = rc_location.replace(rc_bucket,'')[1:]
            print("Release folder path : " + rc_path)
            rc_plugin_path = rc_path + odfe_version + "/" + "rc-build-" + str(run_number) + "/"
            print("Release candiate path : " + rc_plugin_path)
            prod_location = source.get('urls').get('ODFE').get('prod')[5:]
            prod_bucket = prod_location.split('/')[0]
            artifact_status = []
            folder_status = []
            for plugin in source.get('plugins'):
                try:
                    if plugin.get('release_candidate'):
                        print("\n")
                        plugin_name = plugin.get('plugin_basename')
                        print("Plugin name : " + plugin_name)
                        plugin_version = plugin.get('plugin_version')
                        print("Plugin version : " + plugin_version)
                        plugin_category = plugin.get('plugin_category')
                        print("Plugin category : " + plugin_category)
                        plugin_build = plugin.get('plugin_build')
                        for spec in plugin.get('plugin_spec'):
                            print(spec)
                            match_found = False
                            for plugin_loc in plugin.get('plugin_location_prod'):
                                for key,value in plugin_loc.items():
                                   if key == spec:
                                        plg_loc = plugin_loc[key]
                                        print(plg_loc)
                                        match_found = True
                                        break
                            if not match_found:
                                for key,value in plugin_loc.items():
                                    if key == "default":
                                        print("The default location will be used for Prod")
                                        plg_loc = plugin_loc["default"]
                                        print(plg_loc)
                            plg_prd_loc = str(plg_loc)[5:]
                            print("Plugin Prod location : " + plg_prd_loc )
                            plg_prd_bucket = plg_prd_loc.split('/')[0]
                            print("Prod Bucket name : " + plg_prd_bucket )
                            plg_prd_path = plg_prd_loc.replace(plg_prd_bucket,'')[1:]
                            dest_state = check_prod_location(plg_prd_bucket,plg_prd_path)
                            print("Prod Folder path : " + plg_prd_path + "\t Status : " + dest_state)
                            folder_status.append([plg_prd_path,dest_state])
                            plugin_fullpath = rc_plugin_path + plugin_category + "/"
                            if plugin_build is not None:
                                plugin_val = check_plugin(rc_bucket,plugin_fullpath,
                                    plugin_name,plugin_version,plugin_build,spec)
                                if plugin_val:
                                    print("Plugin : " + plugin_val.split('/')[-1] + "\t Status : Found")
                                    plg_state = "Found"
                                    plg_name = plugin_val.split('/')[-1]
                                    final_name = re.sub('-build-[0-9]*','',plg_name)
                                    print("Plugin final name :  " + final_name)
                                    if action == "prod-sync":
                                        upload_artifact(rc_bucket,plugin_val,plg_prd_bucket,plg_prd_path)
                                else:
                                    plg_name = "NA"
                                    final_name = plugin_name
                                    plg_state = "Not Found"
                                    print("Plugin : " + plugin_name + "-" + plugin_version + "\t Status : Not Found")
                            else:
                                print("Build number is missing for plugin : " + plugin_name)
                                raise
                            artifact_status.append([final_name,plg_name,plg_state])
                except Exception as ex:
                    print(ex)
            print("\n\n\n\n")
            odfe_es = [["x64.tar.gz","tarball/opendistro-elasticsearch/"],
                       ["arm64.tar.gz","tarball/opendistro-elasticsearch/"],
                       ["exe","downloads/odfe-windows/odfe-executables/"],
                       ["zip","downloads/odfe-windows/ode-windows-zip/"],
                       ["x64.rpm","downloads/rpms/opendistroforelasticsearch/"],
                       ["arm64.rpm","downloads/rpms/opendistroforelasticsearch/"],
                       ["x64.deb","downloads/debs/opendistroforelasticsearch/"],
                       ["arm64.deb","downloads/debs/opendistroforelasticsearch/"]]
            odfe_kb = [["x64.tar.gz","tarball/opendistroforelasticsearch-kibana/"],
                       ["arm64.tar.gz","tarball/opendistroforelasticsearch-kibana/"],
                       ["exe","downloads/odfe-windows/odfe-executables/"],
                       ["zip","downloads/odfe-windows/ode-windows-zip/"],
                       ["x64.rpm","downloads/rpms/opendistroforelasticsearch-kibana/"],
                       ["arm64.rpm","downloads/rpms/opendistroforelasticsearch-kibana/"],
                       ["x64.deb","downloads/rpms/opendistroforelasticsearch-kibana/"],
                       ["arm64.deb","downloads/rpms/opendistroforelasticsearch-kibana/"]]
            for key,value in odfe_es:
                dest_state = check_prod_location(prod_bucket,value)
                folder_status.append([value,dest_state])
                odfe_es_val = check_odfe(rc_bucket,
                        rc_path + odfe_version + "/" + "odfe/",
                        key,"opendistroforelasticsearch-"+odfe_version)
                print("Prod Folder path : " + value + "\t Status : " + dest_state)
                if odfe_es_val:
                    for es in odfe_es_val:
                        odfe_es = es.split('/')[-1]
                        print("ODFE artifact : " + odfe_es)
                        if odfe_es:
                            artifact_status.append(["opendistroforelasticsearch" + "-" + key,
                                                   odfe_es,"Found"])
                            print("Artifact : " + odfe_es + "\t Status : Found")
                            if action == "prod-sync":
                                upload_artifact(rc_bucket,es,prod_bucket,value)
                else:
                    artifact_status.append(["opendistroforelasticsearch",key,"Not Found"])
                    print("Artifact : " + odfe_es + "\t Status : Not Found")
            for key,value in odfe_kb:
                dest_state = check_prod_location(prod_bucket,value)
                folder_status.append([value,dest_state])
                odfe_kb_val = check_odfe(rc_bucket,
                        rc_path + odfe_version + "/" + "odfe/",
                        key,"opendistroforelasticsearch-kibana-" + odfe_version)
                if odfe_kb_val:
                    for kb in odfe_kb_val:
                        odfe_kb = kb.split('/')[-1]
                        print("ODFE artifact : " + odfe_kb)
                        if odfe_kb:
                            artifact_status.append(["opendistroforelasticsearch-kibana" + "-" + key,
                                                   odfe_kb,"Found"])
                            print("Artifact : " + odfe_kb + "\t Status : Found")
                            if action == "prod-sync":
                                upload_artifact(rc_bucket,kb,prod_bucket,value)
                else:
                    artifact_status.append(["opendistroforelasticsearch-kibana",key,"Not Found"])
                    print("Artifact : " + odfe_es + "\t Status : Not Found")
                print("Prod Folder path : " + value + "\t Status : " + dest_state)
            print("\n\n\n\n")
            print(tabulate(folder_status,headers = ["Folder path","State"], tablefmt="github"))
            print("\n\n\n\n")
            print(tabulate(artifact_status,headers = ["Plugin Name","Full Name","State"], tablefmt="github"))
            if action == "prod-sync":
                print("\n\n\n\n")
                print(tabulate(upload_list,headers = ["Artifact name","State"], tablefmt="github"))
    except Exception as ex:
        print(ex)
        exit(1)
                 
if __name__ == "__main__":
    main()
