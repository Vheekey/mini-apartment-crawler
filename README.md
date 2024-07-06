# mini-apartment-crawler
Since we all live busy lives, this is a mini apartment crawler to reduce the checking of bostad websites for first hand contracts as the sites are crawled on a daily basis and emails are sent out directly after the process is finished.

Just a bit of tinkering while feeling bored and a few lines of code later, we have a working solution.

# Usage
To run in console, simply run the following command:

```
bash home_crawler.sh
```

To run in background like myself, do the following:
1. Clone the repo
2. Edit RECIPIENT in constants.sh
3. Check you have the right configuration in ~/.msmtprc. Find guide below (This helps with sending emails)
```
defaults
auth           on
tls            on
tls_trust_file /usr/local/etc/openssl@1.1/cert.pem
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           your_email@gmail.com
user           your_email@gmail.com
password       your_app_password

account default : gmail
```
2. Open crontab
```
crontab -e
```
4. Add the following line to the crontab:
```
# Run script at 4 AM, 1 PM, and 6 PM daily
0 4,13,18 * * * /bin/bash /path/to/folder/home_crawler.sh >/dev/null 2>&1
```
5. Sit back and relax, the script will run every day at 4 AM, 1 PM, and 6 PM.

### Vilken rolighet!