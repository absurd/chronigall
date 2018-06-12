this_directory=`pwd`

while [ "$this_directory" != "/" ] ; do
#file_path=$(find "$this_directory" -maxdepth 1 -path $1)
#if [[ -z "${file_path// }" ]]; then
if [ -f "$this_directory/$1" ]; then
    echo $this_directory"/"$1
    this_directory='/'
else
    this_directory=`dirname "$this_directory"`
fi
done
