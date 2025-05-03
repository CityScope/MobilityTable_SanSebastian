from station_allocators.allocator import Allocator

# TODO: basicaly everithing, filtering, ordering...
class KMeansAllocator(Allocator):
    def __init__(self, max_stations: int) -> None:
        super().__init__()
        self.points = self.population_density.k_means(max_stations)
