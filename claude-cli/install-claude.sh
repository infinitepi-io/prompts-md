install_claude() {
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
    if command -v pnpm &> /dev/null; then
        info "Installing Claude Code with pnpm..."
        pnpm install -g @anthropic-ai/claude-code
    elif command -v npm &> /dev/null; then
        info "Installing Claude Code with npm..."
        npm install -g @anthropic-ai/claude-code
    else
        fail "Neither npm nor pnpm is installed"
    fi
    if command -v pnpm >/dev/null 2>&1; then
        info "Installing MCP server with pnpm..."
        claude mcp add opentofu -- pnpm dlx @opentofu/opentofu-mcp-server
    else
        info "Installing MCP server with npm..."
        claude mcp add opentofu -- npx @opentofu/opentofu-mcp-server
    fi
    if command -v docker &> /dev/null; then
        info "Setting up AWS documentation MCP with Docker..."
        info "Pulling AWS documentation MCP image..."
        docker pull mcp/aws-documentation:latest
        if command -v aws &> /dev/null; then
        info "Syncing bookmarks to S3 bucket..."
        . assume 'infinitepi-io/infra-mgnt/AWSAdministratorAccess' || fail "Failed to assume role for S3 access."
        aws s3 cp s3://bookmark-mcp-aps1-spx5d/bookmarks.json ~/.data/bookmarks.json --source-region ap-south-1 && pass "Bookmarks synced successfully." || fail "Failed to sync bookmarks."
        . assume --unset
        else
            fail "AWS CLI not found, cannot sync bookmarks."
        fi
        claude mcp add aws-docs -- docker run \
            --rm \
            --interactive \
            --env FASTMCP_LOG_LEVEL=ERROR \
            --env AWS_DOCUMENTATION_PARTITION=aws \
            mcp/aws-documentation:latest
        info "Setting up Bookmark Manager MCP server..."
        info "Pulling Bookmark Manager MCP image..."
        docker pull mindriftfall2infinitepiio/bookmark-manager-mcp:v1.0.0
        claude mcp add bookmark-manager -- docker run \
            --rm \
            --interactive \
            --volume ~/.data:/app/.data \
            mindriftfall2infinitepiio/bookmark-manager-mcp:latest
        pass "All the Docker based MCP Server setup is completed successfully."
    else
        info "Docker not found, skipping AWS documentation MCP setup"
    fi
    pass "Starting Claude Code terminal..."
    exec claude
}
