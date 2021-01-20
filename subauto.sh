
#!/bin/bash
#########################
#
# Subdomain takeover tool
#
#########################

# Clean up
rm hosts.txt;
rm domains.txt;
rm tests.txt
rm done.txt
rm takeovers
rm links
rm asn_list
rm ranges.txt
rm masscan.txt
rm orgs.txt

# Get all chaos domains
curl https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/master/chaos-bugbounty-list.json |jq -r '.programs[] | .domains' |sort -u |cut -d '"' -f2 |while read chaos ; do echo $chaos | tee -a hosts.txt ; done

# Get all chaos domains
curl https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/master/chaos-bugbounty-list.json |jq -r '.programs[] | .domains' |sort -u |cut -d '"' -f2 |while read chaos; do subfinder -d $chaos -silent | tee -a domains.txt ; done

# Get all chaos files
org=$(cat hosts.txt | rev | cut -d '.' -f 2 | rev | tee -a orgs.txt)
cat orgs.txt | wget https://chaos-data.projectdiscovery.io/$org.zip -O chaos_domains/$org.zip
find "chaos_domains" -name "*.zip" | xargs -I@ bash -c '{ cat @ | tee -a domains.txt ; }'

# Get the subdomains from the Rapid7 DNS DB
cat hosts.txt | xargs -I @ -P 10 bash -c '{ crobat -s "@" | tee -a domains.txt ; }' 

# Use amass to find subdomains
amass enum -passive -df hosts.txt | tee -a domains.txt

# DNS GEN Scan
cat domains.txt | dnsgen - | tee -a domains.txt

# Get ASN's
cat hosts.txt | rev | cut -d '.' -f 2 | rev | tee -a orgs.txt
for org in `cat orgs.txt`; do amass intel -org $org | awk '{print $1}' | sed 's/\,$//' | tee -a asn_list ; done
cat asn_list | metabigor net --asn -o ranges.txt

# Use masscan to get IP's
masscan -iL ranges.txt --max-rate 100000 -p80,443 -oL masscan.txt
cat masscan.txt | awk '{print $4}' | tee -a domains.txt


# Run the subdomain takeovers all across the subdomains 
cat domains.txt | sort -u | tee -a tests.txt
subtake -c subtake/fingerprints.json -f tests.txt -ssl -o takeovers  
cat takeovers | awk '{print $3}' | tee -a links

touch done.txt
