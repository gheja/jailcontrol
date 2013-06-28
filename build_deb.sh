#!/bin/bash

rm -rf ./build_deb
mkdir ./build_deb
cp -xar ./src/* ./build_deb

if [ -e ".build_deb_version" ]; then
	debian_version=`cat .build_deb_version`
else
	debian_version=0
fi
debian_version=$((debian_version + 1))
echo $debian_version > .build_deb_version

cd ./build_deb

chown 0:0 ./etc/init.d/jailcontrol
chmod 700 ./etc/init.d/jailcontrol

chown 0:0 ./etc/jailcontrol.conf.dist
chmod 600 ./etc/jailcontrol.conf.dist

version=`cat ./etc/init.d/jailcontrol | grep -Eo '^version=.*' | cut -d \" -f 2`
version="${version}-${debian_version}"

cat DEBIAN/control | sed -e "s/__VERSION__/$version/g" > DEBIAN/control.new
mv DEBIAN/control.new DEBIAN/control

# NOTE: will not handle filenames with spaces properly
find -type f | grep -vE "./DEBIAN" | sed -e 's,./,,' > DEBIAN/files
cat DEBIAN/files | xargs md5sum > DEBIAN/md5sums

echo -n "" > DEBIAN/conffiles

cat ../changelog > DEBIAN/changelog

chmod 755 DEBIAN
chmod 644 DEBIAN/changelog
chmod 644 DEBIAN/conffiles
chmod 644 DEBIAN/control
chmod 644 DEBIAN/copyright
chmod 644 DEBIAN/files
chmod 644 DEBIAN/md5sums
chmod 755 DEBIAN/postinst

dpkg-deb --build ./ ../jailcontrol_${version}.deb
