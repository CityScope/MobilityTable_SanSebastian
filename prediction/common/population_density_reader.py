from typing import List, Tuple
import pandas
import geopandas
from sklearn.cluster import KMeans
import pickle
import os

POPULATION_DENSITY_CACHE_PATH = "./cache/population_density.pkl"

class PopulationDensity:
    # List of coordinates (f64, f64) where how many times each appears is its density
    density = []

    def __init__(self, use_cache=True) -> None:
        # use cached if exists
        if use_cache and os.path.exists(POPULATION_DENSITY_CACHE_PATH):
            with open(POPULATION_DENSITY_CACHE_PATH, "rb") as file:
                self.density = pickle.load(file)
            return

        sections_data = geopandas.read_file("./raw_data/buildings_w_section.shp")

        indicators = pandas.read_excel("./raw_data/indicators.xlsx")
        indicators_subset = indicators[indicators["Municipio"] == "Donostia/San"]

        for section_id, population in zip(indicators_subset["Seccion"], indicators_subset["Población"]):
            features = sections_data[sections_data["Seccion"] == str(section_id)]

            if features.empty:
                print(f"Features with Seccion='{section_id}' not found")
                continue

            for _ in range(int(population)):
                # TODO: instead of just hoping that the data is uniform enough by picking random samples
                # pick n of each untill population and pick the remaining at random
                centroid = features.sample().geometry.centroid

                self.density.append((centroid.x.iloc[0], centroid.y.iloc[0]))

        os.makedirs(os.path.dirname(POPULATION_DENSITY_CACHE_PATH), exist_ok=True)
        with open(POPULATION_DENSITY_CACHE_PATH, "wb") as file:
            pickle.dump(self.density, file)

    def k_means(self, k: int) -> List[Tuple[float, float]]:
        kmeans = KMeans(n_clusters=k)
        kmeans.fit(self.density)

        return kmeans.cluster_centers_
