# google-authenticator-backup
Bash script that create new QR codes images from android google authenticator app

The script is only tried on ubuntu.

The script uses mktemp -d in /var/run/lock  if tmpfs is mounted there. 

It will download the sqlite DB from your phone to the temp dir and create png files in the temp dir with a qr code that can be scanned in. 
The db contains the secret,  thats why it only wants to write to tmpfs, although encrypted drive would be safe as well. 

if the script is aborted, completed or fails the rm -rfi will run on the tmpdir
