# Basics
# About this Tool.
  Hey everyone! Thank you for your interest in my data verification tool. This tool is to help users compare data. Right now I've made it just for use at my own company, but it can
  be modified for your company too.

## What does currently
  1. Takes in the Programming Grid, the QA list, and the emails
  2. Makes the user input the Versions and the Merge Variables
  3. Uses those Merge Variables to find out which version each email is, via the QA List
  4. Uses the version to compare each sentence in the email to the Programming Grid and find a match
  5. Highlight the match if there is one. If not it writes "COULD NOT FOUND" next to the sentence

## What it checks for
  1. Takes in the Programming Grid, the QA list, and the emails
  2. Makes the user input the Versions and the Merge Variables
  3. Finds the customer number listed as an integer at the bottom of each email
  3. Uses those customer numbers to find out which version each email is, via the QA List
  4. Uses the version to compare each sentence in the email to the Programming Grid and find a match
  5. Highlight the match if there is one. If not it writes "COULD NOT FOUND" next to the sentence.

## What it DOES NOT check for
  Currently this codes does not check for:
  1. Links
  2. Multiple tabs in the programming grid


# Caveats to use
  * The programming grid must be renamed to "Programming_Grid.xlsx" for the code to find it.
  * To use this there must be only one tab in the programming grid being used. That tab must be called "Email". This is how the code identifies the tab to find.
  * The version in the Merge Variable input fields MUST be the same as the ones in the programming grid.

    For example if I say that:
    Version => Merge Variable
    UNC Cardio => A
    UNC Pulmonary => B

    I cannot use just "Cardio" or "Pulmonary" in the details of my programming grid. I must use "UNC Cardio" or "UNC Pulmonary".

  * Each line in the programming grid must have a version label on it or it will be skipped. This means that if I want to make half of my grid for UNC Cardio, and half for UNC Pulmonary,
  I will have to state that in every line. I CANNOT put "UNC Cardio" at the start of the programming grid and expect this program to self identify if something is UNC Cardio or UNC Pulmonary.

  These versions can be seperated by commas. So if you have "UNC Maternity" as well, you could have something that is "UNC Cardio, UNC Pulmonary" and it would realize that what you have is going to apply to both the Cardio and the Pulmonary version, but not the Maternity one.

  "GLOBAL" can also be used like this. If you have something, like a header, that applies to all the versions, you can put "GLOBAL" in the column instead of each version. This will save you time and allow you to not put every version in, especially if there are a lot of versions.



# Technical
* Ruby version 2.4.1

To get started running this locally
* Upgrade Ruby version to 2.4.1
* Install rails `gem install rails`
* Install bundler if you do not have it already
* Pull down the latest commit of this code `git pull ____`
* `bundle install`
* `rails db:migrate`
* To run the code locally type `rails s` into the command line to start it. To stop this process type ctrl + c.

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

### make_versions_match_specific_format
Make sure the versions match a format.
currently the versions are in `[version, version, version][MV, MV, MV][MV, MV, MV]` Format.
This makes them into `{version=[MV, MV]}` format which is what I want for checking the variables vs the versions.

### check_for_single_version_before_version_match
This method is here just to check if the emails have only one version. if there is just one version then it does nothing. No use trying to compare versions when there is only one! :)

## Direct Mails Controller
WIP

# CSS and JS
## Stylesheets
### main
This is just an overwrite of some Bootstrap. Making buttons different colors and aligning columns so that they fit on my screen.

THIS IS NOT RESPONSIVE. I have made everything to have exact dimensions so that it fits on my screen. If the screen size is changed then the page may look wrong.

## Javascript
### get_text_to_replace_p_tag
This function is reading the text in the p tags and going through all of it, finding what matches what is in the email column, and highlighting it yellow.

I'm sure there is a much better way to achieve this, but the way that I have gone with is
1. put all text in before the match
2. put a span in and make it have a highlight class
3. put all the matching text in
4. close the span
5. put the remaining text in.

This allows the highlight to happen.

# Models
## PG Model
Everything that directly happens to the Programming Grid will happen here.
### merge_variables
This is supposed to return all of the merge variables. This is not currently used but the hope is that it will be used to pull the Merge Variables out of the Programming Grid when I can get the data. It also pulls out the correct row from the QA list.

This should actually be in the QA_LIST class, but I moved it incorrectly when I was refactoring code and I have not gotten around to fixing it.
## Email Model
I wanted to serialize certain columns in the DB, so that is what this model does.
## QA_LIST Model
### sanitize_qa_list
I only wanted to deal with data I needed, so this method is pulling out everything that I don't need.

### clean_parameters
I also only wanted to deal with params that I needed. The clean params gets rid of unecessary data.
# Views
## Emails
There are 2 columns here. This is where all the data from the emails and Programming Grid get spit out. On the left is the email data. On the right is the programming grid data. I want to have it paginate eventually, but the way I have written the code makes it break every time I try, and I just don't have time to get it working right now. So it'll be ugly for a while.

In addition it used to match the section of Programming Grid up to the email, but when I built the highlighter it broke the alignment, so thats on hold for now.
## email_merge_variables_pick
Right now this is just a form where the user can fill out the different versions and the Merge Variables.

## layouts
lots of little pieces. Explore at your own risk.
## Home
This is the root that user lands on. Eventually I want to have instructions here.
# Database

## Emails
