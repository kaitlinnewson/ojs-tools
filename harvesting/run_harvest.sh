#!/bin/sh

#-----------------------------------------------------------------------
# This script takes OAI-PMH URLs from OJS journals, harvests xml files using
# the 'pyoaiharvest' python script (https://github.com/vphill/pyoaiharvester),
# and harvests PDF files from the generated xml file using 'get_full_text.sh'.
#-----------------------------------------------------------------------

# Create array for journal titles & OAI urls

journalTitle[0]='myjournal1'
journalURL[0]='https://ojssite.ca/index.php/myjournal1/oai'

journalTitle[1]='myjournal2'
journalURL[1]='https://ojssite.ca/index.php/myjournal2/oai'

# End of journals list
# ------------------------------------------------------------------

# The directory to save files to
directory="/path/to/files"

# Email address to send the logfile to
email=""

# Check for publications in the last 31 days
lastrundate=$(date --date='31 days ago' '+%Y-%m-%d')

currentdate=$(date +"%Y-%m-%d")

logfile="$directory/logs/log_$currentdate.txt"
touch $logfile

# Loop through journals to harvest xml and full text articles, and redirect the output to the logfile
for ((i=0; i<${#journalTitle[*]}; i++)); do
	echo "Starting harvest for ${journalTitle[i]}..."

	# Catch errors in the OAI URL; ignore SSL certificate issues
	if curl --silent --head --fail --insecure "${journalURL[i]}"; then

		# Create the directory in JOURNALS for the journal if it doesn't exist
		[[ -d $directory/"JOURNALS"/"${journalTitle[i]}" ]] || mkdir $directory/JOURNALS/${journalTitle[i]}

		# Remove the previous xml file if it exists
		[ -e $directory/"JOURNALS"/"${journalTitle[i]}"/"${journalTitle[i]}.xml" ] && rm $directory/"JOURNALS"/"${journalTitle[i]}"/"${journalTitle[i]}.xml"

		# Run the python script to harvest the xml file for articles in JATS format, and write the output to the log file
		python $directory/pyoaiharvest.py -l "${journalURL[i]}" -o $directory/"JOURNALS"/"${journalTitle[i]}"/"${journalTitle[i]}.xml" -m jats -f $lastrundate | tee -a $logfile

		# Get the full text of the articles using the harvested xml file, and write the output to the log file
		echo "Retrieving full text for ${journalTitle[i]}..."
		sudo $directory/get_full_text.sh "$directory/JOURNALS/${journalTitle[i]}/${journalTitle[i]}.xml" "$directory/JOURNALS/${journalTitle[i]}/${journalTitle[i]}-$currentdate" | tee -a $logfile

	else
		echo "URL does not exist: ${journalURL[i]}"
		continue
	fi
done 2>&1 | tee -a $logfile | mail -s "OJS Monthly Harvest Log $currentdate" $email # Email logfile
