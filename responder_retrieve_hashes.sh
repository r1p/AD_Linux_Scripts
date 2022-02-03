#!/bin/bash
# Retrieve the NTLMv2-SSP hashes captured by Responder.py from the Responder-Session.log file
# Download Responder.py here: https://github.com/SpiderLabs/Responder/blob/master/Responder.py

outputfile="responder_retrieve_hashes.txt"
outputfile_existed=false

if [ -f $outputfile ]; then
    outputfile_existed=true
    echo "[*] File $outputfile already exists. A cleanup will be done at the end to avoid duped results."
    echo ""
fi

for user in $(strings * | grep "NTLMv2-SSP Hash" | cut -d ":" -f 4-6 | sort -u -f | awk '{$1=$1};1')
do
    echo "[+] Found hash for the user: $user. Dumping content in $outputfile";
    strings Responder-Session.log | grep "NTLMv2-SSP Hash" | grep -i $user | cut -d ":" -f 4-10 | head -n 1 | awk '{$1=$1};1' >> $outputfile
done

# Remove duped if ran several times
if $outputfile_existed; then
    echo "[*] Doing a cleanup for $outputfile to avoid dupes"
    echo "[*] Initial file length: $(wc -l < $outputfile)"
    awk -i inplace '!seen[$0]++' $outputfile
    echo "[*] Cleanup done!"
    echo "[*] Ending file length: $(wc -l < $outputfile)"
fi