major=$(grep FROM Dockerfile | awk -F':|-' '{print $2}');let minor=$(git tag | grep -E $major-[0-9]+ | sort -V | tail -n 1 | cut -d- -f2 )+1; echo $major-$minor
