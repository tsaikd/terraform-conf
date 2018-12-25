#!/bin/sh
APP_NAME="${1}"

kubectl() {
    docker run --rm -i --volumes-from gcloud-config -v $PWD:$PWD -w $PWD kubectl kubectl "$@"
}

wait_pods_ready() {
    # wait for all pods with internal IP
    while true; do
        PODS_INFO="$(kubectl get pods -l app=${APP_NAME} -o jsonpath='{range.items[*]}{.metadata.name} {.status.podIP}{"\n"}')"
        invalidinfo="$(echo "${PODS_INFO}" | awk '{if(NF!=2){print}}')"
        test "x${invalidinfo}x" = "xx" && break
        sleep 5
    done
}

init_redis_cluster() {
    wait_pods_ready
    PODS_IPS="$(echo "${PODS_INFO}" | awk '{printf "%s:6379 ", $2}')"
    WORK_POD_NAME="$(echo "${PODS_INFO}" | awk '{print $1;exit}')"

    echo yes | kubectl exec -i ${WORK_POD_NAME} -- redis-cli --cluster create ${PODS_IPS}
}

init_redis_cluster
