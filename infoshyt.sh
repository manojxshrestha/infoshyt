#!/bin/bash

# infoshyt - OSINT Reconnaissance Tool
# Usage: ./infoshyt.sh -d <domain> [-D]

# Colors
reset='\033[0m'
bred='\033[1;31m'
yellow='\033[1;33m'
cyan='\033[1;36m'
green='\033[0;32m'

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

# Hudson Rock search targets
HUDSON_DOMAIN=""
HUDSON_EMAIL=""
HUDSON_USERNAME=""
HUDSON_PHONE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d=*)
            domain="${1#*=}"
            ;;
        -d)
            domain="$2"
            shift
            ;;
        -D)
            DIFF=true
            ;;
        --username=*)
            HUDSON_USERNAME="${1#*=}"
            ;;
        --username)
            HUDSON_USERNAME="$2"
            shift
            ;;
        --email=*)
            HUDSON_EMAIL="${1#*=}"
            ;;
        --email)
            HUDSON_EMAIL="$2"
            shift
            ;;
        --phone=*)
            HUDSON_PHONE="${1#*=}"
            ;;
        --phone)
            HUDSON_PHONE="$2"
            shift
            ;;
    esac
    shift
done

# Check if domain is provided
if [ -z "$domain" ] && [ -z "$HUDSON_EMAIL" ] && [ -z "$HUDSON_USERNAME" ] && [ -z "$HUDSON_PHONE" ]; then
    echo "Usage: $0 -d <domain> [--username <user> --email <email> --phone <number>] [-D]"
    echo ""
    echo "Options:"
    echo "  -d <domain>        Target domain"
    echo "  --username <user>  Search by username"
    echo "  --email <email>    Search by email"
    echo "  --phone <number>   Search by phone number"
    echo "  -D                 Force re-run (diff mode)"
    exit 1
fi

# Set directory structure
if [[ -n "$domain" ]]; then
    dir="$PWD/results/$domain"
else
    # Use first available target as directory name
    if [[ -n "$HUDSON_EMAIL" ]]; then
        dir="$PWD/results/email_${HUDSON_EMAIL}"
    elif [[ -n "$HUDSON_USERNAME" ]]; then
        dir="$PWD/results/user_${HUDSON_USERNAME}"
    elif [[ -n "$HUDSON_PHONE" ]]; then
        dir="$PWD/results/phone_${HUDSON_PHONE}"
    fi
fi
called_fn_dir="$dir"
mkdir -p "$dir" "$dir/.tmp" 2>>"$LOGFILE"
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
    printf "%b[%s] [END] %s%b\n" "$green" "$(date +'%Y-%m-%d %H:%M:%S %z')" "$message" "$reset" >>"$LOGFILE"
    echo -e "${green}[$(date +'%Y-%m-%d %H:%M:%S %z')] [END] $message${reset}"
    touch "$called_fn_dir/.${func_name}"
}

# Banner
echo -e "${cyan}
 ▄▀▀█▀▄    ▄▀▀▄ ▀▄  ▄▀▀▀█▄    ▄▀▀▀▀▄   ▄▀▀▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀▄ ▀▀▄  ▄▀▀▀█▀▀▄ 
█   █  █  █  █ █ █ █  ▄▀  ▀▄ █      █ █ █   ▐ █  █   ▄▀ █   ▀▄ ▄▀ █    █  ▐ 
▐   █  ▐  ▐  █  ▀█ ▐ █▄▄▄▄   █      █    ▀▄   ▐  █▄▄▄█  ▐     █   ▐   █     
    █       █   █   █    ▐   ▀▄    ▄▀ ▀▄   █     █   █        █      █      
 ▄▀▀▀▀▀▄  ▄▀   █    █          ▀▀▀▀    █▀▀▀     ▄▀  ▄▀      ▄▀     ▄▀       
█       █ █    ▐   █                   ▐       █   █        █     █         
▐       ▐ ▐        ▐                   ▐   ▐        ▐     ▐         
         
                    OSINT Reconnaissance Tool                    
                                    by ~/.manojxshrestha             
${reset}"

