# docker-chef-server-backup

Debian Jessie with [knife-backup](https://github.com/mdxp/knife-backup) 0.0.11 gem. Base image: ruby:2.2.3-slim. To make Chef Server backup remotely.

## Usage
Assuming that:
  * your Chef Server is already running and is accessible by chef.example.com

Run this docker image e.g. like this:
```bash
$ docker run --name chef_server_backup -v ~/.chef/admin.pem:/root/.chef/admin.pem -e CHEF_SERVER_URL="https://chef.example.com/organizations/testorg" xmik/chef-server-backup:0.0.1
```

where: