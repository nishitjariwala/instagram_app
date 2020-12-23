import pandas as pd
import numpy as np

import pickle
import sys
from sklearn.feature_extraction.text import TfidfVectorizer
import nltk
from nltk.stem.porter import *
import string
import re
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer as VS
from textstat.textstat import *
from sklearn.linear_model import LogisticRegression
from sklearn.feature_selection import SelectFromModel
from sklearn.metrics import classification_report
from sklearn.svm import LinearSVC
from sklearn.model_selection import StratifiedKFold, GridSearchCV
from sklearn.pipeline import Pipeline

from flask import Flask, jsonify, request
import joblib
import traceback
import sys
import re

def preprocess(text_string):
	"""
	1) remove urls
	2) replace multiple whitespaces with one space
	3) removes mentions

	This allows us to get standardized counts of urls and mentions
	Without caring about specific people mentioned
	"""
	space_pattern = '\s+'
	giant_url_regex = ('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|''[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')
	mention_regex = '@[\w\-]+'
	parsed_text = re.sub(space_pattern, ' ', text_string)
	parsed_text = re.sub(giant_url_regex, '', parsed_text)
	parsed_text = re.sub(mention_regex, '', parsed_text)
	return parsed_text

def tokenize(tweet):
	"""Removes punctuation & excess whitespace, sets to lowercase,
	and stems tweets. Returns a list of stemmed tokens."""
	tweet = " ".join(re.split("[^a-zA-Z]*", tweet.lower())).strip()
	tokens = [stemmer.stem(t) for t in tweet.split()]
	return tokens

def basic_tokenize(tweet):
	"""Same as tokenize but without the stemming"""
	tweet = " ".join(re.split("[^a-zA-Z.,!?]*", tweet.lower())).strip()
	return tweet.split()

def count_twitter_objs(text_string):
	"""
	Accepts a text string and replaces:
	1) urls with URLHERE
	2) multiple whitespaces with one space
	3) mentions with MENTIONHERE
	4) hashtags with HASHTAGHERE

	Returns counts of urls, mentions, and hashtags.
	"""
	space_pattern = '\s+'
	giant_url_regex = ('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|''[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')
	mention_regex = '@[\w\-]+'
	hashtag_regex = '#[\w\-]+'
	parsed_text = re.sub(space_pattern, ' ', text_string)
	parsed_text = re.sub(giant_url_regex, 'URLHERE', parsed_text)
	parsed_text = re.sub(mention_regex, 'MENTIONHERE', parsed_text)
	parsed_text = re.sub(hashtag_regex, 'HASHTAGHERE', parsed_text)
	return(parsed_text.count('URLHERE'),parsed_text.count('MENTIONHERE'),parsed_text.count('HASHTAGHERE'))

def other_features(tweet):
	"""Sentiment scores, Text and Readability scores,
	as well as Twitter specific features"""
	sentiment = sentiment_analyzer.polarity_scores(tweet)
    
	words = preprocess(tweet) #Get text only
    
	syllables = textstat.syllable_count(words)
	num_chars = sum(len(w) for w in words)
	num_chars_total = len(tweet)
	num_terms = len(tweet.split())
	num_words = len(words.split())
	avg_syl = round(float((syllables+0.001))/float(num_words+0.001),4)
	num_unique_terms = len(set(words.split()))

	###Modified FK grade, where avg words per sentence is just num words/1
	FKRA = round(float(0.39 * float(num_words)/1.0) + float(11.8 * avg_syl) - 15.59,1)
	##Modified FRE score, where sentence fixed to 1
	FRE = round(206.835 - 1.015*(float(num_words)/1.0) - (84.6*float(avg_syl)),2)

	twitter_objs = count_twitter_objs(tweet)
	retweet = 0
	if "rt" in words:
		retweet = 1
	features = [FKRA, FRE,syllables, avg_syl, num_chars, num_chars_total, num_terms, num_words,
				num_unique_terms, sentiment['neg'], sentiment['pos'], sentiment['neu'], sentiment['compound'],
				twitter_objs[2], twitter_objs[1],
				twitter_objs[0], retweet]
	#features = pandas.DataFrame(features)
	return features

def get_feature_array(tweets):
	feats=[]
	for t in tweets:
		feats.append(other_features(t))
	return np.array(feats)


app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
	#nltk.download('stopwords')
	nltk.download('averaged_perceptron_tagger')
	model = joblib.load('model.pkl')
	print('Model Loaded')
	vectorizer = joblib.load('vectorizer.pkl')
	print('Vectorizer Loaded')
	pos_vectorizer = joblib.load('pos_vectorizer.pkl')
	print('Pos vectorizer Loaded')
	stemmer = joblib.load('stemmer.pkl')
	print('Stemmer Loaded')
	sentiment_analyzer = joblib.load('sentiment_analyzer.pkl')
	print('Sentiment Analyzer Loaded')
	if model:
		try:
			json_ = request.json
			msg_df = pd.DataFrame(json_)

			stopwords=stopwords = nltk.corpus.stopwords.words("english")

			other_exclusions = ["#ff", "ff", "rt", "hi", "hello"]
			stopwords.extend(other_exclusions)
			
			flg = 0
			for msg in msg_df["tweet"]:
				#print(msg)
				msg = preprocess(msg)
				msg = "".join(re.split("[^a-zA-Z]*", msg.lower())).strip()
				#print(msg)
				words = msg.split()
				#print(words)
				#print(stopwords)
				for word in words:
					if word not in stopwords:
						flg = 1
						break

			if flg == 0:
				print("Caught word")
				return jsonify({'prediction': str(2)})
			else:

				msg_vector = vectorizer.transform(msg_df).toarray()
				msg_tags = []
				for m in msg_df:
					tokens = basic_tokenize(preprocess(m))
					tags = nltk.pos_tag(tokens)
					tag_list = [x[1] for x in tags]
					tag_str = " ".join(tag_list)
					msg_tags.append(tag_str)
				pos = pos_vectorizer.transform(pd.Series(msg_tags)).toarray()
				features = get_feature_array(msg_df)

				x_test = np.concatenate([msg_vector, pos, features], axis=1)
				y_pred = model.predict(x_test)

				return jsonify({'prediction': str(y_pred)})

		except:
			return jsonify({'trace': traceback.format_exc()})
	else:
		print('Train the model first')
		return('No model to use')

if __name__ == '__main__':
	try:
		port = int(sys.argv[1])
	except:
		port = 12345

	model = joblib.load('model.pkl')
	print('Model Loaded')
	vectorizer = joblib.load('vectorizer.pkl')
	print('Vectorizer Loaded')
	pos_vectorizer = joblib.load('pos_vectorizer.pkl')
	print('Pos vectorizer Loaded')
	stemmer = joblib.load('stemmer.pkl')
	print('Stemmer Loaded')
	sentiment_analyzer = joblib.load('sentiment_analyzer.pkl')
	print('Sentiment Analyzer Loaded')
	app.run(host='0.0.0.0',port=port, debug=True)
