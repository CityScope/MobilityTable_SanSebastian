from station_allocators.k_means_allocator import KMeansAllocator

allocator = KMeansAllocator(max_stations=300, min_sations=40, min_station_radious=300.)
allocator.show(max=67)
allocator.save_csv("./processed_data/station_positions.csv")
