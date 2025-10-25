import random
import re
from itertools import product

REPLACE = { letter: str(index) for index, letter in enumerate('oizeasgtb') }

def get_leet_speak(word):
    possibles = []
    for letter in word:
        leet_letter = REPLACE.get(letter, letter)
        possibles.append(leet_letter) 
    return ''.join(possibles)

def pick_two_random_words():
    words = []
    with open('/usr/share/dict/words') as f:
        for line in f:
            words.append(line.strip())

    random_words = []
    for word in random.sample(words, 2):
        cleansed_word = re.sub('\'', '', word)
        random_words.append(cleansed_word.capitalize())

    return random_words

special_characters = ['!', '@', '#', '$']
separators = random.sample(special_characters, 2)
random_words = pick_two_random_words()

password = random_words[0] + separators[0] + get_leet_speak(random_words[1]) + separators[1]

regexp = re.compile(r'^(?=.*[0-9])') # Check for existence of number

if not regexp.search(password):
    password += str(random.randrange(10, 99))

# Add generated password to clipboard
clipboard.fill_clipboard(password)

keyboard.send_keys(password)
