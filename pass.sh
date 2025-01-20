#!/bin/bash
#init color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#init bool variables
foundpass=no
anywordlists=no

#init stat variables
wordlistcount=0
wordlisthits=0

#check for directory, create test file
if [ -d wordlists ];
	then
	#worklists directory exists
	cd wordlists
	#check if it has any wordlists			
		txtfiles=$(find . -type f -name "*.txt" | wc -l)
		if [ $txtfiles -eq 0 ]; then
		anywordlists=no
		else
		anywordlists=yes
		fi   
	
	else
	#directory does not exists
	mkdir wordlists
	cd wordlists	
fi


#Welcome screen
echo -e "${GREEN}[+] This simple script will help you check your password against common wordlists${NC}"
echo -e "${ORANGE}[-] Please mind - the script will pull leaked databases and common credentials from SecLists github and its current size is around 500mb${NC}"
echo -e "${ORANGE}[-] If you want to check against other wordlists, just paste the txt files to the wordlists folder${NC}"
echo -e "${ORANGE}[-] Suggested wordlists pages for manual download:${NC}\n"

echo -e "${CYAN}[*] https://weakpass.com/${NC}"
echo -e "${CYAN}[*] https://www.skullsecurity.org/wiki/Passwords${NC}\n"

echo -e "${ORANGE}[-] Or use a downloader and copy to worlists folder${NC}\n"
echo -e "${CYAN}[*] https://github.com/BlackArch/wordlistctl${NC}\n"

echo -e "${ORANGE}[-] Remember! Some wordlists may be VERY big.${NC}\n"

# pull or update wordlists

if [ "$anywordlists" = "no" ];
then
echo -e "${GREEN}[+] It seems that there are no worlists yet, do you want to download some wordlists or exit script?${NC}"
select downloadwordlists in "Download" "Exit"; do
	case $downloadwordlists in
	Download ) 
	#SecLists
	echo -e "${GREEN}[+] Cloning the wordlists from SecLists - this may take a while!${NC}\n"
	git clone -n --depth=1 --filter=tree:0 \
	  https://github.com/danielmiessler/SecLists 
	cd SecLists
	git sparse-checkout set --no-cone /Passwords/Common-Credentials /Passwords/Leaked-Databases
	git checkout
	cd ..
	break;;
	
	Exit ) exit;;
	esac
	done	
		
fi


#read password
echo -e "${GREEN}[+] Please type in your password${NC}"
read -s pass

#later# do string check for empty password
echo ""
#later# check other password lists

#check against all downloaded lists

for i in `find . -type f -name "*.txt"`;
do
  wordlistcount=$((wordlistcount+1))
  if grep -w ^${pass}$ ${i} -q;
  then
  foundpass=yes
  echo -e "${RED}[!] your password is on the wordlist!${NC}\n ${i}"
  wordlisthits=$((wordlisthits+1))
  #echo "$i"
  echo ""

fi
done

#results
if [ "$foundpass" = "no" ];
then
echo -e "${GREEN}[+} It seems that your password is not on the common wordlists"
echo -e "${GREEN}[+} Stats: your password has been checked against $wordlistcount wordlists"
else
echo -e "${GREEN}[+} Stats: your password has been checked against $wordlistcount wordlists and was found on $wordlisthits\n"

fi



#cleanup
echo -e "${GREEN}[+} Do you want to clean up? If so script and files will be deleted\n"

select cleanup in "Yes" "No"; do
	case $cleanup in
	Yes ) 
		cd .. 
		echo -e "${RED}[!] Deleting wordlist folder${NC}\n ${i}"
		rm -rf wordlists
		echo -e "${RED}[!] Deleting script${NC}\n ${i}"
	break;;
	
	No ) 
	echo -e "${GREEN}[+} No, exiting script\n"

	exit;;
	esac
	done	



