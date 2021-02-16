#! /usr/bin/python
"""
About:
               Copy the Staging Artifiacts from Snapshots to Release Candidate folder 

Prerequisites:
               Need python 3.7 or higher
               AWS credentials for S3
               sudo yum install python-pip
               sudo pip install boto3
               sudo pip install pyyaml

Usage: 
              ./staging-copy-artifacts.py $BUILD_NUMBER

"""
import boto3
import os
import sys
import yaml
import hashlib
import requests
import re

s3 = boto3.client('s3')


# Download file to the local
def download_file(filename,url):
    try:
        response = requests.get(url)
        with open("downloads/" + filename, 'wb') as file_name:
            file_name.write(response.content)
            return response.status_code
    except:
        raise


# Upload local file to the release folder
def upload_plugin(plugin,release_bucket_name,plugin_category,rc_folder_path):
    try:
        plg_new = ""
        if "x86_64" in plugin:
            plg_new = plugin.replace("x86_64","x64")
            os.rename("downloads/"+plugin, "downloads/"+ plg_new)
        if "aarch64" in plugin:
            plg_new = plugin.replace("aarch64","arm64")
            os.rename("downloads/"+plugin, "downloads/"+ plg_new)
        if plg_new:
            s3.upload_file("downloads/"+plg_new,release_bucket_name,rc_folder_path+plugin_category+'/'+plg_new)
        else:
            s3.upload_file("downloads/"+plugin,release_bucket_name,rc_folder_path+plugin_category+'/'+plugin)
        print("Upload completed : " + plugin)
    except:
        raise

# Create release folder in S3
def create_release_folder(release_bucket_name,plugin_category,rc_folder_path):
    try:
        response = s3.put_object(Bucket=release_bucket_name, Key=(rc_folder_path + plugin_category + '/'))
        print(response)
        print("Release folder created : " + rc_folder_path + plugin_category + '/')
        if response.get('ResponseMetadata').get('HTTPStatusCode') != 200:
            print("Failed to create folder")
            raise
        return "success"
    except:
        raise

# Create checksum for the downloaded plugin
def create_sha512(plugin_name):
    try:
        hash_type = hashlib.sha512()
        with open("downloads/"+plugin_name, 'rb') as file_name:
            buf = file_name.read()
            hash_type.update(buf)
            checksum_file = open("downloads/"+plugin_name+".sha512", "w")
            checksum_file.write(hash_type.hexdigest() + "  " + plugin_name)
            checksum_file.close()
            print("Plugin checksum : " + plugin_name+".sha512")
        return plugin_name+".sha512"
    except:
        raise


# Download plugin to local
def plugin_download(plugin_full_path,bucket_name):
    try:
        response = s3.download_file(bucket_name,plugin_full_path,"downloads/"+plugin_full_path.split('/')[-1])
        print("Download successful")
        return plugin_full_path.split('/')[-1]
    except:
        raise

# Get the last modified plugin with specific name
def get_latest_plugin(plugin_name,plugin_version,plugin_build,bucket_name,folder_path,key_word):
    try:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=folder_path)
        platform = str(key_word).split('_')[0]
        arch = str(key_word).split('_')[1]
        plugin_type = str(key_word).split('_')[2]
        print("Plugin version " + plugin_version)
        print("Platform " + platform)
        print("Arch " + arch)
        print("plugin_type " + plugin_type)
        suffix = plugin_type
        key = ""
        temp = 0
        plg = ""
        for artifact in sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True):
            key = artifact['Key']
            if plugin_build is None:
                build_number = "-build-"
            else:
                build_number = "-build-"+str(plugin_build)
            if platform == "noplatform":
                platform = ""
            if arch == "noarch":
                arch = ""
            if plugin_name in key and plugin_version in key and build_number in key and platform in key and arch in key:
                if key.endswith(plugin_type):
                    print(key)
                    tmp=key.split('-build-')[1]
                    bld_no=re.split("[-_.]",tmp)[0]
                    print("build number")
                    print(bld_no)
                    if bld_no.isdigit():
                        if float(bld_no) > float(temp):
                            plg = key
                            temp = bld_no
        print("Plugin selected " + plg)
        return plg
    except:
        raise

