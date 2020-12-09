import fuzzy
import unidecode
import re

"""
Distance metrics tell you how similar two strings are based on substitutions, deletions, and insertions. 
But those algorithms don't really tell you anything about how similar the strings are as words in a human language.

Consider, for example, the words "smith," "smythe," and "smote". I can go from "smythe" to "smith" in two steps:
smythe -> smithe -> smith

And from "smote" to "smith" in two steps:
smote -> smite -> smith

So the two have the same distance as strings, but as words, they're significantly different. If somebody told you 
(spoken language) that he was looking for "Symthe College," you'd almost certainly say, "Oh, I think you mean Smith." 
But if somebody said "Smote College," you wouldn't have any idea what he was talking about.

What you need is a phonetic algorithm like Soundex or Metaphone. Basically, those algorithms break a word down into 
phonemes and create a representation of how the word is pronounced in spoken language. You can then compare the result 
against a known list of words to find a match. This method is much faster and more accurate.

Soundex and (Double) Metaphone are phonetic algorithms for ENGLISH names/words. There also exists:

Daitch–Mokotoff Soundex: A refinement of the Soundex algorithm designed to allow greater accuracy in matching of 
Slavic and Yiddish surnames with similar pronunciation but differences in spelling.

Cologne phonetics:The Cologne phonetics is related to the well known Soundex phonetic algorithm but is optimized 
to match the German language.

The final method (3) calculates how many letters the team in hand has with each team in the league.

All of these are fast so can be employed to "work together".
"""

bundesliga_teams = [
    "1. FC Köln",
    "1899 Hoffenheim",
    "Bayer Leverkusen",
    "Bayern Munich",
    "Borussia Dortmund",
    "Borussia Mönchengladbach",
    "Eintracht Frankfurt",
    "FC Augsburg",
    "Hamburger SV",
    "Hannover 96",
    "Hertha BSC",
    "Mainz 05",
    "RB Leipzig",
    "SC Freiburg",
    "Schalke 04",
    "VfB Stuttgart",
    "VfL Wolfsburg",
    "Werder Bremen"]

# Name to compare
name = 'Bayern Muenchen' # Will work for methods 1&2

# Remove accents from football team names
cleaned = [unidecode.unidecode(w) for w in bundesliga_teams]

# Remove numbers:
cleaned = [''.join([i for i in word if not i.isdigit()]) for word in cleaned]

# Remove special characters (&spaces)
cleaned = [" ".join(re.findall(r"[a-zA-Z0-9]+", k)) for k in cleaned]

print("Cleaned data = ", cleaned)

# FEATURE 1: Soundex (phonetic algorithm which assigns to words a sequence of digits, the phonetic code)

# Number of digits to use in the sequence:
N = 4
# Create dictionary of teams and their corresponding soundex values
soundex = fuzzy.Soundex(N)

# Soundex value of name
soundex_name = soundex(name)

corpus = {b:soundex(b) for b in cleaned}

print("Soundex Corpus = ")
for x in corpus.keys():
    print("{x} : {y}".format(x=x,y=corpus[x]))

# Does our name match?
for sx in corpus.keys():
    if soundex_name == corpus[sx]:
        print('`{n}` matches `{x}` in corpus with soundex value `{k}`'.format(
            n=name,x=sx,k=soundex_name)
        )


# FEATURE 2: Double Metaphone (phonetc algorithm: suitable for use with most English words, not just names)
dmeta = fuzzy.DMetaphone()
corpus2 = {b:dmeta(b) for b in cleaned}

print("Metaphone Corpus = ")
for x in corpus.keys():
    print("{x} : {y}".format(x=x,y=corpus2[x]))

# Dmetaphone value of name
dmeta_name = dmeta(name)

# Does our name match?
for dm in corpus2.keys():
    if dmeta_name == corpus2[dm]:
        print('`{n}` matches `{x}` in corpus with soundex value `{k}`'.format(
            n=name,x=dm,k=dmeta_name)
        )

# Feature 3: Count number of characters
# team1 is the name we are trying to find the match for
# METRIC SCORE: lower the score the better;
# Awards strings for the number of characters matching & having fewer letters leftover

def count_chars(team1, team2):
    all_letters = set(l for l in team1).union(set(l for l in team2))
    score = 0

    # Count all occurances of each letter
    team1_count = {letter: team1.count(letter) for letter in team1}
    team2_count = {letter: team2.count(letter) for letter in team2}

    # Get the differences
    for l in all_letters:
        # Credit the string for containing the correct number of occurances
        if (l in team1_count.keys()) and (l in team2_count.keys()):
            res = team1_count[l] - team2_count[l]
            if res >= 0:
                score += res
        elif l in team1_count.keys():
            # Discredit for not having the right letters
            score += team1_count[l]
        else:
            # Discredit for having too many of the wrong letters
            score += team2_count[l]

    return score

new_name = 'B Munich' # This name will not match using phonetics, so I use it here:

# Apply function to all words
results = {clean_word: count_chars(new_name, clean_word) for clean_word in cleaned}

sorted_results = {k: v for k, v in sorted(results.items(), key=lambda item: item[1])}

print("TEAM : SCORES (Lowest = Best)")
for x in sorted_results.keys():
    print("{x} : {y}".format(x=x,y=sorted_results[x]))

minimum = list(sorted_results.keys())[0]

# A combination of these 3 methods (and more) would work best

print("{x} has minimum score of {s}".format(x=minimum,s=sorted_results[minimum]))
