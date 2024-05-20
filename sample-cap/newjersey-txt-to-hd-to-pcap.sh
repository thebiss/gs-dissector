#!

srcfile="RAW_Capture_NJ.txt.txt"
basefile=$(basename -a "${srcfile}")
hdfile="${basefile}.hd"
pcapfile="${basefile}.pcap"

echo "Creating HD file..."
cat ${srcfile} \
	| grep -v "^\[CRC:BAD\]" \
	| sed -E 's/\[CRC: OK\]\s*//' \
	| sed -E 's/\w*Baudrate.*$//' \
	| sed 's/\(\w\w\)/ \1/g' \
	| sed 's/^\(.*\)/000000\t\1\n/' > "${hdfile}"

echo "creating pcap..."
text2pcap -l 147 "${hdfile}" "${pcapfile}"

echo "Done, results in ${pcapfile}"
	

	