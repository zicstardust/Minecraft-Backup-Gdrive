#!/bin/sh
gdrive='/bin/gdrive'
awk='/bin/awk'
bash='/bin/sh'
gp='/bin/grep'

requirements () {
if [[-f $gdrive || -L $gdrive]]; then
	echo "gdrive installed"
else
	echo "please install gdrive"
	exit
fi
if [[-f $awk || -L $awk]]; then
        echo "awk installed"
else    
        echo "please install awk"
        exit
fi
if [[-f $bash || -L $bash]]; then
        echo "bash installed"
else    
        echo "please install bash"
        exit
fi
if [[-f $gp || -S $gp]]; then
        echo "grep installed"
else    
        echo "please install grep"
        exit
fi
}


install () {
    cp main.sh /bin/minebkgdrive
    chmod +x /bin/minebkgdrive
    echo "minebkgdrive installed"
    exit
}


requirements
install
