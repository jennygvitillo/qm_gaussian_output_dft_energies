#!/bin/bash

# Gaussian16 Output Parser
# Description: This script extracts energy values and HOMO/LUMO orbital information
#              from ALL Gaussian 16 output files (.log and .out formats) in the current directory
# 
# Features:
# - Extracts SCF energy, TD-DFT energy (if present), thermochemistry data
# - Extracts HOMO/LUMO orbital energies for both alpha and beta spins
# - Checks frequency calculation status and negative frequencies
# - Outputs results in CSV format with .txt extension
# - Output filename includes current date in YYYYMMDD format
#
# Author: Jenny G. Vitillo (University of Insubria) and DeepSeek
#
# Cite as:
# J.G. Vitillo, 'gaussian_output_dft_energies.sh', https://github.com/jennygvitillo/qm_gaussian_output_dft_energies (2025).
#
# DATA EXTRACTION:
# - SCF energy: always extracted if present
# - TD-DFT energy: extracted if TD calculation was performed
# - HOMO/LUMO orbitals: always extracted if present
# - Thermochemical energies (ZPE, H, G): ONLY if frequency calculation was performed
#
# The script searches for:
# - "SCF Done" (SCF energy - always)
# - "Total Energy, E(TD-HF/TD-DFT)" (TD-DFT energy - if TD calculation) 
# - "Sum of electronic and zero-point Energies" (E+ZPE - if freq calculation)
# - "Sum of electronic and thermal Enthalpies" (H - if freq calculation)
# - "Sum of electronic and thermal Free Energies" (G - if freq calculation)
# - "Alpha/Beta occ/virt eigenvalues" (HOMO/LUMO orbitals - always)
# - "Frequencies" (frequency calculation status)
#
# Usage:
# 1. Make the script executable:
#    chmod +x gaussian_output_dft_energies.sh
#
# 2. Run the script (choose one method):
#
#    Method A - If script is in current directory:
#    ./gaussian_output_dft_energies.sh
#
#    Method B - If script is in different directory:
#    /path/to/script/gaussian_output_dft_energies.sh
#
#    Method C - If script is in your PATH (see point 3. Having the script in the path is convenient
#    because then can be run simply writing:
#    gaussian_output_dft_energies.sh
#    )
#
# 3. Optional: Add script to PATH for easy access
#    To make the script available from any directory:
#    sudo cp gaussian_output_dft_energies.sh /usr/local/bin/
#    OR add this to ~/.bashrc: export PATH=$PATH:/path/to/script/directory
#
# The script will process all .log and .out files in the CURRENT WORKING DIRECTORY
# where you run the command, regardless of where the script is located.
# REQUIREMENTS: Linux system with bash

# Get current date in YYYYMMDD format
current_date=$(date +%Y%m%d)

# Output file name with date prefix
output_file="${current_date}_gaussian_results.txt"

# CSV headers with Frequencies column
echo "File,Frequencies,E (hartree),E TD-HF/TD-DFT (hartree),E+ZPE (hartree),H (hartree),G (Hartree),HOMO alpha (hartree),LUMO alpha (hartree),HOMO beta (hartree),LUMO beta (hartree)" > "$output_file"

# Function to extract energy value from a line
extract_energy() {
    echo "$1" | awk -F'=' '{print $2}' | awk '{print $1}'
}

# Function to check frequency status in a file
check_frequencies() {
    local file="$1"
    
    # Check if file contains frequency lines
    if grep -q -E "[[:space:]]*Frequencies[[:space:]]+--" "$file"; then
        # Check for negative frequencies
        local negative_lines=$(grep -E "[[:space:]]*Frequencies[[:space:]]+--" "$file" | grep -e "-[0-9]")
        
        if [ -n "$negative_lines" ]; then
            echo "error"
        else
            echo "OK"
        fi
    else
        echo "not present"
    fi
}

# Display information about processing directory
current_dir=$(pwd)
echo "Processing Gaussian files in: $current_dir"
echo "Output file: $output_file"
echo "Note: Thermochemical energies (ZPE, H, G) require frequency calculation"
echo "      Other energies and orbitals are extracted regardless"
echo ""

# Arrays to track frequency results
files_with_issues=()
files_ok=()
files_no_freq=()

