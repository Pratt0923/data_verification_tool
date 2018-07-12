# README


* Ruby version 2.4.1

To get started running this locally
* Upgrade Ruby version to 2.4.1
* Install rails `gem install rails`
* Install bundler if you do not have it already
* Pull down the latest commit of this code `git pull ____`
* `bundle install`
* `rails db:migrate`
* To run the code locally type `rails s` into the command line to start it. To stop this process type ctrl + c.

What this code does is
1. Takes in the Programming Grid, the QA list, and the emails
2. Makes the user input the Versions and the Merge Variables
3. Uses those Merge Variables to find out which version each email is, via the QA List
4. Uses the version to compare each sentence in the email to the Programming Grid and find a match
5. Highlight the match if there is one. If not it writes "COULD NOT FOUND" next to the sentence.

# Controllers
This is where the data from ruby is passed to the HTML so that the HTML can display it on the page.
## Emails Controller
All the heavy lifting for the emails is done here.

### email_merge_variables_pick
This method is just used as a bridge for the HTML. It's only purpose is so that I can create a route that goes to this page
This is the page where the user inputs the Merge Variables.

### emails
1. First this method creates a new Programming Grid class so that we can do things to the programming grid.
2. Lines 39-48: Extracting the body as text. When it recieves the email the body is full of links and html that we dont need.
3. Line 0 - Line 57: Defining element of the emails so that we can easily pull out things like the subject line, and who the email is from.
4. Line 59-68: Creating an `Email`. An email will be created in the database for each time it runs this. It is important that this works because Active Record methods are neccessary when manipulating the Emails.
5. Line 69: Matching the version in the QA list to the version the email should be.
6. Lines 72-76: If the email is a single version email then we do not need to find version, so there is a seperate path for that.
7. Line 78: Save the email.
8. Line 80: Return all of the Emails and pass them onto the HTML so we can display them.

### clear
1. This method is only clearing the emails from the database. This is important so that we do not store sensitive data.

### find_with_single_version_or_not
This method is here so that we can find where the lines in the email match the programming grid. We need to split the code into 2 paths. One path for if there is single version, and one for if there are multiple versions. This code will work by finding the line in the email, going through each row of the programming grid, trying to find that sentence in the programming grid, and then seeing the version name is in the same row as the sentence.  
1. Line 92-96: Find the correct matches for the senders email address and for the subject line of the email.
2. Lines 100-107: Loop through each sentence of the body and match each one to the programming grid.
3. Line 109: Reassign the body findings to an accessible place from the `Email` class.

### pull_out_header_and_footer_from_email
Seperating the main body from the `header` and the `footer` is what this method does.
1. The header is everything before `browser`
2. The footer is everything after `About this email`
3. The body is now everything in between.

### compare_correct_row_with_mvs
This method is what is comparing the QA list to the Merge Variables that the user put in on the input screen.
## Direct Mails Controller


# CSS and JS
## Stylesheets

## Javascript

# Models
## PG Model

## Email Model

## QA_LIST Model

# Views
## Emails

## email_merge_variables_pick

## layouts

## Home

# Database

## Emails
