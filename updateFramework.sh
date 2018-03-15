#!/bin/bash

APP_path="./CargoTestApp/Frameworks/"

CAR="./CargoCore/"
CARFr="CargoCore.framework"

rebuild() {
	cd $1
	echo "Rebuild the framework for the $1 directory..."
	xcodebuild -target "Aggregate"
	cd ..
}

updateCargo() {
	AT_path="./ATInternetHandler/"
	ADB_path="./AdobeHandler/"
	FB_path="./FacebookHandler/"
	TUN_path="./TuneHandler/"

	AT_path_frmwrks="$AT_pathFrameworks/"
	ADB_path_frmwrks="$ADB_pathFrameworks/"
	FB_path_frmwrks="$FB_pathFrameworks/"
	TUN_path_frmwrks="$TUN_pathFrameworks/"

	rm -rf "$AT_path_frmwrks$CARFr"
	rm -rf "$ADB_path_frmwrks$CARFr"
	rm -rf "$APP_path$CARFr"
	rm -rf "$FB_path_frmwrks$CARFr"
	rm -rf "$TUN_path_frmwrks$CARFr"

	cp -R "$CAR$CARFr" "$AT_path_frmwrks"
	cp -R "$CAR$CARFr" "$ADB_path_frmwrks"
	cp -R "$CAR$CARFr" "$APP_path"
	cp -R "$CAR$CARFr" "$FB_path_frmwrks"
	cp -R "$CAR$CARFr" "$TUN_path_frmrwks"

	rebuild $AT_path
	rebuild $ADB_path
	rebuild $FB_path
	rebuild $TUN_path
}

error() {
	echo "Possible arguments : 'ATInternet', 'Adobe', 'Facebook', 'CargoCore' or 'Tune'"
	exit
}

if [$# == 0 || [$# == 1 && $1 == "CargoCore"]]; then
	updateCargo
elif [$# > 1]; then
	echo "Too many arguments. Either use one or none."
	error
elif [$# = 1 && [$1 == "ATInternet" || $1 == "Adobe" || $1 == "Facebook" || $1 == "Tune"]]; then
	handler="$1Handler"
	framework="$handler.framework"
	APP_path_frmwrk="$APP_path$framework"

	rm -rf "$APP_path_frmwrk"
	cp -R "./$handler/$framework" "$APP_path"
else
	error
fi


