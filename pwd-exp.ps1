# get today's date
$now = get-date

# Collect all users with their respective password expiry dates
# note the computed field ExpiryDate
$b = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties SAMAccountName,"DisplayName", "msDS-UserPasswordExpiryTimeComputed","emailaddress",mobilephone, officephone, telephoneNumber | Select-Object -Property SamAccountName,"Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},"emailaddress", mobilephone, officephone, telephoneNumber

# who has expired in the last 30 days? (note that $recent is negative)
$recent = -30
$ExpiredPeople = $b | where-object {($_.expirydate -$now).days -lt 0} | where-object {($_.expirydate -$now).days -ge $recent} | sort-object -property expirydate

# who will be expiring within the next week?
$expthreshold = 7
$pwdpeople = $b | where-object {($_.expirydate -$now).days -lt $expthreshold} | where-object {($_.expirydate -$now).days -ge 0} | sort-object -property expirydate

# Define mail parameters
$mailserver = "mail_or_relay_server_fqdn"
$from = "helpdesk@yourcompany.com"
$msg = (get-content ./mailskeleton.txt)

# send the note to each person in turn
foreach ($p in $pwdpeople) {
    $days = ($p.expirydate - $now).days
    $subj = "Your Password will expire in "+$days+" days"
    $emailtext = $msg.replace("XXX",$days) | out-string
    send-mailmessage -smtpserver $mailserver -subject $subj -from $from -to $p.emailaddress -Body $emailtext -BodyAsHtml
    }

# send the two lists of people (expired and soon to expire) to the helpdesk
$subj = "List of recently expired accounts"
$expiredpeople | export-csv ./ExpiredAccounts.csv
$body = "List of recently expired accounts.  Please contact each of them within the next 24 hours."
$to = "helpdesk@yourcompany.com"
send-mailmessage -smtpserver $mailserver -subject $subj -Body $body -attachments ./Expiredaccounts.csv -from $from -to $to

$subj = "List of accounts that will expire soon"
$pwdpeople | export-csv ./ExpiringAccounts.csv
$body = "List of accounts that will expire soon.  Please expect them to contact you shortly."
send-mailmessage -smtpserver $mailserver -subject $subj -Body $body -attachments ./Expiringaccounts.csv -from $from -to $to
