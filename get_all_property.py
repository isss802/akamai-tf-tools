#!/usr/bin/env python3

import json
import pprint
import subprocess
import configparser
import re
import os

config_ini_path = '/workdir/mount/config.ini'
in_contract = None
ex_contract = None
in_group = None
ex_group = None
in_property = None
ex_property = None
exec_groupfilter=False
if os.path.exists(config_ini_path):
    config_ini = configparser.ConfigParser()
    config_ini.read(config_ini_path, encoding='utf-8')
    config_default = config_ini['default']

    if config_default.get('include_contract') is not None and config_default.get('include_contract') != '':
        in_contract = re.compile(config_default.get('include_contract'))
    if config_default.get('exclude_contract') is not None and config_default.get('exclude_contract') != '':
        ex_contract = re.compile(config_default.get('exclude_contract'))

    if config_default.get('include_group') is not None and config_default.get('include_group') != '':
        in_group = re.compile(config_default.get('include_group'))
        exec_groupfilter=True
    if config_default.get('exclude_group') is not None and config_default.get('exclude_group') != '':
        ex_group = re.compile(config_default.get('exclude_group'))
        exec_groupfilter=True

    if config_default.get('include_property') is not None and config_default.get('include_property') != '':
        in_property = re.compile(config_default.get('include_property'))
    if config_default.get('exclude_property') is not None and config_default.get('exclude_property') != '':
        ex_property = re.compile(config_default.get('exclude_property'))

lgret = json.loads(subprocess.check_output( ['akamai', 'pm', 'lg', '-f' ,'json','-s', 'default'] ))

for v in lgret:
    cid = v['contractIds'][0]
    gid = v['groupId']
    if in_contract is not None and in_contract.match(cid) is None:
        #print(">>>A:exclude contract: %s"%(cid))
        continue
    if ex_contract is not None and ex_contract.match(cid) is not None:
        #print(">>>B:exclude contract: %s"%(cid))
        continue
    if in_group is not None and in_group.match(gid) is None:
        #print(">>>E:exclude group: %s"%(gid))
        continue
    if ex_group is not None and ex_group.match(gid) is not None:
        #print(">>>F:exclude group: %s"%(gid))
        continue
    lgret = json.loads(subprocess.check_output( ['akamai', 'pm', 'lpr', '-c', cid, '-g', gid, '-f' ,'json','-s', 'default'] ))
    for vv in lgret:
        ver = 0
        if vv['productionVersion'] is not None and ver < vv['productionVersion']:
            ver = vv['productionVersion']
        if vv['stagingVersion'] is not None and ver < vv['stagingVersion']:
            ver = vv['stagingVersion']
        if ver == 0:
            ver = vv['latestVersion']
        pname = vv['propertyName']
        if in_property is not None and in_property.match(pname) is None:
            #print(">>>A:exclude property: %s"%(pname))
            continue
        if ex_property is not None and ex_property.match(pname) is not None:
            #print(">>>B:exclude property: %s"%(pname))
            continue

        print(">>>contract: %s group: %s property: %s version( stg: %s prod: %s latest: %s get: %s )"%(cid,gid,pname,vv['stagingVersion'],vv['productionVersion'],vv['latestVersion'],ver))
        subprocess.call(['./get_property.sh', pname, str(ver)])
    #pprint.pprint (lgret)
    #break