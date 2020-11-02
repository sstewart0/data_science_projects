# DATAFRAMES
import pandas as pd

# JSON
from urllib.request import urlopen
import json

# DASHBOARD
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State

# PLOTTING
import plotly.express as px

# Initialize app
app = dash.Dash(
    __name__,
    meta_tags=[
        {"name": "viewport", "content": "width=device-width, initial-scale=1.0"}
    ],
)
server = app.server

# GEOJSON data for NYC neighbourhoods
with urlopen('https://raw.githubusercontent.com/veltman/snd3/master/data/nyc-neighborhoods.geo.json') as response:
    counties = json.load(response)

# Bnb data with matched neighbourhoods
bnb_data = pd.read_csv('airbnb.csv')

PRICE = [40,60,80,100,120,140,160,180,200]

app.layout = html.Div(
    id="root",
    children=[
        html.Div(
            id="header",
            children=[
                html.Img(id="logo",
                         src=app.get_asset_url("airbnb_logo3.jpg"),
                         style={
                             'width':'250px',
                             'height':'140px'
                         }),
                html.H4(children="NYC Airbnb Dashboard")
            ]
        ),
        html.Div(
            id="app-container",
            children=[
                html.Div(
                    id="left-column",
                    children=[
                        html.Div(
                            id="choropleth-container",
                            children=[
                                html.P(
                                    children="Choropleth map of Airbnb properties in New York.",
                                    id="choropleth-map-title",
                                ),
                                dcc.Graph(
                                    id="county-choropleth",
                                )
                            ]
                        )
                    ]
                ),
                html.Div(
                    id="right-column",
                    children=[
                        html.Div(
                            id="slider-container",
                            children=[
                                html.P(
                                    id="slider-text",
                                    children="Drag the slider to adjust the price range:",
                                ),
                                dcc.RangeSlider(
                                    id="price-slider",
                                    min=min(PRICE),
                                    max=max(PRICE),
                                    value=[min(PRICE),max(PRICE)],
                                    marks={
                                        str(price): {
                                            "label": "$%s" % str(price),
                                            "style": {"color": "#7fafdf"},
                                        }
                                        for price in PRICE
                                    },
                                ),
                            ]
                        ),
                        html.Div(
                            id="multiselect-container",
                            children=[
                                html.P(
                                    id="multiselect-text",
                                    children="Select room type(s) to include:",
                                ),
                                dcc.Checklist(
                                    id="room-type-checklist",
                                    options=[
                                        {'label': 'Entire Home/Apartment', 'value': 'EH'},
                                        {'label': 'Private Room', 'value': 'PR'},
                                        {'label': 'Shared Room', 'value': 'SR'}
                                    ],
                                    value=['EH', 'PR', 'SR'],
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    ]
)

@app.callback(
    Output("county-choropleth", "figure"),
        [
        Input("price-slider", "value"),
        Input("room-type-checklist", "value")
    ]
)
def display_map(price, roomtypes):
    price_condition = bnb_data['price'].between(price[0],price[1], inclusive=True)

    room_type_map = {
            "EH":"Entire home/apt",
            "PR":"Private room",
            "SR":"Shared room"
    }
    ROOMS = [room_type_map[room] for room in roomtypes]
    room_condition = bnb_data['room_type'].isin(ROOMS)

    filtered_data = bnb_data[price_condition & room_condition]

    # Data frame of counts
    df = pd.DataFrame({'count': filtered_data.groupby(["nbhd_ids"]).size()}).reset_index()

    # Data frame of median price
    aggr = {'price': 'median'}
    df2 = filtered_data[['nbhd_ids', 'price']].groupby(['nbhd_ids']).agg(aggr)

    # Join the dataframes
    df['price'] = df2['price'].tolist()

    # Names of neighbourhoods
    names = [name.replace('_', ' ') for name in df['nbhd_ids'].tolist()]
    df['names'] = names

    fig = px.choropleth_mapbox(data_frame=df,
                               geojson=counties,
                               locations='nbhd_ids',
                               range_color=(price[0],price[1]),
                               color='price',
                               center=dict(lat=40.7,lon=-74),
                               zoom=9.5,
                               hover_name='names',
                               hover_data={
                                   'nbhd_ids':False,
                                   'price':True,
                                   'count':True
                               }
                               )

    fig.update_layout(dict(plot_bgcolor='rgba(0,0,0,0)',
                           paper_bgcolor='rgba(0,0,0,0)',
                           mapbox_style='carto-darkmatter',
                           hoverlabel=dict(
                               bgcolor="white",
                               font_size=12,
                               font_family="Open Sans"
                           ),
                           coloraxis_colorbar=dict(
                               title=dict(
                                   text='PRICE',
                                   font=dict(
                                       color='#7fafdf'
                                   )
                               ),
                               tickfont=dict(
                                   color='#7fafdf'
                               )
                           )
                           )
                      )

    return fig


if __name__ == "__main__":
    app.run_server(debug=True)
