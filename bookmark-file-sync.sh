bookmark_sync_to_s3() {
    set -o nounset
    set -o pipefail
    IFS=$'\n\t'

    # Define colors for output
    if [ -t 1 ] && [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
        red='\e[31m'
        green='\e[32m'
        yellow='\e[33m'
        cyan='\e[36m'
        reset='\e[0m'
    else
        red=''
        green=''
        yellow=''
        cyan=''
        reset=''
    fi

    # Helper functions for logging
    info() { echo >&2 -e "${cyan}[i] $*${reset}"; }
    pass() { echo >&2 -e "${green}[O] $*${reset}"; }
    fail() { echo >&2 -e "${red}[X] $*${reset}"; return 1; }

    # Sync bookmarks to S3 bucket
    if command -v aws &> /dev/null; then
        info "Syncing bookmarks to S3 bucket..."
        . assume 'infinitepi-io/infra-mgnt/AWSAdministratorAccess' || fail "Failed to assume role for S3 access."
        aws s3 cp ~/.data/bookmarks.json s3://bookmark-mcp-aps1-spx5d/bookmarks.json --source-region ap-south-1 && pass "Bookmarks synced successfully." || fail "Failed to sync bookmarks."
        . assume --unset
    else
        fail "AWS CLI not found, cannot sync bookmarks."
    fi
}
