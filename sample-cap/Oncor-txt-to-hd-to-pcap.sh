#!

srcfile="Oncor_Capture_01-07-2023_30hrs.txt"
basefile=$(basename -a "${srcfile}")
hdfile="${basefile}.hd"
pcapfile="${basefile}.pcap"

### This used to remove CRC BAD, but they seem to include other examples...
### - reversed, too many problems with rows marked BAD CRCs...
echo "Creating HD file..."
cat ${srcfile} \
    | grep -v "^\[CRC:BAD\]" \
	| sed -E 's/\[CRC:...\]\s*//' \
	| sed -E 's/\w*Baudrate.*$//' \
	| sed 's/\(\w\w\)/ \1/g' \
	| sed 's/^\(.*\)/000000\t\1\n/' > "${hdfile}"

echo "creating pcap..."
text2pcap -l 147 "${hdfile}" "${pcapfile}"

echo "Done, results in ${pcapfile}"
	

	