---
aliases: ["/archives/4"]
title: "Friday Tips and Tricks"
date: "2007-07-06T23:53:53-05:00"
tags: ["ruby", "shell", "unix"]
guid: "http://blog.afoolishmanifesto.com/archives/4"
---
Time saving tips and tricks!

This first tip is something that I use almost daily. Do you ever want to change a filename to something that is similar to the original name? For instance, maybe you just want to change/add/remove the extension? Well, if you are using a reasonable shell you can do the following:

    # Add .txt to the filename
    cp textfiel{,.txt}
    # change el to le
    cp textfi{el,le}.txt
    # remove extension
    cp textfile{.txt,}

Or how about this; fairly often I will be programming and I will be adding a predefined string to the end of another string a bunch of times, except for the last time. The idea is to put the predefined string between some other things. This is pretty regular if you are generating HTML or SQL. Well, instead of doing the following:

    output = ""
    some_array.each_with_index do |item,index|
    output += item
    output += " AND " unless index = some_array.length - 1
    end

you can do:

    output = some_array.join(" AND ")

Another thing that I find myself doing often is the following:

    output=""
    some_array.each_with_index do |item,index|
    output += "?"
    output += "," unless index=some_array.length-1
    end

That will generate the question marks for an SQL statement. Again, that's a little messy and there is a cleaner way to do it.

    output = some_array.map{"?"}.join(",")

Much better! It's much shorter and should be easier to understand for other Ruby programmers.

It's good to put things like this into practice, because it will make your code more readable and easier to maintain. Generally, in my manifesto, fewer lines of code (comments and whitespace don't count) are better. Of course, in a language like Ruby this can create performance problems; it's a balance between what works for you as the programmer and what works for the user. If the speed is really an issue, change the code. Otherwise, save your skull!

If you have any tips for regular things like this, let me know. I need to know stuff like this just as much as anyone else.
