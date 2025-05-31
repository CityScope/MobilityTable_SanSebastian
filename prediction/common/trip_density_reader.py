import pandas
import geopandas
from shapely.geometry import Point
from collections import defaultdict
import os
import pickle
import random
from typing import Tuple

# Gracias chat :D
def normalize_columns(columns):
    return (
        columns
        .str.lower()
        .str.replace(r'[áàäâ]', 'a', regex=True)
        .str.replace(r'[éèëê]', 'e', regex=True)
        .str.replace(r'[íìïî]', 'i', regex=True)
        .str.replace(r'[óòöô]', 'o', regex=True)
        .str.replace(r'[úùüû]', 'u', regex=True)
        .str.replace(r'[^a-z0-9 ]', '', regex=True)
        .str.replace(r'\s+', '_', regex=True)
    )

class TripDensity:
    _cache_file = "./cache/trip_density.pkl"
    _loading_cache = False

    def __new__(cls, *args, **kwargs):
        if cls._loading_cache:
            return super().__new__(cls)

        if os.path.exists(cls._cache_file):
            cls._loading_cache = True
            with open(cls._cache_file, 'rb') as f:
                instance = pickle.load(f)
            cls._loading_cache = False
            print("Loaded TripDensity from cache")
            return instance
        
        instance = super().__new__(cls)
        return instance

    def section_of_point(self, lat: float, lon: float) -> int:
        p = Point(lon, lat)
        row = self.sections[self.sections.contains(p)]
        return int(row["CUDIS"].iloc[0])

    def __init__(self):
        # Comprobar si ya estan cacheados
        if hasattr(self, '_initialized') and self._initialized:
            return

        # Recoger los datos
        self.sections = geopandas.read_file("./raw_data/sections_gipuzkoa.geojson")
        self.sections = self.sections.to_crs(epsg=25830)

        trips_2021 = pandas.read_csv("./raw_data/datos_2021.csv", sep=';', encoding='latin1')
        trips_2022 = pandas.read_csv("./raw_data/datos_2022.csv", sep=';', encoding='latin1')

        trips_2021.columns = normalize_columns(trips_2021.columns)
        trips_2022.columns = normalize_columns(trips_2022.columns)

        self.trips = pandas.concat([trips_2021, trips_2022], ignore_index=True)
        self.stations = pandas.read_csv("./raw_data/Stations_new.csv")

        # Calcular distribuciones
        # Voy a trabajar con P(START=x)
        # y P(END=y | START=x)
        start_section_weights = defaultdict(int)
        end_station_weights = defaultdict(lambda: defaultdict(int))

        failed_trips = 0
        print("Se va a tener que iterar sobre todos los datos de viajes. SON MUCHOS, va a tardar un rato")
        for idx, trip in self.trips.iterrows():
            # Hay algunos que no tienen estacion de inicio o fin -> sacarlos fuera
            try:
                start_station_id = int(trip["id_de_estacion_de_inicio"])
                end_station_id = int(trip["id_de_estacion_de_fin_de_viaje"])
            except:
                failed_trips += 1
                print(f"Trip {idx} has no start or end station")
                continue

            start_station = self.stations[self.stations["ID"] == start_station_id]
            end_station = self.stations[self.stations["ID"] == end_station_id]

            # Hay algunos que no estan en una seccion -> sacarlos fuera
            try:
                start_section = self.section_of_point(float(start_station["Latitude"].iloc[0]), float(start_station["Longitude"].iloc[0]))
                end_section = self.section_of_point(float(end_station["Latitude"].iloc[0]), float(end_station["Longitude"].iloc[0]))
            except:
                failed_trips += 1
                print(f"Trip {idx} has no matching start or end section")
                continue

            start_section_weights[start_section] += 1
            end_station_weights[start_section][end_section] += 1
        
        print(f"Lost {failed_trips} trips due to incomplete data")

        # Guardar datos en un formato usable
        self.start_section_values = list(start_section_weights.keys())
        self.start_section_weights = list(start_section_weights.values())

        self.end_section_values = {}
        self.end_section_weights = {}
        for start_section, end_section_weight in end_station_weights.items():
            self.end_section_values[start_section] = list(end_section_weight.keys())
            self.end_section_weights[start_section] = list(end_section_weight.values())

        # Guardar en cache
        self._initialized = True
        with open(self._cache_file, 'wb') as f:
            pickle.dump(self, f)
        print("Saved TripDensity to cache")

    # Generates a random trip and returns it from and to section
    def sample_trip(self) -> Tuple[int, int]:
        start_section = random.choices(self.start_section_values, weights=self.start_section_weights, k=1)[0]
        end_section = random.choices(self.end_section_values[start_section], weights=self.end_section_weights[start_section], k=1)[0]
        return (start_section, end_section)
