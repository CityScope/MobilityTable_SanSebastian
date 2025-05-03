from typing import List, Tuple
from pandas.core.frame import Iterable
from pandas.io.formats.style_render import Optional
from common import PopulationDensity
from pyproj import Transformer
from math import sqrt

import folium
import webbrowser

class Allocator:
    def __init__(self) -> None:
        self.population_density = PopulationDensity()
        self.points: List[Tuple[float, float]] = []

    @staticmethod
    def distance(p1: Tuple[float, float], p2: Tuple[float, float]) -> float:
        dif_x = p1[0] - p2[0]
        dif_y = p1[1] - p2[1]
        return sqrt(dif_x * dif_x + dif_y * dif_y)

    @staticmethod
    def point_eq(p1: Tuple[float, float], p2: Tuple[float, float]) -> bool:
        return p1[0] == p2[0] and p1[1] == p2[1]

    @staticmethod
    def filter_lonely(points: List[Tuple[float, float]], max_distance: float) -> Iterable[Tuple[float, float]]:
        def has_other_within_range(point: Tuple[float, float]) -> bool:
            return any(Allocator.distance(point, other_point) <= max_distance and not Allocator.point_eq(point, other_point) for other_point in points)

        return filter(has_other_within_range, points)

    def latlon_points(self) -> Iterable[Tuple[float, float]]:
        transformer = Transformer.from_crs("EPSG:25830", "EPSG:4326", always_xy=True)
        return map(lambda p: transformer.transform(p[0], p[1])[::-1], self.points)

    def show(self, max: Optional[int] = None) -> None:
        points = list(self.latlon_points())
        if max:
            points = points[:max]

        map_to_show = folium.Map(location=points[0], zoom_start=12)
        for lat, lon in points:
            folium.Marker([lat, lon]).add_to(map_to_show)
        map_to_show.save("map.html")
        webbrowser.open("map.html")
