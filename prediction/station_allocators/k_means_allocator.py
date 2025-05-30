from typing import List, Tuple
from station_allocators.allocator import Allocator
from sklearn.cluster import KMeans

class KMeansAllocator(Allocator):
    @staticmethod
    def k_means(points: List[Tuple[float, float]], k: int) -> List[Tuple[float, float]]:
        kmeans = KMeans(n_clusters=k)
        kmeans.fit(points)

        return kmeans.cluster_centers_

    @staticmethod
    def closest_point(point: Tuple[float, float], points: List[Tuple[float, float]]) -> Tuple[float, float]:
        closest_distance = KMeansAllocator.distance(point, points[0])
        closest_point = points[0]

        for other_point in points:
            if KMeansAllocator.distance(point, other_point) < closest_distance:
                closest_distance = KMeansAllocator.distance(point, other_point)
                closest_point = other_point

        return closest_point

    def __init__(self, max_stations: int, min_sations: int, min_station_radious: float) -> None:
        super().__init__()
        all_points = self.population_density.k_means(max_stations)
        filtered_points = KMeansAllocator.filter_lonely(all_points, min_station_radious)

        # Do the recursive / Ordering Stuff
        points_by_depth = [list(filtered_points)]
        k: int = max_stations // 2
        current_depth = 0
        while k > min_sations:
            new_points = KMeansAllocator.k_means(points_by_depth[current_depth], k)
            new_valid_points = []
            for point in new_points:
                new_valid_points.append(KMeansAllocator.closest_point(point, points_by_depth[current_depth]))

            points_by_depth.append(new_valid_points)

            k //= 2
            current_depth += 1

        # Process all the points by depth (reverse -> flatten -> dedup)
        points = points_by_depth[::-1]
        flattened_points = [point for depth in points for point in depth]

        deduped_points = []
        seen = set()
        for point in flattened_points:
            if not any(KMeansAllocator.point_eq(point, seen_point) for seen_point in seen):
                deduped_points.append(point)
                seen.add((point[0], point[1]))

        self.points = deduped_points
