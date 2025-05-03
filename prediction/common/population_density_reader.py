from typing import List, Tuple
import pandas
import geopandas
from sklearn.cluster import KMeans

class PopulationDensity:
    # List of coordinates (f64, f64) where how many times each appears is its density
    density = []

    def __init__(self) -> None:
        sections_geojson = geopandas.read_file("./raw_data/sections_gipuzkoa.geojson")
        sections_geojson = sections_geojson.to_crs(epsg=25830)

        indicators = pandas.read_excel("./raw_data/indicators.xlsx")
        indicators_subset = indicators[indicators["Municipio"] == "Donostia/San"]

        for section_id, population in zip(indicators_subset["Seccion"], indicators_subset["Población"]):
            feature = sections_geojson[sections_geojson["CUSEC"] == str(section_id)]

            if feature.empty:
                print(f"Feature with CUSEC='{section_id}' not found")
                continue

            centroid = feature.geometry.centroid

            self.density.extend([(centroid.x.iloc[0], centroid.y.iloc[0])] * int(population))

    def k_means(self, k: int) -> List[Tuple[float, float]]:
        kmeans = KMeans(n_clusters=k)
        kmeans.fit(self.density)

        return kmeans.cluster_centers_
