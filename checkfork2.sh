# 
# @author webworker01 
# 
#scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" 
#source /home/eclips/tools/main 

#how far ahead or behind before being marked as a fork 
variance=20 
coin=$1 

remotecheck=$(curl -Ssf https://komodostats.com/api/notary/summary.json >/dev/null 2>&1) 
if [ $? -ne 0 ]; then
    exit 2 
fi
remotecheck2=$(curl -Ssf https://dexstats.info/api/explorerstatus.php >/dev/null 2>&1)
if [ $? -ne 0 ]; then
    exit 2
fi

parseKomodostats()
{
    local coin=$1
    local remotedata=$2
    remoteblocks=$(jq --arg coinname $coin '.[] | select(.ac_name==$coinname) | .blocks' <<< $remotedata)
}

parseDexstats()
{
    local coin=$1
    local remotedata=$2
    remoteblocks2=$(jq --arg coinname $coin '.status[] | select(.chain==$coinname) | .height | tonumber' <<< $remotedata)
    remotehash2=$(jq -r --arg coinname $coin '.status[] | select(.chain==$coinname) | .hash' <<< $remotedata)
}

parseNotarystats()
{
    local coin=$1
    local remotedata=$2
    remoteblocks3=$(jq --arg coinname $coin '.coin[] | select(.name==$coinname) | .block' <<< $remotedata)
    remotehash3=$(jq -r --arg coinname $coin '.coin[] | select(.name==$coinname) | .bestblockhash' <<< $remotedata)
}

outputRow()
{
    local coinname=$1
    local localblocks=$2
    local locallongest=$3
    local localhash=$4

    if (( localblocks > 0 )); then
        thisformat=$format

        if (( remoteblocks > 0 )); then
            diff1=$((localblocks-remoteblocks))
        else
            diff1=0
        fi
        if (( remoteblocks2 > 0 )); then
            diff2=$((localblocks-remoteblocks2))
        else
            diff2=0
        fi
        if (( remoteblocks3 > 0 )); then
            diff3=$((localblocks-remoteblocks3))
        else
            diff3=0
        fi  

        if ((localblocks < locallongest)); then
            return 1
        fi
        if (( diff1 < variance * -1 )) || (( diff1 > variance )); then
            return 1
        fi
        if (( diff2 < variance * -1 )) || (( diff2 > variance )); then
            return 1
        fi
        if (( diff3 < variance * -1 )) || (( diff3 > variance )); then
            return 1
        fi

        hasherror2=""
        if [[ ! -z $remotehash2 ]] && [[ -z $hashatheight2 ]]; then
            return 1
        elif [[ -z $remotehash2 ]] && [[ "$hashatheight2" != "$remotehash2" ]]; then
            return 1
        fi
    fi
    return 0
}


if [[ $coin == "KMD" ]]; then
    blocks=$(komodo-cli getinfo | jq .blocks) 
    longest=$(komodo-cli getinfo | jq .longestchain) 
    blockhash=$(komodo-cli getbestblockhash) 
    parseKomodostats "KMD" "$remotecheck" 
    parseDexstats "KMD" "$remotecheck2" 
    if (( blocks >= remoteblocks2 )); then 
        hashatheight2=$(komodo-cli getblockhash $remoteblocks2) 
    else 
        hashatheight2= 
    fi 

    outputRow "KMD" $blocks $longest $blockhash 
else 
    blocks=$(komodo-cli -ac_name=${coin} getinfo | jq .blocks) 
    longest=$(komodo-cli -ac_name=${coin} getinfo | jq .longestchain) 
    blockhash=$(komodo-cli -ac_name=${coin} getbestblockhash) 
    parseKomodostats "${coin}" "$remotecheck" 
    parseDexstats "${coin}" "$remotecheck2" 
    if [[ ! -z $remoteblocks2 ]] && (( blocks >= remoteblocks2 )); then 
        hashatheight2=$(komodo-cli -ac_name=${coin} getblockhash $remoteblocks2) 
    else 
        hashatheight2= 
    fi 
    outputRow "${coin}" $blocks $longest $blockhash 
fi 
