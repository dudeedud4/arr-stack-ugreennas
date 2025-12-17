#!/bin/bash
# Hardcoded domain detection
# Reads domain from local .env and checks if it appears in staged files

check_hardcoded_domain() {
    local warnings=0
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || repo_root="."

    local env_file="$repo_root/.env"

    # Need .env to know what domain to look for
    if [[ ! -f "$env_file" ]]; then
        echo "    SKIP: No .env file (can't determine your domain)"
        return 0
    fi

    # Extract domain from .env
    local domain
    domain=$(grep -E '^DOMAIN=' "$env_file" 2>/dev/null | cut -d= -f2 | tr -d '"' | tr -d "'")

    if [[ -z "$domain" || "$domain" == "yourdomain.com" ]]; then
        echo "    SKIP: No custom domain configured in .env"
        return 0
    fi

    # Get staged files (excluding .env which is gitignored anyway)
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -v '^\.env$')

    if [[ -z "$staged_files" ]]; then
        return 0
    fi

    # Check each staged file for hardcoded domain
    local files_with_domain=""
    for file in $staged_files; do
        # Get staged content
        local content
        content=$(git show ":$file" 2>/dev/null) || continue

        # Skip binary files
        case "$file" in
            *.png|*.jpg|*.gif|*.ico|*.woff|*.ttf) continue ;;
        esac

        # Check for domain (case insensitive)
        if echo "$content" | grep -qi "$domain" 2>/dev/null; then
            # Count occurrences
            local count
            count=$(echo "$content" | grep -ci "$domain" 2>/dev/null || echo 0)
            files_with_domain+="      - $file ($count occurrences)"$'\n'
            ((warnings++))
        fi
    done

    if [[ -n "$files_with_domain" ]]; then
        echo "    WARNING: Your domain '$domain' is hardcoded in staged files:"
        echo "$files_with_domain"
        echo "    Note: Some files (like Traefik dynamic configs) can't use \${DOMAIN}"
        echo "          Review to ensure this is intentional."
    fi

    # Return 0 - warnings don't block commits
    return 0
}
