#!/bin/bash

clear

# Colors for better visual appeal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║               🔐 KEEPER COMMANDER CLI SETUP                  ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

echo -e "${YELLOW}🚀 Initializing your secure environment...${NC}"
echo ""

# Progress steps
steps=(
    "🐍 Setting up Python 3.12 environment"
    "📦 Installing security packages"
    "🔧 Configuring Keeper Commander CLI"
    "⚡ Finalizing setup"
)

# Show progress with animation
for i in "${!steps[@]}"; do
    echo -e "${BLUE}${steps[$i]}${NC}"
    
    # Animated progress bar
    echo -n "   ["
    for j in {1..20}; do
        echo -n "█"
        sleep 0.1
    done
    echo -e "] ${GREEN}✓${NC}"
    echo ""
done

# Wait for actual installation to complete
echo -e "${YELLOW}⏳ Waiting for installation to complete...${NC}"
echo ""

# Clean progress dots
progress_count=0
while [ ! -f /tmp/keeper-setup-complete ]; do
    case $((progress_count % 4)) in
        0) echo -ne "\r   Working ⠋   " ;;
        1) echo -ne "\r   Working ⠙   " ;;
        2) echo -ne "\r   Working ⠹   " ;;
        3) echo -ne "\r   Working ⠸   " ;;
    esac
    progress_count=$((progress_count + 1))
    sleep 0.5
done

echo -ne "\r                    \r"

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║                    ✅ SETUP COMPLETE!                        ║"
echo "║                                                              ║"
echo "║  🎯 Your Keeper Commander CLI environment is ready           ║"
echo "║  🔐 Use test credentials only in this learning environment   ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${CYAN}🚀 Click the START button to begin your tutorial!${NC}"
echo "" 