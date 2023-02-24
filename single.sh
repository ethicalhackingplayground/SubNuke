
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
rm takeovers 
rm done.txt
rm links
rm asn_list
rm ranges.txt
rm masscan.txt

mkdir -p chaos_domains

# The single domain
DOMAIN=$1
if [[ -z "$DOMAIN" ]] ; then
    echo "Usage: $0 <Domain>"
    exit 1;
fi


# Get all chaos domains
curl https://raw.githubusercontent.com/projectdiscovery/public-bugbounty-programs/master/chaos-bugbounty-list.json |jq -r '.programs[]  | .domains' |sort -u |cut -d '"' -f2 |while read chaos; do echo $chaos | grep -i "$DOMAIN" | tee -a domains.txt ; done

# Get all chaos files
org=$(echo $DOMAIN | rev | cut -d '.' -f 2 | rev)
wget https://chaos-data.projectdiscovery.io/$org.zip -O chaos_domains/$org.zip
cd chaos_domains; unzip $org.zip ; cd ../
find "chaos_domains" -name "*.txt" | xargs -I@ bash -c '{ cat @ | tee -a domains.txt ; }'

# Use Subfinder to find subdomains
subfinder -d $DOMAIN -silent -all | anew domains.txt

# Use amass to find subdomains
amass enum -passive -d $DOMAIN | anew domains.txt

# Use amass to do an active subdomain enumeration
amass enum -active -d $DOMAIN | anew domains.txt

# findomain
findomain --output --quiet --target $DOMAIN 
cat $DOMAIN.txt | anew domains.txt

# DNS GEN Scan
cat domains.txt | dnsgen - | anew domains.txt

# Use crobat to get subdomains from rapid7
#crobat -s $DOMAIN | tee -a domains.txt 
#cat domains.txt | xargs -I@ bash -c '{ crobat -s "@" | anew domains.txt ; }'

# Get ASN's

amass intel -org $org | awk '{print $1}' | sed 's/\,$//' | anew asn_list
cat asn_list | metabigor net --asn -o ranges.txt

# Use masscan to get IP's
masscan -iL ranges.txt --max-rate 100000 -p80,443 -oL masscan.txt
cat masscan.txt | awk '{print $4}' | tee -a domains.txt


# Run the subdomain takeovers all across the subdomains 
cat domains.txt | sort -u | tee -a tests.txt
subtake -c subtake/fingerprints.json -f tests.txt -ssl -o takeovers
cat takeovers | awk '{print $3}' | tee -a links

touch done.txt
