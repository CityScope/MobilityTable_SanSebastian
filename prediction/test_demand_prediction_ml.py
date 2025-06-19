import common

demand = common.DemandPredictor()
print(demand.predict(start_section_id=2006901002, num_stations_start=10, end_section_id=2006907034, num_stations_end=10, hour=11))