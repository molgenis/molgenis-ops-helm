#!/bin/bash
echo "Start script"
githubtoken=$1
serverlistServer=molgenis23.gcc.rug.nl
NePort=9100
serverlist=$(curl -s https://${githubtoken}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/master/inventory.ini)
serverlist+=" [extra-prod-scrapes] molgenis79.gcc.rug.nl molgenis26.gcc.rug.nl molgenis27.gcc.rug.nl gbic.target.rug.nl"
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
    elif [[ $val =~ ".gcc.rug.nl" ]] || [[ $val =~ ".target.rug.nl" ]];
    then
        host=$(echo $val | cut -d'.' -f1)
        desc=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=id=='$host'&attrs=~id,description' | rev | cut -d'"' -f2 | rev )
        result=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=id=='$host'&attrs=~id,url,dns' | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*\:?\d*/?[a-zA-Z0-9./?=_-]*/?" | uniq | tr '\n' ' ' )
        case $group in 
            "prod")
                if [[ "$host" == 'gbic' ]]; 
                then
                    prodTargetArray+=("- targets: ['wiki.gcc.rug.nl:${NePort}']")
                else
                    prodTargetArray+=("- targets: ['${host}.gcc.rug.nl:${NePort}']")
                fi
                prodTargetArray+=("  labels: ")
                prodTargetArray+=("    project: \"${desc}\"")
                prodTargetArray+=("    type: \"prod\"")
                
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
                acceptTargetArray+=("    type: \"accept\"")

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
                testTargetArray+=("    type: \"test\"")

                IFS=$'\n' read -a tempArray <<< $result
                for i in $tempArray
                do
                    testWebArray+=("  - $i")
                done
                ;;
        esac
    fi
done
prodWebArray+=("  - https://www.chromosome6.org/contact")
prodWebArray+=("  - https://github.com/molgenis/systemsgenetics/wiki/Genotype-Harmonizer-Download")
prodWebArray+=("  - https://github.com/molgenis/systemsgenetics/wiki/Genotype-Harmonizer")
prodWebArray+=("  - https://github.com/molgenis/systemsgenetics/wiki/Genotype%20Harmonizer%20Download")
prodWebArray+=("  - https://github.com/molgenis/systemsgenetics/wiki/QTL-mapping-pipeline")
prodWebArray+=("  - http://www.eucanconnect.eu")
prodWebArray+=("  - http://www.eucanconnect.com")
printf '%s\n' "${prodWebArray[@]}" >> prod-http-list.yml
printf '%s\n' "${prodTargetArray[@]}" >> prod-target-list.yml
printf '%s\n' "${acceptWebArray[@]}" >> accept-http-list.yml
printf '%s\n' "${acceptTargetArray[@]}" >> accept-target-list.yml
printf '%s\n' "${testWebArray[@]}" >> test-http-list.yml
printf '%s\n' "${testTargetArray[@]}" >> test-target-list.yml
echo $(kubectl --token=$TOKEN create configmap targets-configmap --from-file prod-target-list.yml --from-file accept-target-list.yml --from-file test-target-list.yml --from-file prod-http-list.yml --from-file accept-http-list.yml -o yaml --dry-run | kubectl --token=$TOKEN replace -f -)
echo $(rm -rf *.yml)
echo "Done retrieving and saving to file"
echo "End script"