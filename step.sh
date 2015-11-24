#!/bin/bash

set -e

if [ -z "${gradle_file}" ]; then
	printf "\e[31mNo gradle_file specified\e[0m\n"
	exit 1
fi

if [ -z "${gradle_task}" ]; then
	printf "\e[31mNo gradle_task specified\e[0m\n"
	exit 1
fi

if [ ! -z "${workdir}" ] ; then
	echo
	echo "=> Switching to specified workdir"
	echo '$' cd "${workdir}"
	cd "${workdir}"
fi

if [ -z "${apk_file_include_filter}" ]; then
	apk_file_include_filter="*.apk"
fi

if [ -z "${apk_file_exclude_filter}" ]; then
	apk_file_exclude_filter=""
fi

gradle_tool=gradle
if [ ! -z "$gradlew_path" ] ; then
	gradle_tool="$gradlew_path"
elif [ -x "./gradlew" ] ; then
	gradle_tool="./gradlew"
fi

echo
echo "=== CONFIGURATION ==="
echo " * Using gradle tool: ${gradle_tool}"
echo " * Gradle build file: ${gradle_file}"
echo " * Gradle task: ${gradle_task}"
echo " * Gradle options: ${gradle_options}"

echo
echo "=> Running gradle task ..."
set -x
${gradle_tool} --build-file "${gradle_file}" ${gradle_task} ${gradle_options}
set +x

echo
echo "=> Moving APK files with filter: include-> '${apk_file_include_filter}', exclude-> '${apk_file_exclude_filter}'"
find . -name "${apk_file_include_filter}" ! -name "${apk_file_exclude_filter}" | while IFS= read -r apk; do
	deploy_path="${BITRISE_DEPLOY_DIR}/$(basename "$apk")"

	printf "🚀  \e[32mCopy ${apk} to ${deploy_path}\e[0m\n"
	cp "${apk}" "${deploy_path}"
done

echo
echo "=> DONE"
