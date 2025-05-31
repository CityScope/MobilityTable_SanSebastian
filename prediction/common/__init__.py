from .population_density_reader import PopulationDensity
from .trip_density_reader import TripDensity

from typing import List, Tuple
import csv
from pyproj import Transformer

def stations_from_csv(path: str) -> List[Tuple[float, float]]:
    transformer = Transformer.from_crs("epsg:4326", "epsg:25830", always_xy=True)

    stations = []
    with open(path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            lon = float(row['center_x'])
            lat = float(row['center_y'])

            pos = transformer.transform(lon, lat)
            stations.append(pos)
    return stations


__all__ = ["PopulationDensity", "TripDensity", "stations_from_csv"]
