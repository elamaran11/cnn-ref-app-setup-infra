#!/bin/bash

clear

# once support multiple providers, then add this back
# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

show_menu(){
echo ""
echo "===================================================="
echo "SETUP MENU for $DEPLOYMENT_NAME"
echo "===================================================="
echo "1)  Install Prerequisites Tools"
echo "2)  Enter Installation Script Inputs"
echo "3)  Provision Kubernetes cluster"
echo "4)  Setup Demo Services (jenkins, ELK Monitoring, namespaces)"
echo "----------------------------------------------------"
echo "10) Validate Kubectl"
echo "11) Validate Prerequisite Tools"
echo "----------------------------------------------------"
echo "90) Delete Staging App"
echo "91) Delete Production App"
echo "99) Delete Kubernetes cluster"
echo "===================================================="
echo "Please enter your choice or <q> or <return> to exit"
read opt
}

show_menu
while [ opt != "" ]
    do
    if [[ $opt = "" ]]; then 
        exit;
    else
        clear
        case $opt in
        1)
                ./1-installPrerequisiteTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisiteTools.log
                show_menu
                ;;
        2)
                ./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
                show_menu
                ;;
        3)
                ./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
                show_menu
                ;;
        4)
                ./4-setupDemo.sh $DEPLOYMENT 2>&1 | tee logs/4-setupDemo.log
                show_menu
                ;;
        10)
                ./validateKubectl.sh  2>&1 | tee logs/validateKubectl.log
                show_menu
                ;;
        11)
                ./validatePrerequisiteTools.sh $DEPLOYMENT 2>&1 | tee logs/validatePrerequisiteTools.log
                show_menu
                ;;
        90)
                kubectl delete namespace Staging
                show_menu
                ;;               
        91)
                kubectl delete namespace production
                show_menu
                ;;               
        99)
                ./deleteInfrastructure.sh $DEPLOYMENT 2>&1 | tee logs/deleteInfrastructure.log
                show_menu
                ;;
        q)
           	break
           	;;
        *) 
            	echo "invalid option"
            	show_menu
            	;;
    esac
fi
done
