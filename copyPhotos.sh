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
		mtime=$( stat "$file" -c%y | cut -d" " -f1 | sed 's/-//g')
		myear=$( stat "$file" -c%y | cut -d" " -f1 | cut -d"-" -f1)
                mmonth=$(stat "$file" -c%y | cut -d" " -f1 | cut -d"-" -f2)
                mday=$(  stat "$file" -c%y | cut -d" " -f1 | cut -d"-" -f3)

		if [ ! -d "$dstDir/$myear/$mmonth/$mday" ]; then
		    echo "making directory $dstDir/$myear/$mmonth/$mday";
			mkdir -p "$dstDir/$myear/$mmonth/$mday";
		fi

        if [ $skipDuplicateFiles = true ]; then
            echo "copying -n -v $file to $dstDir/$myear/$mmonth/$mday"
            cp -n -v "$file" "$dstDir/$myear/$mmonth/$mday"
        elif [ $overwriteDuplicateFiles = true ]; then
            echo "copying -v $file to $dstDir/$myear/$mmonth/$mday"
            cp -v "$file" "$dstDir/$myear/$mmonth/$mday"
        fi
	fi
done

