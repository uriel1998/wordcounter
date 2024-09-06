# A simple wordcounter PHP/bash monstrosity

Written to be a simple community-tracking word counter for writing challenges. Uses 
simple straightforward NON-AI/ML technologies.  

## Contents
 1. [About](#1-about)
 2. [Features](#2-features)
 3. [License](#2-license)
 4. [Prerequisites](#3-prerequisites)
 5. [Installation](#4-installation)
 6. [Usage](#6-usage)
 7. [TODO](#12-todo)

***

## 1. About

## 2. Features

PHP script to take an uploaded document file, convert it, count the words with 
`wc`, and return the value to the user. If a username is given, then the count 
along with the date and a datestamp is saved in a simple markdown formatted table 
that pandoc then turns into a webpage.  No user submitted data (save IP address) is 
retained.

Some very simple ratelimiting is done with the PHP script. There's probably a bazillion 
security holes and inefficiencies.

## 3. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites 

This includes all of the helpers as well; the "core" first four are for the 
script itself and are probably already installed on your system.  Installing all 
the helpers is obviously not necessary; however, doing so will result in everything 
working out of the box.

The following can be installed on Debian and probably Ubuntu by typing 

`sudo apt update;sudo apt-get install awk sed file pandoc elinks wv unrtf poppler-utils libfile-mimeinfo-perl node-iconv`


## 4. Installation

If you can't look at this and figure out how to install it, **PLEASE DO NOT TRY**.  Thanks!

## 5. Usage

## 6. TODO


PHP uploading derived from https://github.com/tenebricosa/PHP-File-Uploader/tree/master
