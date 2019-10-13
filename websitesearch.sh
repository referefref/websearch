#!/bin/bash
########################################################
# websitesearch.sh
# Version 1.6
########################################################
# Usage:
# websitesearch.sh url depth searchquery urllist
#
# url = $1
# depth = $2
# searchquery = $3
# urllist = $4
#

breakloop ()
{
	exitloop=1
}

trap breakloop SIGINT SIGTERM

function ProgressBar {
let _progress=(${1}*100/${2}*100)/100
let _done=(${_progress}*4)/10
let _left=40-$_done
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")

printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%" | tee progressbar
progressbarString=$(cat progressbar)

# Update progress % on html output file
sed -i "s/Progress.*/${progressbarString}/g" $htmlOutput
 
}

#########################################################
# Check command line args
#########################################################

if [ "$#" -eq 4 ]; then
	if [ -s $4 ]; then
		listgiven=1
		cp $4 level0.links
		depth=depth+1
	else 
		echo "Error: url list file does not exist" >&2; exit 1
	fi
fi

if [ "$#" -gt 3 ]; then
	searchquery=$3
	#searchquery=$(echo $3 | sed -e "s/'/'\\\\''/g; 1s/^/'/; \$s/\$/'/")
	if [ $searchquery = '' ]; then
		echo "Error: search query is invalid" >&2; exit 1
	fi	
fi

if [ "$#" -gt 2 ]; then
	re='^[0-9]+$'
	if ! [[ $2 =~ $re ]]; then
 		echo "Error: Depth is not a number" >&2; exit 1
	else
		depth=$2
	fi
fi

if [ "$#" -eq 0 ]; then
	echo "Usage: websitesearch url depth searchquery urllist" >&2; exit 1
fi

