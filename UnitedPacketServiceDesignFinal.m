%[text] # Creating a WirelessNetwork Object
%[text] We begin by creating a `WirelessNetwork` object and assign it to `net`, which is the name of the variable that describes our network.
net = WirelessNetwork %[output:6701acb7]
%%
%[text] # Managing Channels
%[text] We have purchased the licenses to 21 RF channels. We are going to use sectorization in this network to reduce interference and increase overall coverage. We would also like to have 3 channel sets (think of this as clusters of size N=3). Because 21 is divisible by 3, each station can have the same number of channels.
%[text] We can specify our channel sets as a vector containing three 7s. This will change once we sectorize the network, but serves as a good illustration of how the channels are split up amongst the cells.
net.channel_sets = [7 7 7] %[output:9c638979]
%[text] This verifies that the total number of channels in the channel set does not exceeed the number of channels we are purchasing.
total_channels = sum(net.channel_sets) %[output:0778e216]
%%
%[text] # Estimating the Number of Base Stations
%[text] Before we start placing our base stations, we need to estimate how many we can afford.  As described in WirelessProjectPart1.mlx, each base station has a fixed cost of \\$250,000 (meant to include the cost of the property it is located on, the tower struture, and the networking/power resources provided to it) plus \\$25,000 per RF channel's transciever (meant to be the cost of the radio equipment).   Because our channel sets all use 7 channels, the cost of each base station is 250+7\*25=\\$425,000.   
%[text] Suppose our total budget is \\$20,000,000.  We have licensed 21 RF channels, which cost \\$500,000 each.  Thus the cost of our spectrum licenses is 21\*500 = \\$10,500,000.  Given our overall budget, this leaves \\$9,500,000 for base stations.  We can afford 9500/425 = 22.35 base stations. We will have to round down and only buy 22 base stations to remain within our budget.
%%
%[text] # Adding the First Cluster of Base Stations
%[text] We used a hexagonal structure of base stations with a cluster size N=3. This works well with our channel set being evenly divided three ways.
net.CreateCentralCluster(3,0) %[output:1f322582]
net.MapCoverage
%%
%[text] # Adding the First Layer of Interferance
%[text] We used the provided methods to provide the first layer of interferance for our network and automate the placement of base stations around the center of the map. This creates a total of 21 base stations, which leaves enough money to place an additional base staion. This issue is resolved in a later step.
net.CreateFirstTier(3) %[output:4c3feabc]
net.MapCoverage
%%
%[text] # Centering Network on Map
%[text] To match the map coordinates, we resized and moved our entire network structure so that it was centered in the middle of the city map.
bs_expanded = 50*net.bs_locations;
bs_shift = bs_expanded + 340 + 300*1i;
net.bs_locations = bs_shift;
%%
%[text] # Repositioning Base Stations
%[text] We need to create a network containing 22 base stations to maximize our budget. To do this, we need to add one base station to the network.
%[text] Before this, we decided to optimize the layout of the pre-existing 21 base stations in the network. We did this by looking at the network coverage map and the map of attempted calls at 19:00, the busiest hour of the day. Through examination of the coverage maps, SINR Map, and overall connection percentage, we determined a more efficient network using a process of trial and error.
%[text] Then, we added the 22nd base station, testing multiple positions before deciding that the position that would provide the best network performance.
net.RemoveBase(20)
net.AddBase(480+160*i, 2, 40) %12
net.RemoveBase(17)
net.AddBase(315+140*i, 2, 40) %13
net.RemoveBase(13)
net.AddBase(125+250i, 1, 40) %14
net.RemoveBase(12)
net.AddBase(150+500i, 3, 40) %15
net.RemoveBase(9)
net.AddBase(375+500*i, 3, 40) %16
net.RemoveBase(5)
net.AddBase(500+270*i, 2, 38) %17
net.RemoveBase(4)
net.AddBase(400+280*i, 1, 32) %18
net.RemoveBase(2)
net.AddBase(340+300*i, 2, 32) %19
net.RemoveBase(14)
net.AddBase(425+175*i, 2, 30) %20
net.RemoveBase(13)
net.AddBase(350+230*i, 3, 30) %21

% Add the 22nd base station
net.AddBase(100+150*i, 3, 40) 

