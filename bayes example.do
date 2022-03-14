* Some complications of two-way tables. 

* First, note that, when we write probabilities, we use the notation p(A | B) to
* mean the probability of A _given_ B, i.e., the probability of A once we know B.
* For example, p(rolling a five) is 1/6 for a fair die, but p(five | face is odd)
* is 1/3 since there are only three possible faces. I know that this can be 
* confusing because the straight-line operator also means "or" in Stata. 

* Example 1. 
/* First, I want to show you that, although two-way tables can never really give
"wrong" information, even if the percentages are flipped, they can still be hard
to interpret and require some real finesse if you do so.

Let's look at unions and race. Let's suppose that we are interested in the question
of whether which racial group, using the modified-but-still-imperfect GSS groups,
has the highest degree of union-friendliess or at least propensity to join a 
union. */ 

use ./modified_data/gssbetterrace, clear
tab union
gen unionfam = (union<4) & ~missing(union)
label define unionfam1 0 "non-union" 1 "union fam"
label values unionfam unionfam1
tab union unionfam
tab racenew unionfam, col
	/* OK, so, here we see that it *is* true that whites are the majority of
	union members. But, let's notice something. The conditional probability of
	union members being white is p(white | union) = 73.94. But what is the 
	marginal probability of being white? p(white) = 72.4. So, looking at an 
	isolated conditional probability is misleading without comparing it to the
	baseline probability or marginal probability (another tactic might be to
	compare p(white | union) to p(white | non-union) or some other conditional
	probability that's not the marginal but can serve as a "reference point"). 
	This is especially true if you are working with a conditional probability 
	that is presumably not causal (union status does not cause race) because 
	you're already taking what is usually implied to be a causal relationship 
	and making it merely predictive, which is already a bit
	counterintuitive (much like regressing mom's education on child's). 
	
	It's *always* a good idea to examine marginal probabilities in using a two-
	way table, but I just wanted to note that it is especially important.
	
	Now, as I mentioned above, it *is* true that this table is technically not
	misleading. For example, the race group most likely to be unionized in this
	sample is Black workers. Technically speaking, in this table, if we compare
	p(Black | union) to p(Black), although p(Back | union) is very small, it is
	higher than the marginal probability of being Black. This is a *necessary
	consequence* -- proof here in footnotes 
	https://tinyurl.com/twowaytablefinerpoint -- of the fact that, if we had
	the percentages going the way that makes more sense, it is immediately
	obvious that Black workers are actually most likely to be union. */
tab racenew unionfam, row

* Example 2. 
/* Here's a classic example of a problem that basically reduces to "don't confuse
inverse conditional probabilities. I've slightly modified the numbers from a
very famous study. It's a little more complicated, but it's interesting and may 
be useful -- you may have heard of this study before. In a paper, Britta Anderson 
and her colleagues (2013 in the J. Grad. Med. Ed.) used the following simplified
vignette to query medical residents in the US. By the way, this example is NOT
intended to pick on medical professionals; it's just a striking and often-cited
study, and a fun example of how statistics can matter IRL. My strong guess is that
most doctors, in practice, don't let a shaky grasp of some finer points of two-
way tables get in the way of their excellent work. 

	<< Ten out of every 1,000 women have breast cancer. Of these 10 women with  
	breast cancer, 9 test positive. Of the 990 women without cancer, about 91  
	nevertheless test positive (the test has a false positive rate of roughly 
	9.2 percent). A woman tests positive and wants to know whether she has breast 
	cancer for sure, or at least what the chances are. What is the answer? >>

About 26 percent of residents surveyed get this correct; the most common wrong
answer was one form or another of "90 percent". 

This is a mistake that stems from two problems: 1) the confusion of the 
sensitivity of the test p(+test | cancer), which is very high, with 
p(cancer | +test), the thing that we want to find; and, 2) the confusion of 
a low false positive rate p(+test | no cancer) with the conditional 
probability p(cancer | +test).  

Let's see this in Stata. */ 

