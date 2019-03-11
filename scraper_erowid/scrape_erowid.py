import time
from scrapy import Selector
import requests
import re

# Function for creating valid filenames
def get_valid_filename(s):
    s = str(s).strip().replace(' ', '_')
    return re.sub(r'(?u)[^-\w.]', '', s)


# Function for extracting the content of each experience
def extract_content(url, Xpath = '//@href'):
    html = requests.get(url, headers=headers).content
    sel = Selector(text = html)
    content = sel.xpath(Xpath).extract()
    return content

# Function to get the links to each page within a substance
# if there is only one page do nothing
def get_links_pages(url_iest):
    # All pages links has the word Cellar in it, return those
    pages = list(filter(lambda x: re.search('Cellar', x), 
                        url_iest))
    if len(pages) < 1:
        pages # just return empty string if there is no pages links
    else: 
        pages.pop(0) # the first page link is deleted
    return pages


url_erowid = 'https://www.erowid.org'
list_drugs = 'https://www.erowid.org/experiences/exp_list.shtml'

all_urls = extract_content(list_drugs, '//@href')

# Select URLs that correspond to experiences
selected_urls = list(filter(lambda x: re.search('General'
                                                 '|First_Times'
                                                 '|Combinations'
                                                 '|Retrospective'
                                                 '|Difficult'
                                                 '|Bad_Trips'
                                                 '|Health_Problems'
                                                 '|Train_Wrecks'
                                                 '|Addiction'
                                                 '|Glowing_Experiences'
                                                 '|Mystical_Experiences'
                                                 '|Health_Benefits', x), 
                                                  all_urls))
        
# Create list to store experiences  
experiences = []
for i in selected_urls:
    url_substance = url_erowid + '/experiences/' + i
    url_first_page = extract_content(url_substance, '//@href')
    url_pages = get_links_pages(url_first_page)
    reports = list(filter(lambda x: re.search('ID', x), url_first_page))
    reports = [re.sub('/experiences/','', r) for r in reports]
    if len(url_pages) == 0:
        reports
    else:
        for page in url_pages:
            urls = extract_content(url_erowid + page, '//@href')
            reps = list(filter(lambda x: re.search('ID', x), urls))
            reports.extend(reps) # adds element to previous list
                                 # instead of appending lists
    for rep in reports:
        url_report = url_erowid + '/experiences/' + rep
        text = extract_content(url_report, 
                               '//div[@class = "report-text-surround"]')
        
        substance = str(extract_content(url_report, '//div[@class = "substance"]'))
        substance = re.sub("\[.*?\>|</div>']| &amp", "", substance)
        title = str(extract_content(url_report, '//div[@class = "title"]'))
        title = re.sub("\[.*?\>|</div>']", "", title)
        title_substance = substance + '__' + title + '.txt'
        with open('./experiences/' + get_valid_filename(title_substance), 
                  'w',encoding='utf-8') as f:
                for item in text:
                    f.write("%s\n" % item)
        time.sleep(5) # added a 5 seconds delay between each iteration for not getting my ip address blocked.
        experiences.append(text)  
