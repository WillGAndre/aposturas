#!/bin/bash -euo pipefail

# Configuration
EMTD="aes-256-cbc"
PMTD="pbkdf2"
ARCH="archive"
CURR="current"
CFGS="--silent --connect-timeout 10 --max-time 15"
declare -a services=("transfer.sh" "0x0.st" "file.io" "anonfiles" "catbox")

git_encrypt() {
    local TIMESTAMP=$(date +%Y%m%d%H%M%S)
    local ARCH_PATH="${ARCH}/apostura_${TIMESTAMP}.tgz.enc"
    local TMPASS=$(openssl rand -base64 32)
    echo "Temporary password: ${TMPASS}"
    read -sp "Password: " PASSWORD
    echo
    tar -czf - "${CURR}" | openssl enc -${EMTD} -${PMTD} -salt -out "${ARCH_PATH}" -pass pass:"${PASSWORD}"
    echo -e "\n[$TIMESTAMP] Encrypted archive at ${ARCH_PATH}"
}

git_decrypt() {
    local TIMESTAMP=$(date +%Y%m%d%H%M%S)
    local LATEST_ARCHIVE=$(ls -t ${ARCH}/*.tgz.enc | head -1)
    if [ -z "${LATEST_ARCHIVE}" ]; then
        echo -e "\nNo archives to decrypt."
    else
        read -sp "Password: " PASSWORD
        echo
        openssl enc -${EMTD} -${PMTD} -d -in "${LATEST_ARCHIVE}" -out "${ARCH}/latest.tgz" -pass pass:"${PASSWORD}"
        tar -xzf "${ARCH}/latest.tgz" -C ./
        rm "${ARCH}/latest.tgz"
        echo -e "\n[$TIMESTAMP] Decryption complete."
    fi
}

upload_file() {
    local file_path="$1"
    local service="$2"
    case $service in
        transfer.sh)
            echo $(curl ${CFGS} --upload-file ./${file_path} https://transfer.sh/${file_path} -H "Max-Days: 1")
            ;;
        0x0.st)
            echo $(curl ${CFGS} -F"file=@${file_path}" https://0x0.st)
            ;;
        file.io)
            echo "[!] Single download only"
            echo $(curl ${CFGS} -F "file=@${file_path}" https://file.io/?expires=5m)
            ;;
        anonfiles)
            echo $(curl ${CFGS} -F "file=@${file_path}" https://api.anonfiles.com/upload)
            ;;
        catbox)
            echo $(curl ${CFGS} -F "reqtype=fileupload" -F "fileToUpload=@${file_path}" https://catbox.moe/user/api.php)
            ;;
    esac
}


case "$1" in 
    -u) ## Upload Script
        SCRIPT_PATH="${BASH_SOURCE[0]}"
        UPLOAD_SCRIPT_PATH="${SCRIPT_PATH}"
        if [[ "${2-}" == "-e" ]]; then
            ENCRYPTED_SCRIPT_PATH="${SCRIPT_PATH}.enc"
            TMPASS=$(openssl rand -base64 32)
            echo "Encrypting with temporary password: ${TMPASS}"
            openssl enc -${EMTD} -${PMTD} -salt -in "${SCRIPT_PATH}" -out "${ENCRYPTED_SCRIPT_PATH}" -pass pass:"${TMPASS}"
            UPLOAD_SCRIPT_PATH="${ENCRYPTED_SCRIPT_PATH}"
        fi
        shuffle=($(shuf -e "${services[@]}"))
        for service in "${shuffle[@]}"; do
            echo "[$service] Trying to upload script"
            UPLOAD_URL=$(upload_file "${UPLOAD_SCRIPT_PATH}" $service)
            if [ -n "$UPLOAD_URL" ]; then
                echo -e "[$service] Script uploaded successfully \n\n${UPLOAD_URL}"
                [[ "${2-}" == "-e" ]] && echo -e "\n[Decryption]\n\t1. curl <link> --output e.enc \n\t2. openssl enc -"${EMTD}" -"${PMTD}" -d -in e.enc -out "${BASH_SOURCE[0]}" -pass pass:"${TMPASS}" \n\t3. rm e.enc" && rm "${ENCRYPTED_SCRIPT_PATH}"
                exit 0
            else
                echo "[$service] Failed to upload script"
            fi
        done
        echo "Failed to upload the script to any service."
        exit 1
        ;;
    -up) ## Upload Password
        read -sp "Use temporary password? (y/n) " PCNT
        echo
        if [[ $PCNT == 'y' || $PCNT == 'Y' ]]; then
            PG=$(openssl rand -base64 32)
            echo "Candidate password: ${PG}"
        elif [[ $PCNT == 'n' || $PCNT == 'N' ]]; then
            read -sp "Password: " PG
            echo
        fi
        read -sp "Continue? (y/n) " CNT
        echo
        if [[ $CNT == 'n' || $CNT == 'N' ]]; then
            echo "Aborted"
            exit 1
        fi
        PGF="pgf.txt"
        echo "${PG}" > "${PGF}"
        shuffle=($(shuf -e "${services[@]}"))
        for service in "${shuffle[@]}"; do
            echo "[$service] Trying"
            UPLOAD_URL=$(upload_file "$PGF" $service)
            if [ -n "$UPLOAD_URL" ]; then
                echo -e "[$service] Success \n\n${UPLOAD_URL}"
                rm "${PGF}"
                break
            else
                echo "[$service] Failed"
            fi
        done
        ;;
    -e) git_encrypt ;; ## Git Archive Encrypt
    -d) git_decrypt ;; ## Git Archive Decrypt
    *)
        echo "Usage: $0 [-u [-e]] | -up | -e | -d"
        echo "-u: Upload this script. Optionally use -e to encrypt before upload."
        echo "-up: Upload Password"
        echo "-e: Encrypt the 'current' directory and move to 'archive'."
        echo "-d: Decrypt the latest archive in 'archive'."
        exit 1
        ;;
esac