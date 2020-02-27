major=$(grep FROM Dockerfile | awk -F':|-' '{print $2}');let minor=$(git describe --tags --abbrev=0 | grep -E $major-[0-9]+ | cut -d- -f2 )+1; echo $major-$minor
