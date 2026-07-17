#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                          BABAFRAR - XSS HUNTING FRAMEWORK                    ║
# ║                      "Catch 'em parameters, Pop 'em XSS"                     ║
# ║                     Version 2.5 - Fully Working Edition                      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# BABAFRAR THEME - Gangsta Colors
# ============================================================================
readonly GOLD='\033[0;33m'
readonly PURPLE='\033[0;35m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly BLUE='\033[0;34m'
readonly WHITE='\033[1;37m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'

# ============================================================================
# BABAFRAR CONFIG
# ============================================================================
readonly BABAFRAR_VERSION="2.5"
readonly CREATOR="baba_frar_crew"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_START_TIME=$(date +%s)

# ============================================================================
# BABAFRAR PATH SETUP - With Homebrew Support
# ============================================================================
setup_babafrar_environment() {
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"
    export PATH="${HOME}/go/bin:${PATH}"
    
    if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    export PATH="${HOME}/.local/bin:${PATH}"
    
    export BABAFRAR_TOOLS="${HOME}/babafrar_tools"
    mkdir -p "${BABAFRAR_TOOLS}"
    export PATH="${BABAFRAR_TOOLS}:${PATH}"
    
    if [ -d "${HOME}/tools/ParamSpider" ]; then
        export PATH="${HOME}/tools/ParamSpider:${PATH}"
    fi
}

# ============================================================================
# BABAFRAR GANGSTA BANNER
# ============================================================================
show_babafrar_banner() {
    clear
    echo -e "${GOLD}"
    cat << "BABAFRAR"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║         ██████╗  █████╗ ██████╗  █████╗ ███████╗██████╗  █████╗ ██████╗      ║
║         ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗     ║
║         ██████╔╝███████║██████╔╝███████║█████╗  ██████╔╝███████║██████╔╝     ║
║         ██╔══██╗██╔══██║██╔══██╗██╔══██║██╔══╝  ██╔══██╗██╔══██║██╔══██╗     ║
║         ██████╔╝██║  ██║██████╔╝██║  ██║██║     ██║  ██║██║  ██║██║  ██║     ║
║         ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝     ║
║                                                                              ║
║              🔥  XSS Hunting Framework - Gangsta Edition  🔥                  ║
║                    "We find em, We test em, We pop em"                        ║
║                                                                              ║
║                     Version 2.5 | By baba_frar_crew                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
BABAFRAR
    echo -e "${NC}"
    echo -e "${PURPLE}                     🎯  Catch parameters like a boss  🎯${NC}"
    echo -e "${RED}                     💉  Inject payloads like a gangsta  💉${NC}"
    echo -e "${GREEN}                     💰  Find XSS like a bounty hunter  💰${NC}"
    echo ""
}

# ============================================================================
# BABAFRAR MESSAGING SYSTEM
# ============================================================================
baba_say() { echo -e "${GOLD}[BABAFRAR]${NC} $1"; }
baba_good() { echo -e "${GREEN}[✓]${NC} $1"; }
baba_bad() { echo -e "${RED}[✗]${NC} $1"; }
baba_warn() { echo -e "${PURPLE}[!]${NC} $1"; }
baba_info() { echo -e "${CYAN}[ℹ]${NC} $1"; }
baba_time() { echo -e "${BLUE}[⏱]${NC} $1"; }
baba_stats() { echo -e "${WHITE}[📊]${NC} $1"; }

print_gangsta_section() {
    echo ""
    echo -e "${GOLD}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║${NC} ${BOLD}$1${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# TIME CALCULATION FUNCTION
# ============================================================================
format_time() {
    local seconds=$1
    if [ "$seconds" -lt 60 ]; then
        echo "${seconds} seconds"
    elif [ "$seconds" -lt 3600 ]; then
        echo "$((seconds / 60)) min $((seconds % 60)) sec"
    else
        echo "$((seconds / 3600)) hr $((seconds % 3600 / 60)) min"
    fi
}

# ============================================================================
# MODULE TIMER
# ============================================================================
module_timer_start() {
    MODULE_START=$(date +%s)
}

module_timer_end() {
    local module_name="$1"
    local module_end=$(date +%s)
    local duration=$((module_end - MODULE_START))
    echo ""
    baba_time "Module [${module_name}] completed in: ${GOLD}$(format_time $duration)${NC}"
    echo ""
}

# ============================================================================
# BABAFRAR DEPENDENCY CHECK
# ============================================================================
check_babafrar_tools() {
    baba_say "Checking if the crew is ready..."
    
    local missing_crew=()
    local crew_tools=("subfinder" "sublist3r" "dalfox" "nuclei" "httpx" "gau" "waybackurls" "anew" "qsreplace")
    
    for tool in "${crew_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            if [ -f "${HOME}/.local/bin/${tool}" ]; then
                export PATH="${HOME}/.local/bin:${PATH}"
            else
                missing_crew+=("$tool")
            fi
        fi
    done
    
    if [ ${#missing_crew[@]} -ne 0 ]; then
        baba_warn "Missing crew members: ${missing_crew[*]}"
        echo ""
        baba_info "Install them automatically? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_babafrar_tools
            setup_babafrar_environment
            baba_say "Tools installed! Continuing with the hunt..."
            echo ""
        else
            baba_warn "Some tools are missing. Script may not work fully."
            echo ""
        fi
    else
        baba_good "All crew members present and ready!"
    fi
}

install_babafrar_tools() {
    print_gangsta_section "🔧 ARMING BABAFRAR - INSTALLING TOOLS"
    
    baba_say "Updating system..."
    sudo apt update -y 2>/dev/null || true
    
    if ! command -v go &>/dev/null; then
        baba_say "Installing Go..."
        sudo apt install -y golang-go 2>/dev/null || {
            wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz
            sudo tar -C /usr/local -xzf /tmp/go.tar.gz
            export PATH="/usr/local/go/bin:${PATH}"
        }
    fi
    
    export PATH="${HOME}/go/bin:${PATH}"
    mkdir -p "${HOME}/go/bin"
    
    if ! command -v pip3 &>/dev/null; then
        baba_say "Installing Python3 pip..."
        sudo apt install -y python3-pip 2>/dev/null || true
    fi
    
    baba_say "Installing Go tools..."
    local go_tools=(
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
        "github.com/tomnomnom/anew@latest"
        "github.com/tomnomnom/qsreplace@latest"
        "github.com/hahwul/dalfox/v2@latest"
        "github.com/lc/gau/v2/cmd/gau@latest"
        "github.com/tomnomnom/waybackurls@latest"
    )
    
    for tool in "${go_tools[@]}"; do
        local tool_name=$(basename "$tool" | cut -d'@' -f1)
        if ! command -v "$tool_name" &>/dev/null; then
            baba_say "Installing $tool_name..."
            go install "$tool" 2>/dev/null || baba_warn "$tool_name failed to install"
        else
            baba_good "$tool_name already installed"
        fi
    done
    
    baba_say "Installing Python tools..."
    if ! command -v sublist3r &>/dev/null; then
        pip3 install --user sublist3r --break-system-packages 2>/dev/null || \
        pip3 install --user sublist3r 2>/dev/null || \
        sudo pip3 install sublist3r 2>/dev/null || \
        baba_warn "sublist3r installation failed"
    fi
    
    pip3 install --user uro --break-system-packages 2>/dev/null || true
    
    if [ ! -d "${HOME}/tools/ParamSpider" ]; then
        baba_say "Cloning ParamSpider..."
        git clone https://github.com/devanshbatham/ParamSpider.git "${HOME}/tools/ParamSpider" 2>/dev/null || true
        if [ -f "${HOME}/tools/ParamSpider/requirements.txt" ]; then
            pip3 install --user -r "${HOME}/tools/ParamSpider/requirements.txt" --break-system-packages 2>/dev/null || true
        fi
    fi
    
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        export PATH="${HOME}/.local/bin:${PATH}"
        if ! grep -q '.local/bin' ~/.zshrc 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        fi
    fi
    
    baba_good "BABAFRAR is fully armed!"
    echo ""
}

# ============================================================================
# TARGET VALIDATION
# ============================================================================
validate_babafrar_target() {
    local target="$1"
    target=$(echo "$target" | sed -E 's|^https?://||' | sed 's|/.*$||')
    
    if [[ ! "$target" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        baba_bad "Invalid target: $target"
        baba_info "Example: $0 example.com"
        exit 1
    fi
    
    echo "$target"
}

# ============================================================================
# MODULE 1: TARGET INITIALIZATION
# ============================================================================
module1_target_init() {
    local target="$1"
    
    print_gangsta_section "🎯 MODULE 1: LOCKING ON TARGET"
    
    module_timer_start
    
    BABAFRAR_WORKSPACE="${SCRIPT_DIR}/babafrar_results/${target}"
    BABAFRAR_RUN="${BABAFRAR_WORKSPACE}/${TIMESTAMP}"
    
    baba_say "Setting up workspace for: ${GOLD}${target}${NC}"
    
    mkdir -p "${BABAFRAR_RUN}"/{subdomains,urls,parameters,analysis,vulnerabilities,logs}
    rm -f "${BABAFRAR_WORKSPACE}/latest"
    ln -sfn "${BABAFRAR_RUN}" "${BABAFRAR_WORKSPACE}/latest"
    
    cat > "${BABAFRAR_RUN}/logs/run_info.txt" << EOF
╔═══════════════════════════════════════╗
║     BABAFRAR HUNT SESSION INFO       ║
╠═══════════════════════════════════════╣
║ Target: ${target}
║ Date: $(date)
║ Version: ${BABAFRAR_VERSION}
║ Workspace: ${BABAFRAR_RUN}
╚═══════════════════════════════════════╝
EOF
    
    baba_good "Workspace ready: ${BABAFRAR_RUN}"
    baba_info "Symlink: ${BABAFRAR_WORKSPACE}/latest"
    
    module_timer_end "TARGET INITIALIZATION"
}

# ============================================================================
# MODULE 2: SUBDOMAIN DISCOVERY
# ============================================================================
module2_subdomain_hunt() {
    local target="$1"
    
    print_gangsta_section "🔍 MODULE 2: SUBDOMAIN DISCOVERY"
    
    module_timer_start
    
    local sub_file="${BABAFRAR_RUN}/subdomains/subdomains.txt"
    local live_file="${BABAFRAR_RUN}/subdomains/live_subdomains.txt"
    
    baba_say "Running Subfinder..."
    subfinder -d "$target" -silent -all -o "${BABAFRAR_RUN}/subdomains/subfinder.txt" 2>/dev/null || {
        touch "${BABAFRAR_RUN}/subdomains/subfinder.txt"
    }
    local sf_count=$(wc -l < "${BABAFRAR_RUN}/subdomains/subfinder.txt")
    baba_good "Subfinder found ${GREEN}${sf_count}${NC} subdomains"
    
    baba_say "Running Sublist3r..."
    sublist3r -d "$target" -o "${BABAFRAR_RUN}/subdomains/sublist3r.txt" 2>/dev/null || {
        touch "${BABAFRAR_RUN}/subdomains/sublist3r.txt"
    }
    local sl_count=$(wc -l < "${BABAFRAR_RUN}/subdomains/sublist3r.txt")
    baba_good "Sublist3r found ${GREEN}${sl_count}${NC} subdomains"
    
    baba_say "Merging and deduplicating..."
    cat "${BABAFRAR_RUN}/subdomains/subfinder.txt" \
        "${BABAFRAR_RUN}/subdomains/sublist3r.txt" 2>/dev/null | \
        sort -u > "$sub_file"
    
    local total=$(wc -l < "$sub_file")
    baba_good "Total unique subdomains: ${GOLD}${total}${NC}"
    
    baba_say "Checking live subdomains..."
    if command -v httpx &>/dev/null; then
        cat "$sub_file" | httpx -silent -no-color -o "$live_file" 2>/dev/null
    else
        while IFS= read -r sub; do
            curl -s -o /dev/null -w "%{http_code}" "https://${sub}" --connect-timeout 3 2>/dev/null | grep -qE '^[23]|^4' && echo "https://${sub}" >> "$live_file"
            curl -s -o /dev/null -w "%{http_code}" "http://${sub}" --connect-timeout 3 2>/dev/null | grep -qE '^[23]|^4' && echo "http://${sub}" >> "$live_file"
        done < "$sub_file"
    fi
    
    local live=$(wc -l < "$live_file" 2>/dev/null || echo 0)
    baba_good "Live subdomains: ${GREEN}${live}${NC}"
    
    echo "subdomains_total:${total}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "subdomains_live:${live}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    
    module_timer_end "SUBDOMAIN DISCOVERY"
}

# ============================================================================
# MODULE 3: PARAMETER DISCOVERY
# ============================================================================
module3_parameter_discovery() {
    local target="$1"
    
    print_gangsta_section "🕷️ MODULE 3: PARAMETER DISCOVERY"
    
    module_timer_start
    
    local raw_urls="${BABAFRAR_RUN}/urls/raw_urls.txt"
    
    baba_say "Running GAU (Get All URLs)..."
    if command -v gau &>/dev/null; then
        echo "$target" | gau --subs 2>/dev/null > "${BABAFRAR_RUN}/urls/gau_urls.txt" &
    fi
    
    baba_say "Running Waybackurls..."
    if command -v waybackurls &>/dev/null; then
        echo "$target" | waybackurls 2>/dev/null > "${BABAFRAR_RUN}/urls/wayback_urls.txt" &
    fi
    
    local live_subs="${BABAFRAR_RUN}/subdomains/live_subdomains.txt"
    baba_say "Running ParamSpider..."
    
    if [ -f "${HOME}/tools/ParamSpider/paramspider.py" ]; then
        if [ -f "$live_subs" ] && [ -s "$live_subs" ]; then
            local clean_live_subs="${BABAFRAR_RUN}/urls/paramspider_live_subs.txt"
            sed -E 's#^https?://##; s#/.*$##' "$live_subs" | grep -E '^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' | sort -u > "$clean_live_subs"
            baba_info "Spidering live subdomains list: ${GOLD}${clean_live_subs}${NC}"
            python3 "${HOME}/tools/ParamSpider/paramspider.py" \
                -l "$clean_live_subs" \
                --output "${BABAFRAR_RUN}/urls/" \
                --level high \
                --quiet 2>/dev/null || true
        else
            local clean_target="${BABAFRAR_RUN}/urls/paramspider_target.txt"
            echo "$target" | sed -E 's#^https?://##; s#/.*$##' | grep -E '^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' | sort -u > "$clean_target"
            baba_info "Spidering target list: ${GOLD}${clean_target}${NC}"
            python3 "${HOME}/tools/ParamSpider/paramspider.py" \
                -l "$clean_target" \
                --output "${BABAFRAR_RUN}/urls/" \
                --level high \
                --quiet 2>/dev/null || true
        fi
    fi
    
    wait
    
    baba_say "Merging all URL sources..."
    {
        find "${BABAFRAR_RUN}/urls/" -type f -name "*.txt" ! -name "raw_urls.txt" -exec cat {} \; 2>/dev/null
        cat "${BABAFRAR_RUN}/urls/gau_urls.txt" 2>/dev/null
        cat "${BABAFRAR_RUN}/urls/wayback_urls.txt" 2>/dev/null
    } | grep -E '^https?://' | grep -E '\?.*=' | sort -u > "$raw_urls"
    
    local url_count=$(wc -l < "$raw_urls")
    baba_good "Total URLs with parameters: ${GOLD}${url_count}${NC}"
    
    echo "urls_total:${url_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    
    module_timer_end "PARAMETER DISCOVERY"
}

# ============================================================================
# MODULE 4: PARAMETER PROCESSING
# ============================================================================
module4_parameter_processing() {
    print_gangsta_section "🔧 MODULE 4: PARAMETER PROCESSING"
    
    module_timer_start
    
    local raw_urls="${BABAFRAR_RUN}/urls/raw_urls.txt"
    local single_params="${BABAFRAR_RUN}/parameters/single_params.txt"
    
    local url_count=$(wc -l < "$raw_urls")
    baba_info "Processing ${url_count} URLs..."
    
    baba_say "Extracting unique parameter endpoints..."
    if command -v qsreplace &>/dev/null; then
        cat "$raw_urls" | grep -E '\?.*=' | qsreplace '123' | sort -u > "$single_params"
    else
        cat "$raw_urls" | grep -E '\?.*=' | sed -E 's/=[^&]*/=123/g' | sort -u > "$single_params"
    fi
    
    local param_count=$(wc -l < "$single_params")
    baba_good "Unique parameter endpoints: ${GOLD}${param_count}${NC}"
    
    baba_say "Analyzing parameter frequency..."
    cat "$raw_urls" | grep -oP '\?[^&\s]+' | sed 's/^?//' | cut -d'=' -f1 | \
        sort | uniq -c | sort -rn > "${BABAFRAR_RUN}/parameters/param_frequency.txt"
    
    baba_info "Top 5 most common parameters:"
    head -5 "${BABAFRAR_RUN}/parameters/param_frequency.txt" | while read count param; do
        echo -e "    ${GOLD}${param}${NC} - ${GREEN}${count}${NC} occurrences"
    done
    
    echo "unique_params:${param_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    
    module_timer_end "PARAMETER PROCESSING"
}

# ============================================================================
# MODULE 5: DOCTORJACK ANALYSIS
# ============================================================================
module5_doctorjack_analysis() {
    print_gangsta_section "🧬 MODULE 5: DOCTORJACK ANALYSIS"
    
    module_timer_start
    
    local single_params="${BABAFRAR_RUN}/parameters/single_params.txt"
    local analysis_dir="${BABAFRAR_RUN}/analysis"
    local param_count=$(wc -l < "$single_params")
    
    mkdir -p "$analysis_dir"
    
    baba_info "Analyzing ${param_count} parameters..."
    
    baba_say "Testing parameter reflection (sampled)..."
    head -20 "$single_params" | while read url; do
        local response=$(curl -s -m 5 "${url}BABAFRAR_TEST" 2>/dev/null)
        if echo "$response" | grep -q "BABAFRAR_TEST"; then
            echo "$url" >> "${analysis_dir}/reflected.txt"
        fi
    done &
    
    baba_say "Detecting dynamic/juicy endpoints..."
    cat "$single_params" | grep -iE '(id=|page=|user=|file=|path=|redirect=|url=|callback=|return=|next=|target=|rurl=|dest=|destination=|redirect_uri=|return_url=|forward=|out=|view=|template=|include=|require=|doc=|document=|pdf=|download=|fetch=|load=|get=|dir=|folder=|root=|home=|domain=|host=|referer=|source=|origin=|continue=|goto=|redir=|search=|query=|q=|s=|keyword=|filter=|type=|action=|method=|cmd=|exec=|command=|run=|process=|open=|read=|write=|delete=|remove=|create=|update=|modify=|change=|set=|config=|setting=|option=|pref=|preference=)' > "${analysis_dir}/dynamic_candidates.txt"
    
    local dynamic_count=$(wc -l < "${analysis_dir}/dynamic_candidates.txt" 2>/dev/null || echo 0)
    baba_good "Dynamic candidates found: ${GREEN}${dynamic_count}${NC}"
    
    baba_say "Classifying and scoring parameters..."
    echo -e "URL\tParameter\tType\tPriority" > "${analysis_dir}/final_review.tsv"
    
    cat "$single_params" | while read url; do
        local param_name=$(echo "$url" | grep -oP '\?[^=]+' | sed 's/^?//')
        local param_type="Generic"
        local priority="LOW"
        
        if echo "$param_name" | grep -qiE '(redirect|url|callback|return|next|target|rurl|dest|destination|redirect_uri|return_url|forward|goto|redir)'; then
            param_type="Open_Redirect"
            priority="CRITICAL"
        elif echo "$param_name" | grep -qiE '(cmd|exec|command|run|process|open|read|write|delete|remove|create|update)'; then
            param_type="Command_Injection"
            priority="CRITICAL"
        elif echo "$param_name" | grep -qiE '(search|query|q|s|keyword|filter|find)'; then
            param_type="Search"
            priority="HIGH"
        elif echo "$param_name" | grep -qiE '(id|page|user|file|path|view|template|include|doc|pdf|download)'; then
            param_type="Dynamic_Content"
            priority="HIGH"
        elif echo "$param_name" | grep -qiE '(name|email|message|comment|title|description|content|body|text)'; then
            param_type="User_Content"
            priority="HIGH"
        elif echo "$param_name" | grep -qiE '(callback|jsonp|api|format|type|action|method)'; then
            param_type="API"
            priority="MEDIUM"
        elif echo "$param_name" | grep -qiE '(lang|locale|country|theme|style|color|size|sort|order|limit|offset)'; then
            param_type="Config"
            priority="MEDIUM"
        fi
        
        echo -e "${url}\t${param_name}\t${param_type}\t${priority}" >> "${analysis_dir}/final_review.tsv"
    done
    
    baba_say "Creating prioritized hit list..."
    grep -E "CRITICAL|HIGH" "${analysis_dir}/final_review.tsv" | cut -f1 > "${analysis_dir}/split_params.txt"
    grep "MEDIUM" "${analysis_dir}/final_review.tsv" | cut -f1 >> "${analysis_dir}/split_params.txt"
    
    local hitlist=$(wc -l < "${analysis_dir}/split_params.txt" 2>/dev/null || echo 0)
    local critical=$(grep -c "CRITICAL" "${analysis_dir}/final_review.tsv" 2>/dev/null || echo 0)
    local high=$(grep -c "HIGH" "${analysis_dir}/final_review.tsv" 2>/dev/null || echo 0)
    local medium=$(grep -c "MEDIUM" "${analysis_dir}/final_review.tsv" 2>/dev/null || echo 0)
    
    baba_good "Hit list created!"
    baba_stats "CRITICAL: ${RED}${critical}${NC} | HIGH: ${RED}${high}${NC} | MEDIUM: ${GREEN}${medium}${NC} | TOTAL: ${GOLD}${hitlist}${NC}"
    
    cat "$single_params" | sort -u > "${analysis_dir}/clean.txt"
    
    if [ ! -f "${analysis_dir}/reflected.txt" ]; then
        touch "${analysis_dir}/reflected.txt"
    fi
    
    local reflected_count=$(wc -l < "${analysis_dir}/reflected.txt" 2>/dev/null || echo 0)
    
    cat > "${analysis_dir}/report_data.json" << EOF
{
    "scan_info": {
        "target": "$target",
        "timestamp": "$TIMESTAMP",
        "tool": "BABAFRAR v${BABAFRAR_VERSION}"
    },
    "statistics": {
        "total_urls": $(wc -l < "${BABAFRAR_RUN}/urls/raw_urls.txt" 2>/dev/null || echo 0),
        "unique_params": $param_count,
        "reflected": $reflected_count,
        "dynamic": $dynamic_count,
        "critical": $critical,
        "high": $high,
        "medium": $medium,
        "hitlist_total": $hitlist
    }
}
EOF
    
    echo "hitlist_total:${hitlist}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "critical:${critical}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "high:${high}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    
    module_timer_end "DOCTORJACK ANALYSIS"
}

# ============================================================================
# MODULE 5B: DALFOX RECON PREPARATION
# ============================================================================
module5b_prepare_dalfox_recon() {
    local target="$1"

    print_gangsta_section "MODULE 5B: PREPARING DALFOX RECON FILES"

    module_timer_start

    local analysis_dir="${BABAFRAR_RUN}/analysis"
    local recon_dir="${analysis_dir}/dalfox_recon"
    local final_review="${analysis_dir}/final_review.tsv"
    local single_params="${BABAFRAR_RUN}/parameters/single_params.txt"
    local reflected="${analysis_dir}/reflected.txt"
    local split_params="${analysis_dir}/split_params.txt"
    local best_file="${recon_dir}/dalfox_best.txt"

    mkdir -p "$recon_dir"
    rm -f "${recon_dir}"/*.txt 2>/dev/null || true

    baba_say "Building DoctorJack recon files for Dalfox..."

    if [ -f "$final_review" ] && [ -s "$final_review" ]; then
        awk -F'\t' -v out="$recon_dir" '
            NR == 1 { next }
            NF >= 4 {
                url = $1
                type = tolower($3)
                priority = tolower($4)
                gsub(/[^a-z0-9]+/, "_", type)
                gsub(/^_+|_+$/, "", type)

                if (url != "") {
                    print url >> out "/priority_" priority ".txt"
                    print url >> out "/type_" type ".txt"
                }
            }
        ' "$final_review"
    fi

    [ -f "$single_params" ] && sort -u "$single_params" > "${recon_dir}/all_params.txt"
    [ -f "$split_params" ] && sort -u "$split_params" > "${recon_dir}/priority_params.txt"
    [ -f "$reflected" ] && sort -u "$reflected" > "${recon_dir}/reflected_params.txt"

    {
        cat "${recon_dir}/reflected_params.txt" 2>/dev/null
        cat "${recon_dir}/priority_critical.txt" 2>/dev/null
        cat "${recon_dir}/priority_high.txt" 2>/dev/null
        cat "${recon_dir}/priority_medium.txt" 2>/dev/null
        cat "${recon_dir}/all_params.txt" 2>/dev/null
    } | grep -E '^https?://.*\?.*=' | sort -u > "$best_file"

    local all_count=$(wc -l < "${recon_dir}/all_params.txt" 2>/dev/null || echo 0)
    local best_count=$(wc -l < "$best_file" 2>/dev/null || echo 0)
    local reflected_count=$(wc -l < "${recon_dir}/reflected_params.txt" 2>/dev/null || echo 0)
    local critical_count=$(wc -l < "${recon_dir}/priority_critical.txt" 2>/dev/null || echo 0)
    local high_count=$(wc -l < "${recon_dir}/priority_high.txt" 2>/dev/null || echo 0)
    local medium_count=$(wc -l < "${recon_dir}/priority_medium.txt" 2>/dev/null || echo 0)

    baba_good "Dalfox recon files ready: ${GOLD}${recon_dir}${NC}"
    baba_stats "BEST: ${GOLD}${best_count}${NC} | REFLECTED: ${GREEN}${reflected_count}${NC} | CRITICAL: ${RED}${critical_count}${NC} | HIGH: ${RED}${high_count}${NC} | MEDIUM: ${GREEN}${medium_count}${NC} | ALL: ${GOLD}${all_count}${NC}"

    cat > "${recon_dir}/README.txt" << EOF
BABAFRAR DALFOX RECON FILES
Target: ${target}
Date: $(date)

Use dalfox_best.txt as the default Dalfox input.
It is built in this order:
1. Reflected URLs from DoctorJack sampling
2. Critical priority URLs
3. High priority URLs
4. Medium priority URLs
5. Remaining normalized parameter URLs

Files:
- dalfox_best.txt: Best all-in-one Dalfox input
- reflected_params.txt: URLs where BABAFRAR_TEST reflected
- priority_critical.txt: Critical DoctorJack candidates
- priority_high.txt: High DoctorJack candidates
- priority_medium.txt: Medium DoctorJack candidates
- priority_params.txt: Critical + High + Medium candidates
- all_params.txt: All normalized parameter URLs
- type_*.txt: URL files grouped by DoctorJack parameter type
EOF

    echo "dalfox_recon_best:${best_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "dalfox_recon_reflected:${reflected_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"

    module_timer_end "DALFOX RECON PREPARATION"
}

first_existing_nuclei_template_path() {
    local fallback="$1"
    shift

    local candidate
    for candidate in "$@"; do
        if [ -e "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    echo "$fallback"
}

select_nuclei_vuln_template() {
    local template_root="$1"
    local choice="${NUCLEI_VULN_CHOICE:-}"
    local custom_path=""

    echo ""
    echo -e "${CYAN}Choose Nuclei vulnerability scan:${NC}"
    echo -e "  ${GREEN}1)${NC} All templates"
    echo -e "  ${GREEN}2)${NC} XSS"
    echo -e "  ${GREEN}3)${NC} SQL Injection"
    echo -e "  ${GREEN}4)${NC} SSRF"
    echo -e "  ${GREEN}5)${NC} LFI / File Inclusion"
    echo -e "  ${GREEN}6)${NC} RCE"
    echo -e "  ${GREEN}7)${NC} Open Redirect"
    echo -e "  ${GREEN}8)${NC} CVEs"
    echo -e "  ${GREEN}9)${NC} Exposures"
    echo -e "  ${GREEN}10)${NC} Custom template path"
    echo ""

    if [ -z "$choice" ]; then
        read -r -p "$(echo -e "${GOLD}Enter choice [1-10] (default: 1): ${NC}")" choice
    fi

    choice="${choice:-1}"

    case "$choice" in
        1|all)
            NUCLEI_SELECTED_LABEL="all"
            NUCLEI_SELECTED_TEMPLATE="$template_root"
            ;;
        2|xss)
            NUCLEI_SELECTED_LABEL="xss"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/xss" \
                "${template_root}/xss" \
                "${template_root}/http/vulnerabilities/xss")
            ;;
        3|sqli|sql)
            NUCLEI_SELECTED_LABEL="sqli"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/sqli" \
                "${template_root}/sqli" \
                "${template_root}/sql-injection" \
                "${template_root}/http/vulnerabilities/sqli")
            ;;
        4|ssrf)
            NUCLEI_SELECTED_LABEL="ssrf"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/ssrf" \
                "${template_root}/ssrf" \
                "${template_root}/http/vulnerabilities/ssrf")
            ;;
        5|lfi|file)
            NUCLEI_SELECTED_LABEL="lfi"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/lfi" \
                "${template_root}/lfi" \
                "${template_root}/http/vulnerabilities/file-inclusion" \
                "${template_root}/http/vulnerabilities/lfi")
            ;;
        6|rce)
            NUCLEI_SELECTED_LABEL="rce"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/rce" \
                "${template_root}/rce" \
                "${template_root}/http/vulnerabilities/rce")
            ;;
        7|redirect|open-redirect)
            NUCLEI_SELECTED_LABEL="open_redirect"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/vulnerabilities/open-redirect" \
                "${template_root}/open-redirect" \
                "${template_root}/http/vulnerabilities/open-redirect")
            ;;
        8|cve|cves)
            NUCLEI_SELECTED_LABEL="cves"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/cves" \
                "${template_root}/cves" \
                "${template_root}/http/cves")
            ;;
        9|exposure|exposures)
            NUCLEI_SELECTED_LABEL="exposures"
            NUCLEI_SELECTED_TEMPLATE=$(first_existing_nuclei_template_path \
                "${template_root}/http/exposures" \
                "${template_root}/exposures" \
                "${template_root}/http/exposures")
            ;;
        10|custom)
            read -r -p "$(echo -e "${GOLD}Enter custom nuclei template file/dir: ${NC}")" custom_path
            NUCLEI_SELECTED_LABEL="custom"
            NUCLEI_SELECTED_TEMPLATE="$custom_path"
            ;;
        *)
            baba_warn "Invalid choice. Using all templates."
            NUCLEI_SELECTED_LABEL="all"
            NUCLEI_SELECTED_TEMPLATE="$template_root"
            ;;
    esac

    if [ -z "$NUCLEI_SELECTED_TEMPLATE" ]; then
        baba_warn "Empty template path selected. Falling back to all templates."
        NUCLEI_SELECTED_LABEL="all"
        NUCLEI_SELECTED_TEMPLATE="$template_root"
    fi

    if [ ! -e "$NUCLEI_SELECTED_TEMPLATE" ]; then
        baba_warn "Selected template path not found: ${NUCLEI_SELECTED_TEMPLATE}"
        baba_info "Nuclei will still run with this path. Set NUCLEI_TEMPLATES if your templates are elsewhere."
    fi
}

# ============================================================================
# MODULE 5C: NUCLEI SCAN FROM DOCTORJACK URL FILES
# ============================================================================
module5c_nuclei_doctorjack_scan() {
    local target="$1"

    print_gangsta_section "MODULE 5C: NUCLEI SCAN FROM DOCTORJACK FILES"

    module_timer_start

    local analysis_dir="${BABAFRAR_RUN}/analysis"
    local recon_dir="${analysis_dir}/dalfox_recon"
    local output_dir="${BABAFRAR_RUN}/vulnerabilities/nuclei"
    local input_file="${output_dir}/nuclei_doctorjack_input.txt"
    local results_file="${output_dir}/results.txt"
    local log_file="${output_dir}/nuclei_run.log"
    local template_dir="${NUCLEI_TEMPLATES:-/usr/share/nuclei-templates}"
    local severity="${NUCLEI_SEVERITY:-critical,high}"

    mkdir -p "$output_dir"
    : > "$input_file"
    : > "$results_file"

    if ! command -v nuclei >/dev/null 2>&1; then
        baba_warn "nuclei not found. Skipping DoctorJack -> Nuclei scan."
        baba_info "Install nuclei, then run: nuclei -l \"${input_file}\" -t \"${template_dir}\" -severity \"${severity}\" -o \"${results_file}\""
        echo "nuclei_findings:0" >> "${BABAFRAR_RUN}/logs/stats.txt"
        module_timer_end "NUCLEI DOCTORJACK SCAN"
        return 0
    fi

    baba_say "Building Nuclei input from all DoctorJack URL files..."

    {
        awk -F'\t' 'NR > 1 && $1 ~ /^https?:\/\// { print $1 }' "${analysis_dir}/final_review.tsv" 2>/dev/null
        cat "${recon_dir}/dalfox_best.txt" 2>/dev/null
        cat "${recon_dir}/priority_params.txt" 2>/dev/null
        cat "${analysis_dir}/split_params.txt" 2>/dev/null
        cat "${analysis_dir}/clean.txt" 2>/dev/null
        cat "${analysis_dir}/reflected.txt" 2>/dev/null
        cat "${BABAFRAR_RUN}/parameters/single_params.txt" 2>/dev/null
    } | grep -E '^https?://.*\?.*=' | sort -u > "$input_file"

    local input_count=0
    local findings_count=0
    input_count=$(wc -l < "$input_file" 2>/dev/null || echo 0)

    if [ "$input_count" -eq 0 ] 2>/dev/null; then
        baba_warn "No DoctorJack URLs found for Nuclei."
        echo "nuclei_findings:0" >> "${BABAFRAR_RUN}/logs/stats.txt"
        module_timer_end "NUCLEI DOCTORJACK SCAN"
        return 0
    fi

    select_nuclei_vuln_template "$template_dir"

    baba_stats "Nuclei input URLs: ${GOLD}${input_count}${NC}"
    baba_info "Input file: ${input_file}"
    baba_info "Scan type: ${NUCLEI_SELECTED_LABEL}"
    baba_info "Template path: ${NUCLEI_SELECTED_TEMPLATE}"
    baba_info "Command: nuclei -l \"${input_file}\" -t \"${NUCLEI_SELECTED_TEMPLATE}\" -severity \"${severity}\" -o \"${results_file}\""

    nuclei -l "$input_file" \
        -t "$NUCLEI_SELECTED_TEMPLATE" \
        -severity "$severity" \
        -o "$results_file" \
        2>&1 | tee "$log_file"

    findings_count=$(wc -l < "$results_file" 2>/dev/null || echo 0)

    cat > "${output_dir}/README.txt" << EOF
BABAFRAR DOCTORJACK -> NUCLEI RESULTS
Target: ${target}
Date: $(date)

Command:
nuclei -l "${input_file}" -t "${NUCLEI_SELECTED_TEMPLATE}" -severity "${severity}" -o "${results_file}"

Scan type: ${NUCLEI_SELECTED_LABEL}
Template path: ${NUCLEI_SELECTED_TEMPLATE}

Files:
- nuclei_doctorjack_input.txt: Clean DoctorJack URL list used by Nuclei
- results.txt: Nuclei findings
- nuclei_run.log: Full Nuclei console output

Input URLs: ${input_count}
Findings lines: ${findings_count}

Only test authorized targets.
EOF

    echo "nuclei_input:${input_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "nuclei_scan_type:${NUCLEI_SELECTED_LABEL}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "nuclei_findings:${findings_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"

    if [ "$findings_count" -gt 0 ] 2>/dev/null; then
        baba_good "Nuclei findings saved: ${results_file}"
    else
        baba_warn "No critical/high Nuclei findings found."
    fi

    module_timer_end "NUCLEI DOCTORJACK SCAN"
}

# ============================================================================
# MODULE 6: VULNERABILITY TESTING (ALL DALFOX FLAGS CORRECTED)
# ============================================================================
extract_dalfox_poc_blocks() {
    local findings_file="$1"
    shift

    : > "$findings_file"

    local existing_files=()
    local f

    for f in "$@"; do
        [ -f "$f" ] && existing_files+=("$f")
    done

    [ "${#existing_files[@]}" -eq 0 ] && return 0

    awk '
        /^\[POC\]/ {
            if (block != "") print block "\n"
            block = $0
            in_block = 1
            next
        }
        in_block && /^[[:space:]]/ {
            block = block "\n" $0
            next
        }
        in_block {
            print block "\n"
            block = ""
            in_block = 0
        }
        END {
            if (block != "") print block
        }
    ' "${existing_files[@]}" 2>/dev/null | awk '!seen[$0]++' > "$findings_file"
}

module6_xss_testing() {
    local target="$1"

    print_gangsta_section "MODULE 6: XSS TESTING - DALFOX POC MODE"

    module_timer_start

    local single_params="${BABAFRAR_RUN}/parameters/single_params.txt"
    local dalfox_recon="${BABAFRAR_RUN}/analysis/dalfox_recon/dalfox_best.txt"
    local recon_priority="${BABAFRAR_RUN}/analysis/dalfox_recon/priority_params.txt"
    local dalfox_params="${BABAFRAR_RUN}/parameters/dalfox_reachable_params.txt"
    local split_params="${BABAFRAR_RUN}/analysis/split_params.txt"
    local vuln_dir="${BABAFRAR_RUN}/vulnerabilities"
    local log_dir="${BABAFRAR_RUN}/logs"
    local vuln_file="${vuln_dir}/vulnerabilities.txt"
    local poc_file="${vuln_dir}/dalfox_pocs.txt"
    local summary_file="${vuln_dir}/dalfox_summary.txt"
    local raw_output_file="${vuln_dir}/dalfox_raw_output.txt"
    local all_urls="${BABAFRAR_RUN}/urls/raw_urls.txt"
    local dalfox_source="$single_params"

    mkdir -p "$vuln_dir" "$log_dir"
    : > "$vuln_file"
    : > "$raw_output_file"
    : > "$poc_file"

    if [ -f "$dalfox_recon" ] && [ -s "$dalfox_recon" ]; then
        dalfox_source="$dalfox_recon"
    fi

    if [ -f "$recon_priority" ] && [ -s "$recon_priority" ]; then
        split_params="$recon_priority"
    fi

    local test_count=0
    local priority_count=0
    local total_urls=0
    local reachable_count=0

    test_count=$(wc -l < "$dalfox_source" 2>/dev/null || echo 0)
    priority_count=$(wc -l < "$split_params" 2>/dev/null || echo 0)
    total_urls=$(wc -l < "$all_urls" 2>/dev/null || echo 0)

    if ! command -v dalfox >/dev/null 2>&1; then
        baba_bad "Dalfox not found!"
        echo "Dalfox not installed" > "$summary_file"
        echo "xss_found:0" >> "${BABAFRAR_RUN}/logs/stats.txt"
        module_timer_end "XSS TESTING"
        return 1
    fi

    if [ -f "$dalfox_source" ] && [ -s "$dalfox_source" ]; then
        if command -v httpx >/dev/null 2>&1; then
            baba_say "Filtering reachable parameter URLs before Dalfox..."
            httpx -l "$dalfox_source" \
                -silent \
                -no-color \
                -timeout 8 \
                -retries 2 \
                -threads 30 \
                -o "$dalfox_params" 2>/dev/null || true

            if [ ! -s "$dalfox_params" ]; then
                baba_warn "httpx found no reachable parameter URLs. Falling back to DoctorJack/Dalfox source file"
                cp "$dalfox_source" "$dalfox_params" 2>/dev/null || true
            fi
        else
            baba_warn "httpx not found. Dalfox will test unfiltered DoctorJack/Dalfox source file"
            cp "$dalfox_source" "$dalfox_params" 2>/dev/null || true
        fi
    fi

    reachable_count=$(wc -l < "$dalfox_params" 2>/dev/null || echo 0)

    echo ""
    baba_stats "Dalfox source file: ${GOLD}${dalfox_source}${NC}"
    baba_stats "Parameter endpoints to test: ${GOLD}${test_count}${NC}"
    baba_stats "Reachable parameter endpoints: ${GOLD}${reachable_count}${NC}"
    baba_stats "Total raw URLs available: ${GOLD}${total_urls}${NC}"
    echo ""

    echo -e "${CYAN}Choose testing method:${NC}"
    echo -e "  ${GREEN}1)${NC} DALFOX FILE SCAN ${RED}(recommended)${NC}"
    echo -e "     Input: ${dalfox_params}"
    echo -e "     Captures [POC], DOM-XSS, reflected XSS, Issue, and Payload lines"
    echo ""
    echo -e "  ${GREEN}2)${NC} PIPE ALL URLS"
    echo -e "     Input: ${all_urls}"
    echo ""
    echo -e "  ${GREEN}3)${NC} TARGETED PARAMETERS"
    echo -e "     Input: ${split_params}"
    echo ""

    read -r -p "$(echo -e "${GOLD}Enter choice [1-3] (default: 1): ${NC}")" method_choice
    method_choice="${method_choice:-1}"
    echo ""

    case "$method_choice" in
        1)
            if [ -f "$dalfox_params" ] && [ -s "$dalfox_params" ]; then
                baba_say "Running DALFOX FILE scan on ${GOLD}${dalfox_params}${NC}"
                baba_info "Command: dalfox file \"${dalfox_params}\" --output \"${vuln_file}\""
                baba_info "This can take 30+ minutes. Do not use a short shell timeout."

                dalfox file "$dalfox_params" \
                    --output "$vuln_file" \
                    --waf-evasion \
                    --workers 30 \
                    --delay 100 \
                    --timeout 20 \
                    --max-targets-per-host 10000 \
                    2>&1 | tee "${log_dir}/dalfox_file.log" | tee -a "$raw_output_file"

                baba_good "Dalfox file scan complete!"
            else
                baba_warn "No reachable parameter file to test: ${dalfox_params}"
            fi
            ;;

        2)
            if [ -f "$all_urls" ] && [ -s "$all_urls" ]; then
                baba_say "Piping ${GOLD}${total_urls}${NC} URLs to Dalfox"
                baba_info "Command: dalfox pipe --output \"${vuln_file}\""

                dalfox pipe \
                    --output "$vuln_file" \
                    --waf-evasion \
                    --workers 30 \
                    --delay 100 \
                    --timeout 20 \
                    --max-targets-per-host 10000 \
                    < "$all_urls" \
                    2>&1 | tee "${log_dir}/dalfox_pipe.log" | tee -a "$raw_output_file"
            else
                baba_warn "No URLs to test: ${all_urls}"
            fi
            ;;

        3)
            if [ -f "$split_params" ] && [ -s "$split_params" ]; then
                baba_say "Testing ${GOLD}${priority_count}${NC} priority parameters"
                baba_info "Command: dalfox file \"${split_params}\" --output \"${vuln_file}\""

                dalfox file "$split_params" \
                    --output "$vuln_file" \
                    --waf-evasion \
                    --workers 30 \
                    --delay 100 \
                    --timeout 20 \
                    --max-targets-per-host 10000 \
                    2>&1 | tee "${log_dir}/dalfox_targeted.log" | tee -a "$raw_output_file"
            else
                baba_warn "No priority parameter file to test: ${split_params}"
            fi
            ;;

        *)
            baba_warn "Invalid choice. Skipping Dalfox scan."
            ;;
    esac

    echo ""
    baba_say "Processing Dalfox results..."

    # Dalfox can print real [POC] lines even when its summary says "XSS found 0 XSS".
    # Parse console logs and --output file together.
    extract_dalfox_poc_blocks "$poc_file" \
        "$raw_output_file" \
        "$vuln_file" \
        "${log_dir}/dalfox_file.log" \
        "${log_dir}/dalfox_pipe.log" \
        "${log_dir}/dalfox_targeted.log"

    if [ ! -s "$poc_file" ]; then
        grep -Eina '\[POC\]|DOM-XSS|XSS payload reflected|Issue:|Payload:' \
            "$raw_output_file" "$vuln_file" "${log_dir}"/dalfox_*.log 2>/dev/null \
            | tee "$poc_file" >/dev/null || true
    fi

    local poc_count=0
    local dom_count=0
    local reflected_count=0
    local active_count=0

    poc_count=$(grep -c '^\[POC\]' "$poc_file" 2>/dev/null || echo 0)
    dom_count=$(grep -c 'DOM-XSS' "$poc_file" 2>/dev/null || echo 0)
    reflected_count=$(grep -c 'XSS payload reflected\|\[POC\]\[R\]' "$poc_file" 2>/dev/null || echo 0)
    active_count=$(grep -c '\[POC\]\[A\]' "$poc_file" 2>/dev/null || echo 0)

    cat > "$summary_file" << EOF
BABAFRAR DALFOX XSS SUMMARY
Target: ${target}
Date: $(date)

PoC blocks: ${poc_count}
DOM-XSS findings: ${dom_count}
Reflected findings: ${reflected_count}
Active/alert-style PoCs: ${active_count}

Important:
- This module detects findings from [POC] blocks.
- It does not trust only the "XSS found 0 XSS" Dalfox summary line.
- Verify all findings manually before reporting.

Files:
- PoCs: ${poc_file}
- Raw console output: ${raw_output_file}
- Dalfox output: ${vuln_file}
EOF

    if [ "$poc_count" -gt 0 ] 2>/dev/null; then
        cp "$poc_file" "$vuln_file"

        echo ""
        echo -e "${RED}XSS / DALFOX POCS FOUND${NC}"
        baba_good "PoC blocks: ${RED}${poc_count}${NC}"
        baba_good "DOM-XSS findings: ${RED}${dom_count}${NC}"
        baba_good "Reflected findings: ${RED}${reflected_count}${NC}"
        baba_good "Active/alert-style PoCs: ${RED}${active_count}${NC}"
        baba_info "PoC file: ${poc_file}"
        baba_info "Summary: ${summary_file}"
        echo ""

        echo -e "${BOLD}FIRST 120 LINES OF DALFOX POCS:${NC}"
        sed -n '1,120p' "$poc_file"
    else
        echo ""
        echo -e "${YELLOW}No Dalfox [POC] blocks detected in this scan${NC}"
        baba_warn "Raw Dalfox logs are saved. Check them before trusting a no-XSS result."
        baba_info "Raw console output: ${raw_output_file}"
        baba_info "Summary: ${summary_file}"
        echo "No Dalfox [POC] blocks found - $(date)" > "$vuln_file"
    fi

    cat > "${vuln_dir}/README.txt" << EOF
BABAFRAR XSS VULNERABILITY REPORT
Target: ${target}
Date: $(date)

PoC blocks: ${poc_count}
DOM-XSS findings: ${dom_count}
Reflected findings: ${reflected_count}
Active/alert-style PoCs: ${active_count}

Main files:
- vulnerabilities.txt: ${vuln_file}
- dalfox_pocs.txt: ${poc_file}
- dalfox_summary.txt: ${summary_file}
- dalfox_raw_output.txt: ${raw_output_file}

Note:
Dalfox may print "XSS found 0 XSS" while still printing [POC] evidence.
This module treats [POC] blocks as positive findings.
Verify all findings manually and only test authorized targets.
EOF

    echo "xss_found:${poc_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "xss_dom:${dom_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "xss_reflected:${reflected_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"
    echo "xss_active:${active_count}" >> "${BABAFRAR_RUN}/logs/stats.txt"

    module_timer_end "XSS TESTING"
}


# ============================================================================
# FINAL REPORT
# ============================================================================
generate_babafrar_report() {
    print_gangsta_section "📊 FINAL REPORT"
    
    module_timer_start
    
    local report="${BABAFRAR_RUN}/BABAFRAR_REPORT.txt"
    
    local sub_total=$(grep "subdomains_total:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local sub_live=$(grep "subdomains_live:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local urls_total=$(grep "urls_total:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local unique_params=$(grep "unique_params:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local hitlist=$(grep "hitlist_total:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local critical=$(grep "critical:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local high=$(grep "high:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | cut -d: -f2 || echo 0)
    local nuclei=$(grep "^nuclei_findings:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | tail -n1 | cut -d: -f2 || echo 0)
    local xss=$(grep "^xss_found:" "${BABAFRAR_RUN}/logs/stats.txt" 2>/dev/null | tail -n1 | cut -d: -f2 || echo 0)
    
    local total_duration=$(($(date +%s) - SCRIPT_START_TIME))
    
    cat > "$report" << EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                         BABAFRAR HUNTING REPORT                              ║
║                      "Results that make you richer"                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

Target: ${target}
Date: $(date)
Version: ${BABAFRAR_VERSION}
Total Duration: $(format_time $total_duration)

═══════════════════════════════════════════════════════════════════════════════
HUNTING STATISTICS
═══════════════════════════════════════════════════════════════════════════════
Subdomains Discovered: ${sub_total}
Live Subdomains: ${sub_live}
URLs with Parameters: ${urls_total}
Unique Parameter Endpoints: ${unique_params}
Critical Priority: ${critical}
High Priority: ${high}
Total Hit List: ${hitlist}
Nuclei Critical/High Findings: ${nuclei}
XSS Vulnerabilities Found: ${xss}

═══════════════════════════════════════════════════════════════════════════════
OUTPUT STRUCTURE
═══════════════════════════════════════════════════════════════════════════════
babafrar_results/
└── ${target}/
    └── ${TIMESTAMP}/
        ├── subdomains/
        │   ├── subdomains.txt
        │   └── live_subdomains.txt
        ├── urls/
        │   └── raw_urls.txt
        ├── parameters/
        │   ├── single_params.txt
        │   └── param_frequency.txt
        ├── analysis/
        │   ├── clean.txt
        │   ├── reflected.txt
        │   ├── dynamic_candidates.txt
        │   ├── split_params.txt
        │   ├── final_review.tsv
        │   └── report_data.json
        ├── vulnerabilities/
        │   ├── vulnerabilities.txt
        │   └── README.txt
        └── logs/
            ├── run_info.txt
            ├── stats.txt
            └── dalfox_file.log

═══════════════════════════════════════════════════════════════════════════════
TOP PARAMETERS FOUND
═══════════════════════════════════════════════════════════════════════════════
$(head -10 "${BABAFRAR_RUN}/parameters/param_frequency.txt" 2>/dev/null || echo "None found")

═══════════════════════════════════════════════════════════════════════════════
EOF
    
    baba_good "Report generated: ${report}"
    
    module_timer_end "REPORT GENERATION"
}

# ============================================================================
# CLEANUP
# ============================================================================
babafrar_cleanup() {
    baba_say "Cleaning up temporary files..."
    rm -f /tmp/babafrar_* 2>/dev/null || true
    baba_good "Cleanup complete!"
}

# ============================================================================
# MAIN BABAFRAR EXECUTION
# ============================================================================
main_babafrar() {
    show_babafrar_banner
    
    if [ $# -eq 0 ]; then
        echo -e "${RED}Usage:${NC} $0 <target-domain>"
        echo -e "${GOLD}Example:${NC} $0 example.com"
        echo ""
        echo -e "${PURPLE}BABAFRAR says: Give me a target and I will make you rich!${NC}"
        exit 1
    fi
    
    setup_babafrar_environment
    
    local target=$(validate_babafrar_target "$1")
    
    check_babafrar_tools
    
    echo ""
    echo -e "${GOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║  🎯 BABAFRAR IS ON THE HUNT!                        ║${NC}"
    echo -e "${GOLD}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "${GOLD}║${NC}  Target: ${target}                    ${GOLD}║${NC}"
    echo -e "${GOLD}║${NC}  Est. Time: 2-4 hours (full scan)         ${GOLD}║${NC}"
    echo -e "${GOLD}║${NC}  Modules: 8                            ${GOLD}║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    module1_target_init "$target"
    module2_subdomain_hunt "$target"
    module3_parameter_discovery "$target"
    module4_parameter_processing
    module5_doctorjack_analysis
    module5b_prepare_dalfox_recon "$target"
    module5c_nuclei_doctorjack_scan "$target"
    module6_xss_testing "$target"
    generate_babafrar_report
    babafrar_cleanup
    
    local total_duration=$(($(date +%s) - SCRIPT_START_TIME))
    
    echo ""
    echo -e "${GOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}║  🎉 BABAFRAR HUNT COMPLETE! 🎉                      ║${NC}"
    echo -e "${GOLD}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "${GOLD}║${NC}  Target:    ${target}                    ${GOLD}║${NC}"
    echo -e "${GOLD}║${NC}  Duration:  $(format_time $total_duration)                  ${GOLD}║${NC}"
    echo -e "${GOLD}║${NC}  Results:   ${BABAFRAR_RUN} ${GOLD}║${NC}"
    echo -e "${GOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local final_poc_file="${BABAFRAR_RUN}/vulnerabilities/dalfox_pocs.txt"
    local final_count=0

    if [ -f "$final_poc_file" ]; then
        final_count=$(grep -c '^\[POC\]' "$final_poc_file" 2>/dev/null || echo 0)
    fi

    if [ "$final_count" -gt 0 ] 2>/dev/null; then
        echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ${final_count} DALFOX POCS FOUND! VERIFY MANUALLY! ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  No Dalfox PoC blocks found in this scan.           ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    fi
    echo ""
}

# ============================================================================
# EXECUTE
# ============================================================================
main_babafrar "$@"
