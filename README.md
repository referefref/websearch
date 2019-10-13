# wesbitesearch
Website searcher for SEO comparisons / OSINT

## Current version 1.6
------------

### Usage:
./websitesearch.sh url depth searchquery urllist
* URL: https:// or http:// url. Note, does not cope well with websites that redirect www. to root
* Depth: Number of levels of links that should be followed
* Search Query: Will search pages for a string and return pages with matches. i.e. passwords, secrets, SEO comparisons
* URLList: Replaces first level of scraping with a file that is a list of URLs

### Features:
* Progress indicator renders on html output while in progress, this is a bit glitchy but functional
* Scrapes website to specified depth
* Returns location of web server on google map
* Shows page structure and location of email addresses with js plugin (visualising link structure)
* Shows h1, h2, h3 tags on pages that contain search term
* Returns emails from all pages
* Recent projects appear in bottom menu
* Does not follow links outisde the chosen domain (this is a feature not a bug)
* Outputs debug file for error checking

### Todo:
* Config file for API keys etc.
* Improve comamnd line args so that search queries etc. are not needed, set default depth for quick search
* Edge link chart for visualising link structure
* Allow comparison searches for the same domain
* Allow specific output html file (not hardcoded)
* Text based output if required

### If i can be bothered:
* Move scraping function to python script and allow multithreading to improve speed
