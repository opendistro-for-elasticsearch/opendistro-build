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
              ./copy_snapshots_to_release.py $BUILD_NUMBER

"""
import boto3
import os
import sys
import yaml
import hashlib
import requests

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
        if plugin_category != "":
            response = s3.upload_file("downloads/"+plugin,release_bucket_name,rc_folder_path+plugin_category+'/'+plugin)
            print("Upload completed : " + plugin)
        else:
            response = s3.upload_file("downloads/"+plugin,release_bucket_name,rc_folder_path+plugin)
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
            print("failed to create folder")
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
            checksum_file.write(hash_type.hexdigest())
            checksum_file.close()
            print("Plugin checksum : " + plugin_name+".sha512")
        return plugin_name+".sha512"
    except:
        raise


# Download plugin to local
def plugin_download(plugin_full_path,bucket_name):
    try:
        response = s3.download_file(bucket_name,plugin_full_path,"downloads/"+plugin_full_path.split('/')[-1])
        print("download successful")
        return plugin_full_path.split('/')[-1]
    except:
        raise

# Get the last modified plugin with specific name
def get_latest_plugin(plugin_version,plugin_build,plugin_type,bucket_name,folder_path,key_word):
    try:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=folder_path)
        suffix = plugin_type
        key = ""
        for artifact in sorted(response['Contents'], key=lambda x: x['LastModified'], reverse=True):
            key = artifact['Key']
            build_number = "-build-"+plugin_build
            if key_word != "":
                if plugin_version in key and build_number in key and key_word in key:
                    if key.endswith(plugin_type):
                        print("last modified plugin : " + key)
                        break
            else:
                if plugin_version in key and build_number in key:
                    if key.endswith(plugin_type):
                        print("last modified plugin : " + key)
                        break
        return key
    except:
        raise

# Download and upload plugins to S3 based on the manifest.yml
def main():
    try:
        with open('manifest.yml') as manifest:
            source = yaml.safe_load(manifest)
            run_number = sys.argv[1]
            release_candidate_location = source.get('releases').get('url')[5:]
            print("Release candidate location : " + release_candidate_location)
            release_bucket_name = source.get('releases').get('url').split('/')[2]
            print("Release bucket name : " + release_bucket_name)
            release_folder_path = release_candidate_location.replace(release_bucket_name,'')[1:] + "/"
            print("Release folder path : " + release_folder_path)
            rc_folder_path = release_folder_path + "rc-" + str(run_number) + "/"
            print("Release candiate path : " + rc_folder_path)
            if not os.path.exists('downloads'):
                os.makedirs('downloads')
            for plugin in source.get('snapshots'):
                try:
                    print("\n")
                    print("Plugin : " )
                    print(plugin)
                    plugin_git_name = plugin.get('plugin_git')
                    print("Plugin GIT name : " + plugin_git_name)
                    plugin_version = plugin.get('plugin_version')
                    print("Plugin full name : " + plugin_version)
                    plugin_build = plugin.get('plugin_build')
                    if plugin_build != "":
                        print("Plugin Build number : " + plugin_build) 
                    plugin_category = plugin.get('plugin_category')
                    print("Plugin category " + plugin_category )
                    plugin_location = plugin.get('plugin_location')[5:]
                    print("Plugin location : " + plugin_location )
                    bucket_name = plugin.get('plugin_location').split('/')[2]
                    print("Bucket name : " + bucket_name )
                    folder_path = plugin_location.replace(bucket_name,'')[1:] + "/"
                    print("Folder path : " + folder_path)
                    for plugin_type in plugin.get('plugin_type'):
                        print("Plugin type : " + plugin_type)
                        if not plugin.get('plugin_keyword'):
                            latest_plugin = get_latest_plugin(plugin_version,plugin_build,plugin_type,bucket_name,folder_path,"")
                            downloaded_plugin_name = plugin_download(latest_plugin,bucket_name)
                            plugin_checksum = create_sha512(downloaded_plugin_name)
                            status = create_release_folder(release_bucket_name,plugin_category,rc_folder_path)
                            if status == "success":
                                upload_plugin(downloaded_plugin_name,release_bucket_name,plugin_category,rc_folder_path)
                                upload_plugin(plugin_checksum,release_bucket_name,plugin_category,rc_folder_path)
                        else:
                            for key_word in plugin.get('plugin_keyword'):
                                latest_plugin = get_latest_plugin(plugin_version,plugin_build,plugin_type,bucket_name,folder_path,key_word)
                                downloaded_plugin_name = plugin_download(latest_plugin,bucket_name)
                                plugin_checksum = create_sha512(downloaded_plugin_name)
                                status = create_release_folder(release_bucket_name,plugin_category,rc_folder_path)
                                if status == "success":
                                    upload_plugin(downloaded_plugin_name,release_bucket_name,plugin_category,rc_folder_path)
                                    upload_plugin(plugin_checksum,release_bucket_name,plugin_category,rc_folder_path)
                except:
                    print("Plugin move to release folder failed : " + plugin.get('plugin_git'))
                    
            # Parse ES url's for downloading to local and upload to release bucket
            print("Upload ES artifacts to release candidate\n")
            for es in source.get('urls').get('ES'):
                element = es
                url = source.get('urls').get('ES').get(element)
                if url != "":
                    filename = url.split('/')[-1]
                    status_code = download_file(filename,url)
                    if status_code == 200:
                        print("Download completed : " + filename)
                        status = create_release_folder(release_bucket_name,"upstream",rc_folder_path)
                        if status == "success":
                            upload_plugin(filename,release_bucket_name,"upstream",rc_folder_path)

            # Parse Kibana url's for downloading to local and upload to release bucket
            print("Upload Kibana artifacts to release candidate\n")
            for es in source.get('urls').get('KIBANA'):
                element = es
                url = source.get('urls').get('KIBANA').get(element)
                if url != "":
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
