import requests
import re
import os

langs_page = requests.get('http://accent.gmu.edu/browse_language.php')

langs = re.findall('(?<=&language=)[a-z]*', langs_page.text)
langs = [l.encode('ascii') for l in langs]
while True:
    lang = raw_input('Language: ').lower()
    if lang == '': break
    if lang not in langs:
        print 'That language is not in our database.'
        continue
    if os.path.isdir(lang):
        print 'There is already a directory called ' + lang + '. Please make sure it doesnt already contain audio samples.'
        continue
    page = requests.get('http://accent.gmu.edu/browse_language.php?function=find&language=' + lang)

    #any specific gender?
    total = page.text.count('male')
    female = page.text.count('female')
    male = total - female
    gender_opts = ['m', 'f', 'a', 'q']
    while True:
        gender_opt = raw_input('There are a total of ' + str(total) + ' speakers, ' + str(male) + ' male and ' + str(female) + ' female. Download male, female, or all? (M/F/A). Q to quit: ').lower()
        if gender_opt in gender_opts: break
    if gender_opt == 'q': continue

    if gender_opt == 'm': gender = 'male'
    if gender_opt == 'f': gender = 'female'
    if gender_opt == 'a': gender = ''

    # retrieving filenames
    filenames = re.findall(lang + '\d+(?=,</a> ' + gender + ')', page.text)
    filenames = [f.encode('ascii') for f in filenames]

    # retrieving info
    info_dat = re.findall('(?<=,</a> )' + gender + '[a-z, ]*', page.text)
    info_dat = [i.encode('ascii') for i in info_dat]
    info = [i.split(', ') for i in info_dat]

    # select region
    while True:
        region = raw_input('From what region (A for all): ').lower()
        if region == 'a': break
        new_filenames = []
        new_info_dat = []
        for i in range(len(info)):
            if region in info[i]:
                new_filenames += filenames[i]
                new_info_dat += info_dat[i]
        affirm = raw_input( 'There are ' + str(len(new_filenames)) + ' speakers from ' + region + ', OK? y/n: ')
        if affirm == 'y':
            filenames = new_filenames
            info_dat = new_info_dat
            break

    # how many to get?
    while True:
        num_str = raw_input('How many files would you like to get? A for all: ').upper()
        if num_str == 'A': break
        if num_str.isdigit():
            num = int(num_str)
            if num <= len(filenames) and num > 0:
                filenames = filenames[0:num]
                info_dat = info_dat[0:num]
                break
        print 'Please enter a valid response.'

    info_dat = '\n'.join('%s: %s' % t for t in zip(filenames, info_dat))

    # making the language folder
    os.makedirs(lang)
    for filename in filenames:
        f = lang+'/'+filename
        os.system('wget -O '+f+'.mov http://accent.gmu.edu/soundtracks/'+filename+'.mov')
        os.system('ffmpeg -i '+f+'.mov -vn -ar 44100 -ac 2 -ab 192k -f wav '+f+'.wav')
    info_file = open(lang+'/info.txt', 'w')
    info_file.write(info_dat)
    info_file.close()




