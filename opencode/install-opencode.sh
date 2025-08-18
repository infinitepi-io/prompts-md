install_opencode() {
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
        info "Installing Opencode with pnpm..."
        pnpm install -g opencode-ai@latest
    elif command -v npm &> /dev/null; then
        info "Installing Opencode with npm..."
        npm install -g opencode-ai@latest
    else
        fail "Neither npm nor pnpm is installed"
    fi
    # Configure OpenTofu MCP server in opencode.json
    info "Configuring OpenTofu MCP server..."
    CONFIG_FILE="$HOME/.config/opencode/opencode.json"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    if command -v pnpm >/dev/null 2>&1; then
        PACKAGE_MANAGER="pnpm dlx"
    else
        PACKAGE_MANAGER="npx"
    fi
    
    # Create or update opencode.json with OpenTofu MCP server
    # Split PACKAGE_MANAGER into array for JSON
    IFS=' ' read -ra PKG_CMD <<< "$PACKAGE_MANAGER"
    
    cat > "$CONFIG_FILE" << EOF
        {
        "\$schema": "https://opencode.ai/config.json",
        "mcp": {
            "opentofu": {
            "type": "local",
            "command": ["${PKG_CMD[0]}", "${PKG_CMD[1]}", "@opentofu/opentofu-mcp-server"],
            "enabled": true
            }
        }
        }
EOF
    pass "OpenTofu MCP server configured successfully."
    if command -v docker &> /dev/null; then
        info "Setting up AWS documentation MCP with Docker..."
        info "Pulling AWS documentation MCP image..."
        docker pull mcp/aws-documentation:latest
        # Configure AWS documentation MCP server
        info "Configuring AWS documentation MCP server..."
        # Update the existing config to add AWS docs MCP server
        if command -v jq &> /dev/null; then
            # Use jq for JSON manipulation if available
            jq '.mcp["aws-docs"] = {
                "type": "local",
                "command": ["docker", "run", "--rm", "--interactive", "--env", "FASTMCP_LOG_LEVEL=ERROR", "--env", "AWS_DOCUMENTATION_PARTITION=aws", "mcp/aws-documentation:latest"],
                "enabled": true
            }' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        else
            # Fallback: recreate the entire config file
            cat > "$CONFIG_FILE" << 'EOF'
            {
            "$schema": "https://opencode.ai/config.json",
            "mcp": {
                "opentofu": {
                "type": "local",
                "command": ["npx", "@opentofu/opentofu-mcp-server"],
                "enabled": true
                },
                "aws-docs": {
                "type": "local",
                "command": ["docker", "run", "--rm", "--interactive", "--env", "FASTMCP_LOG_LEVEL=ERROR", "--env", "AWS_DOCUMENTATION_PARTITION=aws", "mcp/aws-documentation:latest"],
                "enabled": true
                }
            }
            }
EOF
        fi
        info "Setting up Bookmark Manager MCP server..."
        info "Pulling Bookmark Manager MCP image..."
        docker pull mindriftfall2infinitepiio/bookmark-manager-mcp:latest
        # Configure Bookmark Manager MCP server
        info "Configuring Bookmark Manager MCP server..."
        if command -v jq &> /dev/null; then
            # Use jq for JSON manipulation if available
            jq '.mcp["bookmark-manager"] = {
                "type": "local",
                "command": ["docker", "run", "--rm", "--interactive", "--volume", "'$HOME'/.data:/app/.data", "mindriftfall2infinitepiio/bookmark-manager-mcp:latest"],
                "enabled": true
            }' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        else
            # Fallback: recreate the entire config file with all MCP servers
            cat > "$CONFIG_FILE" << 'EOF'
            {
            "$schema": "https://opencode.ai/config.json",
            "mcp": {
                "opentofu": {
                "type": "local",
                "command": ["npx", "@opentofu/opentofu-mcp-server"],
                "enabled": true
                },
                "aws-docs": {
                "type": "local",
                "command": ["docker", "run", "--rm", "--interactive", "--env", "FASTMCP_LOG_LEVEL=ERROR", "--env", "AWS_DOCUMENTATION_PARTITION=aws", "mcp/aws-documentation:latest"],
                "enabled": true
                },
                "bookmark-manager": {
                "type": "local",
                "command": ["docker", "run", "--rm", "--interactive", "--volume", "$HOME/.data:/app/.data", "mindriftfall2infinitepiio/bookmark-manager-mcp:v1.0.0"],
                "enabled": true
                }
            }
            }
EOF
        fi
        pass "All the Docker based MCP Server setup is completed successfully."
    else
        info "Docker not found, skipping AWS documentation MCP setup"
    fi
    pass "Starting Opencode terminal..."
    exec opencode
}