# Start OSINT scan
echo -e "${yellow}[$(date +'%Y-%m-%d %H:%M:%S %z')] [START] OSINT scan for $domain${reset}"

# OSINT Functions

function google_dorks() {
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $GOOGLE_DORKS == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Running: Google Dorks in process"

        if [[ -f "${tools}/dorks_hunter/venv/bin/python3" ]]; then
            DORKS_PY="${tools}/dorks_hunter/venv/bin/python3"
        else
            DORKS_PY="python3"
        fi
        
        if ! "$DORKS_PY" "${tools}/dorks_hunter/dorks_hunter.py" -d "$domain" -o "$dir/dorks.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $GITHUB_DORKS == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Running: Github Dorks in process"

        if [[ -s $GITHUB_TOKENS ]]; then
            if [[ $DEEP == true ]]; then
                if ! gitdorks_go -gd "${tools}/gitdorks_go/Dorks/medium_dorks.txt" -nws 20 -target "$domain" -tf "$GITHUB_TOKENS" -ew 3 | anew -q "$dir/gitdorks.txt" 2>>"$LOGFILE"; then
                    printf "%b[!] gitdorks_go command failed.%b\n" "$bred" "$reset"
                    return 1
                fi
            else
                if ! gitdorks_go -gd "${tools}/gitdorks_go/Dorks/smalldorks.txt" -nws 20 -target "$domain" -tf "$GITHUB_TOKENS" -ew 3 | anew -q "$dir/gitdorks.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir" "$dir/.tmp"

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
                if ! cat "$dir/.tmp/github/"* 2>/dev/null | jq -c | jq -r >"$dir/github_company_secrets.json" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir" "$dir/.tmp"

    # Check if the function should run
    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $METADATA == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Scanning metadata in public files"

        mkdir -p "$dir/.tmp/metagoofil_${domain}/" 2>>"$LOGFILE"
        if [[ -f "${tools}/metagoofil/venv/bin/python3" ]]; then
            METAGOOFIL_PY="${tools}/metagoofil/venv/bin/python3"
        else
            METAGOOFIL_PY="python3"
        fi
        
        if [[ ! -f "${tools}/metagoofil/metagoofil.py" ]]; then
            printf "%b[!] metagoofil.py not found at ${tools}/metagoofil/.%b\n" "$bred" "$reset" >>"$LOGFILE"
            return 1
        fi
        
        if ! "$METAGOOFIL_PY" "${tools}/metagoofil/metagoofil.py" -d "$domain" -t pdf,docx,xlsx -l 10 -w -o "$dir/.tmp/metagoofil_${domain}/" 2>>"$LOGFILE" >/dev/null; then
            printf "%b[!] metagoofil.py command failed (exit code: $?). Check ${tools}/metagoofil/requirements.txt for missing dependencies.%b\n" "$bred" "$reset" >>"$LOGFILE"
        fi
        if ! exiftool -r "$dir/.tmp/metagoofil_${domain}/*" 2>>"$LOGFILE" | tee /dev/null | egrep -i "Author|Creator|Email|Producer|Template" | sort -u | anew -q "$dir/metadata_results.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $API_LEAKS == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Scanning for leaks in public API directories"

        porch-pirate -s "$domain" -l 25 --dump 2>>"$LOGFILE" >"$dir/postman_leaks.txt" || true

        if ! pushd "${tools}/SwaggerSpy" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/SwaggerSpy" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -f "${tools}/SwaggerSpy/venv/bin/python3" ]]; then
            SWAGGER_PY="${tools}/SwaggerSpy/venv/bin/python3"
        else
            SWAGGER_PY="python3"
        fi

        timeout 30 "$SWAGGER_PY" swaggerspy.py "$domain" 2>>"$LOGFILE" | grep -i "[*]\|URL" >"$dir/swagger_leaks.txt" || true

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to the previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -s "$dir/postman_leaks.txt" ]]; then
            if ! trufflehog filesystem "$dir/postman_leaks.txt" -j 2>/dev/null | jq -c | anew -q "$dir/postman_leaks_trufflehog.json" 2>>"$LOGFILE"; then
                printf "%b[!] trufflehog (postman) failed.%b\n" "$bred" "$reset"
            fi
        fi

        if [[ -s "$dir/swagger_leaks.txt" ]]; then
            if ! trufflehog filesystem "$dir/swagger_leaks.txt" -j 2>/dev/null | jq -c | anew -q "$dir/swagger_leaks_trufflehog.json" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir/.tmp"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $EMAILS == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for emails/users/passwords leaks"

        if ! pushd "${tools}/EmailHarvester" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/EmailHarvester" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -f "${tools}/EmailHarvester/venv/bin/python3" ]]; then
            EMAIL_PY="${tools}/EmailHarvester/venv/bin/python3"
        else
            EMAIL_PY="python3"
        fi

        if ! "$EMAIL_PY" EmailHarvester.py -d "$domain" -e all -l 20 2>>"$LOGFILE" | anew -q "$dir/.tmp/EmailHarvester.txt"; then
            printf "%b[!] EmailHarvester.py command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if [[ -s "$dir/.tmp/EmailHarvester.txt" ]]; then
            if ! grep "@" "$dir/.tmp/EmailHarvester.txt" | anew -q "$dir/emails.txt" 2>>"$LOGFILE"; then
                printf "%b[!] email grep failed.%b\n" "$bred" "$reset"
                popd >/dev/null || true
                return 1
            fi
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to popd in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if ! pushd "${tools}/LeakSearch" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/LeakSearch" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -f "${tools}/LeakSearch/venv/bin/python3" ]]; then
            LEAPKSEARCH_PY="${tools}/LeakSearch/venv/bin/python3"
        else
            LEAPKSEARCH_PY="python3"
        fi

        if ! "$LEAPKSEARCH_PY" LeakSearch.py -k "$domain" -o "$dir/.tmp/passwords.txt" 1>>"$LOGFILE"; then
            printf "%b[!] LeakSearch.py command failed.%b\n" "$bred" "$reset"
            popd >/dev/null || true
            return 1
        fi

        if ! popd >/dev/null; then
            printf "%b[!] Failed to return to the previous directory in %s at line %s.%b\n" "$bred" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -s "$dir/.tmp/passwords.txt" ]]; then
            if ! anew -q "$dir/passwords.txt" <"$dir/.tmp/passwords.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $DOMAIN_INFO == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching domain info (whois, registrant name/email domains)"

        if ! whois "$domain" >"$dir/domain_info_general.txt" 2>>"$LOGFILE"; then
            printf "%b[!] whois command failed.%b\n" "$bred" "$reset"
            return 1
        fi
        
        if [[ -f "${tools}/msftrecon/venv/bin/python3" ]]; then
            MSFTRECON_PY="${tools}/msftrecon/venv/bin/python3"
        else
            MSFTRECON_PY="python3"
        fi
        
        if ! "$MSFTRECON_PY" "${tools}/msftrecon/msftrecon/msftrecon.py" -d "$domain" 2>>"$LOGFILE" >"$dir/azure_tenant_domains.txt"; then
            printf "%b[!] msftrecon.py command failed.%b\n" "$bred" "$reset"
            return 1
        fi

        company_name=$(unfurl format %r <<<"$domain")
        
        if [[ -f "${tools}/Scopify/venv/bin/python3" ]]; then
            SCOPIFY_PY="${tools}/Scopify/venv/bin/python3"
        else
            SCOPIFY_PY="python3"
        fi
        
        if ! "$SCOPIFY_PY" "${tools}/Scopify/scopify.py" -c "$company_name" >"$dir/scopify.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $THIRD_PARTIES == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for third parties misconfigurations"

        company_name=$(unfurl format %r <<<"$domain")

        timeout 60 misconfig-mapper -target "$company_name" -service "*" 2>&1 | grep -v "\-\]" | grep -v "Failed" >"$dir/3rdparts_misconfigurations.txt" 2>>"$LOGFILE" || true

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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $SPOOF == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching for spoofable domains"

        if ! pushd "${tools}/Spoofy" >/dev/null; then
            printf "%b[!] Failed to change directory to %s in %s at line %s.%b\n" "$bred" "${tools}/Spoofy" "${FUNCNAME[0]}" "$LINENO" "$reset"
            return 1
        fi

        if [[ -f "${tools}/Spoofy/venv/bin/python3" ]]; then
            SPOOFY_PY="${tools}/Spoofy/venv/bin/python3"
        else
            SPOOFY_PY="python3"
        fi

        if ! "$SPOOFY_PY" spoofy.py -d "$domain" >"$dir/spoof.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $IP_INFO == true ]] && [[ $OSINT == true ]] && [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Searching IP info"

        if [[ -n $WHOISXML_API ]]; then
            if ! curl -s "https://reverse-ip.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ip=${domain}" | jq -r '.result[].name' 2>>"$LOGFILE" | sed -e "s/$/ ${domain}/" | anew -q "$dir/ip_${domain}_relations.txt" 2>>"$LOGFILE"; then
                printf "%b[!] reverse-ip lookup failed.%b\n" "$bred" "$reset"
                return 1
            fi

            if ! curl -s "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=${WHOISXML_API}&domainName=${domain}&outputFormat=json&da=2®istryRawText=1®istrarRawText=1&ignoreRawTexts=1" | jq 2>>"$LOGFILE" | anew -q "$dir/ip_${domain}_whois.txt" 2>>"$LOGFILE"; then
                printf "%b[!] whois lookup failed.%b\n" "$bred" "$reset"
                return 1
            fi

            if ! curl -s "https://ip-geolocation.whoisxmlapi.com/api/v1?apiKey=${WHOISXML_API}&ipAddress=${domain}" | jq -r '.ip,.location' 2>>"$LOGFILE" | anew -q "$dir/ip_${domain}_location.txt" 2>>"$LOGFILE"; then
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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $MAIL_HYGIENE == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Mail hygiene (SPF/DMARC)"

        {
            printf "Domain: %s\n" "$domain"
            printf "\nTXT records:\n"
            dig +short TXT "$domain" | sed 's/^/  /'
            printf "\nDMARC record:\n"
            dig +short TXT "_dmarc.$domain" | sed 's/^/  /'
        } >"$dir/mail_hygiene.txt" 2>>"$LOGFILE"

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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $CLOUD_ENUM == true ]] && [[ $OSINT == true ]] && ! [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        start_func "${FUNCNAME[0]}" "Cloud storage enumeration"

        company_name=$(echo "$domain" | unfurl format %r)
        cloud_enum -k "$company_name" -k "$domain" -k "${domain%%.*}" 2>>"$LOGFILE" | anew -q "$dir/cloud_enum.txt"

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

        if [[ -f "${tools}/fav-up/venv/bin/python3" ]]; then
            FAVUP_PY="${tools}/fav-up/venv/bin/python3"
        else
            FAVUP_PY="python3"
        fi

        timeout 10m "$FAVUP_PY" "${tools}/fav-up/favUp.py" -w "$domain" -sc -o "$dir/hosts/favicontest.json" 2>>"$LOGFILE" >/dev/null

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
    mkdir -p "$dir"

    if { [[ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ]] || [[ $DIFF == true ]]; } && [[ $HUDSON_ROCK == true ]] && [[ $OSINT == true ]]; then
        start_func "${FUNCNAME[0]}" "Searching Hudson Rock Infostealer Intelligence"

        # Check if any Hudson Rock target is provided
        local has_target=false
        
        # Domain search (default if domain is provided)
        if [[ -n "$domain" ]] && [[ ! "$domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            curl -s "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-domain?domain=${domain}" >"$dir/hudson_rock_domain.json" 2>>"$LOGFILE"
            has_target=true
        fi
        
        # Username search
        if [[ -n "$HUDSON_USERNAME" ]]; then
            curl -s "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-username?username=${HUDSON_USERNAME}" >"$dir/hudson_rock_username.json" 2>>"$LOGFILE"
            has_target=true
        fi
        
        # Email search
        if [[ -n "$HUDSON_EMAIL" ]]; then
            curl -s "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-email?email=${HUDSON_EMAIL}" >"$dir/hudson_rock_email.json" 2>>"$LOGFILE"
            has_target=true
        fi
        
        # Phone search
        if [[ -n "$HUDSON_PHONE" ]]; then
            curl -s "https://cavalier.hudsonrock.com/api/json/v2/osint-tools/search-by-username?username=${HUDSON_PHONE}" >"$dir/hudson_rock_phone.json" 2>>"$LOGFILE"
            has_target=true
        fi

        # Parse and save readable output
        {
            echo "=== Hudson Rock Infostealer Intelligence ==="
            
            # Domain results
            if [[ -s "$dir/hudson_rock_domain.json" ]]; then
                echo ""
                echo "=== Domain: $domain ==="
                jq -r '.stealers[]? // .[]? | "Computer: \(.computer_name // "N/A")\nOS: \(.operating_system // "N/A")\nStealer: \(.stealer_family // "N/A")\nDate Compromised: \(.date_compromised // "N/A")\nIP: \(.ip // "N/A")\nTop Passwords: \(.top_passwords[:3] | join(", ") // "N/A")\nTop Logins: \(.top_logins[:3] | join(", ") // "N/A")\n"' "$dir/hudson_rock_domain.json" 2>>"$LOGFILE" || true
            fi
            
            # Username results
            if [[ -s "$dir/hudson_rock_username.json" ]]; then
                echo ""
                echo "=== Username: $HUDSON_USERNAME ==="
                jq -r '.stealers[]? // .[]? | "Computer: \(.computer_name // "N/A")\nOS: \(.operating_system // "N/A")\nStealer: \(.stealer_family // "N/A")\nDate Compromised: \(.date_compromised // "N/A")\nIP: \(.ip // "N/A")\nTop Passwords: \(.top_passwords[:3] | join(", ") // "N/A")\nTop Logins: \(.top_logins[:3] | join(", ") // "N/A")\n"' "$dir/hudson_rock_username.json" 2>>"$LOGFILE" || true
            fi
            
            # Email results
            if [[ -s "$dir/hudson_rock_email.json" ]]; then
                echo ""
                echo "=== Email: $HUDSON_EMAIL ==="
                jq -r '.stealers[]? // .[]? | "Computer: \(.computer_name // "N/A")\nOS: \(.operating_system // "N/A")\nStealer: \(.stealer_family // "N/A")\nDate Compromised: \(.date_compromised // "N/A")\nIP: \(.ip // "N/A")\nTop Passwords: \(.top_passwords[:3] | join(", ") // "N/A")\nTop Logins: \(.top_logins[:3] | join(", ") // "N/A")\n"' "$dir/hudson_rock_email.json" 2>>"$LOGFILE" || true
            fi
            
            # Phone results
            if [[ -s "$dir/hudson_rock_phone.json" ]]; then
                echo ""
                echo "=== Phone: $HUDSON_PHONE ==="
                jq -r '.stealers[]? // .[]? | "Computer: \(.computer_name // "N/A")\nOS: \(.operating_system // "N/A")\nStealer: \(.stealer_family // "N/A")\nDate Compromised: \(.date_compromised // "N/A")\nIP: \(.ip // "N/A")\nTop Passwords: \(.top_passwords[:3] | join(", ") // "N/A")\nTop Logins: \(.top_logins[:3] | join(", ") // "N/A")\n"' "$dir/hudson_rock_phone.json" 2>>"$LOGFILE" || true
            fi
        } >"$dir/hudson_rock.txt" 2>>"$LOGFILE"

        end_func "Results are saved in $domain/hudson_rock.txt and hudson_rock_*.json" "${FUNCNAME[0]}"
    else
        if [[ $HUDSON_ROCK == false ]] || [[ $OSINT == false ]]; then
            printf "\n%b[%s] %s skipped due to mode or configuration settings.%b\n" "$yellow" "$(date +'%Y-%m-%d %H:%M:%S %z')" "${FUNCNAME[0]}" "$reset"
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
