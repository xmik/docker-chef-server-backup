# docker-chef-server-backup

Debian Jessie with [knife-backup](https://github.com/mdxp/knife-backup) 0.0.11 gem. Base image: ruby:2.2.3-slim. To make Chef Server backup remotely.
For Chef Server 11 and 12.

## Warning
It won't backup/restore Chef Server 12 users, because of such knife-backup limitation.

## Usage
Assuming that:
  * your Chef Server is already running and is accessible by chef.example.com
  * some Chef Server user exists

Run this docker image e.g. like this:
```bash
$ docker run --rm --name chef_server_backup -v ~/.chef/admin.pem:/root/.chef/admin.pem -v /var/backups/chef-server/:/var/backups/chef-server/ -e CHEF_SERVER_URL="https://chef.example.com/organizations/testorg" --link chef_server:chef.example.com xmik/chef-server-backup:0.0.1
```

where:
  * you have to mount pem file for the Chef Server user
  * you can mount some directory to `/var/backups/chef-server/` inside container
   or all your backup will be inside container only (it will be lost if using
   `docker run --rm`)
  * you can set `CHEF_USER`, default is admin
  * you can set `PEM_PATH`, default is `/root/.chef/${CHEF_USER}.pem`
  * you can set `CHEF_SERVER_URL`, default is https://chef.example.com/organizations/testorg ,
    for Chef Server 11 the part "organizations/testorg" is not needed
  * you can set `KNIFE_COMMAND`, default is `knife backup export cookbooks roles environments clients users nodes -D /var/backups/chef-server`,
    so actually, you can change this command to `knife backup restore cookbooks roles environments clients users nodes -D /path/to/exported_backup -y`
    and use this image to restore Chef Server backup

## Build
Build an image using the tag from script/version.txt. Use rake task:
```ruby
$ rake build
```

Size of [xmik/chef-server-backup:0.0.1](https://registry.hub.docker.com/u/xmik/docker-chef-server-backup/) is 492 MB.
