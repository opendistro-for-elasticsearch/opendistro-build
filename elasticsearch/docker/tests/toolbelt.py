# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# Description:
# Helper functions.

from subprocess import run, PIPE
import os


def exec_privilege_escalated_command(exec_string, *bindmounts):
    """Function to simulate sudo <command> by bind-mounting affected paths
       through docker.
       bindmounts is a list of `-v` style docker args
       e.g. `/home/user/elasticsearch-docker/tests/datadir1:/datadir1`
    """
    bind_mount_cli_args = []
    for bindarg in bindmounts:
        bind_mount_cli_args.append('-v')
        bind_mount_cli_args.append(bindarg)

    print("running priveleged command: ")
    print(''.join(['docker', 'run', '--rm']))
    print(bind_mount_cli_args)
    print(''.join(['alpine', '/bin/sh', '-c', exec_string]))

    proc = run(
        ['docker', 'run', '--rm'] +
        bind_mount_cli_args +
        ['alpine', '/bin/sh', '-c', exec_string],
        stdout=PIPE)
    return proc


def create_empty_dir(path, uid, gid):
    parent_dir = os.path.dirname(os.path.abspath(path))
    base_newdir = os.path.basename(os.path.normpath(path))

    print("the bind mount command: " +
          'mkdir /mount/{0} && chown {1}:{2} /mount/{0} && chmod 0770 /mount/{0}'.format(base_newdir, uid, gid))
    proc = exec_privilege_escalated_command(
        'mkdir /mount/{0} && chown {1}:{2} /mount/{0} && chmod 0770 /mount/{0}'.format(base_newdir, uid, gid),
        parent_dir + ":" + "/mount"
    )

    if proc.returncode != 0:
        print("Unable to mkdir: {}".format(path))

    return proc


def delete_dir(path):
    parent_dir = os.path.dirname(os.path.abspath(path))
    basedir_parent = os.path.basename(os.path.normpath(parent_dir))
    basedir = os.path.basename(os.path.normpath(path))

    proc = exec_privilege_escalated_command(
        'cd /mount/{0} && rm -rf {1}'.format(basedir_parent, basedir),
        parent_dir + ":" + "/mount/{}".format(basedir_parent)
    )

    if proc.returncode != 0:
        print("Unable to delete: {}".format(path))

    return proc


def recursive_chown(path, uid, gid):
    parent_dir = os.path.dirname(os.path.abspath(path))
    basedir_parent = os.path.basename(os.path.normpath(parent_dir))
    basedir = os.path.basename(os.path.normpath(path))

    proc = exec_privilege_escalated_command(
        'cd /mount/{0} && chown -R {1}:{2} {3} '.format(basedir_parent, uid, gid, basedir),
        parent_dir + ":" + "/mount/{}".format(basedir_parent)
    )

    if proc.returncode != 0:
        print("Unable to delete: {}".format(path))

    return proc
