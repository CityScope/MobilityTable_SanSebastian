from typing import List, Tuple
from common import PopulationDensity

import folium
import webbrowser

class Allocator:
    def __init__(self) -> None:
        self.population_density = PopulationDensity()
        self.points: List[Tuple[float, float]] = []

    def show(self) -> None:
        map = folium.Map(location=self.points[0], zoom_start=12)
        for lat, lon in self.points:
            folium.Marker([lat, lon]).add_to(map)
        map.save("map.html")
        webbrowser.open("map.html")
