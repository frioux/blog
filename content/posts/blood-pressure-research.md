---
title: Blood Pressure Research
date: 2016-09-01T07:48:38
tags: [meta, egocentric, self, health]
guid: A9033BD6-60D0-11E6-9225-F99DF0F5D69D
---
My doctor recently told me I probably have some high blood pressure issues.
That may or may not be the case, because apparently isolated measurements are
not to be trusted, but I did a bunch of research anyway, because that's my deal.

<!--more-->

I have been measured with high blood pressure before.  The last time my personal
doctor (in Texas) told me that it was because I was out of some other meds and that was
causing high blood pressure.  He also told me at that time the general cause for
high blood pressure.  Here's how it went:

> Dr: Do you know the number one cause of high blood pressure?

> Me: Uhh, stress?

> Dr: No, genetics.  Do you know the number two cause?

> Me: Is it stress?

> Dr: No, genetics.  Number three?

> Me: Genetics?

> Dr: You got it!

He went on to tell me that generally speaking, if you have high blood pressure,
you need medicine, because you got it from your parents.

When I was recently told that I had high blood pressure it was from a new
doctor, because I have moved to California, he asked if I was careful to
moderate my salt intake. I was taken aback.  Everything I've read and heard for
the past five years has been that salt is not the evil killer that [New York
City would have you
believe](http://www.nytimes.com/2016/02/25/nyregion/salt-new-york-city-can-require-sodium-warnings-judge-rules.html).

So I decided to do more research.  Before I go further let me quickly describe
how we model blood pressure.  It's two numbers (the maximum pressure of your
blood called systolic and the minimum pressure called diastolic) that are
measured in mmHg, which is a measurement of pressure.  You don't care about the
unit because you don't really care to correlate it to tire pressure or the
pressure of the atmosphere, so just pretend they are weird numbers. For some
crazy reason they are typically rendered as a fraction, though they are not a
fraction at all, they are just a pair of numbers.  You want the numbers to be
90-119 and 60-79, respectively.  If either number is above or below those
ranges, you could be in for trouble.  Of course if you are 120 / 80, you're only
barely high, but still, that's considered high.  Medication is usually
considered if you are up to 140 / 90 (so +20 or +10.)

