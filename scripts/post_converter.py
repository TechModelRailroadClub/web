
import os
from markdownify import markdownify as md

MONTHS = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]

def is_month(string:str) -> bool:
    if string.lower() in MONTHS:
        return True
    else:
        return False
    
def last_day_of_month(month:int, year:int = 1):
    if month == 2:
        if year % 4 == 0:
            return 29
        else:
            return 28
    elif (month <= 6 and month %2 == 0) or (month >=9 and month %2 == 1):
        return 30
    else:
        return 31

    


for year in range(1997,2019):
    for month in [i+1 for i in range(12)]:
        f = os.path.join("old/progress/reports/%d/%d" % (year,month), "index.html")
        if os.path.isfile(f):
            with open(f) as file:
                string = file.read()
                string = string.split("</style>")[1]
                md_string = md(string)
                md_string = md_string.split("---")[0]
                monthname = md_string[md_string.find('**')+2:md_string.find(' ',md_string.find('**'))]
                md_string = md_string.replace("(../", "({{ site.baseurl }}/old/progress/reports/%d/%d/../" % (year,month))
                md_string = md_string.replace('|', "\n")

                if is_month(monthname):
                    md_string = "---\ntitle: Monthly Update %s %d \nlayout: post\nauthor: Tom N. Paulsen\n---\n" % (monthname, year) + md_string
                    print(monthname + ' ' + str(year))
                    with open("_posts/%d-%s-%s-monthly-update.md" % (year, str(month).zfill(2), str(last_day_of_month(month, year)).zfill(2)),  "w") as text_file:
                        text_file.write(md_string)

                # print(md_string)

                





