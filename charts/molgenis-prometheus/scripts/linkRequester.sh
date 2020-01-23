#!/bin/bash
echo "Start script"
githubtoken=$1
serverlistServer=molgenis23.gcc.rug.nl
serverlist=$(curl -s https://${githubtoken}@raw.githubusercontent.com/molgenis/molgenis-ops-ansible/master/inventory.ini)
echo "Serverlist received"
echo "Start domain retrieval"
finalArray=("- targets:")
for val in $serverlist;
do
    if [[ $val =~ ['['] ]];
    then
        group=$(echo $val)
    elif [[ $val =~ ^molgenis.* ]];
    then
        host=$(echo $val | cut -d'.' -f1)
        result=$(curl -s https://$serverlistServer'/api/v2/mm_public_serverlist?q=id=='$host'&attrs=~id,url,dns' | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*\:?\d*/?[a-zA-Z0-9]*/?" | uniq )
        IFS=$'\n' read -a tempArray <<< $result
        for i in $tempArray
        do
            finalArray+=("  - $i")
        done
    fi
done
printf '%s\n' "${finalArray[@]}" >> http-domains.yml
echo "Done retrieving and saving to file"
echo "End script"