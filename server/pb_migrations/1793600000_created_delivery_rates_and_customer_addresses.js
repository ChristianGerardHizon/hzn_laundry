/// <reference path="../pb_data/types.d.ts" />
// Delivery rates (per branch) and saved customer delivery addresses.
// Additive only. The old single-fee fields on `branches` are kept in the schema
// (the app no longer uses them) and migrated into a default "Standard" rate.
migrate((app) => {
  const autodates = (prefix) => [
    {
      hidden: false,
      id: "autodate_" + prefix + "_created",
      name: "created",
      onCreate: true,
      onUpdate: false,
      presentable: false,
      system: false,
      type: "autodate",
    },
    {
      hidden: false,
      id: "autodate_" + prefix + "_updated",
      name: "updated",
      onCreate: true,
      onUpdate: true,
      presentable: false,
      system: false,
      type: "autodate",
    },
  ];

  const idField = {
    autogeneratePattern: "[a-z0-9]{15}",
    hidden: false,
    id: "text3208210256",
    max: 15,
    min: 15,
    name: "id",
    pattern: "^[a-z0-9]+$",
    presentable: false,
    primaryKey: true,
    required: true,
    system: true,
    type: "text",
  };

  const text = (id, name, extra) =>
    Object.assign(
      {
        autogeneratePattern: "",
        hidden: false,
        id: id,
        max: 0,
        min: 0,
        name: name,
        pattern: "",
        presentable: false,
        primaryKey: false,
        required: false,
        system: false,
        type: "text",
      },
      extra || {}
    );

  const number = (id, name) => ({
    hidden: false,
    id: id,
    max: null,
    min: 0,
    name: name,
    onlyInt: false,
    presentable: false,
    required: false,
    system: false,
    type: "number",
  });

  const bool = (id, name) => ({
    hidden: false,
    id: id,
    name: name,
    presentable: false,
    required: false,
    system: false,
    type: "bool",
  });

  // ── branchDeliveryRates ────────────────────────────────────────────────
  const ratesRule =
    '@request.auth.id != "" && branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id';

  const rates = new Collection({
    id: "pbc_deliveryRates01",
    name: "branchDeliveryRates",
    type: "base",
    listRule: ratesRule,
    viewRule: ratesRule,
    createRule: ratesRule,
    updateRule: ratesRule,
    deleteRule: ratesRule,
    fields: [
      idField,
      {
        cascadeDelete: true,
        collectionId: "pbc_2358601297",
        hidden: false,
        id: "relation_rates_branch",
        maxSelect: 1,
        minSelect: 0,
        name: "branch",
        presentable: false,
        required: true,
        system: false,
        type: "relation",
      },
      text("text_rates_name", "name", { max: 100, min: 1, required: true, presentable: true }),
      number("number_rates_baseFee", "baseFee"),
      number("number_rates_includedKm", "includedKm"),
      number("number_rates_ratePerKm", "ratePerKm"),
      bool("bool_rates_isDefault", "isDefault"),
      bool("bool_rates_isDeleted", "isDeleted"),
      ...autodates("rates"),
    ],
    indexes: [
      "CREATE INDEX `idx_deliveryRates_branch` ON `branchDeliveryRates` (`branch`)",
    ],
  });
  app.save(rates);

  // ── customerAddresses ──────────────────────────────────────────────────
  const addrRule =
    '@request.auth.id != "" && (customer.branch = "" || customer.branch.organization.organizationMemberships_via_organization.user ?= @request.auth.id)';

  const addresses = new Collection({
    id: "pbc_custAddresses01",
    name: "customerAddresses",
    type: "base",
    listRule: addrRule,
    viewRule: addrRule,
    createRule: addrRule,
    updateRule: addrRule,
    deleteRule: addrRule,
    fields: [
      idField,
      {
        cascadeDelete: true,
        collectionId: "pbc_customers001",
        hidden: false,
        id: "relation_addr_customer",
        maxSelect: 1,
        minSelect: 0,
        name: "customer",
        presentable: false,
        required: true,
        system: false,
        type: "relation",
      },
      text("text_addr_label", "label", { max: 100 }),
      text("text_addr_address", "address", { max: 500, min: 1, required: true, presentable: true }),
      text("text_addr_notes", "notes", { max: 500 }),
      number("number_addr_distanceKm", "distanceKm"),
      {
        cascadeDelete: false,
        collectionId: "pbc_deliveryRates01",
        hidden: false,
        id: "relation_addr_rate",
        maxSelect: 1,
        minSelect: 0,
        name: "deliveryRate",
        presentable: false,
        required: false,
        system: false,
        type: "relation",
      },
      bool("bool_addr_isDefault", "isDefault"),
      bool("bool_addr_isDeleted", "isDeleted"),
      ...autodates("addr"),
    ],
    indexes: [
      "CREATE INDEX `idx_custAddresses_customer` ON `customerAddresses` (`customer`)",
    ],
  });
  app.save(addresses);

  // ── Migrate existing single branch fee into a default "Standard" rate ──
  const branches = app.findAllRecords("branches");
  for (let i = 0; i < branches.length; i++) {
    const b = branches[i];
    const base = b.getFloat("deliveryBaseFee");
    const incl = b.getFloat("deliveryIncludedKm");
    const rate = b.getFloat("deliveryRatePerKm");
    if (!base && !incl && !rate) continue;
    const r = new Record(rates);
    r.set("branch", b.id);
    r.set("name", "Standard");
    r.set("baseFee", base);
    r.set("includedKm", incl);
    r.set("ratePerKm", rate);
    r.set("isDefault", true);
    r.set("isDeleted", false);
    app.save(r);
  }
}, (app) => {
  const addresses = app.findCollectionByNameOrId("customerAddresses");
  app.delete(addresses);
  const rates = app.findCollectionByNameOrId("branchDeliveryRates");
  app.delete(rates);
});
