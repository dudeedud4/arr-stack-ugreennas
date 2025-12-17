#!/bin/bash
# Port and IP conflict detection for compose files

check_conflicts() {
    local errors=0
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || repo_root="."

    # Check each compose file individually for internal conflicts
    for compose_file in "$repo_root"/docker-compose*.yml; do
        [[ -f "$compose_file" ]] || continue
        local filename
        filename=$(basename "$compose_file")

        # Extract host ports (the left side of port mappings like "8080:80")
        local ports
        ports=$(grep -E '^\s+-\s*"?[0-9]+:[0-9]+"?\s*$' "$compose_file" 2>/dev/null | \
            sed -E 's/.*"?([0-9]+):[0-9]+"?.*/\1/' | sort)

        # Check for duplicate ports
        local dup_ports
        dup_ports=$(echo "$ports" | uniq -d)
        if [[ -n "$dup_ports" ]]; then
            echo "    ERROR: Duplicate ports in $filename:"
            echo "$dup_ports" | while read -r port; do
                echo "      - Port $port is used multiple times"
            done
            ((errors++))
        fi

        # Extract static IPs (ipv4_address: X.X.X.X)
        local ips
        ips=$(grep -E 'ipv4_address:\s*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$compose_file" 2>/dev/null | \
            sed -E 's/.*ipv4_address:\s*([0-9.]+).*/\1/' | sort)

        # Check for duplicate IPs
        local dup_ips
        dup_ips=$(echo "$ips" | uniq -d)
        if [[ -n "$dup_ips" ]]; then
            echo "    ERROR: Duplicate static IPs in $filename:"
            echo "$dup_ips" | while read -r ip; do
                echo "      - IP $ip is assigned to multiple services"
            done
            ((errors++))
        fi
    done

    return $errors
}
