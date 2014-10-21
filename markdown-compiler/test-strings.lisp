
(defparameter *test-hash-headline*
"   # Will Ye Go Lassie, Go? #

    ## Verse 1 ##
Oh, the summertime is coming
And the trees are sweetly blooming
And the wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

    ## CHORUS ##
And we’ll all go together
To pluck wild mountain thyme
All around the blooming heather
Will ye go lassie, go?

    ## Verse 2 ##
I will build my love a bower
Near yon pure crystal fountain
And on it I will pile
All the flowers of the mountain
Will ye go lassie, go?

CHORUS

    ## Verse 3 ##
If my true love she were gone
I would surely find another
Where wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

CHORUS

    ## Verse 4 ##
Oh, the summertime is coming
And the trees are sweetly blooming
And the wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

CHORUS")

(defparameter *test-dash-and-equal-headlines*
"THIS IS A HEADLINE
------------------
And come tell me Sean O'Farrell tell me why you hurry so
Husha buachaill hush and listen and his cheeks were all a glow
I bare orders from the captain get you ready quick and soon
For the pikes must be together by the rising of the moon

CHORUS
======
    By the rising of the moon, by the rising of the moon
    For the pikes must be together by the rising of the moon

And come tell me Sean O'Farrell where the gath'rin is to be
At the old spot by the river quite well known to you and me
One more word for signal token whistle out the marchin' tune
With your pike upon your shoulder by the rising of the moon

By the rising of the moon, by the rising of the moon
With your pike upon your shoulder by the rising of the moon

Out from many a mud wall cabin eyes were watching through the night
Many a manly heart was beating for the blessed warning light
Murmurs rang along the valleys to the banshees lonely croon
And a thousand pikes were flashing by the rising of the moon

By the rising of the moon, by the rising of the moon
And a thousand pikes were flashing by the rising of the moon

All along that singing river that black mass of men was seen
High above their shining weapons flew their own beloved green
Death to every foe and traitor! Whistle out the marching tune
And hurrah, me boys, for freedom, 'tis the rising of the moon

'Tis the rising of the moon, 'tis the rising of the moon
And hurrah, me boys, for freedom, 'tis the rising of the moon")

(defparameter *test-forced-newlines*
"Her skal der være en tvungen newline:  
Her skal det ikke være en tvungen newline:
Her skal der være en igjen:  ")

(defparameter *test-emphasis*
"Emphasis looks is when you put stars around words, like \\*this\\*.
Escaping the stars with slashes '\\' removes the emphasis.
This is why *this* is emphasised, and \\*this\\* is not.")

(defparameter *test-bold*
"Bolded text is denoted by two underscores: \\_
So __this text is bolded__, and \\__this text is not\\__
Why is this text so __bold?__")

(defparameter *test-cite*
"You can cite things§Citatus55AD§ by using the \\§ characters to enclose a citation§Løtveit2014§.
Citing is very important for any good journal or scientific body of work§CaptObvious2006§.")

(defparameter *test-footnote*
"Footnotes are added by using the currency character.¤It looks like this: '\\¤'¤
I tend to overuse them¤No, really, I do!¤, because I like them too much.")

(defparameter *test-underline*
"You can underline things by using a _single_ underscore. (This character '\\_')
This is useful for emphasis, and making a bit of text stand out more.")

(defparameter *test-cursive*
"Cursive text is made by using the \\/ character. It may make you sound quite /mean/.
/Please be aware that people have used the cursive writing as a means to make snarky passive-aggressive comments about others.
You may want to avoid using it too much to not seem like a meanie./")

(defparameter *test-lists*
"A list of all the flaws in flawedtopia:
  - It's not perfect
  - It's rather not good, to be perfectly frank.
  - Frank didn't even like it.

A list of all the good bits of flawedtopia:
  1. The coffee was rather acceptable.
  1. The tea was not too expensive.
  4. The crumpets were excellent.")

(defparameter *test-escape-parens*
  "Hvis vi skal ha parenteser, må de escapes (ellers blir de tolket som kommandoer/tagger i midtspråket).
Derfor er det viktig at de blir escapet korrekt. \\(\\)")

(defparameter *test-code-blocks*
"Here are some code blocks:
    (defun greet-world ()
        (write-line \"Hello World!\"))
        (greet-world)")

(defparameter *test-quotations*
"> Implying you are a cat
> Implying you aren't just trying to steal my gains")
