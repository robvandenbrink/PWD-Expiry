# PWD-Expiry
Handling soon-to-expire and already expired passwords more gracefully

This detects who's AD passwords will expire soon (within 7 days for instance), and sends them a reminder email
It also detects recently expired AD passwords, and sends that list (with the contact phone numbers for the affected people) to your helpdesk for follow-up calls

Described more completely at: https://isc.sans.edu/diary//29758

Tested and working in a prod environment, if this doesn't fly in your environment please comment on the blog (link above) and I'll update as neccessary.
