---
title: NSIS Sucks
date: 2014-10-02T07:55:12
tags: ["NSIS", "Nullsoft Installer", "Windows Installers", "Installers"]
guid: "https://blog.afoolishmanifesto.com/posts/nsis-sucks"
---
This is the first article of a series on [Windows
Installers](/tags/windows-installers).

I wrote an installer for work using [Nullsoft Installer
System](http://nsis.sourceforge.net/Main_Page) (aka NSIS) about
18 months ago.  (To be completely honest I wrote most of it but [my
coworker](https://github.com/wesQ3) has to take a good portion of the credit
for finishing it all the way.)  It works pretty well, but mostly that's because
it just automates what we did before (extract, run a bunch of perl scripts,
done.)  As with many kinds of automation, I found that you cannot leave
the way you came.  I poured so much sweat and blood into an installer that,
while working, is not something I'd brag about if you had access to the code.

Let me back up a little bit before I start enumerating NSIS' foibles.  NSIS was
originally made by the Winamp team in the ancient past as a generic installer
tool.  The first version was released in 1999.  I think that this is probably
part of why NSIS is so weird; a big design goal is to reduce the overhead
required by the installer.  So if your binary is 1M, the installer will only add
a 10-300k (varies hugely based on feature usage of course.)

One really nice thing about NSIS is that it allows users to build installers on
Linux, even though the only target is Windows.  I use this at work and if I had
installable open source stuff I could use [travisci](https://travis-ci.org/) to
generate installers easily.  I haven't looked closely at how this works but it
seems like NSIS leverages GCC and the fact that there [is an OSS port that emits
Windows binaries](http://mingw.org/).

## Stack Based Assembly

Initially creating an installer with NSIS is pretty bewildering.  This brings me
to my first complaint.  The language used to define NSIS installers looks
something like a stack based assembly with a lot of preprocessor macros.  It's a
tiny bit better than that, as there are actual fuctions, but as it is stack
based, you do not pass arguments to functions, you push arguments on to the
stack and pop them off inside the function.  To get a taste of what the language
is like, here's a function that I wrote (with help from the internet of course)
and another example of calling the function:

    Function LoggedExec
       Pop $1
       Pop $0
    
       nsExec::ExecToStack $0
       Pop $0
    
       # Dear future frew, I'm so sorry
       # http://stackoverflow.com/questions/15437910/how-can-i-convert-literal-newlines-into-n-in-nsis
       ${If} $0 != 0
          StrCpy $Errors "$Errors Errors From $1 install!$\n"
          IntOp $InstallErrors $InstallErrors + 1
          Pop $0
          StrCpy $1 -1
          StrCpy $3 "" ; \r \n merge
        more:
            IntOp $1 $1 + 1
            StrCpy $2 $0 1 $1
            StrCmp $2 "" done
            StrCmp $2 "$\n" +2
            StrCmp $2 "$\r" +1 more
            StrCpy $2 $0 $1
            StrCpy $4 $0 1 $1
            StrCmp $3 "" +2
            StrCmp $3 $4 0 more
            StrCpy $3 $4
            IntOp $1 $1 + 1
            StrCpy $0 $0 "" $1
            Push $0
            Push $3
            DetailPrint $2
            Pop $3
            Pop $0
            StrCpy $1 -1
            StrCmp $0 "" +1 more
        done:
       ${EndIf}
    FunctionEnd

And then calling it:

    Push '"Text2Speech\Kate\setup.exe" /s /sms'
    Push 'kate'
    Call LoggedExec

So that's great.  Note that the `${If}` and `${EndIf}` above are preprocessor
macros that literally expand to `IntCmp $0 0 done more more`.

## Slow

The language is my main complaint, but the other issues I think are valid
too.  Our installer includes something like 13 thousand files, because we are
installing our project in addition to Perl, apache, and more.  Each file being
added to the installer adds time.  Weirdly, it's *significantly* faster to
generate a tar file in Perl and to give NSIS the tar file and `7z.exe`.  We're
talking a reduction from a 10 minute build (20 if you build both the installer
and updater) to a 3 minute build (6 for both.)

## Uninstaller oddities

This might fall under the weird made up language category, but it sticks out in
my mind.  In NSIS, unlike MSI based installers (which I'll post about next
time), the uninstaller is defined separately from the installer.  It may be in
the same file, but it's really quite segregated.  The most obvious way is that
any user defined functions that are to be used in the uninstaller need to be
prefixed with `un.`.  While this isn't too tedious, you do often end up with a
handful of functions defined twice.  A better compiler would be able to traverse
the graph of functions and exclude the unreachable ones from the binary, instead
of forcing the user to do this by hand.

## Long in the tooth

I don't mind projects being old.  I use Perl, Vim, Apache, and Firefox, all of
which have much newer, more chic counterparts these days.  But NSIS has
languished pretty significantly.  For example, [here is the NSIS
documentation](http://nsis.sourceforge.net/Docs/).  The docs work, but they
aren't very approachable.

The source code is [Subversion at
sourceforge](http://sourceforge.net/p/nsis/code/HEAD/tree/), which is way less
friendly to browsing than [Github](https://github.com/kichik/nsis).

[Check out the awesome
forum](http://forums.winamp.com/forumdisplay.php?s=&forumid=65).

The NSIS team is working on a new major version, which is great, but the final
stable version was released in 2009, five years ago at this time.  The first 3x
release was in May of 2013.  There have been more alphas and betas since then
but despite the major rev changing, the only major new feature seems to be
unicode support.  There are other major changes, but they seem to mostly be bug
fixes.

## Stuck

Aside from the faults above, I think that NSIS is the best OSS installer
framework for Windows today.  Stay tuned for my next post which will discuss
[WiX Toolset's](http://wixtoolset.org/) failings.

### Appendix: a complete NSIS installer example

I'll leave you with this real world example of NSIS code that's *mostly* written
by hand, though partially generated (filenames, metadata.)

    !include MUI.nsh
    !include nsDialogs.nsh
    !include LogicLib.nsh
    !include sections.nsh
    !include x64.nsh
    !include FileFunc.nsh
    !define MUI_ABORTWARNING
    !define ARB "Software\Microsoft\Windows\CurrentVersion\Uninstall\LCI"
    
    OutFile "foo.exe"
    SetCompressor /SOLID lzma
    SetCompressorDictSize 16
    AllowSkipFiles off
    AutoCloseWindow false
    CRCCheck force
    
    Name "Foo 1.0.0.0"
    InstProgressFlags smooth colored
    LicenseBkColor /windows
    RequestExecutionLevel admin
    VIAddVersionKey ProductName "Foo"
    VIAddVersionKey CompanyName "Micro Technology Services, Inc."
    VIAddVersionKey FileVersion "1.0.0.0"
    VIAddVersionKey ProductVersion "1.0.0.0"
    VIAddVersionKey LegalCopyright "Micro Technology Services, Inc."
    VIAddVersionKey FileDescription "Install Foo"
    InstallDir "C:/Program Files (x86)/foo/bar"
    InstallDirRegKey HKLM "${ARB}" "InstallLocation"
    
    VIProductVersion "1.0.0.0"
    
    Var Dialog
    Var Errors
    Var InstallErrors
    
    Section "Foo" SEC_FOO
       SectionIn RO
       AddSize 6937626
    
       SetOutPath "-"
    
       Push '"net" stop Foo /y'
       Push 'stop Foo'
       Call LoggedExec
    
       File "/oname=foo.dll" "/home/frew/foo/foo.dll"
       File "/oname=foo.pdb" "/home/frew/foo/foo.pdb"
       File "/oname=foo.exe" "/home/frew/foo/foo.exe"
       File "/oname=foo.exe.config" "/home/frew/foo/foo.exe.config"
    
       Push '"net" start Foo /y'
       Push 'start Fpp'
       Call LoggedExec
    
       ${If} $InstallErrors > 0
          GetTempFileName $0
          StrCpy $Errors "Errors were detected during installation; please email $0 to foo@mitsi.com and call foo technical support.$\n$\n$Errors"
          Push $0
          Call DumpLog
       ${EndIf}
    
       WriteRegStr HKLM   "${ARB}" "DisplayName" "Foo"
       WriteRegStr HKLM   "${ARB}" "DisplayVersion" "1.0.0.0"
       WriteRegStr HKLM   "${ARB}" "InstallLocation" '"$INSTDIR"'
       WriteRegDWORD HKLM "${ARB}" "NoModify" 1
       WriteRegDWORD HKLM "${ARB}" "NoRepair" 1
       WriteRegStr HKLM   "${ARB}" "Publisher" "MTSI"
       WriteRegDWORD HKLM "${ARB}" "VersionMajor" 1
       WriteRegDWORD HKLM "${ARB}" "EstimatedSize" 6937626
       WriteUninstaller "$INSTDIR\uninstall.exe"
    SectionEnd
    
    Section "Uninstall"
       Push '"net" stop Foo /y'
       Push 'stop Foo'
       Call un.LoggedExec
    
       Delete $INSTDIR\uninstall.exe
       Delete "$INSTDIR\foo.dll"
       Delete "$INSTDIR\foo.pdb"
       Delete "$INSTDIR\foo.exe"
       Delete "$INSTDIR\foo.exe.config"
    
       DeleteRegKey HKLM "${ARB}\DisplayName"
       DeleteRegKey HKLM "${ARB}\DisplayVersion"
       DeleteRegKey HKLM "${ARB}\InstallLocation"
       DeleteRegKey HKLM "${ARB}\NoModify"
       DeleteRegKey HKLM "${ARB}\NoRepair"
       DeleteRegKey HKLM "${ARB}\Publisher"
       DeleteRegKey HKLM "${ARB}\UninstallString"
       DeleteRegKey HKLM "${ARB}\VersionMajor"
       DeleteRegKey HKLM "${ARB}\EstimatedSize"
       DeleteRegKey HKLM "${ARB}"
    SectionEnd
    
    !insertmacro MUI_PAGE_DIRECTORY
    !insertmacro MUI_PAGE_COMPONENTS
    !insertmacro MUI_PAGE_INSTFILES
    Page custom errorsPage
    
    Function errorsPage
       nsDialogs::Create 1018
       Pop $Dialog
    
       ${If} $Dialog == error
          Abort
       ${EndIf}
    
       ${If} $InstallErrors > 0
          ${NSD_CreateLabel} 0 0 100% 60u $Errors
       ${EndIf}
    
       nsDialogs::Show
    FunctionEnd
    
    !define LVM_GETITEMCOUNT 0x1004
    !define LVM_GETITEMTEXT 0x102D
    
    Function DumpLog
      Exch $5
      Push $0
      Push $1
      Push $2
      Push $3
      Push $4
      Push $6
    
      FindWindow $0 "#32770" "" $HWNDPARENT
      GetDlgItem $0 $0 1016
      StrCmp $0 0 error
      FileOpen $5 $5 "w"
      StrCmp $5 0 error
        SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
        System::Alloc ${NSIS_MAX_STRLEN}
        Pop $3
        StrCpy $2 0
        System::Call "*(i, i, i, i, i, i, i, i, i) i \
          (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
        loop: StrCmp $2 $6 done
          System::Call "User32::SendMessage(i, i, i, i) i \
            ($0, ${LVM_GETITEMTEXT}, $2, r1)"
          System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
          FileWrite $5 "$4$\r$\n"
          IntOp $2 $2 + 1
          Goto loop
        done:
          FileClose $5
          System::Free $1
          System::Free $3
          Goto exit
      error:
        MessageBox MB_OK error
      exit:
        Pop $6
        Pop $4
        Pop $3
        Pop $2
        Pop $1
        Pop $0
        Exch $5
    FunctionEnd
    
    Function DetailPrintTS
       Pop $7
    
       ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
    
       DetailPrint "$4:$5:$6 -- $7$\n"
    FunctionEnd
    
    Function LoggedExec
       Pop $1
       Pop $0
    
       nsExec::ExecToStack $0
       Pop $0
    
       # Dear future frew, I'm so sorry
       # http://stackoverflow.com/questions/15437910/how-can-i-convert-literal-newlines-into-n-in-nsis
       ${If} $0 != 0
          StrCpy $Errors "$Errors Errors From $1 install!$\n"
          IntOp $InstallErrors $InstallErrors + 1
          Pop $0
          StrCpy $1 -1
          StrCpy $3 "" ; \r \n merge
        more:
            IntOp $1 $1 + 1
            StrCpy $2 $0 1 $1
            StrCmp $2 "" done
            StrCmp $2 "$\n" +2
            StrCmp $2 "$\r" +1 more
            StrCpy $2 $0 $1
            StrCpy $4 $0 1 $1
            StrCmp $3 "" +2
            StrCmp $3 $4 0 more
            StrCpy $3 $4
            IntOp $1 $1 + 1
            StrCpy $0 $0 "" $1
            Push $0
            Push $3
            DetailPrint $2
            Pop $3
            Pop $0
            StrCpy $1 -1
            StrCmp $0 "" +1 more
        done:
       ${EndIf}
    FunctionEnd
    
    Function un.LoggedExec
       Pop $1
       Pop $0
    
       nsExec::ExecToStack $0
       Pop $0
    
       # Dear future frew, I'm so sorry
       # http://stackoverflow.com/questions/15437910/how-can-i-convert-literal-newlines-into-n-in-nsis
       ${If} $0 != 0
          StrCpy $Errors "$Errors Errors From $1 install!$\n"
          IntOp $InstallErrors $InstallErrors + 1
          Pop $0
          StrCpy $1 -1
          StrCpy $3 "" ; \r \n merge
        more:
            IntOp $1 $1 + 1
            StrCpy $2 $0 1 $1
            StrCmp $2 "" done
            StrCmp $2 "$\n" +2
            StrCmp $2 "$\r" +1 more
            StrCpy $2 $0 $1
            StrCpy $4 $0 1 $1
            StrCmp $3 "" +2
            StrCmp $3 $4 0 more
            StrCpy $3 $4
            IntOp $1 $1 + 1
            StrCpy $0 $0 "" $1
            Push $0
            Push $3
            DetailPrint $2
            Pop $3
            Pop $0
            StrCpy $1 -1
            StrCmp $0 "" +1 more
        done:
       ${EndIf}
    FunctionEnd
    
    LangString DESC_SectionFoo ${LANG_ENGLISH} "Foo thingy"
    
    !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
       !insertmacro MUI_DESCRIPTION_TEXT ${SEC_FOO} $(DESC_SectionFoo)
    !insertmacro MUI_FUNCTION_DESCRIPTION_END

Do not post comments asking for help with NSIS, I will just delete them.  I am
not going to support its use.
