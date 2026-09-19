/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const employees = app.findCollectionByNameOrId("pbc_3735627160");

  employees.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_organizations01",
    "hidden": false,
    "id": "rel_employees_organization",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  employees.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "hidden": false,
    "id": "rel_employees_branches",
    "maxSelect": 0,
    "minSelect": 0,
    "name": "branches",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }));

  app.save(employees);

  const orgs = app.findAllRecords("organizations");
  if (orgs.length > 0) {
    const defaultOrgId = orgs[0].id;
    const employeeRecords = app.findAllRecords("employees");
    for (let i = 0; i < employeeRecords.length; i++) {
      const record = employeeRecords[i];
      if (!record.get("organization")) {
        record.set("organization", defaultOrgId);
        app.save(record);
      }
    }
  }

  const orgField = employees.fields.getById("rel_employees_organization");
  if (orgField) {
    orgField.required = true;
  }

  const memberRule =
    '@request.auth.id != "" && organization.organizationMemberships_via_organization.user ?= @request.auth.id';
  employees.listRule = memberRule;
  employees.viewRule = memberRule;
  employees.createRule = memberRule;
  employees.updateRule = memberRule;
  employees.deleteRule = memberRule;
  app.save(employees);

  const childRule =
    '@request.auth.id != "" && employee.organization.organizationMemberships_via_organization.user ?= @request.auth.id';

  const attendances = app.findCollectionByNameOrId("pbc_2715706917");
  attendances.listRule = childRule;
  attendances.viewRule = childRule;
  attendances.createRule = childRule;
  attendances.updateRule = childRule;
  attendances.deleteRule = childRule;
  app.save(attendances);

  const deductions = app.findCollectionByNameOrId("pbc_4182736950");
  deductions.listRule = childRule;
  deductions.viewRule = childRule;
  deductions.createRule = childRule;
  deductions.updateRule = childRule;
  deductions.deleteRule = childRule;
  app.save(deductions);
}, (app) => {
  const employees = app.findCollectionByNameOrId("pbc_3735627160");
  employees.fields.removeById("rel_employees_organization");
  employees.fields.removeById("rel_employees_branches");
  employees.listRule = "";
  employees.viewRule = "";
  employees.createRule = "";
  employees.updateRule = "";
  employees.deleteRule = "";
  app.save(employees);

  const attendances = app.findCollectionByNameOrId("pbc_2715706917");
  attendances.listRule = "";
  attendances.viewRule = "";
  attendances.createRule = "";
  attendances.updateRule = "";
  attendances.deleteRule = "";
  app.save(attendances);

  const deductions = app.findCollectionByNameOrId("pbc_4182736950");
  deductions.listRule = "";
  deductions.viewRule = "";
  deductions.createRule = "";
  deductions.updateRule = "";
  deductions.deleteRule = "";
  app.save(deductions);
});
