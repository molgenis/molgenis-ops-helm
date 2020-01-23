#!/bin/bash
GITHUBTOKEN=$1
NePort=9100
ServerlistServer=molgenis23.gcc.rug.nl
BranchMASTER=$(curl -s https://${GITHUBTOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/master/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch20=$(curl -s https://${GITHUBTOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/2.0/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch10=$(curl -s https://${GITHUBTOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/1.0/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch01=$(curl -s https://${GITHUBTOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/0.1/inventory.ini | awk '$2' | cut -d' ' -f1)

printf "Script - start\n"
printf "Branch master - start\n"
while IFS=" " read -r host
do
  if [ ${host} != '#' ]; then
    descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    outputArray=("- targets: ['${host}:${NePort}']")
    outputArray+=("  labels: ")
    outputArray+=("    project: \"${descGrab}\"")
    outputArray+=("    branch: \"master\"")
    outputArray+=("    dtap: \"${dtapGrab}\"")
  fi
done < <(printf '%s\n' "${BranchMASTER}")

printf "Branch master - finished\n"
printf '%s\n' "${outputArray[@]}" >> masterTargetsAcquired.yml
printf "Writing outputArray to masterTargetsAcquired.yml done\nBranch 2.0 - start\n"
outputArray=("")
while IFS=" " read -r host
do
  if [ ${host} != '#' ]; then
    descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${NePort}']")
    outputArray+=("  labels: ")
    outputArray+=("    project: \"${descGrab}\"")
    outputArray+=("    branch: \"2.0\"")
    outputArray+=("    dtap: \"${dtapGrab}\"")
  fi
done < <(printf '%s\n' "${Branch20}")

printf "Branch 2.0 - finished\n"
printf '%s\n' "${outputArray[@]}" >> 20TargetsAcquired.yml
printf "Writing outputArray to 20TargetsAcquired.yml done\nBranch 1.0 - start\n"
outputArray=("")
while IFS=" " read -r host
do
  if [ ${host} != '#' ]; then
    descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${NePort}']")
    outputArray+=("  labels: ")
    outputArray+=("    project: \"${descGrab}\"")
    outputArray+=("    branch: \"1.0\"")
    outputArray+=("    dtap: \"${dtapGrab}\"")
  fi
done < <(printf '%s\n' "${Branch10}")

printf "Branch 1.0 - finished\n"
printf '%s\n' "${outputArray[@]}" >> 10TargetsAcquired.yml
printf "Writing outputArray to 10TargetsAcquired.yml done\nBranch 0.1 - start\n"
outputArray=("")
while IFS=" " read -r host
do
  if [ ${host} != '#' ]; then
    descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$ServerlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${NePort}']")
    outputArray+=("  labels: ")
    outputArray+=("    project: \"${descGrab}\"")
    outputArray+=("    branch: \"0.1\"")
    outputArray+=("    dtap: \"${dtapGrab}\"")
  fi
done < <(printf '%s\n' "${Branch01}")
printf "Branch 0.1 - finished\n"
printf '%s\n' "${outputArray[@]}" >> 01TargetsAcquired.yml
printf "Writing outputArray to 01TargetsAcquired.yml done\n"
printf "Script done\n"
