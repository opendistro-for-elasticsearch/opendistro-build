#!/usr/bin/env sh

# TODO
# ----
# Generalize the creation of security plugin objects,
# as it is now duplicated for each individual object.
# -----

set -e

wait_until_ready=600
poll_interval=5

auth="${ES_USERNAME}:${ES_PASSWORD}"
snapshot_repository="s3_{{ .Values.elasticsearch.s3.provider }}_7.x"
es_url="http://{{ template "opendistro-es.fullname" . }}-client-service:9200"
kibana_url="http://{{ template "opendistro-es.fullname" . }}-kibana-svc:443"
create_indices="{{ .Values.configurer.createIndices }}"

users='{{ toJson .Values.configurer.securityPlugin.users }}'
roles='{{ toJson .Values.configurer.securityPlugin.roles }}'
rolesmappings='{{ toJson .Values.configurer.securityPlugin.roles_mapping }}'

log_error_exit() {
  description=$1
  error_msg=$2
  echo "${description}" 1>&2
  echo "${error_msg}" 1>&2
  exit 1
}

wait_for_kibana() {
  starttime_s=$(date +%s)
  while [ $(($(date +%s) - starttime_s)) -le ${wait_until_ready} ]; do
    status=$(curl --insecure --silent "${kibana_url}/api/status" | grep "^{" | jq -r .'status.overall.state')
    if [ "${status}" = "green" ]; then
      echo "Kibana server is ready"
      break
    fi
    echo "Kibana server is not ready yet"
    sleep ${poll_interval}
  done
}

setup_kibana_dashboard() {
  echo
  echo "Setting up kibana dashboard"
  resp=$(curl -s -kL -X POST "${kibana_url}/api/saved_objects/_import?overwrite=true" \
    -H "kbn-xsrf: true" \
    --form file=@/files/kibana-dashboards.ndjson -u "${auth}")
  success=$(echo "${resp}" | grep "^{" | jq -r '.success')
  if [ "${success}" != "true" ]; then
    log_error_exit "Failed to set up kibana dashboard" "${resp}"
  fi
}

register_s3_repository() {
  echo
  echo "Registering s3 snapshot repository"
  resp=$(curl -X PUT "${es_url}/_snapshot/${snapshot_repository}" \
    -H 'Content-Type: application/json' \
    -d' {"type": "s3", "settings":{ "bucket": "{{ .Values.elasticsearch.s3.bucketName }}", "client": "default"}}' \
    -s -k -u "${auth}")
  acknowledged=$(echo "${resp}" | grep "^{" | jq -r '.acknowledged')
  if [ "${acknowledged}" != "true" ]; then
    log_error_exit "Failed to register s3 repository" "${resp}"
  fi
}

create_index_templates() {
  echo
  echo "Creating index templates"
  overwrite_templates="{{ .Values.configurer.overwriteTemplates }}"
  # The opendistro API uses a value representing 'strict create' rather than
  # 'overwrite_templates', therefore negate
  case "${overwrite_templates}" in
    true) strict="false" ;;
    false) strict="true" ;;
    *) log_error_exit "Unknown value for .Values.configurer.overwriteTemplates, should be 'true' or 'false'" "" ;;
  esac
  for index in kubeaudit kubernetes other; do
    filename="${index}_template.json"
    echo "Creating index template for file '${filename}'"
    resp=$(curl -X PUT "${es_url}/_template/${index}?create=${strict}" \
      -H "Content-Type: application/json" -s \
      -d@/files/${filename} -k -u "${auth}")
    acknowledged=$(echo "${resp}" | grep "^{" | jq -r '.acknowledged')
    if [ "${acknowledged}" != "true" ]; then
      if [ "${overwrite_templates}" = "false" ] \
          && echo "${resp}" | grep "already exists" > /dev/null ; then
        echo "Index template '${index}' already exists, do nothing"
      else
        log_error_exit "Failed to create index template for file '${filename}'" "${resp}"
      fi
    fi
  done
}

