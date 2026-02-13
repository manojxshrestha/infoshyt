#!/bin/bash

# infoshyt - OSINT Reconnaissance Tool
# Usage: ./infoshyt.sh -d <domain> [-D]

# Colors
reset='\033[0m'
bred='\033[1;31m'
yellow='\033[1;33m'

# Variables
LOGFILE="infoshyt.log"
tools=$(cat infoshyt.cfg | grep "TOOLS_DIR" | cut -d'=' -f2)
source infoshyt.cfg

# Default values
OSINT=true
GOOGLE_DORKS=true
GITHUB_DORKS=true
GITHUB_REPOS=true
METADATA=true
API_LEAKS=true
EMAILS=true
DOMAIN_INFO=true
THIRD_PARTIES=true
SPOOF=true
IP_INFO=true
MAIL_HYGIENE=true
CLOUD_ENUM=true
FAVICON=true
ZONETRANSFER=true
HUDSON_ROCK=true
DIFF=false
DEEP=false
INTERLACE_THREADS=10

# Parse command line arguments
while getopts "d:D" opt; do
    case $opt in
        d) domain="$OPTARG";;
        D) DIFF=true;;
        ?) echo "Usage: $0 -d <domain> [-D]"; exit 1;;
    esac
done

# Check if domain is provided
if [ -z "$domain" ]; then
    echo "Usage: $0 -d <domain> [-D]"
    exit 1
fi

# Set directory structure
dir="$PWD/results/$domain"
called_fn_dir="$dir"
mkdir -p "$dir/osint" "$dir/.tmp" 2>>"$LOGFILE"
echo -e "${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [INFO] Using directory: $dir${reset}" >>"$LOGFILE"

# Start function
start_func() {
    local func_name=$1
    local message=$2
    printf "\n%b[%s] [START] %s%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$message" "$reset" >>"$LOGFILE"
    echo -e "\n${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [START] $message${reset}"
}

# End function
end_func() {
    local message=$1
    local func_name=$2
    printf "%b[%s] [END] %s%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$message" "$reset" >>"$LOGFILE"
    echo -e "${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [END] $message${reset}"
    touch "$called_fn_dir/.${func_name}"
}

# Banner
echo -e "
 ▄▀▀█▀▄    ▄▀▀▄ ▀▄  ▄▀▀▀█▄    ▄▀▀▀▀▄   ▄▀▀▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀▄ ▀▀▄  ▄▀▀▀█▀▀▄ 
█   █  █  █  █ █ █ █  ▄▀  ▀▄ █      █ █ █   ▐ █  █   ▄▀ █   ▀▄ ▄▀ █    █  ▐ 
▐   █  ▐  ▐  █  ▀█ ▐ █▄▄▄▄   █      █    ▀▄   ▐  █▄▄▄█  ▐     █   ▐   █     
    █       █   █   █    ▐   ▀▄    ▄▀ ▀▄   █     █   █        █      █      
 ▄▀▀▀▀▀▄  ▄▀   █    █          ▀▀▀▀    █▀▀▀     ▄▀  ▄▀      ▄▀     ▄▀       
█       █ █    ▐   █                   ▐       █   █        █     █         
▐       ▐ ▐        ▐                   ▐   ▐        ▐     ▐         
         
                    OSINT Reconnaissance Tool                    
                                    by ~/.manojxshrestha             
"

# Start OSINT scan
echo -e "${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [START] OSINT scan for $domain${reset}"

# OSINT Functions

