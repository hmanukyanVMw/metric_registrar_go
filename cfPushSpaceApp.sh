#!/bin/bash
#export SYSTEM_DOMAIN=sys.rosequartz.cf-app.com
#export CF_USERNAME=admin
#export CF_PASSWORD=raXUVHLsKRP0f8a-pqLFiQ85v2B_iXyD


#curl --get -H "Authorization: $(cf oauth-token)" \
#     "https://log-store.sys.hw-tas212.platform-automation.cf-denver.com/v1/sources/ee54a92c-2b76-48c0-9259-6d5e97ad2afb/logs"
#     --data-urlencode 'query={message=~"Error.*"}' \
#ee54a92c-2b76-48c0-9259-6d5e97ad2afb



#cf login -a api.${SYSTEM_DOMAIN} -u ${CF_USERNAME} -p ${CF_PASSWORD} -o system -s system
cf create-org system
cf target -o "system"
cf create-space system
cf target -o "system" -s "system"

export name="system"
cf target -o ${name}

export time=$(date +"%T")

for l in {1..2}; do {
  export spaceName="paralel-$time"
  cf create-space ${spaceName}
  cf target -o ${name} -s ${spaceName}

  for i in {1..3}; do {
  export appName=$spaceName${l}${i}

  cf push ${appName} -k 512M -m 512M
  cf register-metrics-endpoint ${appName} /metrics --internal-port 8080
  echo "register ${i}"
}; done
#
#  sleep 15
#  yes Y | cf delete-space ${spaceName}
  sleep 10
}; done


