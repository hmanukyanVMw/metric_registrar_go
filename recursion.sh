#!/bin/bash
for (( ; ; )) do {
  for i in {26..40}; do {
    sleep 1

    curl --location --request GET https://custom-metrics-${i}.apps.buellton.cf-app.com/simple &
    sleep 1
    curl --location --request GET https://custom-metrics-${i}.apps.buellton.cf-app.com/high_latency &
    sleep 1
    curl --location --request GET https://custom-metrics-${i}.apps.buellton.cf-app.com/custom_metric?inc=1 &
    sleep 1
    curl --location --request GET https://custom-metrics-${i}.apps.buellton.cf-app.com/custom_metric &
   }; done

   sleep 50
}; done

# wget https://custom-metrics.apps.pointarena.cf-app.com/simple --no-check-certificate