function google_dorks() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $GOOGLE_DORKS == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Running: Google Dorks in process"

        if ! "${tools}/dorks_hunter/venv/bin/python3" "${tools}/dorks_hunter/dorks_hunter.py" -d "$domain" -o "$dir/osint/dorks.txt" 2>>"$LOGFILE"; then
            printf "%b[!] dorks_hunter.py command failed.%b\n" "$bred" "$reset"
            return 1
        fi
        end_func "Results are saved in $domain/osint/dorks.txt" "${FUNCNAME[0]}"
    else
        if [[ $GOOGLE_DORKS == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function github_dorks() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $GITHUB_DORKS == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Running: Github Dorks in process"

        if [[ -s $GITHUB_TOKENS ]]; then
            if [[ $DEEP == true ]]; then
                if ! gitdorks_go -gd "${tools}/gitdorks_go/Dorks/medium_dorks.txt" -nws 20 -target "$domain" -tf "$GITHUB_TOKENS" -ew 3 | anew -q "$dir/osint/gitdorks.txt" 2>>"$LOGFILE"; then
                    printf "%b[!] gitdorks_go command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            else
                if ! gitdorks_go -gd "${tools}/gitdorks_go/Dorks/smalldorks.txt" -nws 20 -target "$domain" -tf "$GITHUB_TOKENS" -ew 3 | anew -q "$dir/osint/gitdorks.txt" 2>>"$LOGFILE"; then
                    printf "%b[!] gitdorks_go command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            fi
        else
            printf "\n%b[%s] Required file %s does not exist or is empty.%b\n" "$bred" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$GITHUB_TOKENS" "$reset"
            return 1
        fi
        end_func "Results are saved in $domain/osint/gitdorks.txt" "${FUNCNAME[0]}"
    else
        if [[ $GITHUB_DORKS == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function github_repos() {
    mkdir -p "$dir/osint" "$dir/.tmp"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $GITHUB_REPOS == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Github Repos analysis in process"

        if [[ -s $GITHUB_TOKENS ]]; then
            GH_TOKEN=$(head -n 1 "$GITHUB_TOKENS")
            echo "$domain" | unfurl format %r >"$dir/.tmp/company_name.txt"

            if ! enumerepo -token-string "$GH_TOKEN" -usernames "$dir/.tmp/company_name.txt" -o "$dir/.tmp/company_repos.txt" 2>>"$LOGFILE" >/dev/null; then
                printf "%b[!] enumerepo command failed.%b\n" "$bred" "$reset"
                return 1
            fi

            if [[ -s "$dir/.tmp/company_repos.txt" ]]; then
                if ! jq -r '.[].repos[]|.url' <"$dir/.tmp/company_repos.txt" >"$dir/.tmp/company_repos_url.txt" 2>>"$LOGFILE"; then
                    printf "%b[!] jq command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            fi

            mkdir -p "$dir/.tmp/github_repos" "$dir/.tmp/github" 2>>"$LOGFILE"

            if [[ -s "$dir/.tmp/company_repos_url.txt" ]]; then
                if ! interlace -tL "$dir/.tmp/company_repos_url.txt" -threads "$INTERLACE_THREADS" -c "git clone _target_ $dir/.tmp/github_repos/_cleantarget_" 2>>"$LOGFILE" >/dev/null; then
                    printf "%b[!] interlace git clone command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            else
                end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
                return 1
            fi

            if [[ -d "$dir/.tmp/github_repos/" ]]; then
                ls "$dir/.tmp/github_repos" >"$dir/.tmp/github_repos_folders.txt"
            else
                end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
                return 1
            fi

            if [[ -s "$dir/.tmp/github_repos_folders.txt" ]]; then
                if ! interlace -tL "$dir/.tmp/github_repos_folders.txt" -threads "$INTERLACE_THREADS" -c "gitleaks detect --source $dir/.tmp/github_repos/_target_ --no-banner --no-color -r $dir/.tmp/github/gh_secret_cleantarget_.json" 2>>"$LOGFILE" >/dev/null; then
                    printf "%b[!] interlace gitleaks command failed.%b\n" "$bred" "$reset"
                    end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
                    return 1
                fi
            else
                end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
                return 1
            fi

            if [[ -s "$dir/.tmp/company_repos_url.txt" ]]; then
                if ! interlace -tL "$dir/.tmp/company_repos_url.txt" -threads "$INTERLACE_THREADS" -c "trufflehog git _target_ -j 2>&1 | jq -c > _output_/_cleantarget_" -o "$dir/.tmp/github/" 2>>"$LOGFILE" >/dev/null; then
                    printf "%b[!] interlace trufflehog command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            fi

            if [[ -d "$dir/.tmp/github/" ]]; then
                if ! cat "$dir/.tmp/github/"* 2>/dev/null | jq -c | jq -r >"$dir/osint/github_company_secrets.json" 2>>"$LOGFILE"; then
                    printf "%b[!] Error combining results.%b\n" "$bred" "$reset"
                    return 1
                fi
            else
                end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
                return 1
            fi

            end_func "Results are saved in $domain/osint/github_company_secrets.json" "${FUNCNAME[0]}"
        else
            printf "\n%b[%s] Required file %s does not exist or is empty.%b\n" "$bred" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$GITHUB_TOKENS" "$reset"
            return 1
        fi
    else
        if [[ $GITHUB_REPOS == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function metadata() {
    mkdir -p "$dir/osint" "$dir/.tmp"

    # Check if the function should run
    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $METADATA == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Scanning metadata in public files"

        mkdir -p "$dir/.tmp/metagoofil_${domain}/" 2>>"$LOGFILE"
        if [ ! -f "${tools}/metagoofil/venv/bin/python3" ] || [ ! -f "${tools}/metagoofil/metagoofil.py" ]; then
            printf "%b[!] metagoofil.py or its Python environment not found at ${tools}/metagoofil/.%b\n" "$bred" "$reset" >>"$LOGFILE"
            return 1
        fi
        if ! "${tools}/metagoofil/venv/bin/python3" "${tools}/metagoofil/metagoofil.py" -d "$domain" -t pdf,docx,xlsx -l 10 -w -o "$dir/.tmp/metagoofil_${domain}/" 2>>"$LOGFILE" >/dev/null; then
            printf "%b[!] metagoofil.py command failed (exit code: $?). Check ${tools}/metagoofil/requirements.txt for missing dependencies.%b\n" "$bred" "$reset" >>"$LOGFILE"
            return 1
        fi
        if ! exiftool -r "$dir/.tmp/metagoofil_${domain}/*" 2>>"$LOGFILE" | tee /dev/null | egrep -i "Author|Creator|Email|Producer|Template" | sort -u | anew -q "$dir/osint/metadata_results.txt" 2>>"$LOGFILE"; then
            printf "%b[!] exiftool processing failed.%b\n" "$bred" "$reset" >>"$LOGFILE"
            return 1
        fi

        end_func "Results are saved in $domain/osint/[software/authors/metadata_results].txt" "${FUNCNAME[0]}"
    else
        if [[ $METADATA == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function apileaks() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $API_LEAKS == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Scanning for leaks in public API directories"

        if ! porch-pirate -s "$domain" -l 25 --dump 2>>"$LOGFILE" >"$dir/osint/postman_leaks.txt"; then
            printf "%b[!] porch-pirate command failed.%b\n" "$bred" "$reset"
            return 1
        fi

        if ! pushd "${tools}/SwaggerSpy" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/SwaggerSpy" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if ! "${tools}/SwaggerSpy/venv/bin/python3" swaggerspy.py "$domain" 2>>"$LOGFILE" | grep -i "[*]\|URL" >"$dir/osint/swagger_leaks.txt"; then
            printf "%b[!] swaggerspy.py command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to the previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -s "$dir/osint/postman_leaks.txt" ]]; then
            if ! trufflehog filesystem "$dir/osint/postman_leaks.txt" -j 2>/dev/null | jq -c | anew -q "$dir/osint/postman_leaks_trufflehog.json" 2>>"$LOGFILE"; then
                printf "%b[!] trufflehog (postman) failed.%b\n" "$bred" "$reset"
            fi
        fi

        if [[ -s "$dir/osint/swagger_leaks.txt" ]]; then
            if ! trufflehog filesystem "$dir/osint/swagger_leaks.txt" -j 2>/dev/null | jq -c | anew -q "$dir/osint/swagger_leaks_trufflehog.json" 2>>"$LOGFILE"; then
                printf "%b[!] trufflehog (swagger) failed.%b\n" "$bred" "$reset"
            fi
        fi

        end_func "Results are saved in $domain/osint/[postman_leaks_trufflehog.json, swagger_leaks_trufflehog.json]" "${FUNCNAME[0]}"
    else
        if [[ $API_LEAKS == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function emails() {
    mkdir -p "$dir/.tmp" "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $EMAILS == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for emails/users/passwords leaks"

        if ! "${tools}/EmailHarvester/venv/bin/python3" "${tools}/EmailHarvester/EmailHarvester.py" -d "$domain" -e all -l 20 2>>"$LOGFILE" | anew -q "$dir/.tmp/EmailHarvester.txt"; then
            printf "%b[!] EmailHarvester.py command failed.%b\n" "$bred" "$reset"
            return 1
        fi

        if [[ -s "$dir/.tmp/EmailHarvester.txt" ]]; then
            if ! grep "@" "$dir/.tmp/EmailHarvester.txt" | anew -q "$dir/osint/emails.txt" 2>>"$LOGFILE"; then
                printf "%b[!] email grep failed.%b\n" "$bred" "$reset"
                return 1
            fi
        fi

        if ! pushd "${tools}/LeakSearch" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/LeakSearch" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if ! "${tools}/LeakSearch/venv/bin/python3" LeakSearch.py -k "$domain" -o "$dir/.tmp/passwords.txt" 1>>"$LOGFILE"; then
            printf "%b[!] LeakSearch.py command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to the previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -s "$dir/.tmp/passwords.txt" ]]; then
            if ! anew -q "$dir/osint/passwords.txt" <"$dir/.tmp/passwords.txt" 2>>"$LOGFILE"; then
                printf "%b[!] password anew failed.%b\n" "$bred" "$reset"
                return 1
            fi
        fi

        end_func "Results are saved in $domain/osint/emails.txt and passwords.txt" "${FUNCNAME[0]}"
    else
        if [[ $EMAILS == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s%b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "/.${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function domain_info() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $DOMAIN_INFO == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching domain info (whois, registrant name/email domains)"

        if ! whois "$domain" >"$dir/osint/domain_info_general.txt" 2>>"$LOGFILE"; then
            printf "%b[!] whois command failed.%b\n" "$bred" "$reset"
            return 1
        fi
        if ! "${tools}/msftrecon/venv/bin/python3" "${tools}/msftrecon/msftrecon/msftrecon.py" -d "$domain" 2>>"$LOGFILE" >"$dir/osint/azure_tenant_domains.txt"; then
            printf "%b[!] msftrecon.py command failed.%b\n" "$bred" "$reset"
            return 1
        fi

        company_name=$(unfurl format %r <<<"$domain")
        if ! "${tools}/Scopify/venv/bin/python3" "${tools}/Scopify/scopify.py" -c "$company_name" >"$dir/osint/scopify.txt" 2>>"$LOGFILE"; then
            printf "%b[!] scopify.py command failed.%b\n" "$bred" "$reset"
            return 1
        fi

        end_func "Results are saved in $domain/osint/domain_info_[general/azure_tenant_domains].txt" "${FUNCNAME[0]}"
    else
        if [[ $DOMAIN_INFO == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s%b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "/.${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function third_party_misconfigs() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $THIRD_PARTIES == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for third parties misconfigurations"

        company_name=$(unfurl format %r <<<"$domain")

        if ! pushd "${tools}/misconfig-mapper" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/misconfig-mapper" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if ! misconfig-mapper -target "$company_name" -service "*" 2>&1 | grep -v "\-\]" | grep -v "Failed" >"$dir/osint/3rdparts_misconfigurations.txt" 2>>"$LOGFILE"; then
            printf "%b[!] misconfig-mapper command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        end_func "Results are saved in $domain/osint/3rdparts_misconfigurations.txt" "${FUNCNAME[0]}"
    else
        if [[ $THIRD_PARTIES == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s%b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "/.${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function spoof() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $SPOOF == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for spoofable domains"

        if ! pushd "${tools}/Spoofy" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/Spoofy" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if ! "${tools}/Spoofy/venv/bin/python3" spoofy.py -d "$domain" >"$dir/osint/spoof.txt" 2>>"$LOGFILE"; then
            printf "%b[!] spoofy.py command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        end_func "Results are saved in $domain/osint/spoof.txt" "${FUNCNAME[0]}"
    else
        if [[ $SPOOF == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s%b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "/.${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function ip_info() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $IP_INFO == true ]] && [[ $OSINT == true ]] && [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching IP info"

        if [[ -n $WHOISXML_API ]]; then
            if ! curl -s "https://reverse-ip.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ip=${domain}" | jq -r '.result[].name' 2>>"$LOGFILE" | sed -e "s/$/ ${domain}/" | anew -q "$dir/osint/ip_${domain}_relations.txt" 2>>"$LOGFILE"; then
                printf "%b[!] reverse-ip lookup failed.%b\n" "$bred" "$reset"
                return 1
            fi

            if ! curl -s "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=${WHOISXML_API}&domainName=${domain}&outputFormat=json&da=2®istryRawText=1®istrarRawText=1&ignoreRawTexts=1" | jq 2>>"$LOGFILE" | anew -q "$dir/osint/ip_${domain}_whois.txt" 2>>"$LOGFILE"; then
                printf "%b[!] whois lookup failed.%b\n" "$bred" "$reset"
                return 1
            fi

            if ! curl -s "https://ip-geolocation.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ipAddress=${domain}" | jq -r '.ip,.location' 2>>"$LOGFILE" | anew -q "$dir/osint/ip_${domain}_location.txt" 2>>"$LOGFILE"; then
                printf "%b[!] geolocation lookup failed.%b\n" "$bred" "$reset"
                return 1
            fi

            end_func "Results are saved in $domain/osint/ip_[domain_relations|whois|location].txt" "${FUNCNAME[0]}"
        else
            printf "\n%b[%s] WHOISXML_API variable is not defined. Skipping function.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$reset"
        fi
    else
        if [[ $IP_INFO == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s%b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "/.${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function mail_hygiene() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $MAIL_HYGIENE == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Mail hygiene (SPF/DMARC)"

        {
            printf "Domain: %s\n" "$domain"
            printf "\nTXT records:\n"
            dig +short TXT "$domain" | sed 's/^/  /'
            printf "\nDMARC record:\n"
            dig +short TXT "_dmarc.$domain" | sed 's/^/  /'
        } >"$dir/osint/mail_hygiene.txt" 2>>"$LOGFILE"

        end_func "Results are saved in $domain/osint/mail_hygiene.txt" "${FUNCNAME[0]}"
    else
        if [[ $MAIL_HYGIENE == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function cloud_enum_scan() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $CLOUD_ENUM == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Cloud storage enumeration"

        company_name=$(echo "$domain" | unfurl format %r)
        cloud_enum -k "$company_name" -k "$domain" -k "${domain%%.*}" 2>>"$LOGFILE" | anew -q "$dir/osint/cloud_enum.txt"

        end_func "Results are saved in $domain/osint/cloud_enum.txt" "${FUNCNAME[0]}"
    else
        if [[ $CLOUD_ENUM == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function favicon() {
    mkdir -p "$dir/hosts" "$dir/.tmp/virtualhosts"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $FAVICON == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Favicon IP Lookup"

        if ! pushd "${tools}/fav-up" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s @ line %s.%b\n" "$bred" "${tools}/fav-up" "${FUNCNAME[0]}" "${LINENO}" "$reset"
            return 1
        fi

        timeout 10m "${tools}/fav-up/venv/bin/python3" "${tools}/fav-up/favUp.py" -w "$domain" -sc -o "$dir/hosts/favicontest.json" 2>>"$LOGFILE" >/dev/null

        if [[ -s "$dir/hosts/favicontest.json" ]]; then
            jq -r 'try .found_ips' "$dir/hosts/favicontest.json" 2>>"$LOGFILE" | grep -v "not-found" >"$dir/hosts/favicontest.txt"
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        end_func "Results are saved in $domain/hosts/favicontest.txt" "${FUNCNAME[0]}"
    else
        if [[ $FAVICON == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function zonetransfer() {
    mkdir -p "$dir/subdomains"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $ZONETRANSFER == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Zone transfer check"

        for ns in $(dig +short ns "$domain" 2>>"$LOGFILE"); do
            dig axfr "${domain}" @"$ns" 2>>"$LOGFILE" | tee -a "$dir/subdomains/zonetransfer.txt" >/dev/null
        done

        end_func "Results are saved in $domain/subdomains/zonetransfer.txt" "${FUNCNAME[0]}"
    else
        if [[ $ZONETRANSFER == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

function hudson_rock() {
    mkdir -p "$dir/osint"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $HUDSON_ROCK == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching Hudson Rock Infostealer Intelligence"

        # Domain search
        curl -s "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-domain?domain=${domain}" >"$dir/osint/hudson_rock_domain.json" 2>>"$LOGFILE"

        # Parse and save readable output
        if [[ -s "$dir/osint/hudson_rock_domain.json" ]]; then
            {
                echo "=== Hudson Rock Infostealer Intelligence ==="
                echo "Domain: $domain"
                echo ""
                jq -r '.[] | "Compromised Credentials Found: \(.infected_computers // 0)\nStealer Type: \(.stealer_type // "N/A")\nFirst Seen: \(.first_seen // "N/A")\nLast Seen: \(.last_seen // "N/A")\n"' "$dir/osint/hudson_rock_domain.json" 2>>"$LOGFILE" || true
            } >"$dir/osint/hudson_rock.txt" 2>>"$LOGFILE"
        fi

        end_func "Results are saved in $domain/osint/hudson_rock_domain.json and hudson_rock.txt" "${FUNCNAME[0]}"
    else
        if [[ $HUDSON_ROCK == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
        elif [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            return
        else
            printf "%b[%s] %s has already been processed. To force execution, delete:\n    %s/.%s %b\n\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$called_fn_dir" "${FUNCNAME[0]}" "$reset"
        fi
    fi
}

# Execute OSINT functions
google_dorks
github_dorks
github_repos
metadata
apileaks
emails
hudson_rock
domain_info
third_party_misconfigs
spoof
ip_info
mail_hygiene
cloud_enum_scan
favicon
zonetransfer

# End OSINT scan
echo -e "${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [END] OSINT scan completed for $domain${reset}"
