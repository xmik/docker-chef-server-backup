#!/bin/bash

# This assumes empty chef_server and therefore there is much manual work to do.
# The manual part is commented out.

test_chef_domain="chef.example.com"
test_chef_url="https://$test_chef_domain"
oc_id_admins="admin"

# 1. run chef server
# using dummy PUBLIC_URL such as "test_chef_server" will result in an error:
# the scheme https does not accept registry part: test_chef_server (or bad hostname?)
docker run -e PUBLIC_URL=$test_chef_url -e OC_ID_ADMINISTRATORS=$oc_id_admins -v /tmp/chef_server_data:/var/opt/opscode -p 443:443 --name chef_server -dti quay.io/3ofcoins/chef-server

# 2. wait for the "the chef-server-ctl reconfigure" to end, it takes ~4 minutes
# on my workstation
seconds_slept=0
sleep_seconds=15

while [[ ! $(docker logs --tail=10 chef_server) == *"Reconfiguration finished"* ]]; do
  sleep $sleep_seconds
  seconds_slept=$(($seconds_slept + $sleep_seconds))
  if [ $seconds_slept -gt 600 ]; then
      echo "exit after: ${seconds_slept} seconds; reconfiguration did not finish"
      exit 1
  fi
  echo "reconfiguration did not finish after: ${seconds_slept} seconds"
done
echo "reconfiguration finished after: ${seconds_slept} seconds"

# 3. add user admin and organization
docker exec -ti chef_server /bin/bash -c "chef-server-ctl user-create admin admin admin admin@example.com password -f /etc/chef/admin.pem"
docker exec -ti chef_server /bin/bash -c "chef-server-ctl org-create testorg "TestOrg" --association_user admin -f /etc/chef/testorg-validator.pem"

# 4. transfer test_admin public pem key into container and associate with admin user
docker cp test/test_admin.pem.pub chef_server:/etc/chef/test_admin.pem.pub
docker exec -ti chef_server /bin/bash -c "chef-server-ctl add-user-key admin --public-key-path /etc/chef/test_admin.pem.pub"
## to get public key from private key:
## openssl rsa -in test/test_admin.pem -pubout > test/test_admin.pem.pub

## 5. to make knife commands work from your current machine (chef workstation),
## add in /etc/hosts on current machine a line with chef_server ip and
## the $test_chef_url
## 6. test that knife_test.rb works, should return "admin"
# knife user list -c test/knife_test.rb
## 7. restore backup made with "knife-backup" (tested with version 0.0.11)
# knife backup restore cookbooks roles environments clients users nodes -D test/knife_backup_exported_11 -c test/knife_test.rb -y

## restoring backup here is only to show more complete deployment. Users from 
## Chef Server 11 will not be restored into Chef Server 12
## (#<Net::HTTPBadRequest:0x00000003b65c58>)
## To see that cookbooks and all their versions are restored:
# knife cookbook list --all -c test/knife_test.rb

## 8. run chef-server-backup container (docker volumes only accept absolute paths)
## notice the link here, it is only needed if your chef server url is not reachable
## from inside the backup container, e.g. when testing like this
# docker run --name chef_server_backup -v ${PWD}/test/test_admin.pem:/root/.chef/admin.pem -v ${PWD}/test/test_backup:/var/backups/chef-server/ -e CHEF_SERVER_URL="$test_chef_domain/organizations/testorg" --link chef_server:$test_chef_domain xmik/chef-server-backup:0.0.1
