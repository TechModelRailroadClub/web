source "[ns_info pageroot]/progress/progress.funcs"

proc listimages {dir} {
	set pwd [pwd]
	if {[catch {
		cd $dir
	    set result [glob -nocomplain *.{jpg,JPG,gif,GIF,png,PNG}]
	}]} {
		set result {}
	}
	cd $pwd
    return $result
}

set req_year [ns_queryget year]
set req_month [ns_queryget month]
set req_day [ns_queryget day]
if {![string is integer $req_month] || $req_month < 1 || $req_month > 12 ||
	![string is integer $req_year] || $req_year < 1990 || $req_year > 2100 ||
	![string is integer $req_day] || $req_day < 1 || $req_day > 31} {
	ns_returnerror 404 "Invalid or missing parameters"
	return TCL_OK
}

set picdirpath [format "%s/%04d/%02d/%d.picts" $base_dir $req_year $req_month $req_day]

set titles [ns_set create "Photo Titles"]

if {[file exists $picdirpath/index.txt]} {
    set fd [open $picdirpath/index.txt "r"]
    set block 0
    while {[gets $fd line] >= 0} {
	set parts [split $line \t]
	if {[llength $parts] > 1} {
	    set pic [lindex $parts 0]
	    set title [lindex $parts 1]
	    lappend pics $pic
	    ns_set put $titles $pic $title
	} {
	    lappend pics "block-[incr block].txt"
	    ns_set put $titles "block-$block.txt" $line
	}
    }
    close $fd
} {
    set pics [lsort [listimages $picdirpath]]
}
set picurlbase [format "/progress/reports/%04d/%02d/%d.picts" $req_year $req_month $req_day]

#set 
# return the HTTP headers

ReturnHeaders
	ns_write "[tmrc_header "TMRC - Progress Images: [monthname $req_month] $req_year"]
<center>
[tmrc_titleimage "[shortmonthname $req_month] '[twodigityear $req_year] Pictures"]
</center>
<h1>[monthname $req_month] $req_day, $req_year</h1>
"

set width 200
set height 200

global col tableopen rowtitles

set col 0
set tableopen 0
set rowtitles {}

proc opentable {} {
    global col tableopen
    if {$tableopen == 0} {
	ns_write "<table align=\"center\" class=\"album\" cellpadding=\"3\">"
	set col 0
	set tableopen 1
    }
}
proc closetable {} {
    global col tableopen rowtitles
    if {$tableopen == 1} {
	if {[llength $rowtitles] > 0} {
	    ns_write "</tr><tr>"
	    foreach title $rowtitles {
		ns_write "<td>$title</td>"
	    }
	    ns_write "</tr>"
	    lset rowtitles {}
	}
	ns_write "</table>"
	set tableopen 0
    }
}

foreach pic $pics {
    if {[string tolower [file extension $pic]] == ".txt"} {
	closetable
	ns_write "<p>[ns_set get $titles $pic]</p>"
    } {
	opentable
	set srcurl "$picurlbase/$pic"
	set linkurl "/progress/image.tcl?year=$req_year&amp;month=$req_month&amp;day=$req_day&amp;image=$pic"
	if {$col == 0} {
	    ns_write "<tr>"
	}
	set title [ns_set get $titles $pic]
	if {[string length $title] <= 0} {
	    set title [file rootname $pic]
	}
	ns_write "<td align=\"center\" valign=\"middle\" class=\"pic\">[tmrc_imgscale $srcurl $width $height "alt=\"$title\"" $linkurl]</td>"
	lappend rowtitles $title
	if {[incr col] >= 3} {
	    ns_write "</tr><tr>"
	    foreach title $rowtitles {
		ns_write "<td>$title</td>"
	    }
	    ns_write "</tr>"
	    lset rowtitles {}
	    set col 0
	}
    #ns_write "$title<hr>"
    }
}
closetable
#if {[llength $rowtitles] > 0} {
#    ns_write "</tr><tr>"
#    foreach title $rowtitles {
#	ns_write "<td>$title</td>"
#    }
#    ns_write "</tr>"
#    unset rowtitles
#}
#ns_write "</table>"

ns_write "<a href=\"[progressurl $req_year $req_month $req_day]\">Back to [monthname $req_month] $req_day, $req_year</a>"

ns_write "[tmrc_footer]"