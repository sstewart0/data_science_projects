import numpy as np # linear algebra
import pandas as pd # data processing
import sqlite3
from adjustText import adjust_text
import math
from bioinfokit.analys import stat, get_data
import datetime as dt
import matplotlib.pyplot as plt
import seaborn as sns

pd.options.mode.chained_assignment = None  # default='warn'

pd.set_option('display.max_rows', 1000)
pd.set_option('display.max_columns', 1000)
pd.set_option('display.width', 1000)

def sql_to_csv():
    # Create a SQL connection to our SQLite database
    con = sqlite3.connect("switrs.sqlite")
    cur = con.cursor()

    collisions = pd.read_sql_query("SELECT * FROM collisions WHERE motorcycle_collision == 1", con)

    parties_query = " SELECT * FROM parties WHERE case_id IN \
    (SELECT case_id FROM collisions WHERE motorcycle_collision == 1)"

    victims_query = " SELECT * FROM victims WHERE case_id IN \
    (SELECT case_id FROM collisions WHERE motorcycle_collision == 1)"

    parties = pd.read_sql_query(parties_query, con)
    victims = pd.read_sql_query(victims_query, con)

    con.close()
    # Save the data as csv files
    collisions.to_csv('collisions.csv',index=False)
    parties.to_csv('parties.csv',index=False)
    victims.to_csv('victims.csv',index=False)

# Change dtype when we need it, multiple types are memory inefficient
collisions = pd.read_csv('collisions.csv',dtype=str)
parties = pd.read_csv('parties.csv',dtype=str)
victims = pd.read_csv('victims.csv',dtype=str)

"""print("The number of unique case_ids is {n}".format(n=len(parties['case_id'].unique())))
print("There are {x} records from collisions.".format(x=collisions.shape[0]))
print("There are {y} records from parties.".format(y=parties.shape[0]))
print("There are {z} records from victims.".format(z=victims.shape[0]))

all_vehicles = parties.groupby(['statewide_vehicle_type']).agg({'case_id':'count'})"""

motorcycle = ['motorcycle or scooter', 'moped']
motorcycles = parties[parties.statewide_vehicle_type.isin(motorcycle)]

#count = motorcycles.groupby(['vehicle_make']).agg({'case_id':'count'})
#print(count.sort_values(by='case_id',ascending=False).head(20))

# DATA CLEANING: Will roughly cover motorcycles with freq > 100
makes = {
    'HONDA':['HOND'],
    'HARLEY-DAVIDSON':['HARL','HD','HARLE','HARLEY DAVIDSON','HARLEY D','HARLEY-D','HARLEY'],
    'YAMAHA':['YAMA','YAMAH'],
    'KAWASAKI':['KAWA','KAWK','KAWI','KAWAS'],
    'SUZUKI':['SUZU','SUZI'],
    'DUCATI':['DUCA','DUCAT','DUCATI'],
    'TRIUMPH':['TRIU','TRUM','TRIUM'],
    'INDIAN':['INDIAN (MOTORCYCLE)','INDI'],
    'SPCN':['SPCNS']
}

motorcycle_makes = motorcycles.vehicle_make.to_numpy()

for i, moto in enumerate(motorcycle_makes):
    for make in makes:
        if moto in makes[make]:
            motorcycle_makes[i] = make
            break

motorcycles.vehicle_make = motorcycle_makes

"""count = motorcycles.groupby(['vehicle_make']).agg({'case_id':'count'})
count_sorted = count.sort_values(by='case_id',ascending=False)

collisions['collision_time'] = pd.to_timedelta(collisions['collision_time'])

times = collisions.groupby(
    pd.Grouper(key='collision_time',freq='60Min',label='right')).agg(
    {'case_id':'count'}).reset_index()

sorted_times = times.sort_values(by='case_id',ascending=False)"""

collisions['case_id'] = collisions['case_id'].astype(np.float)
collisions['collision_date'] = pd.to_datetime(collisions['collision_date'],format='%Y-%m-%d')

# 1:weekday, 0:weekend
day_type = np.array([1 if x.weekday() < 5 else 0 for x in collisions['collision_date']])

collisions['day_type'] = day_type

"""# Group by day_type for totals:
no_weekdays = sum(1 for _ in collisions.loc[collisions['day_type'] == 1]['day_type'])
no_weekends = sum(1 for _ in collisions.loc[collisions['day_type'] == 0]['day_type'])

# Group by weekend/weekday & times
t = pd.Grouper(key='collision_time',freq='60Min') #time grouper
grouped_df = collisions.groupby([t, 'day_type']).agg({'case_id':'count'}).reset_index()

fracs = np.array(
    [x[2]/no_weekdays if x[1] == 1
     else x[2]/no_weekends
     for i,x in grouped_df.iterrows()
     ]
)
grouped_df['frac'] = fracs

sorted_grouped = grouped_df.sort_values(by='frac',ascending=False)"""


