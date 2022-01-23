import "experimental"
import "array"


FillRange = (
            //timeRangeStart = experimental.subDuration(d:48h,from: now()),
            //timeRangeStop = now(),
            timeRangeStart = v.timeRangeStart,
            timeRangeStop = v.timeRangeStop,
            bucket = "homeassistant",
            field_filter = "value",
            measurement_filter = "°C",
            domain_filter = "sensor",
            entity_id_filter = "warmwasser_umwelzpumpe_status",
            display_name = "display_name",
            default_fill_value_start = 0.0,
            default_fill_value_end = 0.0,
            look_around_time = 24h) =>
{
Data=from(bucket: bucket)
  |> range(start: timeRangeStart, stop: timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)


  
FillRecord1 = from(bucket: bucket)
  |> range(start: experimental.subDuration(d: look_around_time, from: timeRangeStart), stop: timeRangeStart)  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> last()
  |> findRecord(fn: (key) => true, idx: 0)

FillRecord2 = from(bucket: bucket)
  |> range(start: timeRangeStart, stop: timeRangeStop)  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> last()
  |> findRecord(fn: (key) => true, idx: 0)
  
FillValue1 = if (exists FillRecord1._value) then FillRecord1._value 
             else if (exists FillRecord2._value) then FillRecord2._value  
             else default_fill_value_start

FillRecord3 = from(bucket: bucket)
  |> range(start: timeRangeStart, stop: timeRangeStop)  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> last()
  |> findRecord(fn: (key) => true, idx: 0)

FillRecord4 = from(bucket: bucket)
  |> range(start: timeRangeStop, stop: experimental.addDuration(d: look_around_time, to: timeRangeStop))  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> first()
  |> findRecord(fn: (key) => true, idx: 0)


FillValue2 = if (exists FillRecord3._value) then FillRecord3._value 
             else if (exists FillRecord4._value) then FillRecord4._value
             else default_fill_value_end

start_rec = [
  {_start: timeRangeStart,
  _stop: timeRangeStop,
  _time: timeRangeStart,
  _value: FillValue1,
  _field: field_filter,
  _measurement: measurement_filter,
  domain: domain_filter,
  entity_id :entity_id_filter}
]

stop_rec = [
  {_start: timeRangeStart,
  _stop: timeRangeStop,
  _time: timeRangeStop,
  _value: FillValue2,
  _field: field_filter,
  _measurement: measurement_filter,
  domain: domain_filter,
  entity_id :entity_id_filter}
]


FirstRow = array.from(rows:start_rec)
LastRow = array.from(rows:stop_rec)


Table = union(tables: [FirstRow,Data,LastRow])
  |> set(key: "entity_id", value: display_name)
  |>  group(columns: ["entity_id"], mode: "by")
  //|> aggregateWindow(every: 10m, fn: mean, createEmpty: true)
  //|> fill(column: "_value", usePrevious: true)
  |> window(every:inf,timeColumn:"_time")
  |> sort(columns: ["_time"], desc: false)
return Table  
}
FillRange (entity_id_filter:"temperature_1",display_name: "Keller hinten")
  |> yield(name: "Keller hinten")
FillRange (entity_id_filter:"temperature_2",display_name: "Arbeitszimmer")
  |> yield(name: "Arbeitszimmer")
FillRange (entity_id_filter:"temperature_3",display_name: "Schlafzimmer")
  |> yield(name: "Schlafzimmer")
FillRange (entity_id_filter:"temperature_4",display_name: "Garage")
  |> yield(name: "Garage")
FillRange (entity_id_filter:"temperature_5",display_name: "Badezimmer")
  |> yield(name: "Badezimmer")      
FillRange (entity_id_filter:"temperature_6",display_name: "Terrasse")
  |> yield(name: "Terrasse")      
FillRange (entity_id_filter:"temperature_7",display_name: "Flur")
  |> yield(name: "Flur")      
FillRange (entity_id_filter:"temperature_8",display_name: "Wohnzimmer")
  |> yield(name: "Wohnzimmer")
FillRange (entity_id_filter:"indoor_temperature",display_name: "Anschlussraum")
  |> yield(name: "Anschlussraum")

