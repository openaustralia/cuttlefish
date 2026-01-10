#!/bin/bash

extra_args=''

case "$TAGS" in
?*)
    extra_args="$extra_args --tags=facts,$TAGS"
    ;;
esac

case "$SKIP_TAGS" in
?*)
    extra_args="$extra_args --skip-tags=$SKIP_TAGS"
    ;;
esac

case "$START_AT_TASK" in
?*)
    sat=$(echo "*${START_AT_TASK}*" | sed 's/ /*/g')
    extra_args="$extra_args --start-at-task=$sat"
    ;;
esac

ansible-playbook -i provisioning/hosts provisioning/playbook.yml $extra_args "$@"
