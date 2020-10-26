# DATAFRAMES
import pandas as pd

# JSON
from urllib.request import urlopen
import json

# Unique neighbourhoods from geojson data:
def unique_nbhd_ids(geojson):
    ids = []
    for feature in geojson['features']:
        names = feature['id'].split('_')
        ids.append(' '.join(name for name in names))
    return sorted(ids)

# Unique neighbourhoods from Airbnb data:
def unique_bnb_nbhds(data):
    nbhds = data.neighbourhood.unique()
    return sorted(nbhds)

# Match neighbourhoods by name
def match_nbhds(airbnb_data, airbnb_nbhds, geojson_nbhds):
    for nbhd in airbnb_nbhds:
        for nbhd_id in geojson_nbhds:
            if nbhd in nbhd_id:
                nbhd_id_no_spaces = nbhd_id.replace(' ', '_')
                airbnb_data.loc[airbnb_data['neighbourhood'] == nbhd, ['nbhd_ids']] = nbhd_id_no_spaces
    return airbnb_data

# Compute neighbourhood boundaries from geojson data
def compute_boundary(geojson):
    boundaries = {}
    for feature in geojson['features']:
        max_lat = -99999
        min_lat = 99999
        max_long = -99999
        min_long = 99999
        for coords in feature['geometry']['coordinates'][0][0]:
            if type(coords) is not float:
                min_long = min(min_long, coords[1])
                max_long = max(max_long, coords[1])
                min_lat = min(min_lat, coords[0])
                max_lat = max(max_lat, coords[0])
            elif 35 < coords < 45:
                min_lat = min(min_lat, coords)
                max_lat = max(max_lat, coords)
            else:
                min_long = min(min_long, coords)
                max_long = max(max_long, coords)
        boundaries[feature['id']] = [min_lat, max_lat, min_long, max_long]
    return boundaries

# Match remaining neighbourhoods by co-ordinates
def match_nbhds_within_boundary(airbnb_data, nbhd_bounds):
    for index, row in airbnb_data[['latitude', 'longitude', 'nbhd_ids']].iterrows():
        lat, long, nbhd_id = row[0], row[1], row[2]
        if nbhd_id == '':
            for nbhd in nbhd_bounds.keys():
                min_long = nbhd_bounds[nbhd][0]
                max_long = nbhd_bounds[nbhd][1]
                min_lat = nbhd_bounds[nbhd][2]
                max_lat = nbhd_bounds[nbhd][3]
                if (min_lat < lat < max_lat) and (min_long < long < max_long):
                    airbnb_data.loc[index,'nbhd_ids'] = nbhd
    return airbnb_data

def main():
    # Airbnb data
    bnb_data = pd.read_csv('../../Airbnb/AB_NYC_2019.csv')

    # GEOJSON data for NYC neighbourhoods
    with urlopen('https://raw.githubusercontent.com/veltman/snd3/master/data/nyc-neighborhoods.geo.json') as response:
        counties = json.load(response)

    # Create new column for nbhd_ids which match geojson nbhds
    nbhd_ids = ["" for _ in range(len(bnb_data))]
    bnb_data['nbhd_ids'] = nbhd_ids

    nbhd_bounds = compute_boundary(counties)
    geojson_nbhds = unique_nbhd_ids(counties)
    airbnb_nbhds = unique_bnb_nbhds(bnb_data)

    print("Total properties to match to neighbourhood = %s" % len(bnb_data.loc[bnb_data['nbhd_ids'] == '']))
    bnb_data = match_nbhds(bnb_data, airbnb_nbhds, geojson_nbhds)

    print("Total properties to match to neighbourhood = %s" % len(bnb_data.loc[bnb_data['nbhd_ids'] == '']))
    bnb_data = match_nbhds_within_boundary(bnb_data, nbhd_bounds)

    print("Total properties to match to neighbourhood = %s" % len(bnb_data.loc[bnb_data['nbhd_ids'] == '']))

    bnb_data.to_csv("airbnb.csv")

if __name__ == "__main__":
    main()
