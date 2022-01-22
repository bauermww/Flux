
The query can be used in Grafana to work arround missing values at begin and end of timeRangeStart - timeRangeStop 
- it add a record at timeRangeStart with the last value from a previous time frame
- it add a record at timeRangeStop with the last value from the current range

Tested with Homeassistant, 2021.12.10, Grafana 8.3.3 and Influxdb 2.1.1
