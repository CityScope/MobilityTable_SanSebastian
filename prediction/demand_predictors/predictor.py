import geopandas
from typing import Tuple, List
from math import sqrt
from pyproj import Transformer
import os

from common import TripDensity

TRIPS_PATH = "./processed_data/trips.csv"

class DemandPredictor:
    def __init__(self, stations: List[Tuple[float, float]], max_distance_to_station: float):
        self.stations = stations
        self.max_distance_to_station = max_distance_to_station
        self.trip_density = TripDensity()
        self.buildings_by_section = geopandas.read_file("./raw_data/buildings_w_section.shp")
        self.buildings_by_section = self.buildings_by_section.to_crs(epsg=25830)

    def cudis_to_cusec(self, cudis: int) -> int:
        cudis_matches = self.trip_density.sections[self.trip_density.sections["CUDIS"] == str(cudis)]
        sample_cusec = cudis_matches.sample()["CUSEC"].iloc[0]
        return sample_cusec
    
    def sample_building(self, cudis: int) -> Tuple[float, float]:
        features = self.buildings_by_section[self.buildings_by_section["Seccion"] == str(self.cudis_to_cusec(cudis))]
        centroid = features.sample().geometry.centroid

        return (centroid.x.iloc[0], centroid.y.iloc[0])

    def max_trips(self, hour: int) -> int:
        return int(self.trip_density.hourly_trips(hour) * 1.6)
    
    @staticmethod
    def distance(a: Tuple[float, float], b: Tuple[float, float]) -> float:
        x_diff = a[0] - b[0]
        y_diff = a[1] - b[1]
        return sqrt(x_diff * x_diff + y_diff * y_diff)

    def is_position_valid(self, pos: Tuple[float, float]) -> bool:
        min_distance = DemandPredictor.distance(pos, self.stations[0])
        for station in self.stations:
            if DemandPredictor.distance(pos, station) < min_distance:
                min_distance = DemandPredictor.distance(pos, station)
            if min_distance <= self.max_distance_to_station:
                return True
        
        return False

    def simulate_hour(self, max_trips: int) -> List[Tuple[Tuple[float, float], Tuple[float, float]]]:
        trips = []

        for _i in range(max_trips):
            start_sec, end_sec = self.trip_density.sample_trip()
            start_pos = self.sample_building(start_sec)
            end_pos = self.sample_building(end_sec)

            if self.is_position_valid(start_pos) and self.is_position_valid(end_pos):
                trips.append((start_pos, end_pos))
        
        return trips

    def simulate_day(self, day_id: int):
        transformer = Transformer.from_crs("EPSG:25830", "EPSG:4326", always_xy=True)

        trips_each_hour = []
    
        for hour in range(0, 24):
            max_trips = self.max_trips(hour)
            trips = self.simulate_hour(max_trips)

            latlon_trips = list(map(lambda p: (transformer.transform(p[0][0], p[0][1])[::-1], transformer.transform(p[1][0], p[1][1])[::-1]), trips))

            print(f"{len(trips)} trips found at {hour}, id {day_id}")
            trips_each_hour.append(latlon_trips)

        # Save to file
        formated_trips = []
        for hour, trips_in_hour in enumerate(trips_each_hour):
            for trip in trips_in_hour:
                formated_trips.append(f"{hour},{trip[0][0]},{trip[0][1]},{trip[1][0]},{trip[1][1]},{day_id}\n")

        print(f"Finished day {day_id} with {len(formated_trips)} trips")

        already_existed = os.path.exists(TRIPS_PATH)
        with open(TRIPS_PATH, mode='a', newline='') as file:
            if not already_existed:
                file.write("starttime,start_lat,start_lon,target_lat,target_lon,scenario_id\n")

            file.writelines(formated_trips)
