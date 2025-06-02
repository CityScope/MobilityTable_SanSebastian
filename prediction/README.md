Create the following two folders:

1) 'raw_data' --> Include: https://drive.google.com/file/d/1a4B5nZUXbjs9furVmVTBxQvFybyqOXUa/view?usp=sharing

2) 'processed_data' --> Include: https://drive.google.com/file/d/1nzcrKq3jcDcqx9fD-5HO0yKHYjVwzySs/view?usp=sharing

## Generate station positions
To generate new station positions run the **generate_stations.py** script. It will generate a new csv file on **"./processed_data/station_positions.csv"**

This process is not deterministic, so if the stations dont look good enough you can rerun this untill a nice configuration is found.

If no configuration looks reasonable, the density data might not have an even spread (since it's generation is also non-deterministic). In that case run **generate_density_data.py** to regenerate the data