"""# P(crash|weekend) = P(weekend & crash)/P(weekend)
# P(weekend & crash) = P(weekend|crash).P(crash) `proportional to` P(weekend|crash)
# Hence P(crash|weekend) = P(weekend|crash).P(crash)/P(weekend) `proportional to` P(weekend|crash)/P(weekend)

# pwgc = P(weekend|crash)
pwgc = no_weekends/(no_weekdays + no_weekends)
# pw = P(weekend)
pw = 2/7

# pcgw = P(crash|weekend)
pcgw = pwgc/pw
# pcgwd = P(crash|weekday)
pcgwd = (1-pwgc)/(1-pw)

print("P(crash|weekend) `proportional to` {x}".format(x=pcgw))
print("P(crash|weekday) `proportional to` {x}".format(x=pcgwd))"""
"""
# Get the data for the N most popular motorcycle makes
N = 20
count = motorcycles.groupby(['vehicle_make']).agg({'case_id':'count'}).reset_index()
N_most_popular = count.sort_values(by='case_id',ascending=False).head(N)

top_N_motorcycles = N_most_popular.vehicle_make
parties.case_id = parties.case_id.astype(np.float)
top_N_data = parties[parties.vehicle_make.isin(top_N_motorcycles)]

print("The top {n} motorcycles account for {x} collisions".format(
    n=N,x=len(top_N_data)))

# Joing motorcycles and collisions on case_id
merged_df = top_N_data.set_index('case_id').join(collisions.set_index('case_id')).reset_index()

# Group by vehicle_make & day_type (weekend/weekday)
gb_vd = merged_df.groupby(['day_type', 'vehicle_make']).agg(
    {'case_id':'count'}
).reset_index()

# Pivot table:
pivot_table = gb_vd.pivot_table(index='vehicle_make',columns='day_type',values='case_id')

# Chi-square Test for independence
res = stat()
res.chisq(df=pivot_table)

print(res.summary)"""

print(collisions['special_condition'].unique())

"""# CONDITIONS
collisions['collision_time'] = pd.to_timedelta(collisions['collision_time'])

numeric_cols = ['killed_victims','injured_victims','motorcyclist_injured_count',
                'motorcyclist_killed_count','party_count']
collisions[numeric_cols] = collisions[numeric_cols].astype(np.float)

def hour(time):
    days, seconds = time.days, time.seconds
    return days * 24 + seconds // 3600

collisions['time'] = collisions['collision_time'].apply(lambda x: hour(x))

time_loc = collisions.columns.get_loc('time')
day_type_loc = collisions.columns.get_loc('day_type')

commute = np.zeros(len(collisions))

for i, row in collisions.iterrows():
    morning = (row[time_loc] <= 9) and (row[time_loc] >= 5)
    evening = (row[time_loc] <= 19) and (row[time_loc] >= 17)
    weekday = (row[day_type_loc] == 1)
    if weekday:
        if morning or evening:
            commute[i] = 1

collisions['commute'] = commute"""

def plot_condition(conditions, variable, t='case_id'):
    # Replace nan by '-'
    nans = conditions
    collisions[nans] = collisions[nans].replace(np.nan, '-',regex=True)

    n = len(conditions)

    fig, axs = plt.subplots(ncols=len(conditions), sharey=True)

    for i, cond in enumerate(conditions):
        grouped = collisions.groupby(cond)
        agg_grouped = grouped.agg({'killed_victims':'mean',
                                   'injured_victims':'mean',
                                   'motorcyclist_injured_count':'mean',
                                   'motorcyclist_killed_count':'mean',
                                   'case_id':'count'}).reset_index()

        y = np.log(agg_grouped[variable])

        color_labels = agg_grouped[cond].unique()

        # List of colors in the color palettes
        rgb_values = sns.color_palette("Set2", len(color_labels))

        # Map weather to the colors
        color_map = dict(zip(color_labels, rgb_values))

        # motorcyclist_killed_count, killed_victims
        # Use Log-scale to compress
        if t == 'case_id':
            x = np.log(agg_grouped['case_id'])
        else:
            x = agg_grouped[cond]

        if n != 1:
            axs[i].scatter(x, y,c=agg_grouped[cond].map(color_map))

            for j, txt in enumerate(agg_grouped[cond]):
                axs[i].annotate(txt, (x[j], y[j]))

            axs[i].set_ylabel('(Log-scale) {X}'.format(X=variable.replace('_',' ')))

            axs[i].set_title(cond.replace('_', ' '))

            if t == 'case_id':
                axs[i].set_xlabel("(Log-scale) Count")
            else:
                axs[i].set_xlabel(cond.replace('_', ' '))
        else:
            axs.scatter(x, y, c=agg_grouped[cond].map(color_map))

            axs.set_ylabel('(Log-scale) {X}'.format(X=variable.replace('_', ' ')))

            axs.set_title(cond.replace('_', ' '))

            if t == 'case_id':
                axs.set_xlabel("(Log-scale) Count")
                for j, txt in enumerate(agg_grouped[cond]):
                    axs.annotate(txt, (x[j], y[j]))
            else:
                axs.set_xlabel(cond.replace('_', ' '))

    plt.suptitle(' & '.join(c for c in conditions))
    plt.show()
    return None

#plot_condition(['commute'], 'killed_victims')


