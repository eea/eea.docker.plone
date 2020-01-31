major=$(grep FROM Dockerfile | awk -F':|-' '{print $2}');let minor=$(git tag | grep -cE $major-[0-9]+)+1; echo $major-$minor
