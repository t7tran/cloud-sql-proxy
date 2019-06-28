#!/bin/bash
set -e

# credits: https://medium.com/@cotton_ori/how-to-terminate-a-side-car-container-in-kubernetes-job-2468f435ca99

if [[ -n "$TERMINATE_PATH" ]]; then
  cloud_sql_proxy "$@" & CHILD_PID=$!
  (while true; do if [[ -f "$TERMINATE_PATH" ]]; then kill $CHILD_PID; echo "Shutting down..."; fi; sleep 1; done) &
  wait $CHILD_PID
  if [[ -f "$TERMINATE_PATH" ]]; then echo "Shutdown completed. Exiting..."; exit 0; fi
else
  exec cloud_sql_proxy "$@"
fi