setup_policies() {
  create_update_policy() {
    update_policies="{{ .Values.configurer.updatePolicies }}"

    update_policy() {
      policy=$1
      policy_json=$(curl -X GET "${es_url}/_opendistro/_ism/policies/${policy}" \
        -H "Content-Type: application/json" -k -s \
        -u "${auth}")
      seq_no=$(echo "${policy_json}" | jq -r '._seq_no')
      primary_term=$(echo "${policy_json}" | jq -r '._primary_term')
      resp=$(curl -X PUT "${es_url}/_opendistro/_ism/policies/${policy}?if_seq_no=${seq_no}&if_primary_term=${primary_term}" \
        -H "Content-Type: application/json" -k -s \
        -d@"/files/${policy}_policy.json" \
        -u "${auth}")
      id=$(echo "${resp}" | grep "^{" | jq -r '._id')
      if [ "${id}" != "${policy}" ]; then
        log_error_exit "Failed to update policy '${policy}'" "${resp}"
      fi
      echo "Updated policy '${policy}'"
    }

    policy=$1
    echo "Creating policy '${policy}'"
    resp=$(curl -X PUT "${es_url}/_opendistro/_ism/policies/${policy}" \
      -H "Content-Type: application/json" \
      -d@"/files/${policy}_policy.json" -k -s \
      -u "${auth}")
    status=$(echo "${resp}" | grep "^{" | jq -r '.status')
    id=$(echo "${resp}" | grep "^{" | jq -r '._id')
    if [ "${status}" = 409 ]; then # policy already exists
      echo "Policy '${policy}' already exists"
      if [ "${update_policies}" = "true" ]; then update_policy "${policy}"; fi
    elif [ "${id}" != "${policy}" ]; then
      log_error_exit "Unknown response, failed to create policy?" "${resp}"
    fi
  }

  echo
  echo "Creating and adding ISM policies"
  for policy in kubeaudit kubernetes other; do
    create_update_policy "${policy}"
  done
}

init_indices() {
  echo
  echo "Creating initial indices"

  for idx in other kubernetes kubeaudit; do
    indices=$(curl -X GET "${es_url}/_cat/aliases/${idx}" \
      -k -s -u "${auth}")
    if echo "${indices}" | grep "true" > /dev/null; then # idx exists
      echo "Index '${idx}' already exists"
    else # create idx
      resp=$(curl -X PUT "${es_url}/%3C${idx}-default-%7Bnow%2Fd%7D-000001%3E" \
        -H 'Content-Type: application/json' \
        -k -s -u "${auth}" \
        -d '{"aliases": {"'"${idx}"'": {"is_write_index": true }}}')
      acknowledged=$(echo "${resp}" | grep "^{" | jq -r '.acknowledged')
      if [ "${acknowledged}" = "true" ]; then
        echo "Created index '${idx}'"
      else
        log_error_exit "Failed to create index '${idx}'" "${resp}"
      fi
    fi
  done
}

create_role() {
  role_name="$1"; role_definition="$2"
  response=$(curl -X PUT "${es_url}/_opendistro/_security/api/roles/${role_name}" \
    -H 'Content-Type: application/json' \
    -k -s -u "${auth}" \
    -d "${role_definition}")

  status=$(echo "${response}" | grep "^{" | jq -r '.status')

  case "${status}" in
    CREATED|OK)
      echo "Role '${role_name}' created"
      ;;
    *)
      log_error_exit "Failed to create role '${role_name}'" "${response}"
      ;;
  esac
}

create_rolemapping() {
  rolemapping_name="$1"; role_definition="$2"
  response=$(curl -X PUT "${es_url}/_opendistro/_security/api/rolesmapping/${rolemapping_name}" \
    -H 'Content-Type: application/json' \
    -k -s -u "${auth}" \
    -d "${role_definition}")

  status=$(echo "${response}" | grep "^{" | jq -r '.status')

  case "${status}" in
    CREATED|OK)
      echo "Rolemapping '${rolemapping_name}' created"
      ;;
    *)
      log_error_exit "Failed to create role mapping '${rolemapping_name}'" "${response}"
      ;;
  esac
}

create_user() {
  user_name="$1"; user_info="$2"
  response=$(curl -X PUT "${es_url}/_opendistro/_security/api/internalusers/${user_name}" \
    -H 'Content-Type: application/json' \
    -k -s -u "${auth}" \
    -d "${user_info}")

  status=$(echo "${response}" | grep "^{" | jq -r '.status')

  case "${status}" in
    CREATED|OK)
      echo "User '${user_name}' created"
      ;;
    *)
      log_error_exit "Failed to create user '${user_name}'" "${response}"
      ;;
  esac
}

wait_for_kibana
setup_kibana_dashboard
register_s3_repository
create_index_templates
setup_policies
if [ "${create_indices}" = "true" ]; then init_indices; fi

echo
echo "Creating roles"
for row in $(echo "${roles}"  | jq -r '.[] | @base64'); do
    _jq() {
      echo "${row}" | base64 -d | jq -r ${1}
    }

    create_role "$(_jq '.role_name')" "$(_jq '.definition')"
done

echo
echo "Creating role mappings"
for row in $(echo "${rolesmappings}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${row} | base64 -d | jq -r ${1}
    }

    create_rolemapping "$(_jq '.mapping_name')" "$(_jq '.definition')"
done

echo
echo "Creating users"
for row in $(echo "${users}"  | jq -r '.[] | @base64'); do
    _jq() {
        echo ${row} | base64 -d | jq -r ${1}
    }

    create_user "$(_jq '.username')" "$(_jq '.definition')"
done

echo
echo "Done configuring elasticsearch and kibana"
