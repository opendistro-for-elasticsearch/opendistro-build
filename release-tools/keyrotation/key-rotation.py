#! /usr/bin/python
"""
Name:          key_rotation.py
Maintainer:    ODFE Infra Team
Language:      python

About:
               Key rotation of the AWS Accesskeys and update the git secrets.

Prerequisites:
               Need python 3.7 or higher
               Use the below command to export the GIT Access token
               - export git_token=$(GIT_token)
               Use the below command to configure AWS credentials
               - aws configure
               sudo yum install python-pip
               sudo pip install boto3
               sudo pip install pynacl

Usage: 
              ./key_rotation.py config.json

"""
import boto3
import json
import os
import requests
import sys
import logging
from base64 import b64encode
from nacl import encoding, public

iam = boto3.resource('iam')
git_base_url = "https://api.github.com"
git_auth_token="token " + str(os.environ.get('git_token'))

# This function encrypts git secret string using public key
def encrypt_git_key(public_key,secret):
    try:
        key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
        sealed_box = public.SealedBox(key)
        encrypted = sealed_box.encrypt(secret.encode("utf-8"))
    except Exception as ex:
        logging.info("Failed to generate public key")
        logging.info(ex)
        print("Failed to generate public key")
    return b64encode(encrypted).decode("utf-8")

# Provides the number of Access keys for an IAM user
def number_of_keys(iam_username):
    try:
        keys = list(iam.User(iam_username).access_keys.all())
    except:
        logging.info("Failed to find number of keys for the " + iam_username)
        print("Failed to find number of keys for the " + iam_username)
    return len(keys)

# Lists the Access keys of an IAM user
def list_keys(iam_username,key_len):
    try:
        res = iam.meta.client.list_access_keys(
            UserName=iam_username
        )
        logging.info(res['AccessKeyMetadata'])
        print(res['AccessKeyMetadata'])
        if key_len == 1:
            dict = { 
                'access_key_id': str(res.get('AccessKeyMetadata')[0].get('AccessKeyId')) , 
                'create_date': res.get('AccessKeyMetadata')[0].get('CreateDate') 
                }
            logging.info(dict)
            print(dict)
        else:
            dict = []
            dict.append(
                {
                'access_key_id': str(res.get('AccessKeyMetadata')[0].get('AccessKeyId')) ,
                'create_date': res.get('AccessKeyMetadata')[0].get('CreateDate') 
                })   
            dict.append(
                {
                'access_key_id': str(res.get('AccessKeyMetadata')[1].get('AccessKeyId')) ,
                'create_date': res.get('AccessKeyMetadata')[1].get('CreateDate')
                })
            logging.info(dict)
            print(dict)
    except:
        logging.info("Failed to list keys for IAM user : " + iam_username)
        print("Failed to list keys for IAM user : " + iam_username)
    return dict

# Delete the Access key for an IAM user
def delete_key(iam_username,access_key):
    try:
        response = iam.meta.client.delete_access_key( 
            UserName = iam_username,
            AccessKeyId=access_key
            )
        logging.info(response)
        print(response)
    except:
        logging.info("Failed to delete key : " + access_key + " For IAM user : " + iam_username)
        print("Failed to delete key : " + access_key + " For IAM user : " + iam_username)

# Deactiviate the Access key for an IAM user
def deactivate_key(iam_username,access_key):
    try:
        response = iam.meta.client.update_access_key(
            AccessKeyId=access_key,
            Status='Inactive',
            UserName=iam_username
            )
        logging.info("Response for the Access key deactiviation : " + str(response))
        print("Response for the Access key deactiviation : " + str(response))
    except:
        logging.info("Failed to deactivate key : " + access_key + " For IAM user : " + iam_username)
        print("Failed to deactivate key : " + access_key + " For IAM user : " + iam_username)

# Get public key and key ID for Encrypting GIT secret
def get_public_key(git_repo,git_owner):
    try:
        url = git_base_url + "/repos/" + git_owner + "/" + git_repo + "/actions/secrets/public-key"
        logging.info("API URL for the public key : " + url)
        print("API URL for the public key : " + url)
        headers = {
        "accept": "application/vnd.github.v3+json",
        "authorization": git_auth_token
        }
        response=requests.get(url, headers=headers)
        logging.info("Response for the public key request : ")
        logging.info(response)
        print("Response code : " + str(response))
        logging.info("Public key for Repo : " + git_repo + " has been generated")
        print("Public key for Repo : " + git_repo + " has been generated")
    except:
        logging.info("Failed to get public key for GIT owner : " + git_owner)
        print("Failed to get public key for GIT owner : " + git_owner)
    return response.json()


