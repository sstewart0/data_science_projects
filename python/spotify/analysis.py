# Images
from __future__ import print_function
from PIL import Image
from io import BytesIO

# Web-scraping
from bs4 import BeautifulSoup
import requests

# OS
import os

# Data
import pandas as pd
import datetime
import json

# Strings
import re

# Numpy
import numpy as np

# Plotting
import matplotlib.pyplot as plt

# Read streaming history(sh) json files into a pandas dataframe
path_to_json = './MyData/'
json_files = [sh for sh in os.listdir(path_to_json) if sh.startswith('StreamingHistory')]

streaming_history = pd.DataFrame(columns=['endTime', 'artistName', 'trackName', 'msPlayed'])

for js in json_files:
    with open(os.path.join(path_to_json, js)) as json_file:
        json_text = pd.read_json(json_file)
        streaming_history = pd.concat([streaming_history, json_text])

streaming_history['endTime'] = pd.to_datetime(streaming_history['endTime'])


def get_top_songs(data):
    grouped_df = data[['trackName', 'msPlayed', 'artistName']].groupby(['trackName', 'artistName'])
    df = pd.DataFrame({'count': grouped_df.size(),
                       'total_ms_played': grouped_df.agg({'msPlayed': 'sum'})['msPlayed']}
                      ).reset_index()
    return df.sort_values('total_ms_played', ascending=False)


"""# Test get top songs
print(get_top_songs(streaming_history).head(5))"""


def get_top_artists(data):
    grouped_df = data.groupby(['artistName'])
    df = pd.DataFrame(
        dict(
            total_ms_played=grouped_df.agg({'msPlayed': 'sum'})['msPlayed']
        )
    ).reset_index()
    df['total_ms_played'] = df['total_ms_played'].apply(lambda x: datetime.timedelta(milliseconds=x))
    df.columns = ['artist', 'time_played']
    return df.sort_values('time_played', ascending=False)


"""# Test top artists
print(get_top_artists(streaming_history).head(20))"""


def get_genius_url_format(track_name, artist_name):
    if '(' in track_name:
        song, feature = track_name.split(' (')
        words = ('feat.', 'with')
        if not feature.startswith(words):
            collabs = re.sub('[^A-Za-z0-9]+', ' ', feature)
            a = '-'.join(c for c in collabs.split(' '))
            a = a[:-1]
            index = a.rfind('-')
            artists = a[:index] + '-And' + a[index:]
        else:
            artists = artist_name.replace(' ', '-')
    else:
        song = track_name
        artists = artist_name.replace(' ', '-')

    song = re.sub('[^A-Za-z0-9]+', '-', song)
    return artists + '-' + song


"""# Test get_genius_url_format
print(streaming_history[['trackName','artistName']].head(40))
print(streaming_history[['trackName','artistName']].head(40).
      apply(lambda x: get_genius_url_format(x[0],x[1]), axis=1))"""


# Get song artwork
def get_genius_image(entry):
    artistName, trackName = entry[1], entry[2]
    url = 'https://genius.com/' + get_genius_url_format(trackName, artistName) + '-lyrics'
    page = requests.get(url)
    soup = BeautifulSoup(page.text, features="html.parser")
    images = soup.findAll('img')
    image_src = images[0]['src']
    response = requests.get(image_src)
    return Image.open(BytesIO(response.content))


"""# Test get image
x = 0
for index, row in streaming_history.iterrows():
    get_genius_image(row).show()
    x += 1
    if x == 5:
        break"""


def get_song_genre(entry):
    artistName, trackName = entry[1], entry[2]
    song = get_genius_url_format(trackName, artistName)
    google_search = 'https://www.google.com/search?q=' + song + '-genre'
    page = requests.get(google_search)
    soup = BeautifulSoup(page.text, features='html.parser')
    text = soup.find_all(text=True)
    indx = text.index('Genre')
    genre = text[indx + 1]
    return genre


"""
# Test get song genre:
x = 0
for index, row in streaming_history.iterrows():
    print(get_song_genre(row))
    x += 1
    if x == 10:
        break"""


def get_day_data(data):
    dates = data['endTime'].apply(lambda x: datetime.datetime.date(x))
    unique_dates = dates.unique()
    dates_as_weekdays = np.array([datetime.datetime.weekday(x) for x in unique_dates])
    day_count = {}
    for day in dates_as_weekdays:
        if day in day_count.keys():
            day_count[day] += 1
        else:
            day_count[day] = 1
    count = np.array([c for c in day_count.values()])
    data['endTime'] = data['endTime'].apply(lambda x: datetime.datetime.weekday(x))
    grouped_by_day = data.groupby(['endTime'])
    day_data = pd.DataFrame(dict(
        total_ms_played=grouped_by_day.agg({'msPlayed': 'sum'})['msPlayed']
    )).reset_index()
    day_data['count'] = count
    day_data['avg_minutes_played'] = round(day_data['total_ms_played'] / (60000 * day_data['count']), 2)
    return day_data


def get_hour(time):
    return int(str(time).split(':')[0])

BINS = {i:0 for i in range(0,24)}

# average of
def get_time_data(data):
    data['endTime'] = data['endTime'].apply(lambda x: datetime.datetime.time(x))
    data['endTime'] = data['endTime'].apply(lambda x: get_hour(x))
    data['msPlayed'] = pd.to_numeric(data['msPlayed'])
    grouped_by_time = data.groupby(['endTime'])
    time_data = pd.DataFrame(dict(
        total_ms_played=grouped_by_time.agg({'msPlayed':'sum'})['msPlayed']
    )).reset_index()
    return time_data

print(get_time_data(streaming_history))


times = np.array([
    "00:00-01:00","01:00-02:00","02:00-03:00","03:00-04:00","04:00-05:00","05:00-06:00",
    "06:00-07:00","07:00-08:00","08:00-09:00","09:00-10:00","10:00-11:00","11:00-12:00",
    "12:00-13:00","13:00-14:00","14:00-15:00","15:00-16:00","16:00-17:00","17:00-18:00",
    "18:00-19:00","19:00-20:00","20:00-21:00","21:00-22:00","22:00-23:00","23:00-00:00"
])

def plot_time_data(data):
    hour_data = get_time_data(data)
    hours = np.array([count for count in hour_data.values()])
    x = np.arange(len(hours))
    fig, ax = plt.subplots()
    plot = ax.bar(x, hours)
    ax.set_ylabel('Count')
    ax.set_title('Times')
    ax.set_xticks(x)
    ax.set_xticklabels(times)
    fig.tight_layout()
    plt.xticks(rotation=90)
    plt.show()


#print(plot_time_data(streaming_history))

# def get_artist_picture(artist):


"""times = data['endTime'].apply(lambda t: datetime.datetime.time(t))
    hours = [get_hour(t) for t in times]
    msPlayed = data['msPlayed'].to_list()
    hour_data = pd.DataFrame(list(zip(hours, msPlayed)), columns=['hour', 'msPlayed'])

    for index, hour in hour_data.iterrows():
        BINS[hour[0]] += hour[1]

    return BINS"""