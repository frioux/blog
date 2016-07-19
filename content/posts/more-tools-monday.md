---
aliases: ["/archives/562"]
title: "More Tools Monday"
date: "2009-04-21T14:48:55-05:00"
tags: [mitsi, perl-critic, webcritic, perl, perltidy, tool]
guid: "http://blog.afoolishmanifesto.com/?p=562"
---
So I am working on a new way to use perlcritic, and one of the things I'd like perlcritic to check for is a correctly formatted file. Unfortunately the integration between perlcritic and perltidy goes something like this:

 * Tidy the file with perltidy
 * Give vague error if tidy file != original file

That's fine until you discover that = signs get aligned and apparently you cannot turn that feature off. That means that my code gets marked sketch if I don't align my = signs. That is terrible. So I figured I'd make it easy to tidy up source files.

First off you have to install perltidy (I think it's Acme::Tidy.) This also assumes Win32. On Mac and Linux the commandline isn't so painful so this isn't necessary. Next run this code:

    use Win32::TieRegistry;
    $Registry-> Delimiter("/");
    $perlKey = $Registry-> {"HKEY_CLASSES_ROOT/Perl/"};
    $perlKey-> {"shellex/"} = {
    	"DropHandler/" =>  {
    		"/"=> "{86C86720-42A0-1069-A2E8-08002B30309D}"
    	}};

That will allow for you to drag files onto .pl files and put the file list into @ARGV.

Then you just make a script with this in it:

    use Perl::Tidy;
    Perl::Tidy::perltidy();

And drag perl files into it. It will create new files with the .tdy extension in the same dir as the original files. If you create a .perltidyrc and put it in your home it will use those settings. Here's our .perltidyrc:

    -i=3 -ce -bar -nsbl -sot -sct

Enjoy!
