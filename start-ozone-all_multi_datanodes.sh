#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ozone scm --init &> /opt/hadoop/log/scm_init.log
ozone scm &> /opt/hadoop/log/scm.log &

#wait for scm startup
export WAITFOR=localhost:9876

python3 /opt/hadoop/render-site.py
python3 render-site.py
for i in {0..7}; do
    datanode_dir=/opt/ozone/datanode$i
    mkdir -p $datanode_dir/log $datanode_dir/meta $datanode_dir/data
    sudo chown -R hadoop.hadoop $datanode_dir/meta $datanode_dir/data
    CUSTOMIZED_CONFIG_DIR=$datanode_dir/etc/hadoop OZONE_PID_DIR=$datanode_dir sh -x $datanode_dir/libexec/entrypoint.sh $datanode_dir/bin/ozone datanode &> $datanode_dir/log/datanode.log &
done

/opt/hadoop/libexec/entrypoint.sh ozone om --init &> /opt/hadoop/log/om_init.log
/opt/hadoop/libexec/entrypoint.sh ozone om &> /opt/hadoop/log/om.log &

sleep 15
/opt/hadoop/libexec/entrypoint.sh ozone recon &> /opt/hadoop/log/recon.log &
/opt/hadoop/libexec/entrypoint.sh ozone s3g &> /opt/hadoop/log/s3g.log
