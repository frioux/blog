---
title: Open Source Infrastructure and DBIx::Class Diagnostics Improvements
date: 2016-08-01T07:40:11
tags: [perl, guest, dbix-class, dbix-class-helpers, open-source, catalyst, moo, moose, cpan, axel]
guid: 553F8870-54EA-11E6-B585-CD882DB049C7
---
Many people know that [Peter Rabbitson has been wrapping up his time with
DBIx::Class](http://lists.scsys.co.uk/pipermail/dbix-class/2015-December/012125.html)
after his [attempt to get funding for working on it didn't work
out](https://www.tilt.com/tilts/year-of-ribasushi-help-him-focus-on-cpan-for-2016/comments/CMTE1601B878F7343E7B05BB89BB81D4650).
I have long had some scraps of notes on a post about that whole situation and
how troubling it is but I could just never make it happen.  The following is the
[gigantic commit
message](https://github.com/dbsrgits/dbix-class/commit/1cf609901) of the merge
of a large chunk of his work.  I offered to host it since I think that it should
actually get read. I have left it almost completely unchanged, except to make
things proper links.  More thoughts after the post.

<!--more-->

---

# Merge the ResultSource diagnostics rework

> ...And this is what the products that we make do:
> these are the consequences. They either empower
> people, or they steal bits of their lives.
> Because experiences are all we have in life:
> if you think about them as grains of sand in an
> hour glass, once those grains are gone – they are
> gone. And experiences with people and experiences
> with things: they use up the same grains.
>
> That's why we have a profound responsibility to
> respect the experiences of the people that we
> build for...

[Aral Balkan: Free is a Lie TNW 2014](https://youtu.be/upu0gwGi4FE?t=1548)

This set of commits is unusual - the 2+kloc of changes (in lib/ alone) do not
add any new runtime functionality, nor do these changes alter significantly any
aspect of DBIC's runtime operation. Instead this is [a culmination of a nearly 4
months long
death-march](https://gist.github.com/ribasushi/6ea33c921927c7571f02e5c8b09688ef)
ensuring the increasingly complex and more frequent (courtesy of rising use of
Moo(se)) failure modes can be reasoned about and acted upon by ordinary users,
without the need to reach out to a support channel.

The changeset has been extensively tested against 247 downstream CPAN dists
(as described at the end of commit [12e7015](https://github.com/dbsrgits/dbix-class/commit/12e7015aa9372aeaf1aaa7e125b8ac8da216deb5)) and against several darkpan
test suites. As of this merge there are no known issues except [RT#114440](https://rt.cpan.org/Ticket/Display.html?id=114440#txn-1627249)
and a number of dists (enumerated in [12e7015](https://github.com/dbsrgits/dbix-class/commit/12e7015aa9372aeaf1aaa7e125b8ac8da216deb5)) now emitting *REALLY LOUD*
though warranted and actionable, diagnostic messages.

The diagnostic is emitted directly on STDERR - this was a deliberate choice
designed to:

 1. prevent various test suites from failing due to unexpected warnings

 2. make the warnings *harder* to silence by a well meaning but often too
    eager-yet-not-sufficiently-dilligent staffer, before the warnings had
    a chance to reach a senior developer


What follows is a little bit of gory technical details on the commit series,
as the work is both generic/interesting enough to be applied to other large
scale systems, and is "clever" enough to not be easily reasoned about without
a summary. Think of this as a blog post within an unusual medium ;)


## Background

Some necessary history: DBIC as a project is
[rather](http://static.spanner.org/lists/cdbi/2005/07/25/90c9f5f1.html)
[old](http://lists.digitalcraftsmen.net/pipermail/classdbi/2005-August/000039.html).
When it got started Moose wasn't a thing. Neither (for perspective) was jQuery
or even Tw(i)tt(e)r. The software it was modeled on (Class::DBI) has
"single-level" metadata: you have one class per table, and columns/accessor were
defined on that class and that was it. At the time mst made the brilliant
decision to keep the original class-based API (so that the CDBI test suite can
be reused almost verbatim, see
[ea2e61b](https://github.com/dbsrgits/dbix-class/commit/ea2e61bf5bb7187dc5e56513cd66c272d71d5074))
while at the same time moving the metadata to a "metaclass instance" of sorts.
The way this worked was for each level of:

- Individual Result Class (class itself, not instance)
- Result Class attached to a Schema class
- Result Class attached to a Schema instance

to have a separate copy-on-the-spot created metadata instance object of
DBIx::Class::ResultSource. One can easily see this by executing:

```
~/dbic_checkout$ perl -Ilib -It/lib -MDBICTest -MData::Dumper -e '
  my $s = DBICTest->init_schema;
  $Data::Dumper::Maxdepth = 1;
  warn Dumper [
    DBICTest::Schema::Artist->result_source_instance,
    DBICTest::Schema->source("Artist"),
    $s->source("Artist"),
  ]
'
```

The technique (and ingenious design) worked great. The downside was that nobody
ever really audited the entire stack past the original implementation.  The
codebase grew, and mistakes started to seep in: sometimes modifications
(`add_columns`, etc) would happen on a derivative metadata instance, while the
getters would still be invoked on the "parent" (which at this point was
oblivious of its "child" existence, and vice versa). In addition there was a
weird accessor split: given a result instance one could reach *different*
metadata instances via either `result_source()` or `result_source_instance()`.
To add insult to the injury the latter method is never defined anywhere, and was
always dynamically brought to life at runtime [via an accessor maker call on
each individual
class](https://metacpan.org/source/RIBASUSHI/DBIx-Class-0.082840/lib/DBIx/Class/ResultSourceProxy/Table.pm#L17-21).

If that weren't bad enough, some (but crucially *not* all) routines used to
manipulate resultsource metadata [were proxied to the main Result
classes](https://metacpan.org/source/RIBASUSHI/DBIx-Class-0.082840/lib/DBIx/Class/ResultSourceProxy.pm#L53-87),
also aiming at allowing the reuse of the existing Class::DBI test suite, and to
provide a more familiar environment to Class::DBI converts. The complete map of
current metadata manipulation methods and their visibility from a typical
ResultClass can be seen at the end of commit message
[28ef946](https://github.com/dbsrgits/dbix-class/commit/28ef9468343a356954f0e4dc6bba1b834a8b3c3c).

The downside was that to an outsider it would seem only natural that if in
order to make something metadata-related happen, one normally calls:

```
SomeResultClass->set_primary_key
```

then it makes sense that one should be able to override it via:

```
sub SomeResultClass::set_primary_key {
  my $ret = shift->next::method(@_);
  { do extra stuff }
}
```

That thinking has been applied to pretty much all straight-pass-through getters
in the wild, with the expectation that DBIC will respect them throughout, [like
e.g.](https://metacpan.org/source/VANSTYN/RapidApp-1.2000/lib/RapidApp/DBIC/Component/VirtualColumnsExt.pm#L52-67).
In reality this never happened - half of DBIC would never even look at the
Result class and instead simply called the needed method on the result source
instance directly. As noted in
[28ef946](https://github.com/dbsrgits/dbix-class/commit/28ef9468343a356954f0e4dc6bba1b834a8b3c3c):
the overwhelmingly common practice is to hook a method in a Result class and to
"hope for the best". A rare example of "doing it right" would be
[DBIx::Class::ResultSource::MultipleTableInheritance](https://metacpan.org/pod/DBIx::Class::ResultSource::MultipleTableInheritance#SYNOPSIS),
but as can be seen from its SYNOPSIS the API is rather counterintuitive (what is
`table_class()` anyway?!) and more importantly - the earlier example seems "just
right".


Another innovation (remember: pre-Moose) was the use of the [just-in-time
implemented](https://twitter.com/hashtag/dammitstevan) alternative [C3 method
resolution order (MRO)](https://en.wikipedia.org/wiki/C3_linearization) right on
top of the default perl DFS MRO. While DBIC used multiple inheritance (MI) from
the start, [with
all](https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem)
[the
corresponding](http://static.spanner.org/lists/cdbi/2005/07/25/caf44f84.html)
[problems](http://static.spanner.org/lists/cdbi/2005/07/26/e593c147.html) and
[non-scalable
"solutions"](http://static.spanner.org/lists/cdbi/2005/07/26/ea509a6a.html), it
wasn't until C3 MRO became available that the true potential of the resulting
plugin system became clear. To this day (mid-2016) MI, as used within the DBIC
ecosystem, remains the single most flexible (and thus superior given the problem
domain) plugin-system on CPAN, easily surpassing rigid delegation, and having an
upper hand on role-based solutions as promoted by the Moo(se) ecosystem. It must
be noted that delegation and/or roles are not without uses - they are an
excellent (and frankly should be a default) choice for many application-level
systems. It is the mid-level to low-level libraries like DBIC, where the
stateless nature of a predictable yet non-coordinated call-order resolution
truly begins to shine.


## Problem(s)

Things stayed undisturbed for a while, until around 2012~2013 folks started
showing up with more and more complaints which all traced to Moo(se)-based
subclassing. Originally the C3 MRO composition worked just fine, because almost
invariably a `->load_components()` call (which explicitly switches the callER
MRO) would have happened early enough in the life of any end-user
Result/ResultSource class. But when `extends()`/`with()` got more prominent this
was lost. The more complex the inheritance chain - the more likely that the
topmost leaf class is in fact stuck under DFS mro with everything going sideways
from there. Sometimes with [truly mindbending failure
cases](/posts/mros-and-you/).  There was no clear solution at the time, and
aside from [some toothless documentation
warnings](https://metacpan.org/pod/DBIx::Class::ResultSet#ResultSet-subclassing-with-Moose-and-similar-constructor-providers) nothing was done to
address this (in fact even [the doc-patch itself is incomplete](https://github.com/dbsrgits/dbix-class/pull/49#issuecomment-47637403).)

The inconsistencies, and the resulting mistakes, however, were all localized,
and even though the problems were often major, each instance was sufficiently
different (and bizarre) that each individual deployment could neither report
them properly, nor find the time to reason through the layers of history in
order to arrive at a solution they fully understand. Yet the original design
which solidified towards the end of 2007 was *just* good enough to keep being
kicked down the road.

But people kept writing more and more MOP-inspired stuff. Given the general
tendency of perl code to get "all over the place", the desire was only natural
to standardize on "one true way" of doing OO throughout an entire end-user
project/app.  And there were more and more ways in the wild to combine/abstract
individual Result classes and ResultSet components. [The comprehensive
DBIx::Class::Helpers](https://metacpan.org/release/DBIx-Class-Helpers) are just
the tip of the heap of all possible permutations DBIC is exposed to. Towards
mid-2015 it became utterly untenable to brush off problems with "meh, just don't
do that and all will be be fine".

On the personal front I first ran into the baroque jenga tower head-on when I
tried to make sense of the ResultSource subsystem in an airport lounge
pre-YAPC::EU 2011 (Riga). I honestly do not remember *why* I started digging in
this direction but the result of that attempt (and the later effort to revive
it) got immortalized in [my local tree](/static/img/A3acsCD.png). Enough
said.

Next was the dash to implement sane relationship resolution semantics in
[03f6d1f](https://github.com/dbsrgits/dbix-class/commit/03f6d1f7b65051799423237e9401689c1b43ad95),
and then in
[350e8d5](https://github.com/dbsrgits/dbix-class/commit/350e8d57bf21e4006e2a5e5c26648cb5ca4903ea)
(which was actually needed to allow for
[d0cefd9](https://github.com/dbsrgits/dbix-class/commit/d0cefd99a98e7fb2304fe6a5182d321fe7c551fc)
to take place... sigh). During that journey
[4006691](https://github.com/dbsrgits/dbix-class/commit/4006691d207a6c257012c4b9a07d674b211349b0)
made a subtle but fatal in the long run change - it upset the balance of which
source instance object we looked at during *some* (but not all) codepaths. The
really sad part is that I had the feeling that something is not right, and even
made a record of it as the last paragraph of
[350e8d5](https://github.com/dbsrgits/dbix-class/commit/350e8d57bf21e4006e2a5e5c26648cb5ca4903ea).
But light testing did not reveal anything, and I irresponsibly shipped
everything as-is a bit later. It wasn't until Oct 2015 that [someone noticed
this being an actual
problem](https://rt.cpan.org/Ticket/Display.html?id=107462). Early attempts to
fix it quickly demonstrated just how deep the rabbit hole goes, and were the
main reason the entirety of this work was undertaken: the accumulated debt
simply did not leave any room for a half-way solution :/


## Solution(s)

The writeup below describes only the final set of commits: it does not cover
driving into and backing out of at least 3 dead-ends, nor does it cover the
5 distinct rewrites and re-shuffles of the entire stack as more and more
involved testing revealed more and more involved failure modes. I must stress
that if you plan to undertake a similar crusade against another projects
architectural debt you are in for a rough (but *not* impossible!) ride. The
height of the "tenacity-bar" necessary to pull off such work is not reflected
in any way within the seemingly effortless walkthrough that follows. It is
also worth acknowledging that the code at times is incredibly terse and hard
to follow: this was a deliberate choice as the extra diagnostic sites that
are enabled during runtime had to be implemented as "close to the VM", so to
speak, as possible. In isolation none of the contortions are warranted, but
because I ended up with so many of them the result does pay off. See comments
within individual commit messages for various performance impacts for more
info.


As first order of business some mechanism was needed to track the logical
relationship between the 3 levels of ResultSource instances as shown earlier in
this writeup. Luckily, the user-unfriendly nature of the metadata stack meant
there are very few spots on CPAN (and to the best of my knowledge on DarkPAN)
that do anything exotic with the subsystem. This means the simplest thing would
in fact work and was implemented as [534aff6](https://github.com/dbsrgits/dbix-class/commit/534aff612dee17fe18831e445d464d942c27c172): corral all instantiations of
ResultSource objects ([and Schema objects while we are at
it](https://github.com/dbsrgits/dbix-class/blob/534aff61/lib/DBIx/Class/_Util.pm#L1082-L1135).)
This code ensured that nothing in the stack will create an instance of either
class-type without our knowledge. With that in place, [we also provide an
explicit clone
method](https://github.com/dbsrgits/dbix-class/blob/534aff61/lib/DBIx/Class/ResultSource.pm#L160-L184)
encouraging folks to use that whenever possible. The switch of all relevant
callsites within DBIC itself was [verified through another check within
new](https://github.com/dbsrgits/dbix-class/blob/534aff61/lib/DBIx/Class/ResultSource.pm#L126-L143),
guarded by the same compile-time assertion constant (which in turn was provided
by both the CI and the local smoke-script from [5b87fc0](https://github.com/dbsrgits/dbix-class/commit/5b87fc0f74c6f7de9d4b544ef31104fac7b2a5a9))


With the above in place, ensuring 99.99% of the ResultSource "derivative"
instances were obtained via `$rsrc->clone`, it was time for [0ff3368](https://github.com/dbsrgits/dbix-class/commit/0ff3368690783358903b3689a1a96ef21271f825). A simple
private registry hash with object addresses as keys and this hash as values:

```
{
  derivatives => {
    addr_derived_rsrc_1 => $reference_to_infohash_of_derived_rsrc_1,
    addr_derived_rsrc_2 => $reference_to_infohash_of_derived_rsrc_2,
    ...
  },
  weakref => $weak_reference_of_self,
}
```

As necessary for any structure holding addresses of object references, a CLONE
"renumbering" routine takes care of keeping everything in sync on iThread spawns
(if you believe that iThreads are evil and one shouldn't go through the trouble:
be reminded that any call of `fork()` within a Win32 perl is effectively an
iThread, and `fork()` can and *is* [being called by some CPAN
modules](http://grep.cpan.me/?q=my+%5C%24pid%3D+fork+dist%3DXML-Twig)
implicitly).


Now that we had a good handle on "what came from where", the first major
diagnostic milestone
[73f54e2](https://github.com/dbsrgits/dbix-class/commit/73f54e275e7dc98b4a082475ff252afdbeca182f)
could be covered. As can be seen in the table of methods in commit
[28ef946](https://github.com/dbsrgits/dbix-class/commit/28ef9468343a356954f0e4dc6bba1b834a8b3c3c)
there are only a handful of attributes on an actual ResultSource class. A couple
new Class::Accessor::Grouped method types were added, which would behave just
like the 'simple' and 'component_class' they were replacing, but with a twist:

 - any setter-based change would record its callsite in any derivative that was
   being tracked by
   [0ff3368](https://github.com/dbsrgits/dbix-class/commit/0ff3368690783358903b3689a1a96ef21271f825),
   effectively [marking that derivative
   stale](https://github.com/dbsrgits/dbix-class/blob/73f54e27/lib/DBIx/Class/ResultSource.pm#L286-L310)
 - any getter call would consult its own entry in the metadata instance "stale
   log", and [complain that things have moved on based on the
   callsite](https://github.com/dbsrgits/dbix-class/blob/73f54e27/lib/DBIx/Class/ResultSource.pm#L320-L323)
   the setter left earlier

The result is the exact warning as described in commit message [73f54e2](https://github.com/dbsrgits/dbix-class/commit/73f54e275e7dc98b4a082475ff252afdbeca182f). Of
course there are some extra considerations - some high-level setters (e.g.
remove_columns) do call a getter underneath to do their job. These cases had to
be short-circuited by using a local()-based "setter callstack" mark. But in
general the changeset has been surprisingly non-invasive: once the proper hook
points were identified the rest was a breeze. There was also a brief scratching
of heads when the last stages of DarkPAN tests emitted errors which I myself
could not explain for a while, until the reason (and trivial solution) were
identified in [d56e05c](https://github.com/dbsrgits/dbix-class/commit/d56e05c74844b8b22f4f66e378b6ef992045a7b5) and [here](https://github.com/ctrlo/GADS/pull/9/files).


As a brief detour, I considered switching ResultSource to a proper Moo class,
but quickly abandoned this idea as there are no provision for clean get-time
triggers. Nevertheless the attempt was a useful demonstration what does it
take to switch a low-level class (which means many somewhat questionable uses
by consumers in the wild) to Moo(se) with zero loss of functionality. The
result is preserved for posterity as
[8ae83f0e](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-Historic.git;a=commitdiff;h=8ae83f0e).


While working on the above and
[f064a2a](https://github.com/dbsrgits/dbix-class/commit/f064a2abb15858bb39a141ad50391d4191988d2c)
(the solution to
[RT#107462](https://rt.cpan.org/Ticket/Display.html?id=107462)), it occurred to
me that the confusion of having both `result_source_instance()` and
`result_source()` can be reduced further by forcing all "getter" calls to go
through `result_source()` which is defined in Row.pm and is thus always
available. The result was the improved diagnostic as described in the commit
message of
[e570488](https://github.com/dbsrgits/dbix-class/commit/e570488ade8f327f47dd3318db3443a348d561d6),
but also [a useful set of assertions that were used to weed out many of the
wrinkles](https://github.com/dbsrgits/dbix-class/blob/e570488a/t/lib/DBICTest/BaseSchema.pm#L379-L528).


The next major step was to resolve once and for all the fallout from incorrect
inheritance composition. The highly dynamic nature of all Perl's programs, an
"eternal compile/execute/compile/execute... cycle", meant that just "fixing
things" as DBIC sees them would not work - calling `set_mro()` could do little
when called late enough. This led to the revert of the originally-promising
"forced c3-fication" of the stack
[7648acb](https://github.com/dbsrgits/dbix-class/commit/7648acb5dd1f2f281ca84e2152efe314bcbf2c70).
Instead the practical design turned out to be "let the user know and carry on".

The first part of getting there was to devise a way to precisely and very
quickly tell "what does a class look like right now?" I have been brooding over
how to do this since mid-February, but it wasn't until I noticed the excellent
[App::Isa::Splain](https://metacpan.org/pod/App::Isa::Splain#SYNOPSIS) by
[@kentfredric](https://github.com/kentfredric), that the final interface came into focus: [296248c](https://github.com/dbsrgits/dbix-class/commit/296248c321e75da7fd912ed80b8644aa3cdcccd6) (with several
minor fixups later on). Here I want to take a moment to apologize to
[@kentfredric](https://github.com/kentfredric), as he was [led on a several week long wild-goose chase due to a
misguided comment of
mine](https://github.com/kentnl/Devel-Isa-Explainer/issues/1#issuecomment-212248379)
:(

Amusingly while implementing this I hit a wall related to perl 5.8 (for the
first time in 6+ years): As stated in the timings at the end of commit message
[296248c](https://github.com/dbsrgits/dbix-class/commit/296248c321e75da7fd912ed80b8644aa3cdcccd6)
and as elaborated
[here](https://github.com/dbsrgits/dbix-class/blob/12e7015a/lib/DBIx/Class/Schema/SanityChecker.pm#L92-L102)
- the non-core MRO is just too expensive to work with. This resulted in a 1.5
week long detour to try to squeeze every last ounce of performance. Amusingly I
ran into a lot of
["interesting"](https://twitter.com/ribasushi/status/753678208076242944) [stuff
along](https://github.com/dbsrgits/dbix-class/commit/296248c3#diff-c13797cc2e5864c4a1d6a92ba65871b6R801)
[the
way](https://github.com/dbsrgits/dbix-class/commit/296248c3#diff-c13797cc2e5864c4a1d6a92ba65871b6R801).
The result was not only a semi-usable 5.8 implementation, but even running on
5.10+ was sped up about 2 times in the end, which translated into tangible gains
in the end: the number cited as 16% in
[12e7015](https://github.com/dbsrgits/dbix-class/commit/12e7015aa9372aeaf1aaa7e125b8ac8da216deb5)
was originally 28%(!). The moral of this story? -
[gerontoperlia](https://youtu.be/2Ln0YHtKgaI?t=3731) makes your modern
foundation code better.

With a reliable way to tell what each methods "variant stack" looks like, it was
trivial to implement the `valid_c3_composition` part of `::SanityChecker` - one
would simply check a class' MRO, and [in case of `dfs` compare all stacks to
what they would look like if the MRO were
`c3`](https://github.com/dbsrgits/dbix-class/blob/12e7015a/lib/DBIx/Class/Schema/SanityChecker.pm#L484-L505).

In parallel but unrelated to the above the ever increasing tightening of various
DBIC internal callpaths
([e505369](https://github.com/dbsrgits/dbix-class/commit/e50536940adf2ebaef907a0c29ae37fbd5ce95b1),
[d99f2db](https://github.com/dbsrgits/dbix-class/commit/d99f2db7432d90469c7b860a865e0c32f1611cec),
[3b02022](https://github.com/dbsrgits/dbix-class/commit/3b0202245e84a09a41ac31a13b80547a300a227e))
had to be addressed in some way. The urgency truly "hit home" when testing
revealed
[RT#114440](https://rt.cpan.org/Ticket/Display.html?id=114440#txn-1627249) - it
was nothing short of a miracle this code survived that long without being
utterly broken by other components. The solution came out of crossing the work
on `describe_class_methods`
([296248c](https://github.com/dbsrgits/dbix-class/commit/296248c321e75da7fd912ed80b8644aa3cdcccd6))
with the concept of the `fail_on_internal_call` guard
([77c3a5d](https://github.com/dbsrgits/dbix-class/commit/77c3a5dca478801246ff728f80a0c5013e57f4a2)).
We already have a list of method "shadowing stacks" (to borrow [@kentfredric](https://github.com/kentfredric)'s
terminology) - if we find a way to annotate methods in a way that we can tell
when a "non-overrideable" method was in fact overridden - we will be able to
report this to the user.

The somewhat fallen out of favor subsystem of function attributes was chosen
to carry out the "annotation" task. It must be noted that this is one of the
few uses of attributes on CPAN that is architecturally consistent with how
attributes were originally implemented. An attribute is meant to attach to
a specific reference ( in our case a code reference ), instead of a name.
This is also why the FETCH/MODIFY_type_ATTRIBUTE API operates strictly with
references. As an illustration why tracking attributes by name is fraught
with peril consider the following:

```
perl -e '
  use Data::Dumper;
  use Moose;
  use MooseX::MethodAttributes;

  sub somemethod :Method_expected_to_always_returns_true { return 1 };

  around somemethod => sub { return 0 };

  warn Dumper {
    attributes => __PACKAGE__->meta->get_method("somemethod")->attributes,
    result => __PACKAGE__->somemethod
  };
'
```

It should also be noted that as of this merge describe_class_methods lacks
a mechanism to "see" code references captured by around-type modifiers, and
by extension the "around-ed" function's attributes will not appear in the
"shadowed stack". A future modification of Class::Method::Modifiers, allowing
minimal introspection of what was done to which coderef should alleviate most
of this problem.

Once all relevant methods were tagged with a `DBIC_method_is_indirect_sugar`
attribute in
[1b822bd](https://github.com/dbsrgits/dbix-class/commit/1b822bd3e15476666e97d9a95754f123410b3c56),
it was trivial to implement the schema sanity check
`no_indirect_method_overrides` which simply [ensures no user-provided method
"shadows" a superclass method with the `sugar` attribute
set](https://github.com/dbsrgits/dbix-class/blob/12e7015a/lib/DBIx/Class/Schema/SanityChecker.pm#L359-L394).


The success of the attribute-based approach prompted a pass of annotating
all the methods DBIC generates for one reason or another: [09d8fb4](https://github.com/dbsrgits/dbix-class/commit/09d8fb4a05e6cd025924cc08e41484f17a116695). Aside
from enabling the last improvement, it also allowed to replicate a part of
the DBIx::Class::IntrospectableM2M functionality in core, without elevating
the status of the m2m sugar methods in any way (the historic labeling of
these helpers as relationships is a long standing source of confusion). See
the commit message of [09d8fb4](https://github.com/dbsrgits/dbix-class/commit/09d8fb4a05e6cd025924cc08e41484f17a116695) for a couple use-cases.


The last piece of the puzzle
[28ef946](https://github.com/dbsrgits/dbix-class/commit/28ef9468343a356954f0e4dc6bba1b834a8b3c3c)
addressed the "override and hope for the best" duality of ResultSource proxied
methods as described at [the start of this
writeup](https://github.com/dbsrgits/dbix-class/blob/28ef9468/lib/DBIx/Class/MethodAttributes.pm#L242-L298).
What we essentially do is [add an
`around()`](https://github.com/dbsrgits/dbix-class/blob/28ef9468/lib/DBIx/Class/ResultSourceProxy.pm#L137-L333)
for every method in ResultSource, which then checks whether it was called via
ResultSourceProxy (inherited from DBIx::Class::Core), or directly via the
ResultSource instance: i.e. `MySchema::Result::Foo->proxied` vs `$rsrc->proxied`
IFF we are called directly and there *is* an override of the same method on the
currently-used `$rsrc->result_class` we either [follow one of the options as
given by an attribute
annotation](https://github.com/dbsrgits/dbix-class/blob/28ef9468/lib/DBIx/Class/MethodAttributes.pm#L242-L298),
or we emit a diag message so that the user can do something about it.

That was easy wasn't it?

## Final Thoughts

This work took about 50 person-days to carry out, and for obvious reasons
expanded to cover a much larger period of actual wall-time. While I am by far
not the most efficient developer that I have met, I am pretty sure that the
process of planning, designing, implementing and testing all of this could not
have been significantly accelerated. Even at the (laughable) rate of $50/h The
Perl Foundation is [willing to pay for unique
talent](http://news.perlfoundation.org/2016/02/grant-proposal-perl-6-performa.html#comment-38362169)
this endeavor would cost at least $20,000 USD - way beyond the scope (and aim?)
of a TPF grant. On the other hand it would be surprising if this work can be
qualified as unnecessary. I personally estimate that the savings due to the
proper diagnostics alone will "make up" for the effort within the first month of
wide deployment of these improvements. Time will tell of course, as the stream
of questions is only about to start come the first days of August.

In any case - this project is by far not the only one in dire need of such
"humane" overhaul. Moo, Catalyst, various pieces of the toolchain, and other
staples of what is known as "modern perl5" are in similar or worse shape: a
situation which can *not* be rectified simply by "writing patches" without a
concerted effort directed by a [single dedicated
individual](http://queue.acm.org/detail.cfm?id=2349257 ).

I yet again strongly urge the "powers of Perl" to reconsider their hands-off
approach to funding the consistently shrinking pool of maintainers. *PLEASE*
consider stealing (in the spirit of tradition) the proven successful model of
[RubyTogether](https://rubytogether.org/roadmap) before you end up losing even
more maintainers like myself.

Peter "ribasushi" Rabbitson

Outgoing maintainer of a cornerstone Perl5 ecosystem project

---

Here are a few takeaways from the post from my perspective.

### Volunteer Burnout

People get burned out all the time.  The causes are myriad: not enough rest,
depression, unrewarding work, etc.  I feel like OSS and volunteers in general
get burnt out for more specific reasons.

First off, they aren't getting paid, so they tend to be doing this OSS *in their
rest time.*  ribasushi tried to resolve this, but companies who use OSS were
unable, unwilling, or too out-of-touch to fund him in his efforts.

Second, I think that people who are volunteering get an unreasonable amount of
responsibility put on their shoulders. This is internal: feeling guilty for not
fixing a bug or whatever. (I know ribasushi suffer's from this.) And ashamedly,
external: when people point the finger and demand work.  I have seen this happen
within the Perl community and am disgusted that someone would demand a gift like
this.  Luckily for the individual, I didn't save the link in my notes.  (Ask me
privately and I may relay the story; I recall it, and it's public, but don't
think it's worth the effort to preserve the event in infamy.)

### OSS Infrastructure is Not Solved

Open Source is *great* for scratching your own itch.  I consider my body of work
to be a testament to this.  In general, most of my own effort is small bits of
effort that pay off well for me, and maybe a few other people.  I think this is
often why OSS software is often hastily put together.  The entire idea is
predicated on [New Jersey Style](https://en.wikipedia.org/wiki/Worse_is_better)
work, of which I am an unashamed believer in.

The problem comes with things that are too complicated to be built this way.  A
webserver is simple.  An ORM that supports many databases as well as DBIx::Class
is not.  I think it is reasonable and unsurprising the the DBIx::Class tarball
is over 4 times as big as Plack.  The problem is that the money for pure OSS
(that is, stuff that is not using a freemium model like Chef or Puppet) is
fairly scant.

The Linux Kernel is funded, but honestly not really, because [the majority of
the contributors are paid to work on it](https://lwn.net/Articles/679289/) for
hardware or software their employers use.  A model where a single individual (or
even a small group) support a piece of software that many companies use does not
seem to be common.  We all know what happened to [OpenSSL in
2014](https://en.wikipedia.org/wiki/Heartbleed), and that is another critical
piece of OSS infrastructure.  There has been some effort to fund it, but given
that it's so foundational compared to DBIx::Class, I just cannot see that model
working for DBIx::Class either.

### Stack Decoration with Attributes

I think this is a really interesting technique and think that it would be an
interesting way to, for example, filter backtraces.  Like it would be nice not
the have Try::Tiny in the middle of all my backtraces; this technique could
resolve that. The current method involves weird regular expressions to filter
packages etc.  Could be cool.

---

I know this has been a long post.  I hope some people read it and consider how
some of these problems can be solved in the long run.  For my part, I bid
ribasushi a fond farewell.  I do not have any problem with how long his work has
taken except that was more time stolen from him to live his life.  If
DBIx::Class does indeed get a new janitor, I wish him or her luck.  These are
big shoes to fill.
