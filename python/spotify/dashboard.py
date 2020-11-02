# DASHBOARD
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State

# Data
import pandas as pd

# sf = spotify functions
import analysis as sf

# Read data
stream_data = sf.get_data()

top_songs = sf.get_top_songs(stream_data)

def get_top_song_imgs():
    imgs = []
    for index, row in top_songs.iterrows():
        print(index)
        img = sf.get_genius_image(row)
        #save image
        fp = './assets/img{i}.png'.format(i=index)
        sf.save_image(img, fp)
        imgs.append(fp)
    return imgs

images = get_top_song_imgs()

# Initialize app
app = dash.Dash(
    __name__,
    meta_tags=[
        {"name": "viewport", "content": "width=device-width, initial-scale=1.0"}
    ],
)
server = app.server

app.layout = html.Div(
    id="root",
    children=[
        html.Div(
            id="banner",
            children=[
                html.Img(id="logo",
                         src=app.get_asset_url("spotify_logo2.png"),
                         style={
                             'width':'212px',
                             'height':'80px'
                         })
            ]
        ),
        html.Div(
            id="app-container",
            children=[
                html.Div(
                    id="column1",
                    children=[
                        html.Div(
                            id="genre-container"
                            # polar plot
                        ),
                        html.Div(
                            id="artist-container"
                            # list
                        )
                    ]
                ),
                html.Div(
                    id="column2",
                    children=[
                        html.Div(
                            id="list-container",
                            children=[
                                html.Div(
                                    className="list-col",
                                    children=[
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image1",
                                                    src = images[0],
                                                    style={
                                                        'max-width':'100%',
                                                        'max-height':'100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image2",
                                                    src=images[1],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image3",
                                                    src=images[2],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image4",
                                                    src=images[3],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image5",
                                                    src=images[4],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image6",
                                                    src=images[5],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image7",
                                                    src=images[6],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image8",
                                                    src=images[7],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image9",
                                                    src=images[8],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        ),
                                        html.Div(
                                            className="song-art-container",
                                            children=[
                                                html.Img(
                                                    id="image10",
                                                    src=images[9],
                                                    style={
                                                        'max-width': '100%',
                                                        'max-height': '100%'
                                                    }
                                                )
                                            ]
                                        )
                                    ]
                                ),
                                html.Div(
                                    className="list-col",
                                    children=[
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("1")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("2")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("3")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("4")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("5")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("6")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("7")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("8")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("9")
                                            ]
                                        ),
                                        html.Div(
                                            className="song-name-container",
                                            children=[
                                                html.P("10")
                                            ]
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                html.Div(
                    id="column3",
                    children=[
                        html.Div(
                            id="day-container"
                        ),
                        html.Div(
                            id="time-container"
                        )
                    ]
                )
            ]
        )
    ]
)

if __name__ == "__main__":
    app.run_server(debug=True)