net.MapCoverage
%%
%[text] # Sectorizing the Network
%[text] We decided to divide each cell into 3 sectors to limit interference. We compared these results to a variety of network options featuring both no sectorization and 6 sectors per cell, and found that 3 sectors was by far the best option. Because each cell has 7 RF channels, the sectors have unequal numbers of RF channels. We divided the RF channels as evenly as possible in each cell, with one sector having 3 channels, and the other 2 sectors having 2 channels each. Additionally, we tested a range of angle offsets, finding that a 15 degree offset produced the best results.
net.Sectorize(3, 15*pi/180) %[output:3ca0d4a8]
net.channel_sets = [3 2 2 3 2 2 3 2 2] %[output:05c502ae]
net.bs_channels %[output:80472269]
net.channel_sets %[output:6312b886]
sum(net.channel_sets) %[output:95d7c131]
%%
%[text] # Setting Network Power
%[text] We also experimented with variations in transmitting power between base stations. The stations on the interior of the network, which were focused around areas with high calling activity, had a lower transmitting power to limit their range, making them less susceptible to being overwhelmed by call requests. Inversely, the stations on the outside of the network had higher transmitting power to compensate for a lower density of call requests. Additionally, we tested variations in transmitting power between sectors. Through trial and error, we found the highest-performing combination of transmit powers for the network we constructed.
bs_power_dBm = [30 30 30; 30 30 30; 38 40 38; 40 40 35; 30 30 40; 37 31 40; 31 40 38; 37 33 36; 32 37 30; 37 37 37; 37 37 37; 40 40 40; 37 37 37; 38 38 38; 40 40 40; 40 40 40; 40 40 40; 38 38 38; 35 35 35; 36 40 40; 30 30 30; 40 40 40] %[output:83aa2f15]
net.SetPower(bs_power_dBm)
%%
%[text] # Analyzing the Network
%[text] ## Coverage Map
%[text] This generates a map of the areas covered by each base station.
net.MapCoverage
%[text] ## SINR Outage Map
%[text] This generates a map of the areas that meet the minimum SINR requirement for users to be connected to the network.
net.MapSINR %[output:1016a063]
%[text] ## City Map with Mobiles at 19:00 Superimposed
%[text] This generates a city map of all the users within the city at 19:00, the hour with the highest volume of network traffic. Blue dots indicate users that meet the minimum SINR requirements to be covered by the network. Red dots indicate users that do not meet the minimum SINR requirements to be covered by the network.
net.MapCity( ms_locations{19} ) %[output:1d944f78]
%[text] ## Coverage Map with Mobiles at 19:00 Superimposed
%[text] This generates a coverage map of all the users within the within the city at 19:00, the hour with the highest volume of network traffic. Black dots indicate users that meet the minimum SINR requirements to be covered by the network. Black crosses indicate users that do not meet the minimum SINR requirements to be covered by the network.
net.MapMobiles( ms_locations{19} ) %[output:68ef1245]
%[text] ## Connected Users, Call Attempts, and Number Over Threshold by Hour
%[text] This plots the number of attempted calls per hour, along with the number of those calls that is covered by the network and the number of those calls that is connected to the network.
[num_connected, num_over_thresh] = net.AnalyzeNetwork( ms_locations ) %[output:89afe6a7] %[output:8e0b56e5]
plot( 1:length(call_attempts), call_attempts, '-k', ...
    1:length(call_attempts), num_over_thresh, '-r', ...
    1:length(call_attempts), num_connected, '-b' );
xlabel( 'time (in hours)' );
ylabel( 'number calls' );
legend( 'call attempts', 'number covered', 'number connected' );
%[text] ## Connected and Covered Users by Hour
%[text] This plots the fraction of attempted calls that are covered by the network, along with the fraction of attempted calls that are connected to the network.
fraction_over_thresh = num_over_thresh./call_attempts;
fraction_connected = num_connected./call_attempts;
plot( 1:length(call_attempts), fraction_over_thresh, '-r', ...
    1:length(call_attempts), fraction_connected, '-b');
