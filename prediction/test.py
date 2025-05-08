from station_allocators.k_means_allocator import KMeansAllocator

allocator = KMeansAllocator(max_stations=100, min_sations=10)
allocator.show(max=150)
