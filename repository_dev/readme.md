- create repository
  . sudo su
  . mkdir -p /STORAGE/repository/hOS/debian|ubuntu/conf
  . cd /STORAGE/repository/hOS/debian|ubuntu/conf

    - vi distributions
Origin: hOS Repository
Label: hOS
Suite: bionic
Codename: bionic
Version: 18.04
Architectures: i386 amd64 armhf arm64
Components: main
Description: hOS Repository

    - vi options
verbose
basedir  .
ask-passphrase
distdir  /STORAGE/repository/hOS/ubuntu/repos/dists
outdir   /STORAGE/repository/hOS/ubuntu/repos

  . cd /STORAGE/repository/hOS/ubuntu
  . reprepro --ask-passphrase -Vb /STORAGE/repository/hOS/ubuntu export
Created directory "/STORAGE/repository/hOS/ubuntu/db"
Exporting bionic...
Created directory "/STORAGE/repository/hOS/ubuntu/repos"
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists"
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic"
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main"
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-i386"
 exporting 'bionic|main|i386'...
  creating '/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-i386/Packages' (uncompressed,gzipped)
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-amd64"
 exporting 'bionic|main|amd64'...
  creating '/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-amd64/Packages' (uncompressed,gzipped)
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-armhf"
 exporting 'bionic|main|armhf'...
  creating '/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-armhf/Packages' (uncompressed,gzipped)
Created directory "/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-arm64"
 exporting 'bionic|main|arm64'...
  creating '/STORAGE/repository/hOS/ubuntu/repos/dists/bionic/main/binary-arm64/Packages' (uncompressed,gzipped)

  . nginx virtualhost
    - ! E: Failed to fetch http://hos.serveftp.org/ubuntu/pool/main/d/dbus-mq/dbus-mq_1.0.2-r-2.90_all.deb  404  Not Found [IP: 106.104.7.46 80]
      . location ~ /(db|conf) -> (^db$|^conf$)
    - vi /etc/nginx/sites-available/hos.serveftp.org
        root            /STORAGE/www/hOS;
        autoindex       on;
        server_tokens   off;
        autoindex_exact_size    off;
        autoindex_localtime     on;

        location ~ /(^db$|^conf$) {
                deny        all;
                return      404;
        }

##      ssl_certificate /etc/letsencrypt/live/aigo.serveftp.org/fullchain.pem;
##      ssl_certificate_key /etc/letsencrypt/live/aigo.serveftp.org/privkey.pem;
}

server {
        listen          19280;
        server_name     hos.serveftp.org;
        root            /STORAGE/www/hOS;
        autoindex       on;
        server_tokens   off;
        autoindex_exact_size    off;
        autoindex_localtime     on;

        location ~ /(^db$|^conf$) {
                deny        all;
                return      404;
        }
}

    - ln -s /etc/nginx/sites-available/hos.serveftp.org /etc/nginx/sites-enable/hos.serveftp.org
	- ln -s /STORAGE/repository/hOS/ubuntu/repos /STORAGE/www/hOS/ubuntu

- add deb to repository
  . put xx.deb ~/workspace/hOS
  . sudo su
  . repro_hOS.sh add ~/workspace/hOS/xx.deb
~/workspace/hOS/xx.deb: component guessed as 'main'
Exporting indices...
gpg: using "50842E4A" as default secret key for signing
gpg: using "50842E4A" as default secret key for signing

- apt client
  . sudo su
  . echo 'deb [trusted=yes] http://url/ubuntu bionic main' > /etc/apt/sources.list.d/hOS.list
  . apt-key adv --keyserver keyserver.ubuntu.com --recv 50842E4AExecuting: /tmp/apt-key-gpghome.JyZw3HZPGy/gpg.1.sh --keyserver keyserver.ubuntu.com --recv 50842E4A
gpg: key EDB94E1250842E4A: public key "Cheng-Chang Ho (StarfruitPi Project Repository) <earlybird.astro@gmail.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
  . exit
  . sudo apt-get update
    !! W: Conflicting distribution: http://hos.serveftp.org/ubuntu bionic InRelease (expected xenial but got )
    - rm -rf /var/lib/apt/lists/*
	- deb ... /ubuntu bionic -> ./bionic
	