#=====================================
# COLOR VARIABLES FOR PRINT STATEMENTS
#=====================================

GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;36m'
RESET_COLOR='\033[0m'


#!/bin/bash
# function to upload screenshots to Terrablob

function uss {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: uss filename.png"
    echo "       ![filename.png](https://terrablob.uberinternal.com/_gateway/prod/dwrk-personal/uploads/random-images/filename.png)"
    return 1
 elif [[ ! -f "$1" ]]; then
    printf "${RED} File path does not exist. ${RESET_COLOR}\n"
    return 1
 else
    local parsed_file_name=$(echo $1 | rev | cut -d'/' -f1 | rev | sed 's/ /_/g')
    tb-cli put $1 /prod/dwrk-personal/uploads/random-images/$parsed_file_name
    echo "![$parsed_file_name](https://terrablob.uberinternal.com/_gateway/prod/dwrk-personal/uploads/random-images/$parsed_file_name)" | pbcopy
    printf "\n${BLUE}Markdown paste - ${RESET_COLOR}\n![$parsed_file_name](https://terrablob.uberinternal.com/_gateway/prod/dwrk-personal/uploads/random-images/$parsed_file_name)\n\n"
    osascript -e 'display notification "Copied '"$parsed_file_name"' path to clipboard" with title "Terrablob upload"' 
    printf "${GREEN}Markdown based TB path copied to clipboard. ${RESET_COLOR}\n"
   fi
}