if [ "$#" -gt 1 ]; then
	re='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	if [[ $1 =~ $re ]]; then 

		#Make a folder for the project files
		project=$(echo $1 | sed -e 's/https:\/\///g' -e 's/\///g' -e 's/http:\/\///g')
		mkdir -p $project
		cd $project
		touch pages.txt
		printf "\r\n"

		## Add in HTML Output feature
		## Modify the htmlOutput variable to change the location of the output file, will add a command line parameter for this in future
		htmlName=$(echo $project | sed -e 's/\/\(.*\)./\1/')
		htmlOutput=$(echo "/var/www/html/$htmlName.html")
		echo "html file is called: $htmlName"
	       	dateStarted=$(date +"%m-%d-%Y")	
		
		## Add in HTML Header and styles
		printf '\r<html>\n<head>\n' > $htmlOutput
		echo "<title>Websitesearch $htmlName $dateStarted</title>" >> $htmlOutput
		# Auto-refresh page
		printf '<meta http-equiv="refresh" content="2" >\n' >> $htmlOutput
		# CSS
		
		# Google maps
		printf '<style>#map { width: 100%%; height: 400px; background-color: black; } </style>' >> $htmlOutput

		# Header menu
		printf '<style>ul { list-style-type: none; margin: 0; padding: 0; overflow: hidden; background-color: #333; position: fixed; top: 0; width:100%%; }\r\nli { float: left; }\r\nli a { display: block; color: white; text-align: center; padding: 14px 16px; text-decoration: none; }\r\nli a:hover:not(.active) { background-color: #111; }\r\n.active { background-color: #4CAF50;
}\r\n</style>' >> $htmlOutput

		# Footer menu for recent projects
		printf '<style>projects { list-style-type: none; margin: 0; padding: 0; overflow: hidden; background-color: #333; position: fixed; bottom: 0; width: 100%%;}</style>\r\n' >> $htmlOutput

		# Buttons for pages
	       printf '\r\n<style>.linkButton { -moz-box-shadow:inset 0px 34px 0px -15px #b54b3a; -webkit-box-shadow:inset 0px 34px 0px -15px #b54b3a; box-shadow:inset 0px 34px 0px -15px #b54b3a; background-color:#a73f2d; border:1px solid #241d13; display:inline-block; cursor:pointer; color:#ffffff; font-family:Arial; font-size:15px; font-weight:bold; padding:9px 23px; text-decoration:none; text-shadow:0px -1px 0px #7a2a1d; }\r\n.linkButton:hover { background-color:#b34332; }\r\n .linkButton:active { position:relative; top:1px; }</style>' >> $htmlOutput	

	        # CSS for filename heading
		printf '\r\n<style>.filename { -moz-box-shadow:inset 0px 1px 0px 0px #ffffff;-webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;box-shadow:inset 0px 1px 0px 0px #ffffff;background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #ffffff), color-stop(1, #f6f6f6));background:-moz-linear-gradient(top, #ffffff 5%%, #f6f6f6 100%%);background:-webkit-linear-gradient(top, #ffffff 5%%, #f6f6f6 100%%);background:-o-linear-gradient(top, #ffffff 5%%, #f6f6f6 100%%);background:-ms-linear-gradient(top, #ffffff 5%%, #f6f6f6 100%%);background:linear-gradient(to bottom, #ffffff 5%%, #f6f6f6 100%%);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#ffffff", endColorstr="#f6f6f6",GradientType=0);background-color:#ffffff;-moz-border-radius:6px;-webkit-border-radius:6px;border-radius:6px;border:1px solid #dcdcdc;display:inline-block;cursor:pointer;color:#666666;font-family:Arial;font-size:15px;font-weight:bold;padding:6px 24px;text-decoration:none;text-shadow:0px 1px 0px #ffffff;}.filename:hover {background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #f6f6f6), color-stop(1, #ffffff));	background:-moz-linear-gradient(top, #f6f6f6 5%%, #ffffff 100%%);background:-webkit-linear-gradient(top, #f6f6f6 5%%, #ffffff 100%%);background:-o-linear-gradient(top, #f6f6f6 5%%, #ffffff 100%%);background:-ms-linear-gradient(top, #f6f6f6 5%%, #ffffff 100%%);	background:linear-gradient(to bottom, #f6f6f6 5%%, #ffffff 100%%);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr="#f6f6f6", endColorstr="#ffffff",GradientType=0);background-color:#f6f6f6;}.filename:active {position:relative;top:1px;}</style>' >> $htmlOutput
		
		# Google fonts
		printf '<link href="https://fonts.googleapis.com/css?family=Zilla Slab" rel="stylesheet">\n<link href="https://fonts.googleapis.com/css?family=Source Code Pro" rel="stylesheet">\n' >> $htmlOutput
		printf '<style>\r\na { color: white; }\r\nbody { font-family: "Source Code Pro"; font-size: 12px; background-color: black; }\r\nh1 { color: white; font-size; 35px}\r\nh2 { color: crimson; font-size: 25px }\r\nh3 { color: white; }\r\np { color: lime; }\r\nheading { font-family: "Source Code Pro"; font-size: 18px; color: white; float: right; text-align: right vertical-align: middle}\r\ndiv.search { line-height: 100%%; colour: lime; }\r\ndiv.header { font-family: "Zilla Slab"; font-size: 20px; line-height: 80%%; }\r\ndiv.scan { color: lime; font-size: 15px; line-height: 80%%; }\r\nsearchterm { color: white; font-size 25 }\r\n</style>' >> $htmlOutput
		
		# d3 Graph for link structure (emails, 404s)
	 	printf '<style>\r\n.link {\r\nfill: none;\r\nstroke: #666;\r\nstroke-width: 1.5px;\r\n}\r\n#404\r\n{\r\nfill: red;\r\n}\r\n#ahref {\r\nfill: green;\r\n}\r\n.link.ahref\r\n{\r\nstroke: green;\r\n}\r\n.link.email {\r\nstroke-dasharray: 0,2 1;\r\n}\r\n.link.404 { stroke: red; }\r\ncircle {\r\nfill: #ccc;\r\nstroke: #333;\r\nstroke-width: 1.5px;\r\n}\r\ntext {\r\nfont: 10px sans-serif;\r\npointer-events: none;\r\ntext-shadow: 0 1px 0 #fff, 1px 0 0 #fff, 0 -1px 0 #fff, -1px 0 0 #fff;\r\n}\r\n</style>' >> $htmlOutput
		printf '\r\n<script src="https://d3js.org/d3.v3.min.js"></script>\r\n' >> $htmlOutput
		structurePages=$(echo pages.txt)

		# Edge point graph for link structure
		#printf '<style>\r\n.node {\r\n  font: 300 11px "Helvetica Neue", Helvetica, Arial, sans-serif;\r\n  fill: #bbb;\r\n}\r\n\r\n.node:hover {\r\n  fill: #000;\r\n}\r\n\r\n.link {\r\n  stroke: steelblue;\r\n  stroke-opacity: 0.4;\r\n  fill: none;\r\n  pointer-events: none;\r\n}\r\n\r\n.node:hover,\r\n.node--source,\r\n.node--target {\r\n  font-weight: 700;\r\n}\r\n\r\n.node--source {\r\n  fill: #2ca02c;\r\n}\r\n\r\n.node--target {\r\n  fill: #d62728;\r\n}\r\n\r\n.link--source,\r\n.link--target {\r\n  stroke-opacity: 1;\r\n  stroke-width: 2px;\r\n}\r\n\r\n.link--source {\r\n  stroke: #d62728;\r\n}\r\n\r\n.link--target {\r\n  stroke: #2ca02c;\r\n}\r\n\r\n</style>\r\n' >> $htmlOutput

		# Menu items (header)
		printf '\n</head>\n\r<body>\r\n<ul>\r\n<li><a class="active" href="#header">Home</a></li>\r\n  <li><a href="#search">Search</a></li>\r\n<li><a href="#files">Files</a></li>\r\n<li><a href="#results">Results</a></li>\r\n<li><a href="#404s">404s</a></li>\r\n <li><a href="#headings">Heading Tags</a></li>\r\n <li><a href="#emails">Emails</a></li>\r\n <li><a href="#otherfiles">Other Files</a></li>\r\n <li><a href="#structure">Link Structure</a></li>\r\n<li><a class="heading">websitesearch Version 1.6  Date: %s  Depth: %d</a></li></ul>\r\n<div class="header" id="header"></br>\r\n</div></br>' $dateStarted $2 >> $htmlOutput
		
		# Menu items (footer)
		printf '<projects>' >> $htmlOutput
		# Insert current project as active list element
		printf '<li><a class="active" href="%s">%s</a></li>\r\n' $project $project >> $htmlOutput
		# Get files in webroot
		
		ls /var/www/html/*.html > projectlist
		sed -i -e 's/\/var\/www\/html\///g' projectlist
		# remove specific files from projectlist
		sed -i -e 's/pages.html//g' projectlist

		while read line; do
			if [[ ${line}!=${project} ]]; then
				label=$(echo $line | sed -e 's/.html//g')
				printf '<li><a href="%s">%s</a></li>' $line $label >> $htmlOutput
			fi
		done < projectlist

		printf '</projects>' >> $htmlOutput

		# Get the starting (root) file
		wget -o wgetlog -O startHere $1
		indexfile="startHere"
		grep "failed" wgetlog > errors
		if [ -s errors ]; then
			rm wgetlog errors
			rm -Rf "$project"
			echo "Error: URL is invalid or down, please check" >&2; exit 1
		elif [[ $3!='' ]]; then
			echo "Checking" $1 "for references to" $3 "at a depth of" $2
		else
			echo "Checking" $1
		fi
	else
		echo "Error: URL is invalid"  >&2; exit 1
	fi
fi

#########################################################
# Geo-location of server
#########################################################
geodata=$(echo "geodata")
printf "<div id='geo_data'>\r\n<p>" > geodatadiv
printf "<h2 id='geo_data'>\r\nServer Geo Information</h2>" >> geodatadiv
server=$(echo ${1} | sed -e 's/^.*\:\/\///g')
#echo "Server:" $server
serverip=$(nslookup $server | grep "Address:" | tail -1 | sed -e 's/Address\://g' | sed -e 's/\#.*$//g' | sed -e 's/\s//g')
ipinfo=`curl -s https://ipinfo.io/${serverip}`
echo "ServerIP:" $serverip

# Get geo data from IP
curl -s https://ipvigilante.com/${serverip} | jq '.data.latitude, .data.longitude, .data.city_name, .data.country_name' | \
        while read -r LATITUDE; do
                read -r LONGITUDE
                read -r CITY
                read -r COUNTRY
                echo "${LATITUDE},${LONGITUDE},${CITY},${COUNTRY}" | tr --delete \" > ${geodata}
        done
cat geodata >> geodatadiv
lat=$(cat geodata | awk -F, '{print $1}')
long=$(cat geodata | awk -F, '{print $2}')
rm geodata
echo "<p>" >> $htmlOutput
echo geodatadiv
cat geodatadiv >> $htmlOutput
echo "</p>" >> $htmlOutput

# Put marker on google map
## NOTE!!! See google maps API key at the end of this line, you'll need to add yours in here for this to work.
printf "<div id='map'></div>\r\n <script>function initMap() {\r\n var server = {lat: ${lat}, lng: ${long}};\r\n var map = new google.maps.Map(\r\n document.getElementById('map'), {zoom: 12, center: server, styles: [\r\n{elementType: 'geometry', stylers: [{color: '#242f3e'}]},\r\n{elementType: 'labels.text.stroke', stylers: [{color: '#242f3e'}]},\r\n{elementType: 'labels.text.fill', stylers: [{color: '#746855'}]},\r\n{\r\nfeatureType: 'administrative.locality',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#d59563'}]\r\n},\r\n{\r\nfeatureType: 'poi',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#d59563'}]\r\n},\r\n{\r\nfeatureType: 'poi.park',\r\nelementType: 'geometry',\r\nstylers: [{color: '#263c3f'}]\r\n},\r\n{\r\nfeatureType: 'poi.park',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#6b9a76'}]\r\n},\r\n{\r\nfeatureType: 'road',\r\nelementType: 'geometry',\r\nstylers: [{color: '#38414e'}]\r\n},\r\n{\r\nfeatureType: 'road',\r\nelementType: 'geometry.stroke',\r\nstylers: [{color: '#212a37'}]\r\n},\r\n{\r\nfeatureType: 'road',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#9ca5b3'}]\r\n},\r\n{\r\nfeatureType: 'road.highway',\r\nelementType: 'geometry',\r\nstylers: [{color: '#746855'}]\r\n},\r\n{\r\nfeatureType: 'road.highway',\r\nelementType: 'geometry.stroke',\r\nstylers: [{color: '#1f2835'}]\r\n},\r\n{\r\nfeatureType: 'road.highway',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#f3d19c'}]\r\n},\r\n{\r\nfeatureType: 'transit',\r\nelementType: 'geometry',\r\nstylers: [{color: '#2f3948'}]\r\n},\r\n{\r\nfeatureType: 'transit.station',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#d59563'}]\r\n},\r\n{\r\nfeatureType: 'water',\r\nelementType: 'geometry',\r\nstylers: [{color: '#070824'}]\r\n},\r\n{\r\nfeatureType: 'water',\r\nelementType: 'labels.text.fill',\r\nstylers: [{color: '#515c6d'}]\r\n},\r\n{\r\nfeatureType: 'water',\r\nelementType: 'labels.text.stroke',\r\nstylers: [{color: '#17263c'}]\r\n}\r\n]});\r\n var marker = new google.maps.Marker({position: server, map: map});\r\n}</script>\r\n <script async defer src='https://maps.googleapis.com/maps/api/js?key=INSERTMAPSAPIKEY&callback=initMap'></script>\r\n" >> $htmlOutput

# Close the div
echo "</p></div>" >> $htmlOutput

#########################################################
# Scrape level 0
#########################################################

sizeoffile=$(wc -l "$indexfile")

_start=1
_end=$sizeoffile
n=1

startTime=`date +%s`

if [ $listgiven!=1 ]; then
	while read line; do
		ProgressBar ${n} ${_end}
		echo $line | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' > linkline 
		cat linkline | grep $1 > isFullPath
		if [ -s isFullPath ]; then
			cat linkline >> level0.links
			linkline=$(cat linkline)
			if [[ ! -z "$linkline" ]]; then echo $1 "references:" $linkline >> pages.txt; fi			
			rm isFullPath
		else
			sed -i -e "s#^#${1}#" linkline
			cat linkline >> level0.links
			linkline=$(cat linkline)
			if [[ ! -z "$linkline" ]]; then echo $1 "references:" $linkline >> pages.txt; fi
		fi
		rm linkline
		n=$((n+1))
	done < $indexfile
fi

sort level0.links > level0sorted
uniq level0sorted > level0.links
rm level0sorted

endTime=`date +%s`
runTime=$((endTime-startTime))

printf "\r\n"
echo "                     Completed in ${runTime} seconds"

#########################################################
# Scrape deeper levels
#########################################################
n=0
touch checkedpages
touch level1.links
touch level2.links
touch level3.links

printf '<div class="Scan" id="search">' >> $htmlOutput
printf "\r\n<h2 id='depth'> </h2>" >> $htmlOutput

while [[ $n -le $depth && $exitloop!=1 ]]
do
	sed -i -e 's/Please wait\.\.\.<\/br>//g' $htmlOutput
	next=$((n+1))
	previous=$((n-1))
	nextlevel=$(echo "level${next}.links")
	previouslevel=$(echo "level${previous}.links")
	linkfile=$(echo "level${n}.links")
	previous=$((n-1))
	noLinks=1
	noLevelZeroLinks=$(wc -l "$linkfile" | sed -e "s/${linkfile}//g")
	_end=$noLevelZeroLinks

	if [[ "$n" == 0 ]]
       		then previousfile=$(echo "/dev/null")
       	else
	       	previousfile=$(echo "level${previous}.links")
	fi

	if [[ "$n" == 0 ]] || [[ -s ${previousfile} ]]; then
		startTime=`date +%s`
		depthString=$(printf "<h2 id='depth'>Going %d deep: Checking %d links</h2>" $n $noLevelZeroLinks)
		sed -i -e "s#<h2 id='depth'>.*<\/h2>#${depthString}#g" $htmlOutput
		printf '\r\n' >> $htmlOutput

		if [[ $n -ne 0 ]]; then sed -i -e "s/<h2>Going.*/${depthString}/g"; fi
		echo "Going ${n} deep: Checking ${noLevelZeroLinks} links"
		pleasewait=$(printf '<p>> Please wait...</p>\r\n' $project)
	        echo $pleasewait >> $htmlOutput
		startingscan=$(printf '<p>> Progress: starting scan</p>\r\n' $project)
	        sed -i -e "s#${pleasewait}#${startingscan}#g" $htmlOutput

		# Replace whitespace with new line character on links file to resolve multiple links on single line issue
		sed -i -e 's/ /\n/g' $linkfile

		while read line; do

		strippedline=$(echo $line | sed -e 's#.*http://##g' | sed -e 's#.*https://##g')

		if [[ "$exitloop" == 1 ]]; then break; fi
		
		#printf "\r\n========= Getting %4d of %4d =========\n" $noLinks $noLevelZeroLinks	
		ProgressBar ${noLinks} ${_end}

		# Check if page has already been crawled
		if grep -q "$line" checkedpages; then
			echo "Page" $line "already checked" >> debug.txt
		else
			echo $line | grep "#" > hasHash
			#echo $line | grep -e '^.*\.comhttp.*' > multipleLinks
			#echo $line | grep -e '^.*\.nethttp.*' >> multipleLinks
			echo $line | grep -e '^.*(\.nethttp|\.comhttp|\.auhttp|\/htt).*' >> multipleLinks

			if [ -s hasHash ] || [ -s multipleLinks ]; then
				echo $line "has # in it, or has external link" >> debug.txt
				rm hasHash multipleLinks
			else
				
				# Remove // from any url's
				echo $line | sed -e 's#///#/#2' > downloadme
				sed -i -e 's#//#/#g' downloadme
				sed -i -e 's#http:#http:/#g' downloadme
				sed -i -e 's#https:#https:/#g' downloadme
				downloadme=$(cat downloadme)
				
				# Check for specific file types to exclude from downloading
				grep -E "^.*(\.exe|\.zip|\.pdf|\.tar|\.gz|\.doc|\.docx)" downloadme > ignore
				rm downloadme

				if [ -s ignore ]; then
					echo $downloadme "contains ignored filetype" >> debug.txt
					echo "<p>$downloadme contains ignore filetype</p>" >> otherFiles
					rm ignore
				else
					echo "Getting" $downloadme >> debug.txt
					wget -nc --timeout=1 --tries=1 -o wgetOutPut $downloadme
				fi

				baseFile=$(basename "$downloadme")

				if [ "$baseFile" == '#' ]; then
					baseFile='index'
				fi
	
				#Output if page does not exist; ADD IN which page references this?
				if grep -q "404" wgetOutPut; then echo $downloadme "is 404" >> debug.txt 
					echo "$downloadme is 404" >> 404s
					echo "$downloadme is 404" >> pages.txt

				else
					if [ -s "$baseFile" ]; then
					#echo "basefile exists"
					pages=1

					numberOfLinesBase=$(wc -l $baseFile | sed -e "s/$baseFile//g" )

					while read htmlLine; do
						if [[ "$exitloop" == 1 ]]; then break; fi
						
						# Detect email addresses
						shopt -s extglob
						email=''
						email=$(echo $htmlLine | grep mailto | sed -e 's/*mailto:\(.*\)\s/\1/' | sed -e 's/^.*mailto://' | sed -e 's/".*$//' | sed -e 's/'\''.*$//')
						echo "$email" >> emails
						echo $downloadme "email" $email >> pages.txt

						# Detect soft 404s
						echo $htmlLine | grep "404" > isSoft404
						if [[ -s isSoft404 ]]; then echo "> $downloadme might be soft 404" >> 404s; 
						else	
							echo $htmlLine | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' > linkline
							cat linkline | grep "https" > isFullPath
							cat linkline | grep "http" >> isFullPath
							
							# Replace empty space \s in line with new line character \n to separate multiple links on a line
							sed -i -e 's#\s#\n#g' linkline
							
							if [[ -n linkline ]]; then
								if [[ linkline != *"#"* ]]; then
									if [ -s isFullPath ]; then
										link=$(cat linkline)
										echo $link >> $nextlevel
										echo $htmlLine | grep "$3" > containsSearchQuery
										echo $htmlLine | grep "$project" > isInternalLink
										if [[ -s containsSearchQuery && -s isInternalLink ]]; then 
											echo $downloadme "references:" $link >> pages.txt
										fi
										rm containsSearchQuery isInternalLink
										# html output
										#echo "</br>" $downloadme "references:" $link >> $htmlOutput
										echo $downloadme >> checkedpages
										rm isFullPath
									else
										cat linkline | grep "/" > hasslash
										if [ -s hasslash ]; then
											sed -i -e "s#^#${1}#" linkline
											rm hasslash
										else
											sed -i -e "s#^#${1}#" linkline
										fi
	
										link=$(cat linkline)
										echo $link >> $nextlevel
										# If downloaded page contains the search query, add to pages.txt
										# Make the graph more useful
										echo $htmlLine | grep "$3" > containsSearchQuery
										echo $htmlLine | grep "$project" > isInternalLink
										if [[ -s containsSearchQuery && -s isInternalLink ]]; then 
											echo $downloadme "references:" $link >> pages.txt
										fi
										rm containsSearchQuery isInternalLink
										#html output
										#echo '</br> <a href="'${downloadme}'">'${baseFile}'</a> references: '${link}'' >> ${htmlOutput}
										echo $downloadme >> checkedpages
									fi
									sort pages.txt > upages.txt
									uniq upages.txt > pages.txt
									sort $nextlevel > sortednext
									uniq sortednext > $nextlevel
									#uniqpages=$(wc -l ../pages.txt)
									#printf "\r==== Checked %6d of %6d lines ====" $pages $numberOfLinesBase
							       		pages=$((pages+1))
									sed -i '/^$/d' $nextlevel
									rm linkline
								fi
							fi
						fi
					done < $baseFile
					fi
				fi
			fi
		fi
		noLinks=$((noLinks+1))
		#rm baseFile isFullPath startHere
		done < $linkfile
	fi

	# Iterate $n to move through depth levels
	(( n=n+1 ))

	# Time taken to scan depth $n
	endTime=`date +%s`
	runTime=$((endTime-startTime))
	printf '\r\n'
	printf '<p>> Completed scan depth %d in %d seconds </p>' $n $runTime >> $htmlOutput
done

if [[ $exitloop == 1 ]]; then printf '\r\n<p>> Search terminated by user</p>' >> $htmlOutput; fi

cp pages.txt /var/www/html/pages.html

#########################################################
# Search query
#########################################################

echo "Doing a search now..."

instancesOfSearch=0

#ls | grep -P ".[0-9]{1}" | xargs -d"\n" rm
ls > pagestocheck 

sed -i 's/404s//g; s/emails//g; s/headertags//g; s/checkedpages//g; s/\s//g; s/debug.txt//g; s/errors.txt//g; s/hasHash//g; s/level0.links//g; s/level1.links//g; s/level2.links//g; s/level3.links//g; s/sortednext//g; s/index.html/Homepage/g; s/ignore//g; s/linkline//g; s/multipleLinks//g; s/pagestocheck//g; s/pages.txt//g; s/startHere//g; s/wgetlog//g; s/wgetOutPut//g;' pagestocheck

if [ -s pagestocheck ]; then
	while read line; do
		if [ "$line"!='' ]; then
			cat "${line}" | grep "$3" > searchOut 
			if [ -s searchOut ]; then
				occurences=$(grep -o -i $3 "${line}" | wc -l)
				
				# Number of heading tags
				h1tags=$(cat ${line} |  grep "^<[Hh][1]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h1>//g; s/<strong>//g; s/\&nbsp\;//g' | wc -l)
				h2tags=$(cat ${line} |  grep "^<[Hh][2]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h2>//g; s/<strong>//g; s/\&nbsp\;//g' | wc -l)
				h3tags=$(cat ${line} |  grep "^<[Hh][3]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h3>//g; s/<strong>//g; s/\&nbsp\;//g' | wc -l)
				h4tags=$(cat ${line} |  grep "^<[Hh][4]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h4>//g; s/<strong>//g; s/\&nbsp\;//g' | wc -l)
				
				# Extract heading tags
				echo $line |  grep "^<[Hh][1]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h1>//g; s/<strong>//g; s/\&nbsp\;//g' > h1
				if [ -s h1 ]; then
					h1=$(cat h1)
					echo "Page:" $line "h1 tag:" $h1 >> headertags
					rm h1
				fi	
				echo $line | grep "^<[Hh][2]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h2>//g; s/<strong>//g; s/\&nbsp\;//g' > h2 
				if [ -s h2 ]; then
					h2=$(cat h2)
					echo "Page:" $line "h2 tag:" $h2 >> headertags
					rm h2
				fi
				echo $line | grep "^<[Hh][3]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h3>//g; s/<strong>//g; s/\&nbsp\;//g' > h3
				if [ -s h3 ]; then
					h3=$(cat h3)
					echo "Page:" $line "h3 tag:" $h3 >> headertags
					rm h3
				fi	
				echo $line | grep "^<[Hh][4]>" | sed -e 's/<span.*">//g; s/<\/span.*//g; s/<h4>//g; s/<strong>//g; s/\&nbsp\;//g' > h4
				if [ -s h4 ]; then
					h4=$(cat h4)
					echo "Page:" $line "h4 tag:" $h4 >> headertags
					rm h4
				fi		

				echo "DIVID${line}DIVENDheader3-----------${line}-------------endhead3" | tee --append searchReturns 
				head -20 searchOut | cut -c1-500 | tee --append searchReturns 
				echo $line >> pagesWithSearchQuery
				echo ' ' >> searchReturns
				echo "$3 appears $occurences times" >> searchReturns
				echo "Number of h1 tags:" $h1tags >> searchReturns
				echo "Number of h2 tags:" $h2tags >> searchReturns
				# echo "header3GOTOHOMELINKendhead3" >> searchReturns
				instancesOfSearch=$((instancesOfSearch+occurences))
				if [ -s searchOut ]; then rm searchOut; fi
			fi
		fi
	done < pagestocheck
fi

echo '<div class="Search" id="files">' >> $htmlOutput
printf '<h2>Search Results:</h2>' >> $htmlOutput

if [ -s pagesWithSearchQuery ]; then
	echo "> Found ${instancesOfSearch} instances of ${3} in the following files:" | tee --append $htmlOutput
	echo "<p>" >> $htmlOutput
	#cat "$line" | tee --append $htmlOutput
	while read line; do
		echo $line | sed "s/[^ ][^ ]*/<a href='#&' class="linkButton">${line}<\/a>/g" | tee --append $htmlOutput
	done < pagesWithSearchQuery
	echo "</p>" >> $htmlOutput
	# Heading for contents from files with search query
	echo "</div><div class="Search" id="results"><h2>Contents from files with search query:</h2></br>" >> $htmlOutput
else
	echo "> No instances of ${3} found" | tee --append $htmlOutput
fi
##########################################################
# Search Contents
##########################################################

# Show contents from files that have search query / Wrap search term in h3 tags to make it stand out
cat searchReturns | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"//g; s/'"'"'//g; s/header3/<h3>/g; s/endhead3/<\/h3>/g; s/DIVID/<div id="/g; s/DIVEND/">/g; s/GOTOHOMELINK/<a href="#header">Go to top<\/a>/g' | sed -e "s#${3}#<searchTerm>${3}</searchTerm>#g" | perl -p -e 's/\n/<\/br>/' >> $htmlOutput

##########################################################
# 404's
##########################################################

printf '<h2>404s:</h2>' >> $htmlOutput
printf '<div id="404s">' >> $htmlOutput

if [ -s 404s ]; then
	while read line; do
		echo "<p> ${line} </p>" >> $htmlOutput
	done < 404s
else
	echo "<p> All good :) </p>" >> $htmlOutput
fi

printf '</div>' >> $htmlOutput

##########################################################
# Heading Tags
##########################################################

printf '<h2>Heading Tags:</h2>' >> $htmlOutput
printf '<div id="headings">' >> $htmlOutput

if [ -s headertags ]; then
	while read line; do
		printf '<p> %s </p>' $line >> $htmlOutput
	done < headertags
else
	echo "<p>> No heading tags detected </p>" >> $htmlOutput
fi

printf '</div>' >> $htmlOutput

##########################################################
# Show detected emails
##########################################################

printf '<h2>Email Addresses:</h2>' >> $htmlOutput
printf '<div id="emails">' >> $htmlOutput

if [ -s emails ]; then
	
	sort emails > sortedemails
	uniq sortedemails > emails

	while read line; do
		printf '<p> %s </p>' $line >> emailsdiv
	done < emails

	rm sortedemails emails

	if [ -s emailsdiv ]; then cat emailsdiv >> $htmlOutput;	fi
else
	echo "<p>> No email addresses detected </p>" >> $htmlOutput
fi

printf '</div>' >> $htmlOutput

##########################################################
# Other Files
##########################################################

printf '<h2>Other Files:</h2>' >> $htmlOutput
printf '<div id="otherfiles">' >> $htmlOutput

if [ -s OtherFiles ]; then
	while read line; do
		echo ${line} | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"//g; s/'"'"'//g;' > strippedfilelink
		strippedfilelink=$(cat strippedfilelink)
	 	rm strippedfilelink
		echo "<p> ${strippedfilelink} </p>" >> $htmlOutput
	done < OtherFiles
else
	echo "<p>> No additional files (docx, doc, pdf, exe, zip etc.) detected </p>" >> $htmlOutput
fi

printf '</div>' >> $htmlOutput

##########################################################
# Link Structure (Emails and 404s; links)
##########################################################

printf '<h2>Link structure:</h2>' >> $htmlOutput
printf '<div id="structure">' >> $htmlOutput
printf '<script>\r\nvar links = [' >> $htmlOutput

chartHeight=$(wc -l $structurePages | sed -e "s/${structurePages}//g")
chartHeight=$(expr $chartHeight \* 9)

# Create data structure
while read line; do
	trimmedLine=$(echo $line | sed -e 's/${project}//g')
	is404=$(echo $trimmedLine | awk '{print $2}')
	level1=$(echo $trimmedLine | awk '{print $1}' | sed -e 's,'"$1"',$,g')
	level2=$(echo $trimmedLine | awk '{print $3}' | sed -e 's,'"$1"',$,g')
	isEmail=$(echo $trimmedLine | awk '{print $2}') 
	if [[ "$level2" != '' ]]; then
		# is it a 404?
		if [[ "$is404" == "is" ]]; then
			printf '{source: "%s", target: "404", type: "404"},\r\n' $level1 >> $htmlOutput
		# is it an email?
		elif [[ "$isEmail" == "email" ]]; then
			printf '{source: "%s", target: "%s", type: "email"},\r\n' $level1 $level2 >> $htmlOutput
		else
		# must be a link
			# is it internal?
			echo $level2 > lineFile
			if grep -q "$" lineFile; then
				printf '{source: "%s", target: "%s", type: "ahref"},\r\n' $level1 $level2 >> $htmlOutput
			fi
			rm lineFile
		fi
	fi
done < $structurePages

# Create chart
printf '];\r\n' >> $htmlOutput
printf 'var nodes = {};\r\nlinks.forEach(function(link) {\r\nlink.source = nodes[link.source] || (nodes[link.source] = {name: link.source});\r\nlink.target = nodes[link.target] || (nodes[link.target] = {name: link.target});\r\n});\r\nvar width = 1200,\r\nheight = %d;\r\nvar force = d3.layout.force()    \r\n.nodes(d3.values(nodes))    \r\n.links(links)    \r\n.size([width, height])    \r\n.linkDistance(50)    \r\n.charge(-200)    \r\n.on("tick", tick)    \r\n.start();\r\nvar svg = d3.select("body").append("svg")    \r\n.attr("width", width)    \r\n.attr("height", height);\r\nsvg.append("defs").selectAll("marker")    \r\n.data(["404", "ahref", "email"])  \r\n.enter().append("marker")    \r\n.attr("id", function(d) { return d; })    \r\n.attr("viewBox", "0 -5 10 10")    \r\n.attr("refX", 10)    \r\n.attr("refY", -1.5)    \r\n.attr("markerWidth", 6)    \r\n.attr("markerHeight", 6)    \r\n.attr("orient", "auto")  \r\n.append("path")    \r\n.attr("d", "M0,-5L10,0L0,5");\r\nvar path = svg.append("g").selectAll("path")    \r\n.data(force.links())  \r\n.enter().append("path")    \r\n.attr("class", function(d) { return "link " + d.type; })    \r\n.attr("marker-end", function(d) { return "url(#" + d.type + ")"; });\r\nvar circle = svg.append("g").selectAll("circle")    \r\n.data(force.nodes())  \r\n.enter().append("circle")    \r\n.attr("r", 6)    \r\n.call(force.drag);\r\nvar text = svg.append("g").selectAll("text")    \r\n.data(force.nodes())  \r\n.enter().append("text")    \r\n.attr("x", 8)    \r\n.attr("y", ".12em")    \r\n.text(function(d) { return d.name; });\r\nfunction tick() {  \r\npath.attr("d", linkArc);  \r\ncircle.attr("transform", transform);  \r\ntext.attr("transform", transform);\r\n}\r\nfunction linkArc(d) {  \r\nvar dx = d.target.x - d.source.x,      \r\ndy = d.target.y - d.source.y,      \r\ndr = Math.sqrt(dx * dx + dy * dy);  \r\nreturn "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;\r\n}\r\nfunction transform(d) {  \r\nreturn "translate(" + d.x + "," + d.y + ")";\r\n}\r\n</script>' $chartHeight >> $htmlOutput

printf '</div></div>' >> $htmlOutput

printf '<script async src="https://cse.google.com/cse.js?cx=003366497132526601933:yjjgyhat87y"></script>
<div class="gcse-search"></div>' >> $htmlOutput


##########################################################
# Clean up
##########################################################

# Close html tags
echo "</div></body></html>" >> $htmlOutput
if [ -s searchReturns ]; then
	rm searchReturns pagesWithSearchQuery
fi

rm hasHash ignore linkline multipleLinks pagestocheck startHere wgetOutPut

# Turn off refresh
sed -i 's/<meta http-equiv="refresh" content="2"/<meta /g' $htmlOutput  

##########################################################
##########################################################
