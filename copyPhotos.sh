#!/bin/sh

usage()
{
    echo "Usage: copyPhotos.sh -h|[[-s|-o] <src-directory> <dst-directory>]"
}

paramIndex=0

fillParam()
{
    param=$1
    
    echo "fillParam: $param from $1"
    
    if [ $paramIndex -eq 0 ]; then
        srcDir=`echo "$param" | sed 's/\/*$//'`
    fi
    if [ $paramIndex -eq 1 ]; then
        dstDir=`echo "$param" | sed 's/\/*$//'`
    fi
    
    paramIndex=`expr $paramIndex + 1`
}

skipDuplicateFiles=false
overwriteDuplicateFiles=false

while [ $# -gt 0 ]; do
    echo "param: $1"
    
    case "$1" in
        -s ) skipDuplicateFiles=true ;;
        -o ) overwriteDuplicateFiles=true ;;
        -h ) usage ;;
        * ) fillParam "$1" ;;
    esac
    
    shift
done

echo "skipDuplicates: $skipDuplicateFiles"
echo "overwriteDuplicates: $overwriteDuplicateFiles"

echo "srcDir: $srcDir"
echo "dstDir: $dstDir"

if [ -z "$srcDir" ] || [ -z "$dstDir" ]; then
	usage
	exit 1
fi

srcDir=`readlink -f "$srcDir"`
dstDir=`readlink -f "$dstDir"`

cd "$dstDir"

if [ "$PWD" != "$dstDir" ]; then
	echo "<dst-directory> ($dstDir) is not a valid directory."
	exit 2
fi

cd "$srcDir"

if [ "$PWD" != "$srcDir" ]; then
	echo "<src-directory> ($srcDir) is not a valid directory."
	exit 3
fi

for file in *; do
	if [ -f "$file" ]; then
		mtime=$(stat "$file" -c%y | cut -d" " -f1 | sed 's/-//g')
		myear=$(stat "$file" -c%y | cut -d" " -f1| cut -d"-" -f1)

		if [ ! -d "$dstDir/$mtime" ]; then
		    echo "making directory $dstDir/$mtime";
			mkdir -p "$dstDir/$mtime";
		fi

        if [ $skipDuplicateFiles = true ]; then
            echo "copying -n -v $file to $dstDir/$mtime"
            cp -n -v "$file" "$dstDir/$mtime"
        elif [ $overwriteDuplicateFiles = true ]; then
            echo "copying -v $file to $dstDir/$mtime"
            cp -v "$file" "$dstDir/$mtime"
        fi
	fi
done

