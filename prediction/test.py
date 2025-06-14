from demand_predictors.predictor import DemandPredictor
from common import stations_from_csv, current_stations

MAX_DISTANCE_TO_STATIONS = 250

predicted_stations = stations_from_csv("./results_May8/station_positions.csv")

for station_amount in range(len(predicted_stations)):
    # Da error en el caso de 0, era lo mas facil
    if station_amount == 0:
        continue

    stations_to_use = predicted_stations[:station_amount]
    predictor = DemandPredictor(stations_to_use, MAX_DISTANCE_TO_STATIONS)
    predictor.simulate_day(station_amount)
