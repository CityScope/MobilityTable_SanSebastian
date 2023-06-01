/**
* Name: test
* Based on the internal empty template. 
* Author: naroacorettisanchez
* Tags: 
*/


model test

global{
	
	float step <- 2 #sec;
	
	 //--------------------------Demand Parameters-----------------------------
    string cityDemandFolder <- "./../includes/Demand";

    csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_demand_cambridge_oct7_2019_week.csv",true); 
    
    //Simulation starting date
	date starting_date <- date("2019-10-07 00:00:00"); 
	

	init{
				create people from: demand_csv with:
				[start_hour::date(get("starttime"))
					]{
					
					
					string start_day_str <- string(start_hour, 'dd');
					int start_day <- int(start_day_str);
					
					string start_h_str <- string(start_hour,'kk');
					int start_h <- int(start_h_str);
					string start_min_str <- string(start_hour,'mm');
					int start_min <- int(start_min_str);
					
					
					write 'start '+(start_day);
					write 'current '+ (current_date.day);
					
					//write "Start "+start_point+ " " +start_h+ ":"+ start_min;
					
			}
	}
}

species people{
	
	date start_hour;
	
}


experiment test type: gui{
}


/* Insert your model definition here */

