#!/bin/bash
export SYSTEM_DOMAIN=sys.taft.cf-app.com
export CF_USERNAME=admin
export CF_PASSWORD=ioBCiKlhq_iOfcEZ1y6Hhj12kM47DIRf


cf login -a api.${SYSTEM_DOMAIN} -u ${CF_USERNAME} -p ${CF_PASSWORD} -o system -s system
cf create-org system
cf target -o "system"
cf create-space system
cf target -o "system" -s "system"

export name="system"
cf target -o ${name}

export time=$(date +"%T")

for l in {1..20}; do {
  export spaceName="paralel-$time"
  cf create-space ${spaceName}
  cf target -o ${name} -s ${spaceName}

  for i in {1..3}; do {
  export appName=$spaceName${l}${i}

  cf push ${appName} -k 128M -m 128M
  cf register-metrics-endpoint ${appName} /metrics --internal-port 8080
  echo "register ${i}"
}; done

  sleep 15
  yes Y | cf delete-space ${spaceName}
  sleep 10
}; done


