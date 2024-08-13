STATE="$1"

SUBNET_LIST=()
while IFS='' read -r line; do SUBNET_LIST+=("$line"); done < <(echo $STATE | jq -r '.resources[] | select((.type == "ibm_is_vpc") and (.mode == "data") and (.name == "vpc_by_id")) | .instances[0] | .attributes | .subnets[] | .id')
ADDRESS_LIST=()
while IFS='' read -r line; do ADDRESS_LIST+=("$line"); done < <(echo $STATE | jq -r '.resources[] | select(.type == "ibm_is_instance") | .module')

for i in "${!SUBNET_LIST[@]}"; do
    for j in "${!ADDRESS_LIST[@]}"; do
        VSI_RESOURCES="$(echo $STATE | jq -r --arg address "${ADDRESS_LIST[$j]}" '.resources[] | select((.type == "ibm_is_instance") and (.module == $address)) | .instances')"
        subnet_name=$(echo $STATE | jq -r --arg subnet_id "${SUBNET_LIST[$i]}" '.resources[] | select((.type == "ibm_is_vpc") and (.mode == "data") and (.name == "vpc_by_id")) | .instances[0] | .attributes | .subnets[] | select(.id == $subnet_id) | .name')
        vsi_names=$(echo "$VSI_RESOURCES" | jq -r --arg subnet_id "${SUBNET_LIST[$i]}" '.[] | select(.attributes.primary_network_interface[0].subnet == $subnet_id) | .index_key')
        VSI_LIST=()
        IFS=$'\n' read -r -d '' -a VSI_LIST <<<"$vsi_names"
        for x in "${!VSI_LIST[@]}"; do
            SOURCE="${ADDRESS_LIST[$j]}.ibm_is_instance.vsi[\"${VSI_LIST[$x]}\"]"
            DESTINATION="${ADDRESS_LIST[$j]}.ibm_is_instance.vsi[\"${subnet_name}-${x}\"]"
            if [ -n "${VSI_LIST[$x]}" ] && [ -n "${subnet_name}" ]; then
                MOVED_PARAMS+=("$SOURCE, $DESTINATION")
            fi
            if [ -n "${VSI_LIST[$x]}" ]; then
                VOL_NAMES=$(echo "$VSI_RESOURCES" | jq -r --arg vsi "${VSI_LIST[$x]}" '.[] | select(.index_key == $vsi) | .attributes.volume_attachments[].volume_name')
            fi
            if [ -n "${VSI_LIST[$x]}" ]; then
                FIP_RESOURCES="$(echo $STATE | jq -r --arg address "${ADDRESS_LIST[$j]}" '.resources[] | select((.type == "ibm_is_floating_ip") and (.module == $address)) | .instances')"
            fi
            if [ -n "$FIP_RESOURCES" ]; then
                FIP_SOURCE="${ADDRESS_LIST[$j]}.ibm_is_floating_ip.vsi_fip[\"${VSI_LIST[$x]}\"]"
                FIP_DESTINATION="${ADDRESS_LIST[$j]}.ibm_is_floating_ip.vsi_fip[\"${subnet_name}-${x}\"]"
                if [ -n "${VSI_LIST[$x]}" ] && [ -n "${subnet_name}" ]; then
                    MOVED_PARAMS+=("$FIP_SOURCE, $FIP_DESTINATION")
                fi
            fi
            str="${VSI_LIST[$x]}"
            lastIndex=$(echo "$str" | awk '{print length}')
            for ((l = lastIndex; l >= 0; l--)); do
                if [[ "${str:$l:1}" == "-" ]]; then
                    str="${str::l}"
                    break
                fi
            done
            if [ -n "$VOL_NAMES" ]; then
                VOL_ADDRESS_LIST=()
                while IFS='' read -r line; do VOL_ADDRESS_LIST+=("$line"); done < <(echo $STATE | jq -r '.resources[] | select(.type == "ibm_is_volume") | .module')
                VOL_NAME=()
                IFS=$'\n' read -r -d '' -a VOL_NAME <<<"$VOL_NAMES"
                for a in "${!VOL_NAME[@]}"; do
                    for b in "${!VOL_ADDRESS_LIST[@]}"; do
                        VOL_RESOURCES="$(echo $STATE | jq -r --arg address "${VOL_ADDRESS_LIST[$b]}" '.resources[] | select((.type == "ibm_is_volume") and (.module == $address)) | .instances')"
                        vol_names=$(echo "$VOL_RESOURCES" | jq -r --arg vol1 "${VOL_NAME[$a]}" '.[] | select(.attributes.name == $vol1) | .index_key')
                        VOL_LIST=()
                        IFS=$'\n' read -r -d '' -a VOL_LIST <<<"$vol_names"
                        for c in "${!VOL_LIST[@]}"; do
                            if [ -n "${VOL_LIST[$c]}" ]; then
                                VOL_SOURCE="${ADDRESS_LIST[$j]}.ibm_is_volume.volume[\"${VOL_LIST[$c]}\"]"
                                test="${VOL_LIST[$c]/$str/}"
                                vol=$(echo "$test" | cut -d"-" -f3-)
                                VOL_DESTINATION="${ADDRESS_LIST[$j]}.ibm_is_volume.volume[\"${subnet_name}-${x}-${vol}\"]"
                                if [ -n "${VOL_LIST[$c]}" ] || [ -n "${subnet_name}" ]; then
                                    MOVED_PARAMS+=("$VOL_SOURCE, $VOL_DESTINATION")
                                fi
                            fi
                        done
                    done
                done
            fi
        done
    done
done
for ab in "${!MOVED_PARAMS[@]}"; do
    echo "${MOVED_PARAMS[$ab]}"
done
