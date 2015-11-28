#!/bin/bash

if [ -z "$CHEF_USER"  ]; then
    # set default
    CHEF_USER="admin"
fi

if [ -z "$PEM_PATH" ]; then
    # set default
    PEM_PATH="/root/.chef/${CHEF_USER}.pem"
fi

if [ -z "$CHEF_SERVER_URL" ]; then
    # set default
    CHEF_SERVER_URL="https://chef.example.com/organizations/testorg"
fi

if [ -z "$KNIFE_COMMAND" ]; then
    # set default
    KNIFE_COMMAND="knife backup export cookbooks roles environments clients users nodes -D /var/backups/chef-server"
fi

echo "
log_level                :info
log_location             STDOUT
node_name                '$CHEF_USER'
client_key               '$PEM_PATH'
chef_server_url          '$CHEF_SERVER_URL'
syntax_check_cache_path  '/root/.chef/syntax_check_cache'
ssl_verify_mode          :verify_none
" > /root/.chef/knife.rb

$KNIFE_COMMAND -c /root/.chef/knife.rb
