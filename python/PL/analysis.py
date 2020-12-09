import pandas as pd
import numpy as np

pd.set_option('display.max_columns', 1000)

players = pd.read_csv('all_player_stats.csv', index_col = 'Unnamed: 0')

clubs = players.groupby(['club']).agg('mean').reset_index()

print(clubs.sort_values(by='shots on target',ascending=False).head(20))
