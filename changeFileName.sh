if [ $# -eq 0 ]; then
	echo "Usage: CommandName fileRootName startNo endNo offset"
	exit 1
fi

fileName=$1
startNo=$2
endNo=$3
offset=$4

NOfChanges=$((endNo-startNo+1))
echo "$NOfChanges files names are changed!"

if [ $offset -gt 0 ]; then
	for ((i=endNo; i>=startNo; i--))
	do
		newNo=$((i+offset))
		echo $fileName$newNo"_raw.dat"
		oldFileName=$fileName$i"_raw.dat"
		newFileName=$fileName$newNo"_raw.dat"

		mv $oldFileName $newFileName
		echo "$oldFileName is changed to $newFileName"
		echo "****************************************************************************************************************"
	done	 
else
	for ((i=startNo; i<=endNo; i++))
	do
		newNo=$((i+offset))
		echo $fileName$newNo"_raw.dat"
		oldFileName=$fileName$i"_raw.dat"
		newFileName=$fileName$newNo"_raw.dat"

		mv $oldFileName $newFileName
		echo "$oldFileName is changed to $newFileName"
		echo "****************************************************************************************************************"
	done	 
fi




