from demand_predictors.predictor import DemandPredictor
from common import stations_from_csv

stations = stations_from_csv("./results_May8/station_positions.csv")
max_distance_to_station = 500
predictor = DemandPredictor(stations, max_distance_to_station)
predictor.simulate_day()
