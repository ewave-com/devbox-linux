UNISON_VERSION=2.48.4
sudo apt-get -y install inotify-tools ocaml-nox build-essential
curl -L https://github.com/bcpierce00/unison/archive/2.48.4.tar.gz | tar zxv -C /tmp
cd /tmp/unison-2.48.4
sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c
make UISTYLE=text NATIVE=true STATIC=true
cp src/unison src/unison-fsmonitor ~/bin
