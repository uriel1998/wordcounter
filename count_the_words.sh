#!/bin/bash

# PDF
# Markdown
# DOC
# DOCX
# RTF
# HTML
# CSV




########################################################################
# Definitions
########################################################################
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
infile="${1}"
user="${2}"
ip="${3}"
time=$(date +%H:%M)
day=$(date +%m/%d/%Y)
sorting_timestamp=$(date +%H%M%d%m%Y)
words=""
OutputDir=${SCRIPT_DIR}/output
CacheDir=${SCRIPT_DIR}/cache

OIFS=$IFS
IFS=$'\n'; set -f
#echo "${1}" >> /home/steven/test.txt


echo "$@" >> ${CacheDir}/variables.txt


LOUD=0

function loud() {
    if [ $LOUD -eq 1 ];then
        echo "$@"
    fi
}


##############################################################################
# Mimetype Strings
##############################################################################
docxstring="Microsoft Word 2007+"
txtstring="ASCII text"
odtstring="OpenDocument Text"
docstring="Composite Document File V2 Document"  #NOTE IS SAME AS XLS
pdfstring="PDF document"
rtfstring="Rich Text Format"
utf8string="UTF-8 Unicode text"
htmlstring="HTML document"


show_docx (){
    words=$(pandoc -f docx "${infile}" -t html  | elinks -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
}

show_doc (){
    if [[ "$mimetype" == *"$docstring"* ]];then        
        words=$(wvWare "${infile}" | elinks -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
    elif [[ "$mimetype" == *"$rtfstring"* ]];then
        words=$(unrtf --html "${infile}" | elinks -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
    else
        show_text
    fi
}

show_odt (){
    words=$(pandoc -f odt "${infile}" -t html | elinks -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
}

show_rtf (){
    words=$(unrtf --html "${infile}" | elinks -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
}

show_pdf (){
    words=$(pdftotext -nopgbrk -layout -nodiag "${infile}" - | wc -c )
}

show_html (){
    words=$(elinks "${infile}" -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
}

show_markdown (){
    
    words=$(pandoc -s -f markdown -t html ${infile} | elinks "${infile}" -dump -no-references -no-numbering -dump-charset UTF-8 | wc -c)
}

show_text (){
    words=$(cat "${infile}" | wc -c)
}




if [ -f "${infile}" ]; then
    filename=$(basename "${infile}")
    #get extension, lowercase it
    extension=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')
    mimetype=$(file "$filename" | awk -F ':' '{ print $2 }') 
    # Match extension first, since DOC and XLS give the same mimetype
    case "$extension" in
        docx) show_docx ;;          
        odt) show_odt ;; 
        doc) show_doc ;;
        rtf) show_rtf ;;
        pdf) show_pdf ;; 
        ods ) show_ods ;;
        "md" | "mkd") show_markdown ;; 
        "xhtml" | "htm" | "html" ) show_html ;;
        rc|txt|sh|conf|ini) show_text ;;
        *)
            # Try to match by mimetype instead
            case "$mimetype" in     
            *Word*2007* )           show_docx ;;
            *OpenDocument*Text*)    show_odt ;;
            *PDF*document*)         show_pdf ;;
            *Composite*Document*File*V2*) show_doc ;;
            *Rich*Text*Format*)     show_rtf ;;
            *HTML*document* )       show_html ;;
            *ASCII*text* )          show_text ;;
            *UTF-8*Unicode*text*)   show_text ;;
            *) ;;
            esac 
        ;;
    esac
fi

# check the username
# check the password
# And then we will output the count to something that can be easily parsed by a webpage
if [ ${words} -gt 0 ];then
    # output to user
    echo "user: ${user} | date: ${day} at ${time} | ${words} "
    echo "user: ${user} | date: ${day} at ${time} | ${words} " >>  ${CacheDir}/checking.txt
    if [ "${user}" != "None" ];then
        # output to file
        echo "| ${sorting_timestamp} | user: ${user} | date: ${day} at ${time} | ${words} | ${ip} |" >> "${CacheDir}"/runninglog.md    
        # processing output
        # this should probably be moved to a cronjob?
        # github flavored markdown has tables! 
        echo "| timestamp | user | date | wordcount | from ip | " > "${CacheDir}"/output.md
        echo "| --- | --- | --- | --- | --- |" >> "${CacheDir}"/output.md
        sort -r "${CacheDir}"/runninglog.md | uniq >> "${CacheDir}"/output.md
        # now to convert it into html and append our snippeds
        cat "${SCRIPT_DIR}"/html_head > "${OutputDir}"/output.html
        echo "<h4>Updated $(date +%H:%M) on $(date +%m/%d/%Y)</h4>" >> "${OutputDir}"/output.html
        pandoc -f gfm -t html "${CacheDir}"/output.md >> "${OutputDir}"/output.html
        cat "${SCRIPT_DIR}"/html_footer >> "${OutputDir}"/output.html
    fi
else
    echo "Error in input or script"
fi

IFS=$OIFS
