#####################################################################
#     ___        ____             __    ______                      #
#    /   |____  / __ )____ ______/ /_  / ____/___  __  ______ ___   #
#   / /| /_  / / __  / __ `/ ___/ __ \/ __/ / __ \/ / / / __ `__ \  #
#  / ___ |/ /_/ /_/ / /_/ (__  ) / / / /___/ / / / /_/ / / / / / /  #
# /_/  |_/___/_____/\__,_/____/_/ /_/_____/_/ /_/\__,_/_/ /_/ /_/   #
#                                                                   #
#              Author: Sacha Roussakis-Notter - 2022                #
# ###################################################################

#!/bin/bash

################
# BASH COLOURS #
################

nc='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
white='\033[1;37m'
yellow='\033[0;33m'

declare attack_list_file="attack_list/azure_attack_list_.txt"
declare run_date=$(TZ=Australia/Sydney date +"%FI%H:%M")
declare author="Sacha Roussakis-Notter"

# Main function for script
main() {
    check_if_azure_cli_installed
    check_login_status
    enumerate_attack_surfaces
    create_attack_list_directory
    generate_attack_list
    author
}

banner() {
cat << "EOF"
#####################################################################
#     ___        ____             __    ______                      #
#    /   |____  / __ )____ ______/ /_  / ____/___  __  ______ ___   #
#   / /| /_  / / __  / __ `/ ___/ __ \/ __/ / __ \/ / / / __ `__ \  #
#  / ___ |/ /_/ /_/ / /_/ (__  ) / / / /___/ / / / /_/ / / / / / /  #
# /_/  |_/___/_____/\__,_/____/_/ /_/_____/_/ /_/\__,_/_/ /_/ /_/   #
#                                                                   #
#              Author: Sacha Roussakis-Notter - 2022                #
# ###################################################################
EOF
}

# Check if the Azure CLI is installed.
check_if_azure_cli_installed() {
    if ! [ -x "$(command -v az)" ];
    then
        echo -e "⚠️ Installing Azure CLI..."
    else
        echo -e "✅ ${yellow}Azure CLI ${white}is already installed."
    fi
}

# Check if we're logged in with Azure CLI.
check_login_status() {
    echo -e "🔍 ${white}Checking logged in status..."
    if ! [ -n "$(az account show --query id -o tsv)" ];
    then
        echo -e "⛔️ ${white}You are ${red}not ${white}logged into Azure CLI!"
        az account show -o table
        exit 1
    else
        echo -e "✅ ${white}You are ${green}logged ${white}into Azure CLI."
    fi
}

# Enumerate resources that are attackable.
enumerate_attack_surfaces() {
    echo -e  "🔍 ${white}Enumerating ${yellow}resource ${white}attack surfaces...${nc}"
    
    echo -e  "🔍 ${white}Enumerating ${yellow}virtual machines${white}..."
    if ! [ -n $(az vm list --query [].osProfile.computerName -o tsv) ];
    then
        echo -e "❌ ${red}No ${yellow}virtual machines ${white}found..."
    else
        virtual_machine_names=$(az vm list --query [].osProfile.computerName -o tsv)
        number_found="$(echo "${virtual_machine_names}" | wc -l)"
        echo -e "💻 [${green}${number_found}] ${yellow}Virtual machines ${white}have been ${green}found${white}."
    fi
    
    echo -e  "🔍 ${white}Enumerating ${yellow}storage accounts${white}..."
    if ! [ -n "$(az storage account list --query "[? contains(type, 'Microsoft.Storage/storageAccounts')][].{name:name}" -o tsv)" ];
    then
        echo -e "❌ ${red}No ${yellow}storage accounts ${white}found..."
    else
        storage_account_names="$(az storage account list --query "[? contains(type, 'Microsoft.Storage/storageAccounts')][].{name:name}" -o tsv)"
        number_found="$(echo "${storage_account_names}" | wc -l)"
        echo -e "📦 [${green}${number_found}] ${yellow}Storage Accounts ${white}have been ${green}found${white}."
    fi

    echo -e  "🔍 ${white}Enumerating ${yellow}key vaults${white}..."
    if ! [ -n "$(az keyvault list --query "[? contains(type, 'Microsoft.KeyVault/vaults')][].{name:name}" -o tsv)" ];
    then
        echo -e "❌ ${red}No ${yellow}key vaults ${white}found..."
    else
        keyvault_names="$(az keyvault list --query "[? contains(type, 'Microsoft.KeyVault/vaults')][].{name:name}" -o tsv)"
        number_found="$(echo "${keyvault_names}" | wc -l)"
        echo -e "🔑 [${green}${number_found}] ${yellow}Key Vaults ${white}have been ${green}found${white}."
    fi
}

# Create the attack list directory where attack lists will be outputed to.
create_attack_list_directory() {
    if [ ! -d "attack_list" ];
    then 
        echo -e "🔷 Creating attack list directory in working directory for resource attack list..."
        mkdir attack_list
    else
        echo -e "✅ Attack list directory already exists."
    fi
}

# Generate attack surface list
generate_attack_list() {
    echo -e "📋 Generating resource attack list..."
    banner >> ${attack_list_file}
    echo -e "📅 Date:" $run_date >> ${attack_list_file}
    echo -e "---------------------------------------------" >> ${attack_list_file}
    echo >> ${attack_list_file}
    echo -e "Storage Accounts: " >> ${attack_list_file}
    echo -e "Names: " >> ${attack_list_file}
    echo -e "${storage_account_names}" >> ${attack_list_file}
    echo -e "---------------------------------------------" >> ${attack_list_file}
    echo -e "Key Vaults: " >> ${attack_list_file}
    echo -e "Names: " >> ${attack_list_file}
    echo -e "${keyvault_names}" >> ${attack_list_file}
    echo -e "---------------------------------------------" >> ${attack_list_file}
    echo -e "Virtual Machines: " >> ${attack_list_file}
    echo -e "Names: " >> ${attack_list_file}
    echo -e "${virtual_machine_names}" >> ${attack_list_file}
    echo -e "---------------------------------------------" >> ${attack_list_file}
    echo -e "Data Disks: " >> ${attack_list_file}
    echo -e "---------------------------------------------" >> ${attack_list_file}
}

author() {
    echo -e "🔥 ${white}This script has been created by ${yellow}Sacha Roussakis-Notter${white}."
}

main