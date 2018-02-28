---
title: Reflections on Ng's Machine Learning
date: 2018-02-27T22:32:19
tags: [ machine-learning, mooc, coursera ]
guid: 452bd58a-425d-46fb-9dfb-d37bd5a1244b
---
I recently took [Andrew Ng's Machine Learning class on Coursera][ml]; here were my
takeaways.

[ml]: https://www.coursera.org/learn/machine-learning/home/welcome

<!--more-->

Before I get into this I want to point out that I am not at all a machine
learning person.  I took this class in part because someone I know said that a
big part of the future of the Computer Science industry is in machine learning
and I didn't know anything about machine learning.  Someone else, who I think
has pretty good insight, said I took the class to be able to call BS when I need
to.

## Statistics Based / Logical Thinking

I think possibly the most generally useful takeaway I got from this class is a
concrete understanding of some statistical mistakes and logical fallacies.  A
common mistake is to [invent hypotheses based on
data](https://www.buzzfeed.com/stephaniemlee/brian-wansink-cornell-p-hacking),
instead of before seeing the data.  As my statistics teacher in college put it,
you shoot the side of a barn and then draw a circle around it; this does not
make you a good shot.

In machine learning these mistakes are easy to make on accident, and the outcome
is not simply bad science or being branded a charlatan; the model just does not
work as well, because once you give it data it's never seen it is likely to be
incorrect.

In machine learning you end up segregating your data such that you train against
one set, pick training parameters based on another set, and finally check that
the first two sets yielded a sufficiently general model with a final set.  I'll
get into this more later, but from what I understand, this is not exactly
simple in practice.

## Machine Learning

If I show you some machine learning results, they will look like magic.  Even
knowing how they work, they are still somehow magic.  During this class I
implemented code that recognized handwritten digits; that's pretty magical!

All of the machine learning in this course is basically predicated on linear
regression or logistic regression.  Linear regression is when you draw a line
(maybe straight, maybe not) based on some points.  The idea is that in your
space you want to be able to predict one variable based on a bunch of other
ones.  If you think of the handwriting example, each pixel is a variable and you
want to know the value is a 1, 2, 3, etc.  It's more complicated than that, but
bear with me.

Most of the stuff you learn is how to use gradient descent in different
situations.  The basic idea of gradient descent is, if you knew how well your
current predictor is working, you could make a little tweak, see it get better
or worse, and repeat to find the best predictor.  I'm leaving out all the
terminology here because I'm not trying to teach you, dear reader, machine
learning, but I do think that a high level grasp of what this type of machine
learning is doing is worth something.

To give a touch more detail, gradient descent actually uses partial derivatives
(which is the rate of change with respect to whatever value you are optimizing;
to be concreate, you could imagine that you could do this for each pixel in the
image recognition example before, a bunch of times.)  The derivative allows the
gradient descent to actually make smaller tweaks as the derivative gets smaller.
Eventually the derivative is zero, which means you are done.  In some situations
this will mean you have found the absolute best predictor for your problem
domain.  More likely you have found one of many local optimums, though Ng says
basically that you shouldn't worry too much about this.

I think that the above is actually pretty straightforward.  It makes sense to me
and there was basically no magic to it, though I didn't do the derivations
myself because I don't remember Calculus that well.  On the other hand,
*literally the techniques above were used for Neural Networks*.

What I mean by that is that we literally took the derivative of the neural
network to use gradient descent to try to find the optimum neural network for a
given problem.  I couldn't have done the derivative myself, but it was
definitely the same tooling I'd written for earlier parts of the class.

Neural networks sound big and impressive.  They definitely yield impressive
results.  They are built to look like how the neurons in our brains work.  What
they really are is gigantic linear equations.  Basically the neural network has
the inputs (the pixels above, or whatever) and each of those inputs has a
mapping to the next layer.  The mapping is *just multiplying constants*.  Each
layer is built of multiple neurons, and the neuron just combines *all* of the
neurons from the prior layer via addition and multiplication.

The above probably sounds like gibberish if you don't know what a neural network
is, and that's fine, I'm still not trying to teach you machine learning, but the
take away is that neural networks are actually not very powerful computationally
speaking, despite being incredibly powerful and useful.  In college we learned
about the various classes of automata.  I remember learning about finite state
machines, pushdown automata, and finally Turing machines.  **A neural network is
not even a finite state machine.**

Presumably you could wire the outputs of a later layer to an earlier layer to
build a finite state machine, or something far more advanced, but we can
recognize this handwriting without going that route.  Neural networks are
incredibly useful and yet they have no conception of loops or state.

## Machine Learning and Work

At [work](https://www.ziprecruiter.com/hiring/technology) we have quite a bit of
machine learning throughout our product.  A little over halfway through this
class I had some conversations with members of one of the teams that uses
machine learning, and I attended a deep dive into how that team does work.

The first thing that I noticed was that there is an incredible breadth of
tooling and details in this field.  Every single member of the team in question
used different tools which have different methods of building their models.

On top of this breadth, the level of abstraction in the machine learning field
is astounding.  The simile that I've been using is that Ng's Machine Learning is
like assembly, and what most people do at work is an Object Relational Mapper.
They are so stratospherically distinct that they are nearly unrelated.  On the
other hand, I did have intuition regarding the higher level tools that confirms
the value of learning the foundations.

## The Really Hard Part

Unfortunately, while learning about neural networks and gradient descent is a
lot of fun, the real difficulty often comes with acquiring data and making it
useful.  While I did successfully implement a hand written digit recognizer, I
did not have to get thousands of samples.  I didn't have to normalize the data
such that the numbers were close in size and location in the samples.

And that's just for simple data like two dimensional handwriting.  Extracting
features from samples was barely discussed in this class and is critical for
successfully applying machine learning.

I mentioned before that partitioning the data for validating the model is
difficult in practice.  Consider that you are Amazon and you do some machine
learning based on what ads a customer sees and what they end up buying.  While
you might be able to take customers who have a `1` as the last digit of their
customer id, you may end up accidentally leaking data back and forth as human
individuals recreate accounts or use multiple accounts of whatever reason.  If,
instead, you take the easier approach of using a slice of time (for example the
current month of data) as your validation subset, you are running similar risks
where not only is the data partially *based on* the other data, but may not even
be comparable (is February comparable to the rest of the year, or all time?
Surely it depends on the business.)

---

I'm glad that I took this class; I have no idea how much machine learning will
end up being a part of my career, but being able understand what people are
saying always has value.  This class has sparked an interest in learning more
statistics, so I will dive into that before taking more machine learning
classes.

---

If you want to learn more, I have heard good things about
<a target="_blank" href="https://www.amazon.com/gp/product/0262035618/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0262035618&linkCode=as2&tag=afoolishmanif-20&linkId=32b4ad10682973b74d32d58c0e4a58df">Deep Learning</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0262035618" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I actually originally intended to read that instead of taking this class, but
the class was great and I may still read the book.

I mentioned that I want to learn statistics better.  I picked up
<a target="_blank" href="https://www.amazon.com/gp/product/1491907339/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1491907339&linkCode=as2&tag=afoolishmanif-20&linkId=e75af251c9c64933fde1ea5cfdc8f98a">Think Stats</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1491907339" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and expect that reading that will help me feel more comfortable with statistics.
I also got a bunch of other stats books but I'll share them by and by.
