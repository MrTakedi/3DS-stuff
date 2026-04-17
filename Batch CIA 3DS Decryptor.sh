#!/bin/bash
# Batch CIA 3DS Decryptor

echo "$(date '+%a %b %d %T %Y')" > log.txt 2>&1
echo "Decrypting..."

# Enable case-insensitive globbing and ignore unmatched globs
shopt -s nullglob nocaseglob

# Delete all .ncch files
for a in *.ncch; do
    rm -f "$a" >/dev/null 2>&1
done

# Process .3ds files
for a in *.3ds; do
    CUTN="${a%.*}"
    # Check if the filename does not contain "decrypted"
    if [[ "${CUTN,,}" != *"decrypted"* ]]; then
        echo | decrypt "$a" >> log.txt 2>&1
        ARG=()
        for f in "$CUTN".*.ncch; do
            case "$f" in
                "$CUTN.Main.ncch") i=0 ;;
                "$CUTN.Manual.ncch") i=1 ;;
                "$CUTN.DownloadPlay.ncch") i=2 ;;
                "$CUTN.Partition4.ncch") i=3 ;;
                "$CUTN.Partition5.ncch") i=4 ;;
                "$CUTN.Partition6.ncch") i=5 ;;
                "$CUTN.N3DSUpdateData.ncch") i=6 ;;
                "$CUTN.UpdateData.ncch") i=7 ;;
                *) continue ;;
            esac
            ARG+=("-i" "$f:$i:$i")
        done
        makerom -f cci -ignoresign -target p -o "$CUTN-decrypted.3ds" "${ARG[@]}" >> log.txt 2>&1
    fi
done

# Process .cia files
for a in *.cia; do
    CUTN="${a%.*}"
    if [[ "${CUTN,,}" != *"decrypted"* ]]; then
        ctrtool -tmd "$a" > content.txt
        FILE="content.txt"
        
        if grep -qE "^T.*D.*00040000" "$FILE"; then
            echo | decrypt "$a" >> log.txt 2>&1
            ARG=()
            i=0
            for f in "$CUTN".*.ncch; do
                ARG+=("-i" "$f:$i:$i")
                ((i++))
            done
            makerom -f cia -ignoresign -target p -o "$CUTN-decfirst.cia" "${ARG[@]}" >> log.txt 2>&1
        fi
        
        if grep -qE "^T.*D.*0004000E|^T.*D.*0004008C" "$FILE"; then
            X=0
            echo | decrypt "$a" >> log.txt 2>&1
            for h in "$CUTN".*.ncch; do
                NCCHN="${h%.*}"
                n="${NCCHN#$CUTN.}"
                if [[ "$n" -gt "$X" ]]; then
                    X=$n
                fi
            done
            
            ARG=()
            i=0
            while IFS= read -r CONLINE; do
                if [[ "$CONLINE" == *"Content id"* ]]; then
                    while [[ $X -ge $i ]]; do
                        if [[ -f "$CUTN.$i.ncch" ]]; then
                            CONLINE_SUB="${CONLINE:24:8}"
                            ID=$((16#$CONLINE_SUB))
                            ARG+=("-i" "$CUTN.$i.ncch:$i:$ID")
                            ((i++))
                            break
                        else
                            ((i++))
                        fi
                    done
                fi
            done < "$FILE"
            
            if grep -qE "^T.*D.*0004000E" "$FILE"; then
                makerom -f cia -ignoresign -target p -o "$CUTN (Patch)-decrypted.cia" "${ARG[@]}" >> log.txt 2>&1
            fi
            if grep -qE "^T.*D.*0004008C" "$FILE"; then
                makerom -f cia -dlc -ignoresign -target p -o "$CUTN (DLC)-decrypted.cia" "${ARG[@]}" >> log.txt 2>&1
            fi
        fi
    fi
done

rm -f content.txt >/dev/null 2>&1

for a in *-decfirst.cia; do
    CUTN="${a%.*}"
    makerom -ciatocci "$a" -o "${CUTN/-decfirst/-decrypted}.cci" >> log.txt 2>&1
done

for a in *-decfirst.cia; do
    rm -f "$a" >/dev/null 2>&1
done

for a in *.ncch; do
    rm -f "$a" >/dev/null 2>&1
done

clear
read -n 1 -s -r -p "Finished, please press any key to exit."
echo
