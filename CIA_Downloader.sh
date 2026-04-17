#!/bin/bash
# CIA Downloader

error_exit() {
    clear
    echo
    echo "Download failed, please press any key to finish."
    read -n 1 -s -r
    finish_script
}

finish_script() {
    rm -f ERROR >/dev/null 2>&1
    rm -f content.txt >/dev/null 2>&1
    rm -rf "./$INPUT/" >/dev/null 2>&1
    exit
}

# Main Menu Loop
while true; do
    clear
    echo
    read -p "Enter the Title ID of the Game: " INPUT
    
    # Check string length (must be 16 characters)
    if [[ ${#INPUT} -eq 16 ]]; then
        break
    fi
    echo
    read -n 1 -s -r -p "Please Enter a Valid ID, eg. 0004000000030800 or 0004000000040a00, press any key to Continue."
done

clear
echo
echo "Checking..."

aria2c "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/cetk" --dir="./$INPUT" --allow-overwrite=true --conf-path=aria2.conf >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    aria2c "http://ccs.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/cetk" --dir="./$INPUT" --allow-overwrite=true --conf-path=aria2.conf >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        aria2c "http://3DS.titlekeys.gq/ticket/$INPUT" --dir="./$INPUT" --out=cetk --allow-overwrite=true --conf-path=aria2.conf >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            error_exit
        fi
    fi
fi

# Fetch TMD
aria2c "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/tmd" --dir="./$INPUT" --allow-overwrite=true --conf-path=aria2.conf >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    aria2c "http://ccs.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/tmd" --dir="./$INPUT" --allow-overwrite=true --conf-path=aria2.conf >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        error_exit
    fi
fi

# Download CIA Parts
ctrtool -t tmd "./$INPUT/tmd" > content.txt
i=0
while IFS= read -r CONLINE; do
    if [[ "$CONLINE" == *"Content id"* ]]; then
        ((i++))
        clear
        echo
        echo "Downloading..."
        echo "Close the window to cancel for next time resume."
        echo
        echo "#$i data"
        
        CONTENT_ID="${CONLINE:24:8}"
        
        aria2c "http://nus.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/$CONTENT_ID" --dir="./$INPUT" --conf-path=aria2.conf --console-log-level=error
        if [[ $? -ne 0 ]]; then
            clear
            echo
            echo "Downloading..."
            echo "Close the window to cancel for next time resume."
            echo
            echo "#$i data"
            aria2c "http://ccs.cdn.c.shop.nintendowifi.net/ccs/download/$INPUT/$CONTENT_ID" --dir="./$INPUT" --conf-path=aria2.conf --console-log-level=error
            if [[ $? -ne 0 ]]; then
                error_exit
            fi
        fi
    fi
done < content.txt

# Package it together
clear
echo
echo 'Do not insert \/:*?"<>|'
read -p "Enter the Name of the Game: " GNAME
clear
echo
echo "Packing..."
make_cdn_cia "$INPUT" "$GNAME.cia" 2>ERROR

if [[ -s ERROR ]]; then
    rm -f "$GNAME.cia" >/dev/null 2>&1
    error_exit
fi

clear
echo
echo "Finished, please press any key to exit."
read -n 1 -s -r
finish_script
