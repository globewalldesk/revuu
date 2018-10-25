zip -r tester.zip ../starters
sleep 1
ls -ltr tester.zip
sleep 1
unzip -: tester.zip -d starters
sleep 1
ls -ltr starters
rm tester.zip
rm -rf starters


echo '<--spacer-->'
#####################################


