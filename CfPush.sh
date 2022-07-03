#!/bin/bash

cf target -o system
cf target -s system
cd /Users/hmanukyan/workspace/metric-registrar-examples/golang/src/metric_registrar_examples;


for i in {1..1}; do {
     cf stop custom-metrics-${i}

#  cf scale custom-metrics-${i} -m 256 -k 64M
# cf push custom-metrics-${i} -k 64M -m 64M
#   echo "done ${i}"
#
# cf register-metrics-endpoint custom-metrics-${i} /metrics --internal-port 8080
#  echo "register ${i}"
}; done


#for i in {10..62}; do {
#   cf stop custom-metrics-${i}
##  echo "done ${i}"
##  cf register-metrics-endpoint custom-metrics-${i} /metrics --internal-port 8080
#}; done


#running pipeline
#for i in {1..5}; do {
#  for i in {1..20}; do {
#    echo "done ${i}"
#    fly -t hw-denver trigger-job --job catalyst-tmp-monitor/send-metrics-${i}
#  }; done
#}; done
# for i in {1..1}; do {
#    echo "done ${i}"
#    fly -t hw-denver trigger-job --job catalyst-tmp-monitor/send-metrics-${i}
#  }; done
#fly -t hw-denver jobs -p catalyst-tmp-monitor;
#fly -t hw-denver trigger-job --job catalyst-tmp-monitor/send-metrics-1
