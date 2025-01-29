#!/bin/bash
if [ -z "${1}" ]; then
  exit 1
fi

sleep 5

while true; do
  SCRUB_STATE="$(btrfs scrub status /mnt/${1} | grep "Status:" | awk '{print $2}')"
  if [ "${SCRUB_STATE}" == "running" ]; then
   sleep 10
  else
   logger "Scrubber: Scrub from BTRFS Pool: ${1} done!"
   SCRUB_FINISHED="$(btrfs scrub status /mnt/${1})"
   SCRUB_SUMMARY="$(grep "Error summary:" <<< "${SCRUB_FINISHED}")"
   if grep -q "no errors" <<< "${SCRUB_SUMMARY}" ; then
     IMPORTANCE="normal"
   else
     IMPORTANCE="alert"
   fi
   /usr/local/emhttp/plugins/dynamix/scripts/notify -e "Scrubber" -s "BTRFS Scrub from Pool: ${1} finished!" -d "$(echo "${SCRUB_FINISHED}" | awk '{printf "%s<br/>", $0}')" -i ${IMPORTANCE}
   unset SCRUB_STATE SCRUB_FINISHED SCRUB_SUMMARY IMPORTANCE
   break
 fi
done