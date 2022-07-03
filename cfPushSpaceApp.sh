#!/bin/bash

#cf target -s system
cd /Users/hmanukyan/workspace/metric-registrar-examples/golang/src/metric_registrar_examples;

export name="system"
#cf create-org ${name}
cf target -o ${name}

export time=$(date +"%T")

for l in {1..20};  do {
  export spaceName="paralel-$time"
  cf create-space ${spaceName}
  cf target -o ${name} -s ${spaceName}

  for i in {1..5}; do {
    export appName=$spaceName${l}${i}

    cf push ${appName} -k 128M -m 128M
    cf register-metrics-endpoint ${appName} /metrics --internal-port 8080
    echo "register ${i}"
  }; done

  sleep 10
  yes Y | cf delete-space ${spaceName}
}; done

#for i in {1..1}; do {
#     cf stop custom-metrics-${i}
#
##  cf scale custom-metrics-${i} -m 256 -k 64M
## cf push custom-metrics-${i} -k 64M -m 64M
##   echo "done ${i}"
##
## cf register-metrics-endpoint custom-metrics-${i} /metrics --internal-port 8080
#  echo "register ${i}"
#}; done



