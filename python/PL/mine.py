# Web-scraping
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from webdriver_manager.chrome import ChromeDriverManager
import time
import pickle
import pandas as pd

pd.set_option('display.max_columns', 1000)

seasons = {
    '2020_21':
        dict(
            code = 363,
            teams =
            dict(
                Arsenal = 1,
                Aston_Villa = 2,
                Brighton_and_Hove_Albion = 131,
                Burnley = 43,
                Chelsea = 4,
                Crystal_Palace = 6,
                Everton = 7,
                Fulham = 34,
                Leeds_United = 9,
                Leicester_City = 26,
                Liverpool = 10,
                Manchester_City = 11,
                Manchester_United = 12,
                Newcastle_United = 23,
                Sheffield_United = 18,
                Southampton = 20,
                Tottenham_Hotspur = 21,
                West_Bromwich_Albion = 36,
                West_Ham_United = 25,
                Wolverhampton_Wanderers = 38
            )
        )
}

s = {
    '2020_21': 363,
    '2019_20': 274,
    '2018_19': 210,
    '2017_19': 79,
    '2016_17': 54
}

def get_players(team, season, season_code):
    data = {}
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_experimental_option("prefs", {"profile.default_content_settings.cookies": 2})

    browser = webdriver.Chrome('/Users/stephenstewart/.wdm/drivers/chromedriver/mac64/87.0.4280.88/chromedriver',
                               options=chrome_options)

    teams = seasons['2020_21']['teams']

    url = 'https://www.premierleague.com/players?se={s}&cl={n}'.format(s=season_code, n=teams[team])
    browser.get(url)
    time.sleep(4)

    html = browser.page_source
    browser.quit()
    soup = BeautifulSoup(html, 'lxml')

    for a in soup.findAll("a", {"class": "playerName"}):
        data[a.text] = [season, team, a['href']]

    return data

def clean_link(player):
    if player.startswith('//www.'):
        link = 'https://' + player[2:-8] + 'stats'
    else:
        link = 'https://www.premierleague.com' + player[:-8] + 'stats'
    return link

positions = ['goalkeeper', 'defender', 'midfielder', 'forward']

# Goalkeeper stats
goalkeeper_columns = [
    'club','position',
    # General
    'appearances', 'clean sheets', 'wins', 'losses',
    # Goalkeeping
    'saves', 'penalties saved', 'punches', 'high claims',
    'catches', 'sweeper clearances', 'throw outs', 'goal kicks',
    # Defence
    'clean sheets', 'goals conceded', 'errors leading to goal', 'own goals',
    # Discipline
    'yellow cards', 'red cards', 'fouls',
    # Team Play
    'goals', 'assists', 'passes', 'passes per match', 'accurate long balls'
]

# defender stats
defender_columns = [
    'club','position',
    # General
    'appearances', 'goals', 'wins', 'losses',
    # Defence
    'clean sheets','goals conceded','tackles','tackle success %','last man tackles','blocked shots','interceptions',
    'clearances','headed clearance','clearances off line','recoveries','duels won','duels lost','successful 50/50s',
    'aerial battles won','aerial battles lost','own goals','errors leading to goal',
    # Team Play
    'assists', 'passes', 'passes per match', 'big chances created','crosses','cross accuracy %','through balls',
    'accurate long balls',
    # Discipline
    'yellow cards', 'red cards', 'fouls', 'offsides',
    # attack
    'goals','headed goals','goals with right foot','goals with left foot','hit woodwork'
]

# midfielder
midfielder_columns = [
    'club','position',
    'appearances', 'goals', 'wins', 'losses',
    # attack
    'goals','goals per match','headed goals','goals with right foot','goals with left foot',
    'penalties scored','freekicks scored','shots','shots on target','shooting accuracy %','hit woodwork',
    'big chances missed',
    # Team Play
    'assists', 'passes', 'passes per match', 'big chances created','crosses','cross accuracy %','through balls',
    'accurate long balls',
    # Discipline
    'yellow cards', 'red cards', 'fouls', 'offsides',
    # Defence
    'tackles','tackle success %','blocked shots','interceptions','clearances','headed clearance','recoveries',
    'recoveries','duels won','duels lost','successful 50/50s','aerial battles won','aerial battles lost',
    'errors leading to goal'
]
# attack stacks
forward_columns = [
    'club','position',
    'appearances', 'goals', 'wins', 'losses',
    # attack
    'goals','goals per match','headed goals','goals with right foot','goals with left foot',
    'penalties scored','freekicks scored','shots','shots on target','shooting accuracy %','hit woodwork',
    'big chances missed',
    # Team Play
    'assists', 'passes', 'passes per match', 'big chances created','crosses',
    # Discipline
    'yellow cards', 'red cards', 'fouls', 'offsides',
    # Defence
    'tackles','blocked shots','interceptions','clearances','headed clearance'
]

def get_stats(club, player_link):
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_experimental_option("prefs", {"profile.default_content_settings.cookies": 2})

    browser = webdriver.Chrome('/Users/stephenstewart/.wdm/drivers/chromedriver/mac64/87.0.4280.88/chromedriver',
                               chrome_options=chrome_options)
    try:
        url = player_link
        browser.get(url)

        html = browser.page_source
        browser.quit()

        soup = BeautifulSoup(html, 'lxml')

        position = soup.findAll("div", {"class": "info"})[1].text.lower()

        if position == 'goalkeeper':
            player_info = {k: '' for k in goalkeeper_columns}
        elif position == 'forward':
            player_info = {k: '' for k in forward_columns}
        elif position == 'defender':
            player_info = {k: '' for k in defender_columns}
        elif position == 'midfielder':
            player_info = {k: '' for k in midfielder_columns}
        else:
            return None

        player_info['club'] = club
        player_info['position'] = position

        for stat in soup.findAll("span", {"class": "stat"}):
            vals = stat.text.split()
            if len(vals) > 1:
                name = ' '.join(x.lower() for x in vals[:-1])
                statistic = vals[-1]
                if name in player_info:
                    if statistic.isnumeric():
                        player_info[name] = float(statistic)

        return player_info

    except WebDriverException:
        return None


def main():

    """stats = {}

    for season in seasons.keys():
        teams = seasons[season]['teams']
        code = seasons[season]['code']
        for team in teams:
            team_players = get_players(season=season,season_code=code,team=team)
            print(team_players)
            stats = {**team_players,**stats}

    df = pd.DataFrame.from_dict(stats,orient='index',
                                columns=['season','team','player_link'])

    df.player_link = df.player_link.apply(lambda x: clean_link(x))
    df.to_csv('players.csv')"""

    players = pd.read_csv('players.csv', index_col='Unnamed: 0')

    all_player_info = {}

    for i, p in players.iterrows():
        player_info = get_stats(club=p[2], player_link=p[3])
        if player_info is not None:
            all_player_info[p[0]] = player_info
            print(player_info)

    with open('player_info.p', 'wb') as x:
        pickle.dump(all_player_info, x)

    df = pd.DataFrame.from_dict(all_player_info, orient='index')
    df.to_csv('all_player_stats.csv')


if __name__ == '__main__':
    main()

