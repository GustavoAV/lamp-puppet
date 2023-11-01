#!/usr/bin/env bash

set -euo pipefail

log_dir=/var/log/puppetlabs/puppet
log_file="${log_dir}/setup.log"
completion_file="${log_dir}/.bootstrap_try_complete"

cert_line="Couldn't fetch certificate from CA server; you might still need to sign this agent's certificate ($(hostname).)."
error_line="Error: Could not run: Another puppet instance is already running and the waitforlock setting is set to 0; exiting"

# Clean log file content
echo "" >"${log_file}"

# Sends command to background
/opt/puppetlabs/puppet/bin/puppet ssl bootstrap >"${log_file}" 2>&1 &

# Gets process pid
puppet_pid=$!

# Read log file
tail -f "${log_file}" | while IFS= read -r line; do
    echo "${line}"
    if [[ ${line} == *"${error_line}"* ]]; then
        kill -TERM "${puppet_pid}"
        exit 1
    # Exits when "cert_line" found, creating a file
    elif [[ ${line} == *"${cert_line}"* ]]; then
        kill -TERM "${puppet_pid}"
        touch "${completion_file}"
        exit 0
    fi
done
