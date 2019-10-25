#!/bin/bash
# You can add ./k8sScrapeTargetExtractor <TOKEN> or just ./k8sScrapeTargetExtractor
# # You can add ./k8sScrapeTargetExtractor <TOKEN> or just ./k8sScrapeTargetExtractor
# if [ $# -eq 0 ];
# then
#   echo "Input github personal token"
#   read GITHUB_TOKEN
#   #echo "Input rancher token"
#   #read RANCHER_TOKEN
#   #echo "Input kubernetes token"
#   #read KUBECTL_TOKEN
# else
  GITHUB_TOKEN=$1
#  RANCHER_TOKEN=$2
# fi
nePort=9100
serverlistServer=molgenis23.gcc.rug.nl
BranchMASTER=$(curl -s https://${GITHUB_TOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/master/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch20=$(curl -s https://${GITHUB_TOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/2.0/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch10=$(curl -s https://${GITHUB_TOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/1.0/inventory.ini | awk '$2' | cut -d' ' -f1)
Branch01=$(curl -s https://${GITHUB_TOKEN}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/0.1/inventory.ini | awk '$2' | cut -d' ' -f1)
#echo ${REPOMASTER}
#echo ${REPO20}
#echo ${REPO10}

printf "Script - start\n"
printf "Branch master - start\n"
#outputArray+=("masterTargetsAcquired.yml: |")
while IFS=" " read -r host
do
  if [ ${host} != '#' ]; then
    descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    outputArray=("- targets: ['${host}:${nePort}']")
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
    descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${nePort}']")
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
    descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${nePort}']")
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
    descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f4 | rev | cut -d'"' -f2)
    dtapGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,TAP,description,url' | rev | cut -d':' -f1 | rev | cut -d'"' -f2)
    if [ "${descGrab}" = "," ]; then
      descGrab=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=url=='https://$host'&attrs=~id,description' | rev | cut -d':' -f3 | rev | cut -d'"' -f2)
    fi
    outputArray+=("- targets: ['${host}:${nePort}']")
    outputArray+=("  labels: ")
    outputArray+=("    project: \"${descGrab}\"")
    outputArray+=("    branch: \"0.1\"")
    outputArray+=("    dtap: \"${dtapGrab}\"")
  fi
done < <(printf '%s\n' "${Branch01}")
printf "Branch 0.1 - finished\n"
printf '%s\n' "${outputArray[@]}" >> 01TargetsAcquired.yml
printf "Writing outputArray to 01TargetsAcquired.yml done\n"
echo $(rancher kubectl config set-context edgecluster --namespace=molgenis-prometheus-prod)
echo $(rancher kubectl create configmap targets-configmap --from-file masterTargetsAcquired.yml --from-file 20TargetsAcquired.yml --from-file 10TargetsAcquired.yml --from-file 01TargetsAcquired.yml -o yaml --dry-run | kubectl replace -f -)
printf "Rancher kubectl updatet configmap from molgenis-prometheus-prod\n"
$(rm -f *TargetsAcquired.yml)
printf "Removed artifacts\n"printf "Script done\n"
