---
aliases: ["/archives/853"]
title: "YAPC Day 2"
date: "2009-06-23T23:50:49-05:00"
tags: ["perl", "yapc", "yapcna"]
guid: "http://blog.afoolishmanifesto.com/?p=853"
---
This is day 2 (my final day :-( ) of YAPC. I tried my best to keep reasonable notes but near the end of the day my brain started to slow down. Hope you dig it nonetheless!

The Future of DBIx::Class

FYI: mst doesn't use a mic, he yells. Instead of using MI, the future will use Moose and Roles.

Good things DBIC already did:

- Everything objects (almost no class methods)
- Schema object
  - multiple connections
- storage and cursors are objects
  - hides away backend specifics
- ResultSource object
  - table/view metadata
  - not tied to the class
  - so multiple classes associated with the same table
- relationships
  - near side, far side, join condition
- no single columns assumptions for keys
- result class (inflate\_result) minimal protocol
- ResultSet (my favorite)
  - virtual view
  - pure functional
  - chainable
  - updatable
  - cacheable
  - RestrictWithObject is a really cool use of this stuff
  - Extensible
  - were an accident
  - 'aha' moment needed
- Result Class vs ResultSource
- list context vs scalar context
- search() args vs find args()
- aha moments indicate conceptual inconsistency
- essential vs implementation complexity

Bad things:

- find() deflates, search() doesn't
- connection attached to schema instance
- details result in underlying design mistakes
- persistent vs. non persistent
- query handling should be more flexible by less DWIM and more consistency
- Objects know too much, classes shouldn't need to know how to serialize themselves
- $rs->next, implicit iterators are a bad idea
- ORM: where's the mapper?
- search() doesn't understand delegation

- rebuild
- refactor
- re-use
- rebase

The Future:

- generic persistence backend
- so you just declare a moose class and tell DBIC to persist it
- very sugary
- uniform data API's
- perl array == files == database table == LDAP
- Data::CapabilityBased
- A role with a default implementation
- validation suite
- semantic queries
  - use perl syntax for searches
  - instead of foo => $bar, 'foo' eq $bar
- SQLA2 provides an explicit AST
- Autojoins!
- Stream API so that there won't be the implicit cursor in ResultSet
- lots more!

join #dbix-class for the fun

And that is my weird list of DBIC Future points. This stuff is **really, really** exciting. The ability to both use Moose and DBIC with a very sexy API is extremely exciting. And as I may have mentioned yesterday, mst has plans to make Moose startup time instant. Feel free to doubt it! That won't stop him :-)

----

Fundamentals of Modern Perl

This was chromatic's talk. It was very polished and he had his ideas very well organized. The outline should give you a very good idea of what the talk really was.

- About ideas, not people.
- Perl is great.
- Problems
  - lots of terrible legacy code
  - Not a lot of external support for perl 5 (ActiveState)
  - Chaotic dev process
- Plan
  - fix problems of ancient code
  - Replace bad tutorials with good ones or drown them out
  - Sustainable dev models
  - Advocate modern Perl
- Complementary Efforts
- Enlightened Perl
- The Perl Foundation
- Strawberry + Chocolate Perl
- Governing Principle of Modernity
  - What is painful in the language?
  - What is painful in the ecosystem?
  - Solve pain for everyone (good defaults) so that noobs don't have to get in touch with people to find out how to do things right
- The Heirachy of Defaults
  - Unknown Problem
  - Poorly Recognized Problem
  - IAQ (Infrequently)
  - FAQ
  - Frequently Reinvented Module
  - Available Module
  - Communiy Idiom
  - Popular Module
  - Bundled Modle
  - Core Module
  - Core Language
  - (higher in the hierarchy, the more a problem)
- How to advocate Modern Perl
  - experiment with new techniques
  - give good feedback
  - help converge to good defaults
  - refactor code regularly for good design
- How to develop Modern Perl
  - deliberate convergence multiplies our power, great effort over the past years has made this possible and even advisable
  - document experience, reuse foundational concepts as often as possible
- How to experiment with Modern Perl: just do it!
- How to Pumpking Modern Perl: n/a :-)
- New features you need
  - given/when, smartmatch are going to change
  - say, awesome
  - $x //= 'default'
  - named captures
  - Work Around Core Bugs (and lacking areas):
    - [SUPER](http://search.cpan.org/perldoc?SUPER)
    - [UNIVERSAL::ref](http://search.cpan.org/perldoc?UNIVERSAL::ref) fixes ref
    - [Time::y2038](http://search.cpan.org/perldoc?Time::y2038) / [Time::y2038::Everywhere](http://search.cpan.org/perldoc?Time::y2038::Everywhere), perl 5 is not y2038 compliant
    - [CLASS](http://search.cpan.org/perldoc?CLASS) :-)
    - [autobox](http://search.cpan.org/perldoc?autobox), [autobox::Core](http://search.cpan.org/perldoc?autobox::Core), [Moose::Autobox](http://search.cpan.org/perldoc?Moose::Autobox) (my addition)
    - [Moose](http://search.cpan.org/perldoc?Moose) duh
    - [Method::Signatures](http://search.cpan.org/perldoc?Method::Signatures), as mentioned yesterday, this is sketch
    - [Exception::Class](http://search.cpan.org/perldoc?Exception::Class)
    - [Modern::Perl](http://search.cpan.org/perldoc?Modern::Perl)
    - Roles ([See here](http://www.modernperlbooks.com/mt/2009/04/the-why-of-perl-roles.html))
    - [Module::Build](http://search.cpan.org/perldoc?Module::Build)
    - [autodie](http://search.cpan.org/perldoc?autodie) !!!
    - [Devel::Declare](http://search.cpan.org/perldoc?Devel::Declare)
    - [MooseX::Declare](http://search.cpan.org/perldoc?MooseX::Declare)
    - [Devel::NYTProf](http://search.cpan.org/perldoc?Devel::NYTProf)
    - [Perl::Critic](http://search.cpan.org/perldoc?Perl::Critic)
    - [MooseX::Multimethods](http://search.cpan.org/perldoc?MooseX::Multimethods)
  - What's missing?
    - Single installable tarball
    - Easy-to-use GUI programming
    - non-Lovecreaftian XS replacement
    - make taint less all-or-nothing
    - Support policy
    - ponie
  - [perl5i](http://search.cpan.org/perldoc?perl5i) autoincludes some of these things
  - [Book!](http://github.com/chromatic/modern_perl_book/)
----
    I <3 Email    This was rjbs' talk on sending email. He's done a few of these before; I know that Email hates the living is on Google Video. This was less about the standards of email, and more about how to get everything working. Mostly just module namedropping, but very awesome!    Sending Email in the past: [MIME::Lite](http://search.cpan.org/perldoc?MIME::Lite), [Mail::Send](http://search.cpan.org/perldoc?Mail::Send), [Mail::Sender](http://search.cpan.org/perldoc?Mail::Sender), [Mail::Sendmail](http://search.cpan.org/perldoc?Mail::Sendmail), [Mail::Mailer](http://search.cpan.org/perldoc?Mail::Mailer), [Email::Send](http://search.cpan.org/perldoc?Email::Send)    [Email::Sender](http://search.cpan.org/perldoc?Email::Sender) The future! [Eail::Sender::Simple](http://search.cpan.org/perldoc?Eail::Sender::Simple) for most of us Email::Sender::Transport::* is excellent; allows you to easily create new transports for email. Already exist:
    - Sendmail
    - SMTP
    - Persistent SMTP
    - Maildir
    - Mbox
    - DevNull
    - Print
    - Test
    - SQLite    Programmable failure means you can wrap any transport and make it fail under any conditions (great for testing) structured failure, partial success [Email::MIME::Kit](http://search.cpan.org/perldoc?Email::MIME::Kit) <-- most excellent [SWAK](http://search.cpan.org/perldoc?SWAK) [EMK::Assembler::Markdown](http://search.cpan.org/perldoc?EMK::Assembler::Markdown) Very, very cool stuff.    This is the kind of thing that makes email work on par with things like Perl based webapps. I'd say that Perl based webapps are mostly a solved problem. Yes we have more elegant ways to do things, but there is very little arcana involved. This makes email like that.    As a side note, I was trying to install the module (I never did get it working) and after the talk I showed rjbs the error log and when he looked at the terminal he said, "Oh, you're fREW!" So that was cool. I felt a little famous!    I've now shaken hands with rjbs, Steven Little, mst, castaway, Larry Wall, and more!
----
    Business Process Management with Workflow.pm    This talk educated me about the idea of Workflow management in general. It wasn't extremely exciting, but I can't imagine a case in which it would be. He had some code, he had some concrete examples, but it's really just kindav a boring topic. But I still think the idea and the module could be extremely useful at $work. Here is a summary that I think is worthwhile.
    - Benefits
      - Fully document your business process
      - Can keep business rules separate from tools
      - Automate some parts
      - Can discover the state of any work in the system (reporting)
      - Can expose parts to external systems (including other companies)
    - Components
      - Model (Map, Business Process)
      - Workflow Engine
      - Workflow Client
      - Workflow API: Descripe the Workflow
      - Workflow API: Act on incendents
      - Reporting
    - Model
    - Business process described in a config or model
    - Also called workflow or map
    - Determines how incedents (tasks, processes) move from step to step
    - These are your business rules    And basically the rest of the talk was specifics. Boring to take notes on, but good ideas. Workflows are basically state machines, and documenting that stuff can really simplify or even change your business model. The slides for this would be great. He has a lot of info about how, for example, most of your time will be spent figuring out undocumented business practices. The code will be easy after that.
----
    Driving a USB Rocket Launcher from Perl in User Space    This was way cool! He shot [a toy rocket](http://www.thinkgeek.com/geektoys/warfare/8a0f/) with perl! Slides are a must for this, but I don't see them yet.
----
    What Haskell did to my brain    This one was alright. I expected more revelations, but that may have been unreasonable for a 50 minute talk. A lot of his talk boiled down to: be immutable, and stop worrying about performance.
----
    Catching a ::Std - Standardisation and best practices in the perl community    This was mst's talk that was a segue into the Enlightened Perl Extended Core. It was very similar to chromatics talk in a lot of ways. Here are some major points.
      - What is a standard? Spec, Multiple Implementations, One Way
      - TMTOWTDI BSCIAGTT (bicarbonate) (but sometimes consistency is a good thing though)
      - Four types of standards:
        - Inferred standards
        - invented standards
        - enforced standards
        - evolved standards
      - Perl is an inferred standard
      - TCP/IP is invented; awesome
      - IMAP is invented; zomg terrible but it works mostly
      - Java is enforced; JCP (requires $$$, sketch)
      - POSIX is evolved
      - LSB is evolved
      - Scheme is evolved
      - Perl6 is
        - inferred from perl5
        - invented by larry
        - enforced by standard grammar and test suite
        - evolved based on implementation attempts
      - "best practices"
      - Class::Std: "your code caught a Std!"
      - STD in french is MST. lawlz
      - Socially Transmitted Disease, aka Cargo Culting, but gone good.
      - Enlightened Perl Extended Core
        - what do the experts use?
        - One Good Way (not Only)
      - beware the cargo cult
      - the first few plugins that get written become the template
      - The principles for Std community based creation are a good thing.    Maybe you could call this kind of thing whirlpool standardization? I don't know. Notes were hard to take in this one as it wasn't very concrete. The slides will be up for sure, but without video they may not be very helpful. We'll see!
----
    The EPO Extended Core    Basically the name says it all. There are a lot of bad modules in the core and a lot of good ones that are not in the core. These should not be **added** to the core, but instead added to a list of things that are known to be good. It already exists! It just has a weird name: [Task::Kensho](http://search.cpan.org/perldoc?Task::Kensho). Check it out! Use it! Give feedback!
----
    I almost didn't go to this one because my brain was so full. I'm glad I did though!    CHI: Unified caching for Perl
        - Generic caching for perl
        - you can cache all kinds of stuff
          - Templates
          - MVC stuff
          - Sessions
          - ORMs
          - Code Processing
          - Startup Performance things like Moose
        - Lots of backend drivers
          - Memory
          - file fastmmap
          - memcached
          - dbi
          - bdb
          - cachecache
        - super simple to write more drivers
        - avoiding miss stampedes
          - soln 1: probabilistic expiration (expires_variance) so instead of everything expiring at once, one thing probably will expire first
          - soln 2: busy locks
        - avoiding recomputation latency
          - soln 1: background recomputation which manually recomputes value over given time (not done)
          - soln 2: externally initiated recomp (ping the server regularly)
        - Multilevel caches
          - L1 cache in memory and everything else can be in a server or something.
          - Mirrored caches
----
    And I think that's it. This summary is huge! Why did I do this?! Sadly, I have to leave tomorrow at 4am for a flight to another trip that I booked on accident. I probably won't post again until **next** Monday as I'll be at a "regular" vacation :-) If I do though it will probably be reactions to some of the stuff I thought about here.
