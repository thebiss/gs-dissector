#!
echo "Naive LUA test by parsing the pcaps. Any output after this is an error."
./view-D5.sh 2>&1 | grep -ni --context=3 "Lua"
./view-Oncor.sh 2>&1 | grep -ni --context=3 "Lua"

echo ""
echo "Test done."

