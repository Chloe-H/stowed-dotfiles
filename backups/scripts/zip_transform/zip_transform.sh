#!/bin/bash

# This script will zip up the release version of the DLL and PDB file for the
# specified transform.

echo -e "\nEnter the site name abbreviation as it appears in the repo folder name (e.g. 'tmc' for 'cls.impl.tmc')."
read -p "Site name: " siteName
repoFolder="cls.impl.${siteName}"

echo -e "Enter a description for the file." 
read -p "File description: " fileDescription

if [ -d ${repoFolder} ]; then
    # Pattern to find the release binaries
    searchPattern="*Softek.Cls.Impl.*/bin/Release/Softek.Cls.Impl.*"

    # Pattern to exclude the test directory
    excludePattern="*Softek.Cls.Impl.*.Test/*"

    # Get the path to the release directory
    releaseDirectory=$(dirname $(find ${repoFolder} -not -path ${excludePattern} -wholename ${searchPattern}.dll))

    # Get the names of the DLL and PDB files
    declare -a files
    for file in $(find ${repoFolder} -not -path ${excludePattern} -wholename ${searchPattern}); do
        files+=($(basename ${file}))
    done

    outputDirectory=$(pwd)

    # Get names of more files to include in the archive
    echo -e "Enter the name of another file in the release directory to include in the archive."
    read -p "File name (leave blank to continue): " additionalFileName

    while [ -n "${additionalFileName}" ]; do
        # Only add the file to the list if it exists
        if [ -e "${releaseDirectory}/${additionalFileName}" ]; then
            files+=(${additionalFileName})
        fi

        read -p "File name (leave blank to continue): " additionalFileName
    done

    # Get the short commit hash and branch name
    cd ${repoFolder}
    commitHash=$(git rev-parse --short HEAD)
    branchName=$(git rev-parse --abbrev-ref HEAD)
    cd ${outputDirectory}

    archiveName="${outputDirectory}/${siteName}-transform-${branchName}-${commitHash}.tar"

    # Create the archive
    echo -e "\nZipping up files..."
    tar -cvf ${archiveName} -C ${releaseDirectory} ${files[@]}

    echo -e "\nOutput archive: ${archiveName}"

    # Run the script that exports the auth tokens for Rocket.Chat
    source ./rocket_chat_auth.sh

    echo -e "\nUploading the archive to Rocket.Chat..."
    curl \
        -H "X-User-Id: ${rocketChatUserId}" \
        -H "X-Auth-Token: ${rocketChatToken}" \
        -F "description=${fileDescription}" \
        -F file=@${archiveName} \
        "https://chat.goilluminate.com/api/v1/rooms.upload/oFcZmSsHHhr3L8HRD"

    echo -e "\n\nRemoving local copy of archive..."
    rm ${archiveName}

    echo -e "\nDone!"
else
    echo "The directory '${repoFolder}' does not exist!"
fi

