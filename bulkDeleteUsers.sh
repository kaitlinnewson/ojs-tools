#!/bin/sh

# A little script to bulk delete a list of users in OJS.
# Useful once you've identified a list of spam usernames.

# the user to merge all accounts into
username='OJSUSER'

# the list of users to delete
users=(
    one
    two
    three
)

listlen=${#users[*]}

echo "Beginning removal of $listlen users."

for ((i=0; i<$listlen; i++)); do
    echo "Removing user: ${users[i]}"
    php tools/mergeUsers.php "$username" "${users[i]}"
done
