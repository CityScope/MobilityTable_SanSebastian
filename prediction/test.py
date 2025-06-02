from demand_predictors.predictor import DemandPredictor
from common import stations_from_csv, current_stations

stations = current_stations()
max_distance_to_station = 250
predictor = DemandPredictor(stations, max_distance_to_station)
predictor.simulate_day()
