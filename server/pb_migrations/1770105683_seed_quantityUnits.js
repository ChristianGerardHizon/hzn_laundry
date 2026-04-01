/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_quantityunits")

  const defaultUnits = [
    { name: "pieces", shortSingular: "pc", shortPlural: "pcs", longSingular: "piece", longPlural: "pieces" },
    { name: "kilograms", shortSingular: "kg", shortPlural: "kg", longSingular: "kilogram", longPlural: "kilograms" },
    { name: "loads", shortSingular: "load", shortPlural: "loads", longSingular: "load", longPlural: "loads" },
    { name: "meters", shortSingular: "m", shortPlural: "m", longSingular: "meter", longPlural: "meters" },
    { name: "liters", shortSingular: "L", shortPlural: "L", longSingular: "liter", longPlural: "liters" },
    { name: "bags", shortSingular: "bag", shortPlural: "bags", longSingular: "bag", longPlural: "bags" },
    { name: "sets", shortSingular: "set", shortPlural: "sets", longSingular: "set", longPlural: "sets" },
    { name: "bottles", shortSingular: "btl", shortPlural: "btls", longSingular: "bottle", longPlural: "bottles" },
    { name: "boxes", shortSingular: "box", shortPlural: "boxes", longSingular: "box", longPlural: "boxes" },
    { name: "pairs", shortSingular: "pair", shortPlural: "pairs", longSingular: "pair", longPlural: "pairs" },
  ]

  for (const unit of defaultUnits) {
    const record = new Record(collection)
    record.set("name", unit.name)
    record.set("shortSingular", unit.shortSingular)
    record.set("shortPlural", unit.shortPlural)
    record.set("longSingular", unit.longSingular)
    record.set("longPlural", unit.longPlural)
    record.set("isDeleted", false)
    app.save(record)
  }
}, (app) => {
  // Down migration: delete all seeded units
  const collection = app.findCollectionByNameOrId("pbc_quantityunits")
  const records = app.findRecordsByFilter(collection, "1=1", "-created", 100, 0)
  for (const record of records) {
    app.delete(record)
  }
})
