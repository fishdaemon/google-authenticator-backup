#/bin/bash 
set -eu
function clean_up()
{
	echo "cleaning up due to $1" 1>&2
	echo ""
	if [ -d $out ]
	then
		rm -rfi $out
	fi
	exit 1
}
function tmpfs_fail()
{
	echo "/run/lock is not tmpfs" 1>&2
	exit 1
}
function deps_fail()
{
	echo "please install $1 or add it to you path" 1>&2
	exit 1
}
skip_xdg="no"
for dep in adb sqlite3 qrencode xdg-open
do
	if [[ $dep == "xdg-open" ]]
	then 
		command -v $dep &> /dev/null || skip_xdg="yes"
	else
		command -v $dep &> /dev/null || deps_fail $dep
	fi
done


trap "'clean_up' 'SIGHUP'" SIGHUP
trap "'clean_up' 'SIGINT'" SIGINT
trap "'clean_up' 'SIGTERM'" SIGTERM  
trap "'clean_up' 'a general error on line ${LINENO}'"  ERR

mount | grep /run/lock | grep tmpfs || tmpfs_fail

out=$(mktemp -d /run/lock/XXXXXXX)
adb root 
adb pull /data/data/com.google.android.apps.authenticator2/databases/databases $out/db
for a in $(sqlite3  $out/db "select original_name,secret from accounts")
do 
	echo "otpauth://totp/"$(echo $a | cut -f1 -d'|')"?secret="$(echo $a | cut -f2 -d'|') | qrencode -o $out/$(echo $a | cut -f1 -d'|')".png"
done
echo "your files are located at $out"
if [[ $skip_xdg == "no" ]]
then
	for f in $(ls $out | grep .png)
	do
		while read -p"Do you want to open $f? [y/n]"
		do
			if [[ $REPLY == "y" ]]
			then 
				echo "opening: $out/$f"
				xdg-open $out/$f
				break
			elif [[ $REPLY == "n" ]]
			then
				echo "skipping: $out/$f"
				break
			fi
		done
	done
fi
clean_up "program complete"

