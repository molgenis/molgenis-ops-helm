#!/bin/bash
echo "Start script"
githubtoken=$1
serverlistServer=molgenis23.gcc.rug.nl
NePort=9100
serverlist=$(curl -s https://${githubtoken}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/master/inventory.ini)
testTargetArray=("")
testWebArray=("- targets:")
acceptTargetArray=("")
acceptWebArray=("- targets:")
prodTargetArray=("")
prodWebArray=("- targets:")
echo "Serverlist received"
echo "Start domain retrieval"
for val in $serverlist;
do
    if [[ $val =~ ['['] ]];
    then
        if [[ "$val" =~ .*"prod".* ]];
        then
            group="prod"
        elif [[ "$val" =~ .*"acc".* ]];
        then
            group="accept"
        elif [[ "$val" =~ .*"test".* ]] || [[ "$val" =~ .*"master".* ]];
        then
            group="test"
        fi
    elif [[ $val =~ ^molgenis.* ]];
    then
        host=$(echo $val | cut -d'.' -f1)
        desc=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=id=='$host'&attrs=~id,description' | rev | cut -d'"' -f2 | rev )
        result=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=id=='$host'&attrs=~id,url,dns' | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*\:?\d*/?[a-zA-Z0-9]*/?" | uniq )
        case $group in 
            "prod")
                prodTargetArray+=("- targets: ['${host}.gcc.rug.nl:${NePort}']")
                prodTargetArray+=("  labels: ")
                prodTargetArray+=("    project: \"${desc}\"")
                
                IFS=$'\n' read -a tempArray <<< $result
                for i in $tempArray
                do
                    prodWebArray+=("  - $i")
                done
                ;;
            "accept")
                acceptTargetArray+=("- targets: ['${host}.gcc.rug.nl:${NePort}']")
                acceptTargetArray+=("  labels: ")
                acceptTargetArray+=("    project: \"${desc}\"")

                IFS=$'\n' read -a tempArray <<< $result
                for i in $tempArray
                do
                    acceptWebArray+=("  - $i")
                done
                ;;
            "test")
                testTargetArray+=("- targets: ['${host}.gcc.rug.nl:${NePort}']")
                testTargetArray+=("  labels: ")
                testTargetArray+=("    project: \"${desc}\"")

                IFS=$'\n' read -a tempArray <<< $result
                for i in $tempArray
                do
                    testWebArray+=("  - $i")
                done
                ;;
        esac
    fi
done
printf '%s\n' "${prodWebArray[@]}" >> prod-http-list.yml
printf '%s\n' "${prodTargetArray[@]}" >> prod-target-list.yml
printf '%s\n' "${acceptWebArray[@]}" >> accept-http-list.yml
printf '%s\n' "${acceptTargetArray[@]}" >> accept-target-list.yml
printf '%s\n' "${testWebArray[@]}" >> test-http-list.yml
printf '%s\n' "${testTargetArray[@]}" >> test-target-list.yml
echo $(kubectl --token=$TOKEN create configmap targets-configmap --from-file prod-target-list.yml --from-file accept-target-list.yml --from-file test-target-list.yml --from-file prod-http-list.yml -o yaml --from-file accept-http-list.yml --from-file test-http-list.yml --dry-run | kubectl --token=$TOKEN replace -f -)
echo $(rm -rf *.yml)
echo "Done retrieving and saving to file"
echo "End script"