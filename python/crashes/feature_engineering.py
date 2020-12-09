import numpy as np # linear algebra
import pandas as pd # data processing

pd.set_option('display.max_columns', 1000)

collisions = pd.read_csv('collisions.csv',dtype=str)

collisions['case_id'] = collisions['case_id'].astype(np.float)

collisions['collision_date'] = pd.to_datetime(collisions['collision_date'],format='%Y-%m-%d')
collisions['collision_time'] = pd.to_timedelta(collisions['collision_time'])

# 1 NEW FEATURE: DAY TYPE
day_type = np.array([1 if x.weekday() < 5 else 0 for x in collisions['collision_date']])

collisions['day_type'] = day_type

def hour(time):
    days, seconds = time.days, time.seconds
    return days * 24 + seconds // 3600

collisions['time'] = collisions['collision_time'].apply(lambda x: hour(x))

time_loc = collisions.columns.get_loc('time')
day_type_loc = collisions.columns.get_loc('day_type')

# 2 NEW FEATURE: COMMUTE
commute = np.zeros(len(collisions))

for i, row in collisions.iterrows():
    morning = (row[time_loc] <= 9) and (row[time_loc] >= 5)
    evening = (row[time_loc] <= 19) and (row[time_loc] >= 17)
    weekday = (row[day_type_loc] == 1)
    if weekday:
        if morning or evening:
            commute[i] = 1

# 3 NEW FEATURE: FATAL (DEPENDENT VARIABLE)
collisions['killed_victims'] = collisions['killed_victims'].astype(np.float)
fatal = np.array([1 if x > 0 else 0 for x in collisions['killed_victims']])

# 4 NEW FEATURE: POPULATION2
population2 = np.array([1 if x == '9' else 0 for x in collisions['population']])

# FEATURE: SPECIAL CONDITION, special_condition
sc = np.array([1 if x == '1' else 0 for x in collisions['special_condition']])

# BEAT TYPE
bt = np.array([1 if x == '1' else 0 for x in collisions['beat_type']])

# NEW FEATURE: DIRECTION {E,W} OR {N,S} !!!
directions = ['east','west']
E_or_W = np.array([1 if x in directions else 0 for x in collisions['direction']])

# NEW FEATURE: INTERSECTION
intersect = np.array([1 if x == '1.0' else 0 for x in collisions['intersection']])

# NEW FEATURE: HIGHWAY SIDE {E,W} OR {N,S}
bound = ['eastbound','westbound']
bound_EW = np.array([1 if x in bound else 0 for x in collisions['side_of_highway']])

# towaway
towaway = np.array([1 if x == '1.0' else 0 for x in collisions['tow_away']])

# PARTY COUNT
pc = collisions['party_count'].astype(np.float)

# head on?
headon = np.array([1 if x == 'head-on' else 0 for x in collisions['type_of_collision']])

# lighting2
dark = ['dark with no street lights','dark with street lights not functioning']
mid = ['dark with street lights', 'dusk or dawn']
light = ['daylight']

lighting2 = np.zeros(len(collisions))

for i, x in enumerate(collisions['lighting']):
    if x in dark:
        lighting2[i] = 2
    elif x in mid:
        lighting2[i] = 1
    elif x in light:
        lighting2[i] = 0

# pedestrian collision
pedestrian = np.array([1 if x == '1.0' else 0 for x in collisions['pedestrian_collision']])

# control device:
devices = ['functioning','none']
cd = np.array([1 if x in devices else 0 for x in collisions['control_device']])

# road type:
rt = ['5','0']
roadtype = np.array([1 if x in rt else 0 for x in collisions['chp_road_type']])

# bicycle collision
bc = np.array([1 if x == '1.0' else 0 for x in collisions['bicycle_collision']])

# truck collision
tc = np.array([1 if x == '1.0' else 0 for x in collisions['truck_collision']])

# alcohol
alcohol = np.array([1 if x == '1.0' else 0 for x in collisions['alcohol_involved']])

collisions2 = list(zip(day_type,commute,population2,bt,E_or_W,
                       intersect,bound_EW,towaway,pc,headon,lighting2,
                       pedestrian,cd,roadtype,bc,tc,alcohol,fatal,sc))

cols = ['day_type','commute','population','beat_type','direction',
        'intersection','highway_direction','tow_away','party_count',
        'head_on','lighting','pedestrian_collision','control_device',
        'road_type','bicycle_collision','truck_collision','alcohol',
        'special_condition','fatal']

new_collisions = pd.DataFrame(collisions2,columns=cols)

print(new_collisions.describe())

new_collisions.to_csv('new_collisions.csv')
