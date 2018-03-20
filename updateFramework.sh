#!/bin/bash
SCRIPT_NAME="updateFramework.sh"

APP_path="./CargoTestApp/"
APP_path_frmwrks="${APP_path}Frameworks/"

CAR="./CargoCore/"
CARFr="CargoCore.framework"

rebuild() {
	cd $1
	echo "${SCRIPT_NAME}: Rebuild the framework for the $1 directory..."
	xcodebuild -target "Aggregate"
	cd -
}

updateCargo() {
	AT_path="./ATInternetHandler/"
	ADB_path="./AdobeHandler/"
	FB_path="./FacebookHandler/"
	TUN_path="./TuneHandler/"

	AT_path_frmwrks="${AT_path}Frameworks/"
	ADB_path_frmwrks="${ADB_path}Frameworks/"
	FB_path_frmwrks="${FB_path}Frameworks/"
	TUN_path_frmwrks="${TUN_path}Frameworks/"

	rm -rf "${AT_path_frmwrks}${CARFr}"
	rm -rf "${ADB_path_frmwrks}${CARFr}"
	rm -rf "${APP_path_frmwrks}${CARFr}"
	rm -rf "${FB_path_frmwrks}${CARFr}"
	rm -rf "${TUN_path_frmwrks}${CARFr}"

	cp -R "${CAR}${CARFr}" "${AT_path_frmwrks}"
	cp -R "${CAR}${CARFr}" "${ADB_path_frmwrks}"
	cp -R "${CAR}${CARFr}" "${APP_path_frmwrks}"
	cp -R "${CAR}${CARFr}" "${FB_path_frmwrks}"
	cp -R "${CAR}${CARFr}" "${TUN_path_frmwrks}"

	rebuild ${AT_path}
	rebuild ${ADB_path}
	rebuild ${FB_path}
	rebuild ${TUN_path}
}

error() {
	echo "${SCRIPT_NAME}: Possible arguments are 'ATInternet', 'Adobe', 'Facebook', 'CargoCore' or 'Tune'"
	exit
}

if [[ $# == 0 || ($# == 1 && $1 == "CargoCore") ]]; then
	updateCargo
elif [[ $# > 1 ]]; then
	echo "${SCRIPT_NAME}: Too many arguments. Either use one or none."
	error
elif [[ $# == 1 && ($1 == "ATInternet" || $1 == "Adobe" || $1 == "Facebook" || $1 == "Tune") ]]; then
	handler="${1}Handler"
	framework="${handler}.framework"

	rm -rf "${APP_path_frmwrks}${framework}"
	cp -R "./${handler}/${framework}" "${APP_path_frmwrks}"

	echo "${SCRIPT_NAME}: Copied ${framework} into ${APP_path_frmwrks}"
else
	error
fi


