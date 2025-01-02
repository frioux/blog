---
title: Notion Book Sorter
date: 2025-01-01T20:20:06
tags: [ "frew-warez" ]
guid: c2cc343c-4369-4d9c-9b55-7c0a9f67f9b0
---
Quick tip on custom sorting in Notion.

<!--more-->

A while ago I started keeping all of my notes in [Notion](https://www.notion.so/).
Mostly because I wanted to be able to easily access and edit notes from my phone, rather than only on a laptop.
My old system was too desktop oriented.

One of the things I had set up for my old notes system was a way to "book-sort" text.
I use this when sorting Book, Show, or Movie titles.

Here's how I achieve the same thing in Notion:

1. Create a new column in the database called sort name.
2. Press the lightning bolt at the top of a database to create a new automation.
3. For the triggers I set them to: when `any` of "Page is added", "Name is edited", or "sort name is set to x"
4. For the Action I set Sort Name to `replace(replace(replace(lower(Trigger Page.Name), "^\W+", ""), "^(the|a|an)\b", ""), "^\W+", "")`, make sure to do this in the Formula mode, not plain text.

Now, any time a new page is created or the Name field is edited, the sort name will become a lowercased version of the name with leading articles removed.

It's not perfect, as if you modify the name multiple times in a second, only the *first* edit triggers the behavior, but I think that's probably not very common.

Enjoy!