clear all
set obs 1000 // Let's use 1000 observations
gen n = _n // we need this as an index
gen cancer = n <10 // We first make 9 of the 10 cancer-having individuals.
label define carcinogen 0 "no cancer" 1 "cancer"
label values cancer carcinogen
gen test = n <101 // We'll stipulate that 100/1000 (ten percent) test positive.
label define testing 0 "negative" 1 "positive"
label values test testing
replace cancer =1 if n ==101
* Let's randomize these and then examine some observations
gen sortorder = runiform()
sort sortorder
gen ID = _n 
	// now let's make an ID variable that's independent of the assignment of 
	// treatment and control above
drop n // and get rid of the original ID var
list ID cancer test in 1/100

/* Now, let's calculate row conditional probabilities. Here, we find the prob. 
of testing positive given your various cancer statuses. Notably, this makes it
seem as though a positive test very likely means that you have cancer! Only 10
percent of people who don't have cancer test positive.*/ 

tab cancer test, row

/* But, this is a specific case of conditioning on the wrong thing. We want to 
think about conditioning instead on what we know: that you tested positive for 
cancer. We can do that by conditioning on test status. Here, it is clearer that,
conditional having a positive cancer test, your probability of cancer ...
... p(cancer | +test) = nine percent. */ 

tab cancer test, col

/* This example is a little more confusing because it's not immediately clear 
why the first way to think about it is wrong. One way to see this is that while
it is true that only a small percentage of cancer-free people test positive, 
there is no reason that it shouldn't be any particular person (assuming that
false positives are randomly-distributed). So, it is improbable for any specific
person to test positive if they are cancer free, but -someone- has to be one of
the false positives, right? One way to think about it is to assume that all of
these people are tested at the same hospital. If you were an oncologist at the
hospital, you should *not* look at a woman's chart and say "ah! the probability 
of her testing positive if she's cancer-free is only 10 percent! panic!" And that
would be counterintuitive *from that standpoint*. Instead, you'd say "OK, well, 
we get 100 positive tests a day and 91 are false positives. No big deal. The false
positives have to come from somewhere. It was unlikely to be any specific person,
because positive tests are rare overall, but given that you have a positive test,
you still probably don't have cancer". */ 

/* Example 3. 
Here's a little analogy that might help, which I often use. Suppose that we turn
to a happier subject, excellence in women's sports. What's the probability of any
woman athlete being a top-ten percent basketball player in high school?  
Obviously, it's 10 percent. We can actually just re-label the items in the 
cancer example to show this. We'll let "positive test" be "top tier HS athlete" 
and "has cancer" turn into a happier rarity, being a WNBA player. */ 

gen topHSplayer = test
label define hsp 0 "not top tier" 1 "top tier"
label values topHSplayer hsp

gen WNBA = cancer
label define wnba 0 "not in league" 1 "pro athlete"
label values WNBA wnba

tab WNBA topHSplayer, row

/* Now, what's the probability, conditional on your not-being in the WNBA, of
still having-been a top-tier athlete? 

Technically that is a very low probability as well: 9.19 percent. That said, it
would still clearly be unwise to conclude, if someone says "Back in HS, I could 
throw a basketball over those mountains", that they are probably currently in the
WNBA. This is a bit more intuitive because it's familiar: there's not a lot of
great amateur athletes out there, but that still doesn't mean that any hotshot
at the pickup game is, was, or will be a pro. You can picture it like pouring
rocks through two filters, the first one with small holes and the second with
tiny holes, above a tub that is almost-perfectly sealed.

Yes, it's unlikely for any particular rock to get through the first
filter, and yes almost no rocks get into the tub without going through either 
sieve, but that says nothing about whether rocks that get through the first
filter can easily get through a second filter.

And, once again, we see that no matter which way you calculate the two-way table,
there is no "wrong" way to do it, just a confusing way.*/  

tab WNBA topHSplayer, col

/* For example, this column conditional probability does correctly indicate that 
being a great HS basketball player does, in fact, makes you *relatively* much 
more likely to play in the pros -- about nine times more probable, if we want
to be really exact! However, in these epidemiological and life-course settings, 
people are often more interested in the absolute p(x) and interested in their 
own outcome rather than in how unlikely it is for anyone to be in their shoes.
So, instead of saying "well, p(+test | cancer) is much higher than 
p(+test | no cancer)" or "it is unlikely for anyone to be a great HS basketball
player", they want to know "is p(cancer | +test) something I should worry about"
and "do I have a chance to play pro ball if I am really good at HS ball". In this
case, the answers to the first and second sets of questions are different. */ 