# Download and upload plugins to S3 based on the manifest.yml
def main():
    try:
        with open('manifest.yml') as manifest:
            source = yaml.safe_load(manifest)
            run_number = sys.argv[1]
            odfe_version = source.get('versions').get('ODFE').get('current')
            release_candidate_location = source.get('urls').get('ODFE').get('releases')[5:]
            print("Release candidate location : " + release_candidate_location )
            release_bucket_name  = release_candidate_location.split('/')[0]
            print("Release bucket name : " + release_bucket_name)
            release_folder_path = release_candidate_location.replace(release_bucket_name,'')[1:]
            print("Release folder path : " + release_folder_path)
            rc_folder_path = release_folder_path + odfe_version + "/" + "rc-build-" + str(run_number) + "/"
            print("Release candiate path : " + rc_folder_path)
            if not os.path.exists('downloads'):
                os.makedirs('downloads')
            for plugin in source.get('plugins'):
                try:
                    if plugin.get('release_candidate'):
                        print("\n")
                        plugin_name = plugin.get('plugin_basename')
                        print("Plugin name : " + plugin_name)
                        plugin_version = plugin.get('plugin_version')
                        print("Plugin version : " + plugin_version)
                        plugin_build = plugin.get('plugin_build')
                        if plugin_build is not None:
                            print("Plugin Build number : " + str(plugin_build)) 
                        plugin_category = plugin.get('plugin_category')
                        print("Plugin category " + plugin_category )
                        plg_loc = ""
                        for spec in plugin.get('plugin_spec'):
                            print(spec)
                            match_found = False
                            for plugin_loc in plugin.get('plugin_location_staging'):
                                for key,value in plugin_loc.items():
                                   if key == spec:
                                        plg_loc = plugin_loc[key]
                                        print(plg_loc)
                                        match_found = True
                                        break
                            if not match_found:
                                for key,value in plugin_loc.items():
                                    if key == "default":
                                        print("The default location will be used for staging")
                                        plg_loc = plugin_loc["default"]
                                        print(plg_loc)
                            plugin_location = str(plg_loc)[5:]
                            print("Plugin location : " + plugin_location )
                            bucket_name = plugin_location.split('/')[0]
                            print("Bucket name : " + bucket_name )
                            folder_path = plugin_location.replace(bucket_name,'')[1:]
                            print("Folder path : " + folder_path)
                            latest_plugin = get_latest_plugin(plugin_name,plugin_version,plugin_build,bucket_name,folder_path,str(spec))
                            downloaded_plugin_name = plugin_download(latest_plugin,bucket_name)
                            plugin_checksum = create_sha512(downloaded_plugin_name)
                            status = create_release_folder(release_bucket_name,plugin_category,rc_folder_path)
                            if status == "success":
                                upload_plugin(downloaded_plugin_name,release_bucket_name,plugin_category,rc_folder_path)
                                upload_plugin(plugin_checksum,release_bucket_name,plugin_category,rc_folder_path)
                except Exception as ex:
                    print(ex)
                    
            # Parse ES url's for downloading to local and upload to release bucket
            print("Upload ES artifacts to release candidate\n")
            for es in source.get('urls').get('ES'):
                url = source.get('urls').get('ES').get(es)
                if url is not None:
                    print("URl " + url)
                    filename = url.split('/')[-1]
                    status_code = download_file(filename,url)
                    if status_code == 200:
                        print("Download completed : " + filename)
                        status = create_release_folder(release_bucket_name,"upstream",rc_folder_path)
                        if status == "success":
                            upload_plugin(filename,release_bucket_name,"upstream",rc_folder_path)

            # Parse Kibana url's for downloading to local and upload to release bucket
            print("Upload Kibana artifacts to release candidate\n")
            for kb in source.get('urls').get('KIBANA'):
                url = source.get('urls').get('KIBANA').get(kb)
                if url is not None:
                    print("URl " + url)
                    filename = url.split('/')[-1]
                    status_code = download_file(filename,url)
                    if status_code == 200:
                        print("Download completed : " + filename)
                        status = create_release_folder(release_bucket_name,"upstream",rc_folder_path)
                        if status == "success":
                            upload_plugin(filename,release_bucket_name,"upstream",rc_folder_path)

    except Exception as ex:
        print(ex)
                 
if __name__ == "__main__":
    main()
