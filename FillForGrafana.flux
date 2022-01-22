import "experimental"
import "array"

bucket = "homeassistant"
field_filter = "value"
measurement_filter = "state"
domain_filter = "binary_sensor"
entity_id_filter = "warmwasser_umwelzpumpe_status"

Data=from(bucket: "homeassistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)

  
FillRecord1 = from(bucket: "homeassistant")
  |> range(start: experimental.subDuration(d: 24h, from: v.timeRangeStart), stop: v.timeRangeStart)  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> last()
  |> findRecord(fn: (key) => true, idx: 0)
FillValue1 = if (exists FillRecord1._value) then FillRecord1._value else 0.0  

FillRecord2 = from(bucket: "homeassistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)  
  |> filter(fn: (r) => r["_measurement"] == measurement_filter)
  |> filter(fn: (r) => r["_field"] == field_filter)
  |> filter(fn: (r) => r["domain"] == domain_filter)
  |> filter(fn: (r) => r["entity_id"] == entity_id_filter)
  |> last()
  |> findRecord(fn: (key) => true, idx: 0)
FillValue2 = if (exists FillRecord2._value) then FillRecord2._value else 0.0

start_rec = [
  {_start: v.timeRangeStart,
  _stop: v.timeRangeStop,
  _time: v.timeRangeStart,
  _value: FillValue1,
  _field: field_filter,
  _measurement: measurement_filter,
  domain: domain_filter,
  entity_id :entity_id_filter}
]

stop_rec = [
  {_start: v.timeRangeStart,
  _stop: v.timeRangeStop,
  _time: v.timeRangeStop,
  _value: FillValue2,
  _field: field_filter,
  _measurement: measurement_filter,
  domain: domain_filter,
  entity_id :entity_id_filter}
]


FirstRow = array.from(rows:start_rec)
LastRow = array.from(rows:stop_rec)


Table = union(tables: [FirstRow,Data,LastRow])
  |> group()
  |> window(every:inf,timeColumn:"_time")
  |> sort(columns: ["_time"], desc: false)

Table




