#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import os

class Render:
    def __init__(self, template_file, output_file, meta_variables):
        self.template_file = template_file
        self.output_file = output_file
        self.meta_variables = meta_variables

    def render(self):
        try:
            with open(self.template_file, 'r') as f:
                lines = f.readlines()
        except IOError as e:
            print(f"open file failed, file: {self.template_file}, err: {str(e)}")
            return

        try:
            fw = open(self.output_file, 'w')
        except IOError as e:
            print(f"create file failed, file: {self.output_file}, err: {str(e)}")
            return

        pattern = re.compile(r'{{\s*([a-zA-Z][a-zA-Z0-9_.]*)\s*}}')
        for line in lines:
            matches = pattern.findall(line)
            if matches:
                for match in matches:
                    value = self.meta_variables.get(match)
                    if value is None:
                        print(f"render variable {match} error, no such variable in meta config, please check, exit")
                        fw.close()
                        return
                    line = line.replace(f"{{{{ {match} }}}}", value)
            fw.write(line)

        fw.close()

if __name__ == '__main__':
    datanode_path_prefix = "/opt/ozone/datanode"
    port1 = 9855
    port2 = 19864
    port3 = 9882
    port4 = 9859
    port5 = 9858
    port6 = 9857
    port7 = 9856
    port8 = 9886
    datanode_id_dir = "/tmp/datanodes"
    os.makedirs(datanode_id_dir, exist_ok=True)
    # 0-7, start all 8 datanode instances
    for i in range(0, 8):
        datanode_dir = "{path}{i}".format(path=datanode_path_prefix, i=i)
        datanode_data_dir = os.path.join(datanode_dir, 'data')
        datanode_meta_dir = os.path.join(datanode_dir, 'meta')
        os.makedirs(datanode_meta_dir, exist_ok=True)
        os.makedirs(datanode_data_dir, exist_ok=True)
        port_offset = i * 1000
        meta_variables = {
            'container.ratis.datastream.port': str(port1 + port_offset),
            'datanode.client.port': str(port2 + port_offset),
            'datanode.http_address.port': str(port3 + port_offset),
            'container.ipc.port': str(port4 + port_offset),
            'container.ratis.ipc.port': str(port5 + port_offset),
            'container.ratis.admin.port': str(port6 + port_offset),
            'container.ratis.server.port': str(port7 + port_offset),
            'datanode.dir': datanode_data_dir,
            'datanode.replication.port': str(port8 + port_offset),
            'ozone.metadata.dirs': datanode_meta_dir,
            'ozone.scm.datanode.id': os.path.join(datanode_id_dir, f"datanode{i}.id"),
        }
        target_config_file = "{path}/etc/hadoop/ozone-site.xml".format(path=datanode_dir)
        config_template = "/opt/hadoop/etc/hadoop/ozone-site_dn_template.xml"
        os.makedirs(os.path.dirname(target_config_file), exist_ok=True)
        render = Render(config_template, target_config_file, meta_variables)
        try:
            render.render()
        except Exception as e:
            print(f"render config file failed, err: {str(e)}")
            sys.exit(1)
        print(f"render config file success, file: {target_config_file}")
