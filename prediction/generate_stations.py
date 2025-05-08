from station_allocators.k_means_allocator import KMeansAllocator

allocator = KMeansAllocator(max_stations=150, min_sations=40)
allocator.show(max=67)
allocator.save_csv("./processed_data/station_positions.csv")
