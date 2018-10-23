curl http://larrysanger.org/ > temp.tmp
echo "This is another line." >> temp.tmp
tail temp.tmp
rm data/temp.tmp