# Process all .log and .out files in current directory
for input_file in *.log *.out; do
    # Skip if no matching files exist
    [ -e "$input_file" ] || continue
    
    echo "Processing $input_file..."
    
    # Check frequency status first
    freq_status=$(check_frequencies "$input_file")
    
    # Display frequency status
    case "$freq_status" in
        "OK")
            echo "  ✓ Frequencies: OK (all positive)"
            files_ok+=("$input_file")
            ;;
        "error")
            echo "  ✗ Frequencies: ERROR (negative frequencies found)"
            files_with_issues+=("$input_file")
            ;;
        "not present")
            echo "  ○ Frequencies: Not present"
            files_no_freq+=("$input_file")
            ;;
    esac
    
    # Variables for energy values
    e_scf=""
    e_td=""
    e_zpe=""
    enthalpy=""
    free_energy=""
    
    # Variables for HOMO/LUMO orbitals
    homo_alpha=""
    lumo_alpha=""
    homo_beta=""
    lumo_beta=""
    
    # Variables to store last found energy values
    last_scf_energy=""
    last_td_energy=""
    
    # Flags to track orbital sections
    in_alpha_occ=0
    in_alpha_virt=0
    in_beta_occ=0
    in_beta_virt=0
    
    # Read file line by line
    while IFS= read -r line; do
        # === ENERGY EXTRACTION ===
        # Look for SCF energy line and update last found value
        if [[ "$line" == *"SCF Done:  E("* ]] && [[ "$line" == *"= "* ]]; then
            last_scf_energy=$(extract_energy "$line")
        fi
        
        # Look for TD-DFT energy line
        if [[ "$line" == *"Total Energy, E(TD-HF/TD-DFT) ="* ]]; then
            last_td_energy=$(extract_energy "$line")
        fi
        
        # Look for thermochemistry energy summaries
        if [[ "$line" == *"Sum of electronic and zero-point Energies="* ]]; then
            e_zpe=$(extract_energy "$line")
        fi
        
        if [[ "$line" == *"Sum of electronic and thermal Enthalpies="* ]]; then
            enthalpy=$(extract_energy "$line")
        fi
        
        if [[ "$line" == *"Sum of electronic and thermal Free Energies="* ]]; then
            free_energy=$(extract_energy "$line")
        fi
        
        # === HOMO/LUMO ORBITAL EXTRACTION ===
        # Check if we reached optimization completion
        if [[ "$line" == *"Optimization completed."* ]]; then
            # Reset flags for new optimization
            in_alpha_occ=0
            in_alpha_virt=0
            in_beta_occ=0
            in_beta_virt=0
        fi
        
        # Alpha occupied section
        if [[ "$line" == *"Alpha  occ. eigenvalues"* ]]; then
            in_alpha_occ=1
            in_alpha_virt=0
            in_beta_occ=0
            in_beta_virt=0
            # Take the last value in the line
            homo_alpha=$(echo "$line" | awk '{print $NF}')
        elif [[ "$line" == *"Alpha virt. eigenvalues"* ]]; then
            in_alpha_occ=0
            in_alpha_virt=1
            in_beta_occ=0
            in_beta_virt=0
            # If this is the first Alpha virt line, take the first value
            if [[ -z "$lumo_alpha" ]]; then
                lumo_alpha=$(echo "$line" | awk '{print $5}')
            fi
        # Beta occupied section (if present)
        elif [[ "$line" == *"Beta  occ. eigenvalues"* ]]; then
            in_alpha_occ=0
            in_alpha_virt=0
            in_beta_occ=1
            in_beta_virt=0
            # Take the last value in the line
            homo_beta=$(echo "$line" | awk '{print $NF}')
        elif [[ "$line" == *"Beta virt. eigenvalues"* ]]; then
            in_alpha_occ=0
            in_alpha_virt=0
            in_beta_occ=0
            in_beta_virt=1
            # If this is the first Beta virt line, take the first value
            if [[ -z "$lumo_beta" ]]; then
                lumo_beta=$(echo "$line" | awk '{print $5}')
            fi
        # If we're in Alpha occupied section, always update the last value
        elif [[ $in_alpha_occ -eq 1 ]]; then
            if [[ "$line" != "" ]]; then
                homo_alpha=$(echo "$line" | awk '{print $NF}')
            fi
        # If we're in Beta occupied section, always update the last value
        elif [[ $in_beta_occ -eq 1 ]]; then
            if [[ "$line" != "" ]]; then
                homo_beta=$(echo "$line" | awk '{print $NF}')
            fi
        fi
        
    done < "$input_file"
    
    # Assign the last found SCF energy
    if [ -n "$last_scf_energy" ]; then
        e_scf="$last_scf_energy"
    else
        e_scf="N/A"
    fi
    
    # Assign the last found TD energy (if present)
    if [ -n "$last_td_energy" ]; then
        e_td="$last_td_energy"
    else
        e_td="N/A"
    fi
    
    # Handle missing HOMO/LUMO values
    [ -z "$homo_alpha" ] && homo_alpha="N/A"
    [ -z "$lumo_alpha" ] && lumo_alpha="N/A"
    [ -z "$homo_beta" ] && homo_beta="N/A"
    [ -z "$lumo_beta" ] && lumo_beta="N/A"
    
    # Write results to CSV file with frequency status
    echo "\"$input_file\",$freq_status,$e_scf,$e_td,$e_zpe,$enthalpy,$free_energy,$homo_alpha,$lumo_alpha,$homo_beta,$lumo_beta" >> "$output_file"
    
    echo ""
done

# Display frequency summary
echo "=== FREQUENCY CALCULATION SUMMARY ==="
if [ ${#files_ok[@]} -gt 0 ]; then
    echo "✓ Files with OK frequencies (all positive):"
    printf '   - %s\n' "${files_ok[@]}"
    echo ""
fi

if [ ${#files_no_freq[@]} -gt 0 ]; then
    echo "○ Files without frequency calculation:"
    printf '   - %s\n' "${files_no_freq[@]}"
    echo ""
fi

if [ ${#files_with_issues[@]} -gt 0 ]; then
    echo "✗ Files with NEGATIVE frequencies (CHECK NEEDED):"
    printf '   - %s\n' "${files_with_issues[@]}"
    echo ""
fi

echo "Processing completed. Results saved to: $output_file"
echo "Total files processed: $(ls *.log *.out 2>/dev/null | wc -w)"
