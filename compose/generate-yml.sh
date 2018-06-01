#!/bin/bash

# # Common
source "../scripts/common.sh"

RUNFILE="./docker-compose.sh"
echo "#!/bin/bash" > "${RUNFILE}"
{
    echo "yq m \\"
    echo "./.reqs/v1.yml \\"
    echo "./.reqs/v2.yml \\"
} >> "${RUNFILE}"
while read -r l || [ -n "${l}" ]; do
    for f in ./.apps/*.override.yml; do
        [[ -e ${f} ]] || break
        if [[ ${f} =~ /${l}\.override\. ]]; then
            echo "${f} \\" >> "${RUNFILE}"
        fi
    done
    for f in ./.apps/*.yml; do
        [[ -e ${f} ]] || break
        if [[ ${f} =~ /${l}\. ]]; then
            if [[ ${ARCH} == "arm64" ]]; then
                if [[ -f ${f/\.apps\//.apps\/aarch64\/} ]]; then
                    {
                        echo "${f/\.apps\//.apps\/aarch64\/} \\"
                        echo "${f} \\"
                    } >> "${RUNFILE}"
                fi
                if [[ -f ${f/\.apps\//.apps\/armhf\/} ]]; then
                    {
                        echo "${f/\.apps\//.apps\/armhf\/} \\"
                        echo "${f} \\"
                    } >> "${RUNFILE}"
                fi
            fi
            if [[ ${ARCH} == "arm" ]]; then
                if [[ -f ${f/\.apps\//.apps\/armhf\/} ]]; then
                    {
                        echo "${f/\.apps\//.apps\/armhf\/} \\"
                        echo "${f} \\"
                    } >> "${RUNFILE}"
                fi
            fi
            if [[ ${ARCH} == "amd64" ]]; then
                echo "${f} \\" >> "${RUNFILE}"
            fi
        fi
    done
done <"./apps.conf"
{
    echo "> ./docker-compose.yml"
    echo "docker-compose up -d"
} >> "${RUNFILE}"

bash "${RUNFILE}"
rm "${RUNFILE}"
