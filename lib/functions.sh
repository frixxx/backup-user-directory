# ----- check functions ------------------------------------------------------------
is_homebrew_installed () {
  which brew >/dev/null
  if [[ $? -eq 1 ]]; then
    echo "You do not have Homebrew installed.
Please install Homebrew first.
Visit https://brew.sh/ for more details."
    exit 1
  fi
}

is_application_installed_with_homebrew () {
  brew list -1 | grep -q "^${1}\$"
  if [[ $? -eq 1 ]]; then
  	echo "${1} is not properly installed.
Install the Homebrew Version please.
-> brew install ${1}"
  	exit 1
  fi
}

is_ssh_key_present () {
  if [[ -z $FX_BACKUP_SSH_KEY_PATH ]]; then
    echo "FX_BACKUP_SSH_KEY_PATH is missing."
    exit 1
  fi
}

is_remote_path_present() {
  (does_remote_path_exist "${1}" "${2}")

  if [[ "$?" == "1" ]]; then
    echo "Remote path '${2}' does not exist."
    exit 1
  fi
}

does_remote_path_exist() {
  RESPONSE=$(ssh "${1}" "[[ -d '${2}' ]] && echo yes || echo no")
  if [[ "${RESPONSE}" == "no" ]]; then
    exit 1
  else
    exit 0
  fi
}


# ----- exclusion functions ------------------------------------------------------------
get_time_machine_exclusions() {
  echo "$(sudo mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'")"
}

add_time_machine_exclusions_to_exclusion_file() {
  EXCLUSIONS=$(get_time_machine_exclusions)

  COUNT=$(echo "${1}" | wc -m)
  while IFS= read -r line; do
  	if [[ "${line:0:($COUNT-1)}" == "${1}" ]] then
  		echo "${line}" >> $2
  	fi
  done <<< "${EXCLUSIONS}"
}

# ----- other functions ------------------------------------------------------------
create_remote_path_if_not_exists() {
  (does_remote_path_exist "${1}" "${2}")
  if [[ "$?" == "1" ]]; then
    echo -n "The remote directory '${2}' does not exist.
Creating remote directory '${2}' ... "
    ssh ${1} "mkdir -p ${2}"
    echo "done"
  fi
}

getDateTime() {
  date +"%d.%m.%Y %H:%M:%S"
}

logStatusMessage() {
#  type ssh || echo "ssh not found"
#  type ssh
  if [[ "${REMOTE_LOGGING_ENABLED}" == "1" ]]; then
    SSH=$(which ssh)
    local clientName="${1}"
    local path="${2}"
    local state="${3}"
    echo "LOG: '${DESTINATION_SERVER}:${REMOTE_LOGGING_SCRIPT} ${clientName} ${path} ${state}"
    $SSH -q "${DESTINATION_SERVER}" -t "${REMOTE_LOGGING_SCRIPT} ${clientName} ${path} ${state}"
  fi
}

is_dry_run() {
  for arg in "$@"; do
    case $arg in
      --dry-run)
        return 0  # found dry-run flag
        ;;
    esac
  done
  return 1  # not found
}

is_debug() {
  for arg in "$@"; do
    case $arg in
      --debug)
        return 0  # found dry-run flag
        ;;
    esac
  done
  return 1  # not found
}

load_env_file() {
  local env_file="${1}"
  if [[ -f "${env_file}" ]]; then
    echo "Loading environment variables from ${env_file}"
    source "${env_file}"
  else
    echo "No environment file found at ${env_file}, please provide one."
    exit 1
  fi
}

validate_configuration() {
  if [[ -z "${BACKUP_USER_DIRECTORY___REMOTE_SERVER}" ]]; then
    echo "Error: BACKUP_USER_DIRECTORY___REMOTE_SERVER is missing in ${ENV_FILE}."
    exit 1
  fi
}

replace_hostname_if_needed() {
  if [[ -n "${BACKUP_USER_DIRECTORY___HOSTNAME_REPLACEMENT}" ]]; then
    local tmp="Hostname '${HOSTNAME}' replaced with '${BACKUP_USER_DIRECTORY___HOSTNAME_REPLACEMENT}'"
    HOSTNAME="${BACKUP_USER_DIRECTORY___HOSTNAME_REPLACEMENT}"
    echo "${tmp}"
  fi
}