[The salt article I'd read in the past was published by Scientific
American](http://www.scientificamerican.com/article/its-time-to-end-the-war-on-salt/).
It's fundamental claim was from a study done by the US Department of Health that
says you could lower each number by about 1 mmHg by lowering your sodium intake.
So let's put that in perspective: if your blood pressure is 140 / 90 and you cut
out salt, at best you'll go down to about 138.9 / 89.4.  Your food will taste bad
and you will not be in the "good range."

My doctor told me to lose weight, exercise, and cut out salt; so I decided to
research these (and other non-medical remedies) in the two weeks he gave me to
measure my BP every morning to see if it's a real issue.

Here's what I found.

### A brief note about averages

In the software engineering world averages are considered misleading.  You can
go to a webpage and the average time of the page can be 100 milliseconds, but if
the 75th percentile is 1 second, a quarter of requests (or users depending on
the reason for the decrease in speed) are ten times slower.  On top of that, the
whole idea of averages assumes that the data is Gaussian, or in layman terms, it
follows a bell curve.  Not a lot of things in real life are actually Gaussian,
so a simple average and standard deviation is not enough information to be
helpful.  A lot of the information presented below is based on averages.  Some
of them give nice box plots that even show the non-Gaussian data, but for the
most part assume that the data I am presenting is from such lossy sources.

## Diet

There have been a couple well cited studies on a diet that should help with high
blood pressure.  The first one ([Dietary Approaches to Stop Hypertension
(DASH)](https://biolincc.nhlbi.nih.gov/studies/dash/)) basically studied adding
a lot of fruits, vegetables, and low-fat dairy to your diet, and significantly
reducing dessert foods.  The results were a reduction of 5.5 and 3.0,
respectively.  So assuming you started at 140 / 90, now you're at 134.5 / 87.

The other diet study ([Dietary Approaches to Stop Hypertension Diet and Reduced
Sodium Intake
(DASH-Sodium)](http://onlinelibrary.wiley.com/doi/10.1111/j.1524-6175.2004.03523.x/full))
basically tests DASH with and without salt.  This study is much harder for me to
read and give a summary of, because it tracks a lot of axes.  The gist is if
your BP is really high, you can do better (as much as 6mmHg reduction) but if
it's not really high, you won't do as well (maybe 3mmHg.)  They measured 140
dropping to 136 and 129 dropping to 125.

## Exercise

There was a study done on doing both DASH and exercising ([Effects of
Comprehensive Lifestyle Modification on Blood Pressure Control
(PREMIER)](https://jama.jamanetwork.com/article.aspx?articleid=1357324).)  This
study basically said that in six months of exercise, you could go from 136 / 85 to
126 / 79.  If you did the exercise and DASH they found 135 / 84 to 124 / 78.  So to be
clear, exercise: -10/-6, exercise+diet: -11/-8.  They discussed in the paper
that it's typical for this stuff to not be additive and that you tend to hit
diminishing returns.

## Stress

This is a fun interlude just because it's hilarious to me. [An article from
the American Heart
association](http://www.heart.org/HEARTORG/Conditions/HighBloodPressure/PreventionTreatmentofHighBloodPressure/Stress-and-Blood-Pressure_UCM_301883_Article.jsp)
has this to say about stress:

> Although stress is not a confirmed risk factor for either high blood
> pressure or heart disease, and has not been proven to cause heart
> disease, scientists continue to study how stress relates to our
> health.
>
> [ ... ]
>
> Although stress does not clearly cause heart disease, it can play a
> role in general wellness.

SO YOU'RE SAYING THERE'S A CHANCE!

This is all fine and dandy, but if I care about a thing I want to do the things
that matter.  I have two children now and do not see any way to reduce stress,
other than going back to work (Thanks ZipRecruiter for the awesome paid
paternity!) which is sorta a silly way to reduce stress.

## Weight Loss

A long term study on the correlation between BMI and BP was done in [Overweight
and Obesity as Determinants of Cardiovascular Risk (The Framingham
Experience)](http://archinte.jamanetwork.com/article.aspx?articleid=212796).
The paper doesn't really correlate weight loss with BP reduction like I would
like, but instead correlates BMI (effectively weight) with likelihood of having
hypertension (high BP.)  So obese (BMI ≥ 30) increases risk of high BP by nearly
30% and overweight (BMI ≥ 25) by nearly 20%.  That's great, but it really gives
me very little concrete to work with.  I would love to and plan to lose some
weight, but I can't really give concrete examples of reductions.

## Alcohol Reduction

A meta-analysis ([Effects of Alcohol Reduction on Blood
Pressure](http://hyper.ahajournals.org/content/38/5/1112.full)) found that
reduction of alcohol consumption could reduce BP by -6.3mmHg and -6.0mmHg
respectively.  Unfortunately, like some of the salt stuff, this assumes that you
are drinking 3-6 drinks a day.  I have read that in the US a drink counts as 1
beer, 5 oz wine, or 1 1/2 oz 80 proof spirits.  I do not drink 3-6 of those a
day.  I could and maybe will reduce from 2 drink units a day to 1, but the study
didn't seem to go into that much detail.

## Potassium Increase

The World Health organization did a sprawling search to find correlations of
Salt and Potassium intake and Blood Pressure.  It's super long ([PDF, see
section 3.8, table 3.53 for
results](http://apps.who.int/iris/bitstream/10665/79331/1/9789241504881_eng.pdf).)
If I'm reading it correctly, an increase of potassium could decrease BP by 1 to
5.  Unlike salt, which pervades everything, I have no problem adding a banana to
breakfast, so while this is fairly modest change, it's super easy to do.

---

Over the course of researching and editing this blog post I have faithfully
measured my blood pressure every morning.  I am not in the danger zone that my
doctor thought I was in, but my diastolic number could go down a super small
amount and I'd be in the clear.  After the research of everything above I have
basically gotten into the habit of having a banana in oatmeal for breakfast,
exercising six times a week (jogging and 7 minute working alternating days with
a break on sunday,) vaguely trying to lose weight, and eat lots of fruits and
veggies.

I should probably put more effort into losing weight, which would mean recording
everything I eat, trying to stay under a certain caloric intake, etc, but it's a
lot of work and I'm trying to get the other changes down first.

I hope you found this research informative and maybe even helpful for you.  I'm
not a doctor and I don't typically read these kinds of research papers, so
feel free to correct any of my interpretations.
