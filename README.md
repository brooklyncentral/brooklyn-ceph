# Ceph

[Ceph](http://ceph.com/) is a unified, distributed storage system which implements object storage on a single distributed computer cluster, and provides 
interfaces for object-, block- and file-level storage. Ceph aims primarily for completely distributed operation without a single point of failure, scalable to the exabyte level, 
and freely available. Ceph replicates data and makes it fault-tolerant, using commodity hardware and requiring no specific hardware support. As a result of its design, the system 
is both self-healing and self-managing, aiming to minimize administration time and other costs.

## Basic Config

The Ceph blueprint is set up to provide a basic scalable HA cluster by default. For information on the Ceph specific technical terms such as OSD, please consult the [Ceph glossary](http://docs.ceph.com/docs/jewel/glossary/).

| Config Key                    | Default         | Description                                           |
|-------------------------------|-----------------|-------------------------------------------------------|
| ceph.osd.pool.size            | 3               | The initial number of OSD (storage) nodes             |
| ceph.mon.pool.size            | 3               | The initial number of Monitor nodes                   |
| ceph.mds.pool.size            | 3               | The initial number of Meta data nodes                 |
| ceph.replicates               | 3               | Number of times Ceph replicates the data              |
| ceph.maximum.usage            | 80              | The max (%) usage before ceph scales up the cluster   |
| ceph.minimum.usage            | 10              | The min (%) usage before ceph scales down the cluster |
| ceph.maximum.osd              | 10              | The total maximum number of OSDs                      |
| ceph.filesystem.data.name     | cephfs_data     | Name of the data volume                               |
| ceph.filesystem.metadata.name | cephfs_metadata | Name of the metadata volume                           |
| ceph.filesystem.name          | ceph            | Name of the filesystem                                |
| ceph.block.device.name        | ceph-vol        | Name of the block device                              |
| ceph.osd.device               | null (use OS)   | The device to use for ceph e.g. /dev/deviceN          |
| ceph.enable.ext4              | false           | See: goo.gl/Qqthbt                                    |

## Usage

To include a Ceph mount point on an Apache brooklyn entity include the `ceph-template` entity. In addition include a child `ceph-linux-mount` entity on any VMs on which
you would like to mount the Ceph storage and include config as below:

    - type: ceph-template
      id: ceph
    - id: my-entity
      brooklyn.config:
        children.startable.mode: BACKGROUND
        ...
      brooklyn.children:
        - type: ceph-linux-mount
          brooklyn.config:
            ceph.monitor.fsid: $brooklyn:component("monitor-cluster").attributeWhenReady("cluster.first.entity").attributeWhenReady("ceph.monitor.fsid")
	        ceph.client.admin.keyring: $brooklyn:component("monitor-cluster").attributeWhenReady("cluster.first.entity").attributeWhenReady("ceph.client.admin.keyring")
	        ceph.monitor.hostnames: $brooklyn:component("monitor-cluster").attributeWhenReady("ceph.monitor.hostnames")      
	        ceph.cluster.name: $brooklyn:component("monitor-cluster").attributeWhenReady("cluster.first.entity").config("ceph.cluster.name")
            
This configures the `ceph-linux-mount` to have the correct admin keys and config required to connect to the Ceph cluster.

NOTE: http://docs.ceph.com/docs/jewel/rados/configuration/filesystem-recommendations/

## Administrative Interfaces

The Brooklyn Ceph deployment also includes [Inkscope](https://github.com/inkscope/inkscope), a Ceph admin and supervision interface. It relies on API provided by ceph and uses 
[MongoDB](https://www.mongodb.com/) to store real time metrics and history metrics.

The admin interfaces to both Inkscope and MongoDB are displayed in the `main.uri` sensor of the `Ceph MongoDB` and `Ceph Inkscope Node`. Note that the default user created by
Inkscope has the username and password `admin`. This should not be regarded as secure however and additional [auth](https://httpd.apache.org/docs/2.4/howto/auth.html) should be 
configured through Apache web server. 

## Future development

The blueprint is currently fully functional but the following things probably require further input:  

* Currently the blueprint doesn't scale down / end nodes properly
* More automated tests are needed
* More configuration should be pulled out into `brooklyn.parameters`