xlabel( 'time (in hours)' );
ylabel( 'fraction' );
legend( 'fraction covered', 'fraction connected');
%[text] ## Network Cost in Dollars
%[text] This computes the cost of the network in tens of thousands of dollars.
net.ComputeCost %[output:7d006140]
actual_cost = net.ComputeCost * 1000 %[output:24ce6569]
fprintf( 'The cost of the network is $%10.2f\n', actual_cost) %[output:9199b7a0]
%[text] ## Total Number of Connected Users
%[text] This computes the total number of calls that were successfully connected to the network over the span of a day.
sum(num_connected) %[output:620d249e]
%[text] ## Total Number of Call Attempts
%[text] This computes the total number of attempted calls made on the network over the span of a day.
sum( call_attempts ) %[output:3f4cbcdc]
%[text] ## Total Percentage of Users Connected
%[text] This computes the percentage of attempted calls that were successfully connected to the network over the span of a day.
percent_connected = sum(num_connected)/sum(call_attempts);
fprintf( 'The percentage connected is %2.2f%%n', 100*percent_connected) %[output:5317e30d]
%%
%[text] # Preliminary Network Draft
net.MapCity %[output:1eb612b7]
%%
%[text] # Saving the Network
%[text] This saves our network file as "UnitedPacketServiceFinal.mat"
net.Save("UnitedPacketServiceFinal.mat")

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":35.2}
%---
%[output:6701acb7]
%   data: {"dataType":"textualVariable","outputData":{"name":"net","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: []\n            bs_channels: []\n           bs_power_dBm: []\n           channel_sets: []\n    sector_offset_angle: 0\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: []\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: []\n"}}
%---
%[output:9c638979]
%   data: {"dataType":"textualVariable","outputData":{"name":"net","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: []\n            bs_channels: []\n           bs_power_dBm: []\n           channel_sets: [7 7 7]\n    sector_offset_angle: 0\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: []\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: []\n"}}
%---
%[output:0778e216]
%   data: {"dataType":"textualVariable","outputData":{"name":"total_channels","value":"21"}}
%---
%[output:1f322582]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: [3×1 double]\n            bs_channels: [3×1 double]\n           bs_power_dBm: [3×1 double]\n           channel_sets: [7 7 7]\n    sector_offset_angle: 0\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: []\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: []\n"}}
%---
%[output:4c3feabc]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: [21×1 double]\n            bs_channels: [21×1 double]\n           bs_power_dBm: [21×1 double]\n           channel_sets: [7 7 7]\n    sector_offset_angle: 0\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: []\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: []\n"}}
%---
%[output:3ca0d4a8]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: [22×1 double]\n            bs_channels: [22×3 double]\n           bs_power_dBm: [22×3 double]\n           channel_sets: [1 1 1 1 1 1 1 1 1]\n    sector_offset_angle: 0.2618\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: [22×3 double]\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: 11650\n"}}
%---
%[output:05c502ae]
%   data: {"dataType":"textualVariable","outputData":{"name":"net","value":"  <a href=\"matlab:helpPopup('WirelessNetwork')\" style=\"font-weight:bold\">WirelessNetwork<\/a> with properties:\n\n           bs_locations: [22×1 double]\n            bs_channels: [22×3 double]\n           bs_power_dBm: [22×3 double]\n           channel_sets: [3 2 2 3 2 2 3 2 2]\n    sector_offset_angle: 0.2618\n         map_resolution: 250\n              noise_dBm: -100\n            pl_exponent: 3\n            SINR_thresh: 10\n         ms_per_channel: 10\n              max_users: [22×3 double]\n           map_filename: 'Morgantown'\n          save_filename: 'MyProject'\n                   cost: 11650\n"}}
%---
%[output:80472269]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"ans","rows":22,"type":"double","value":[["1","4","7"],["3","6","9"],["3","6","9"],["1","4","7"],["2","5","8"],["1","4","7"],["2","5","8"],["2","5","8"],["3","6","9"],["1","4","7"],["3","6","9"],["1","4","7"],["2","5","8"],["1","4","7"],["3","6","9"]]}}
%---
%[output:6312b886]
%   data: {"dataType":"matrix","outputData":{"columns":9,"name":"ans","rows":1,"type":"double","value":[["3","2","2","3","2","2","3","2","2"]]}}
%---
%[output:95d7c131]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"21"}}
%---
%[output:83aa2f15]
%   data: {"dataType":"matrix","outputData":{"columns":3,"name":"bs_power_dBm","rows":22,"type":"double","value":[["30","30","30"],["30","30","30"],["38","40","38"],["40","40","35"],["30","30","40"],["37","31","40"],["31","40","38"],["37","33","36"],["32","37","30"],["37","37","37"],["37","37","37"],["40","40","40"],["37","37","37"],["38","38","38"],["40","40","40"]]}}
%---
%[output:1016a063]
%   data: {"dataType":"text","outputData":{"text":"Covering 94.27 percent of the area with sufficient SINR\nworst case SINR is -1.031843\n","truncated":false}}
%---
%[output:1d944f78]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"ans","value":"       cdata: [275×434×3 uint8]\n    colormap: []\n"}}
%---
%[output:68ef1245]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"ans","value":"       cdata: [275×434×3 uint8]\n    colormap: []\n"}}
%---
%[output:89afe6a7]
%   data: {"dataType":"matrix","outputData":{"columns":24,"name":"num_connected","rows":1,"type":"double","value":[["469","377","287","190","240","433","568","844","1065","986","980","1229","1259","1146","1127","1165","1263","1264","1322","1287","1231","1079","901","708"]]}}
%---
%[output:8e0b56e5]
%   data: {"dataType":"matrix","outputData":{"columns":24,"name":"num_over_thresh","rows":1,"type":"double","value":[["469","377","287","190","240","433","571","862","1180","1030","1024","1518","1610","1323","1275","1374","1657","1703","1895","1752","1509","1184","945","710"]]}}
%---
%[output:7d006140]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"19825"}}
%---
%[output:24ce6569]
%   data: {"dataType":"textualVariable","outputData":{"name":"actual_cost","value":"19825000"}}
%---
%[output:9199b7a0]
%   data: {"dataType":"text","outputData":{"text":"The cost of the network is $19825000.00\n","truncated":false}}
%---
%[output:620d249e]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"21420"}}
%---
%[output:3f4cbcdc]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"26550"}}
%---
%[output:5317e30d]
%   data: {"dataType":"text","outputData":{"text":"The percentage connected is 80.68%n","truncated":false}}
%---
%[output:1eb612b7]
%   data: {"dataType":"textualVariable","outputData":{"header":"struct with fields:","name":"ans","value":"       cdata: [275×434×3 uint8]\n    colormap: []\n"}}
%---