# Update GIT secrets with the new AWS Access key ID and Access key Secret
def update_git_secret(git_repo,git_owner,git_secret_name,secret):
    try:
        public_key = get_public_key(git_repo,git_owner)
        encrypted_key=encrypt_git_key(public_key.get('key'),secret)
        body = {"encrypted_value": str(encrypted_key), "key_id": str(public_key.get('key_id'))}
        data = json.dumps(body)
        url = git_base_url + "/repos/" + git_owner + "/" + git_repo + "/actions/secrets/" + git_secret_name
        logging.info("GIT Secret to be updated : " + git_secret_name)
        logging.info("URL for updating GIT Secret : " + url)
        print("URL for updating GIT Secret : " + url)
        headers = {
        "accept": "application/vnd.github.v3+json",
        "authorization": git_auth_token
        }
        response_update_secret=requests.put(url,headers=headers,data=data)
        logging.info("Response code for the GIT Secret update : " + str(response_update_secret.status_code))
        print("Response code for the GIT Secret update : " + str(response_update_secret.status_code))
    except:
        logging.info("Failed to update GIT secret : " + git_secret)
        print("Failed to update GIT secret : " + git_secret)
    

# Create an Access key for an IAM user
def create_key(iam_username,git_repo,git_owner,git_access_id,git_access_secret):
    try:
        key_pair = iam.User(iam_username).create_access_key_pair()
        logging.info("New Access ID created : " + key_pair.id)
        print("New Access ID created : " + key_pair.id)
        update_git_secret(git_repo,git_owner,git_access_id,key_pair.id)
        update_git_secret(git_repo,git_owner,git_access_secret,key_pair.secret)
    except:
        logging.info("Failed to create key for IAM user : " + iam_username)
        print("Failed to create key for IAM user : " + iam_username)


def main():
    try:
        logging.basicConfig(filename='keyrotate.log',level=logging.INFO)
        if len(sys.argv) < 2:
            print("Please provide the config file as an argument")
            exit()
        with open(sys.argv[1]) as source:
            source_data = json.loads(source.read())
            git_owner = source_data.get("key-rotate").get("git-owner")
            logging.info("The GIT owner defined in the config is : " + git_owner)
            print("GIT owner : " + git_owner)
            repos = source_data.get("key-rotate").get("odfe-repos")
            for repo in repos:
                try:
                    print(repo)
                    logging.info("Key rotation is in progress for Repo : " + repo.get("repo"))
                    logging.info("Repo configuration : ")
                    logging.info(repo)
                    print("Repo name: " + repo.get("repo"))
                    git_repo = repo.get("repo")
                    logging.info("IAM username: " + repo.get("aws_iam_user"))
                    print("IAM username: " + repo.get("aws_iam_user"))
                    num_of_keys = number_of_keys(repo.get("aws_iam_user"))
                    logging.info("Number of secret access keys for " + repo.get("aws_iam_user") + " : " + str(num_of_keys))
                    print("Number of secret access keys for " + repo.get("aws_iam_user") + " : " + str(num_of_keys))
                    if num_of_keys == 0:
                        logging.info("Number of secret access keys are 0")
                        print("Number of secret access keys are 0")
                        create_key(repo.get("aws_iam_user"),git_repo,git_owner,repo.get("git_access_key_id"),repo.get("git_access_secret_key"))
                    elif num_of_keys == 1:
                        logging.info("Number of secret access keys are 1")
                        print("Number of secret access keys are 1")
                        dict = list_keys(repo.get("aws_iam_user"), 1)
                        logging.info(dict)
                        deactivate_key(repo.get("aws_iam_user"),dict.get('access_key_id'))
                        logging.info("Access key has been deactivated : " + dict.get('access_key_id'))
                        print("Access key has been deactivated : " + dict.get('access_key_id'))
                        create_key(repo.get("aws_iam_user"),git_repo,git_owner,repo.get("git_access_key_id"),repo.get("git_access_secret_key"))
                    else:
                        logging.info("Number of secret access keys are 2")
                        print("Number of secret access keys are 2")
                        dict = list_keys(repo.get("aws_iam_user"), 2)
                        dict_values = list(dict)
                        logging.info(dict_values)
                        logging.info("Delete Access key : " + dict_values[0].get('access_key_id'))
                        print("Delete Access key : " + dict_values[0].get('access_key_id'))
                        delete_key(repo.get("aws_iam_user"),dict_values[0].get('access_key_id'))
                        deactivate_key(repo.get("aws_iam_user"),dict_values[1].get('access_key_id'))
                        create_key(repo.get("aws_iam_user"),git_repo,git_owner,repo.get("git_access_key_id"),repo.get("git_access_secret_key"))
                    logging.info("Keyrotation completed for Repo : " + git_repo)
                    print("Keyrotation completed for Repo : " + git_repo)
                except:
                    logging.info("Failed to rotate keys for the Repo : " + git_repo)
                    print("Failed to rotate keys for the Repo : " + git_repo)
    except Exception as ex:
        logging.info(ex)
        print(ex)
                 
if __name__ == "__main__":
    main()
