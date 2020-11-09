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
              ./key_rotation.py

"""
import boto3
import json
import os
import requests
from base64 import b64encode
from nacl import encoding, public

iam = boto3.resource('iam')

def encrypt_git_key(public_key,git_secret):
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(git_secret.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")

def get_json_data(data):
    tmp_data=json.dumps(data)
    json_data=json.loads(tmp_data)
    return json_data

def number_of_keys(keyname):
    keys = list(iam.User(keyname).access_keys.all())
    return len(keys)

def list_keys(iam_username,key_len):
    res = iam.meta.client.list_access_keys(UserName=iam_username)
    print(res['AccessKeyMetadata'])
    if key_len == 1:
        dict = { 
                'access_key_id': str(res.get('AccessKeyMetadata')[0].get('AccessKeyId')) , 
                'create_date': res.get('AccessKeyMetadata')[0].get('CreateDate') 
               }
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
        print(dict)
    return dict



def create_key(iam_username):
    key_pair = iam.User(iam_username).create_access_key_pair()
    print("New Access ID created : " + key_pair.id)


def delete_key(iam_username,access_key):
    response = iam.meta.client.delete_access_key( 
        UserName = iam_username,
        AccessKeyId='string'
    )


def deactivate_key(iam_username,access_key):
    response = iam.meta.client.update_access_key(AccessKeyId=access_key,Status='Inactive',UserName=iam_username)
    print("Response for the Access key deactiviation : " + str(response))


#def update_git_secret():



def main():
    with open('config.json') as source:
        source_data = json.loads(source.read())
#        print(source_data)
        git_owner = source_data.get("key-rotate").get("git-owner")
        print(git_owner)
        repos = source_data.get("key-rotate").get("odfe-repos")
        for repo_val in repos:
             print(repo_val)
             print("Repo name: " + repo_val.get("repo"))
             print("Access IAM user name: " + repo_val.get("aws_iam_user_name"))
             num_of_keys = number_of_keys(repo_val.get("aws_iam_user_name"))
             print("Number of secret access keys for " + repo_val.get("aws_iam_user_name") + " : " + str(num_of_keys))
             if num_of_keys == 0:
                 print("Number of secret access keys are 0")
                 create_key(repo_val.get("aws_iam_user_name"))
             elif num_of_keys == 1:
                 print("Number of secret access keys are 1")
                 dict = list_keys(repo_val.get("aws_iam_user_name"), 1)
                 deactivate_key(repo_val.get("aws_iam_user_name"),dict.get('access_key_id'))
                 print("Access key has been deactivated : " + dict.get('access_key_id'))
                 create_key(repo_val.get("aws_iam_user_name"))
             else:
                 print("Number of secret access keys are 2")
                 dict = list_keys(repo_val.get("aws_iam_user_name"), 2)
                 dict_values = list(dict)
                 print("########################################")
                 print(dict_values[0].get('access_key_id'))





if __name__ == "__main__":
    main()
