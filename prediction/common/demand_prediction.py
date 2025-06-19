import pandas as pd
from xgboost import XGBRegressor

class DemandPredictor():
    def __init__(self):
        avg_trips = pd.read_csv('./processed_data/avg_trips_forprediction.csv')
        self.data = avg_trips

        features = avg_trips.columns.difference(["avg_trips", "log_avg_trips", "weights", "stratify_group",'hour_c', 'Seccion_init_c', 'Seccion_end_c', 'num_stations_c', 'num_stations_end_c'])
        self.features = features
        target = "log_avg_trips"

        data = avg_trips
        X = data[features]
        Y = data[target]

        # Model Training
        xgb_model = XGBRegressor(n_estimators=300, learning_rate=0.1, subsample=0.8, max_depth=7, random_state=42)
        xgb_model.fit(X, Y, )

        self.model = xgb_model

    def predict(self, start_section_id: int, num_stations_start: int, end_section_id: int, num_stations_end: int, hour: int):
        x = self.data[(self.data["Seccion_init_c"] == start_section_id) & (self.data["Seccion_end_c"] == end_section_id) & (self.data["day_of_week"] == 4) & (self.data["hour_c"] == hour)]
        x = x[self.features]
        x.iloc[0, x.columns.get_loc('num_stations')] = num_stations_start
        x.iloc[0, x.columns.get_loc('num_stations_end')] = num_stations_end
        return self.model.predict(x)[0]
