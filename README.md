# Name Generator for gerbil scheme

## What is namegen?

Namegen is a gerbil package for generating random names.

Port of https://github.com/skeeto/fantasyname/ on gerbil scheme.

## Documentation

This is mostly just some thoughts on an elisp name generator. Is it
based on the RinkWorks generator, though none of the syntax is
specifically used, only sexps. Symbols are replaced by a random
selection from its group,

s  syllable
v  single vowel
V  single vowel or vowel combination
c  single consonant
B  single consonant or consonant combination suitable for beginning a word
C  single consonant or consonant combination suitable anywhere in a word
i  an insult
m  a mushy name
M  a mushy name ending
n  a name
a  an adjective
sw a star wars name
D  consonant suited for a stupid person's name
d  syllable suited for a stupid person's name (always begins with a vowel)

Strings are literal and passed in verbatim. If a list is presented,
select one of it's elements of random to be generated.



## Usage & Example

To generate a name beginning with a syllable, then "ith" or a '
followed by a constant, and ending in a vowel sound,

```scheme
    (s ("ith" ("'" C)) V)
```

Just call it with namegen,

```scheme
    (import :namegen/namegen)
    (namegen '(s ("ith" ("'" C)) V))
;; -> undshou.moswae
```