"""
# Conditions and Severity
w = ['weather_1','weather_2']
collisions[w] = collisions[w].replace(np.nan, '-',regex=True)

weather = list(zip(collisions['weather_1'],collisions['weather_2']))
collisions['weather'] = weather

gb = 'weather'
collisions[gb] = collisions[gb].astype(str)

conditions_grouped = collisions.groupby([gb]).agg(
    {'case_id':'count'}
).reset_index()

print(conditions_grouped.sort_values(by='case_id',ascending=False))"""

"""
P(crash|condition_i) = P(crash n condition_i)/P(condition_i)
P(crash n condition_i) = P(condition_i|crash).P(crash)

P(condition_i) = sum_j(P(condition_i,month_j))
"""
"""
# Get months
months = np.array([m.month for m in collisions['collision_date']])
collisions['month'] = months

gb_month_weather1 = collisions.groupby(['month','weather_1'])
agg_month_weather1 = gb_month_weather1.agg({'case_id':'count'}).reset_index()

# P(condition_i|month_j)
# divide by total count of conditions in the month
p_table = agg_month_weather1.pivot_table(index='month',
                                         columns='weather_1',
                                         values='case_id')
p_table['sum'] = p_table.sum(axis=1)
p_condition_given_month = p_table.iloc[:,0:7].div(p_table["sum"], axis=0)

# p(condition_i) = sum_j(P(condition_i|month_j).P(month_j)) = 1/12 * sum_j(P(condition_i|month_j))
p_condition = 1/12 * p_condition_given_month.sum(axis=0)

# Get P(crash n condition_i) for each i:
gb_weather1 = collisions.groupby(['weather_1']).agg({'case_id':'count'}).reset_index()
weathers = gb_weather1['weather_1']

total = gb_weather1['case_id'].sum()

# P(crash|condition_i) = P(condition_i|crash) * P(crash) / P(condition_i)
p_condition_given_crash = gb_weather1['case_id'] / total

p_crash_given_cond = np.array([x / p_condition[i]
                               for i,x in enumerate(p_condition_given_crash)])
# P(crash|condition_i) as DF
p_cr_g_co = pd.DataFrame(list(zip(weathers,
                                  p_crash_given_cond,
                                  p_condition)))
p_cr_g_co.columns = ['Condition', 'P(Crash|Condition)/P(Crash)','P(Condition)']"""

"""# Distirbution of fatalities
plt.hist(collisions['killed_victims'],bins=10)
plt.show()"""


"""collisions['killed_victims'] = collisions['killed_victims'].astype(np.float)
collisions['killed_victims'] = collisions['killed_victims'].replace(np.nan,0)"""

"""# Pareto distribution
n = len(collisions)

sum_ln_x = sum(np.log(x+1) for x in collisions['killed_victims'])

alpha = round(n/sum_ln_x,2)

a, m = alpha, 1.  # shape and mode
s = (np.random.pareto(a, 1000) + 1) * m

fig, ax = plt.subplots()

count, bins, _ = ax.hist(s, 100, density=True)
fit = a*m**a / bins**(a+1)
ax.plot(bins, max(count)*fit/max(fit), linewidth=2, color='r')
ax.set_xlabel('Number of deaths + 1')
ax.set_ylabel('P((Num Deaths + 1) & Crash)')

plt.suptitle('Estimation of P(Num Deaths & Crash) using a Pareto Distribution \n \
             with shape paramter (alpha) = {a} & scale parameter = {m}'.format(
    a=alpha,m=m))

plt.show()"""

"""nans = ['weather_1','weather_2']
collisions[nans] = collisions[nans].replace('-', np.nan,regex=True)

collisions_with_deaths = collisions[collisions.killed_victims > 0]

# All unique weathers
weathers = collisions_with_deaths['weather_1'].unique()

gb_weather1 = collisions_with_deaths.groupby(['weather_1']).agg({'case_id':'count'}).reset_index()
gb_weather2 = collisions_with_deaths.groupby(['weather_2']).agg({'case_id':'count'}).reset_index()

# Combine weather_1 & weather_2 totals
for i,b in gb_weather2.iterrows():
    gb_weather1.at[i+1, 'case_id'] += b[1]

print(gb_weather1)

# Total
total = gb_weather1['case_id'].sum()

# P(condition|crash&death) =
p_condition_given_crash = gb_weather1['case_id'] / total

# P(crash&death|condition_i) = P(condition_i|crash&death) * P(crash&death) / P(condition_i)
p_crash_given_cond = np.array([x / p_condition[i] for i,x in enumerate(p_condition_given_crash)])

# P(crash&death|condition_i) as DF
p_cr_g_co = pd.DataFrame(list(zip(weathers,
                                  p_crash_given_cond,
                                  p_condition)))
p_cr_g_co.columns = ['Condition',
                     'P((Crash & Fatality)|Condition)/P(Crash & Fatality)',
                     'P(Condition)']

p_cr_g_co = p_cr_g_co.sort_values(by='P((Crash & Fatality)|Condition)/P(Crash & Fatality)',
                                  ascending=False)

print(p_cr_g_co)
"""