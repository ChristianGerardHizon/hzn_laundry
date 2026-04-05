// Shared logic for activity_logger.pb.js
// Loaded via require() inside each handler (goja scope isolation).

module.exports = {
  NAME_FIELDS: {
    "sales": "receiptNumber",
    "products": "name",
    "services": "name",
    "customers": "name",
    "employees": "name",
    "users": "name",
    "userRoles": "name",
    "branches": "name",
    "machines": "name",
    "storages": "name",
    "promos": "name",
    "payments": "",
    "employeeAttendances": "",
    "employeeDeductions": "name",
    "saleItems": "productName",
    "saleServiceItems": "serviceName"
  },

  SKIP_FIELDS: {
    "id": true,
    "collectionId": true,
    "collectionName": true,
    "created": true,
    "updated": true
  },

  COLLECTION_LABELS: {
    "sales": "sale",
    "products": "product",
    "services": "service",
    "customers": "customer",
    "employees": "employee",
    "users": "user",
    "userRoles": "user role",
    "branches": "branch",
    "machines": "machine",
    "storages": "storage",
    "promos": "promo",
    "payments": "payment",
    "employeeAttendances": "attendance",
    "employeeDeductions": "deduction",
    "saleItems": "sale item",
    "saleServiceItems": "sale service item"
  },

  ORDER_STATUS_LABELS: {
    "pending": "Pending",
    "processing": "Processing",
    "ready": "Ready",
    "pickedUp": "Picked Up"
  },

  SALE_STATUS_LABELS: {
    "pending": "Pending",
    "completed": "Completed",
    "refunded": "Refunded",
    "voided": "Voided"
  },

  PAYMENT_METHOD_LABELS: {
    "cash": "Cash",
    "card": "Card",
    "bankTransfer": "Bank Transfer",
    "check": "Check"
  },

  PAYMENT_TYPE_LABELS: {
    "payment": "Payment",
    "deposit": "Deposit",
    "refund": "Refund"
  },

  SERVICE_ITEM_STATUS_LABELS: {
    "pending": "Pending",
    "in_progress": "In Progress",
    "completed": "Completed"
  },

  MACHINE_TYPE_LABELS: {
    "washer": "Washer",
    "dryer": "Dryer",
    "other": "Other"
  },

  capitalize: function(s) {
    if (!s) return s;
    return s.charAt(0).toUpperCase() + s.slice(1);
  },

  getStr: function(record, field) {
    try { return record.getString(field) || ""; } catch(e) { return ""; }
  },

  getFloat: function(record, field) {
    try { return record.getFloat(field); } catch(e) { return 0; }
  },

  getBool: function(record, field) {
    try { return record.getBool(field); } catch(e) { return false; }
  },

  peso: function(n) {
    return "₱" + Number(n).toFixed(2);
  },

  getRecordName: function(record, colName) {
    var field = this.NAME_FIELDS[colName] || "";
    if (!field) return "";
    return this.getStr(record, field);
  },

  // Resolve a relation ID to a display name
  resolveRelationName: function(collectionId, recordId) {
    if (!recordId || recordId === "") return "(none)";
    try {
      var col = $app.findCollectionByNameOrId(collectionId);
      var rec = $app.findRecordById(col.name, recordId);
      var nameFields = ["name", "receiptNumber", "title"];
      for (var i = 0; i < nameFields.length; i++) {
        try {
          var val = rec.getString(nameFields[i]);
          if (val) return val;
        } catch(e) {}
      }
      return recordId;
    } catch (err) {
      return recordId;
    }
  },

  resolveRelationNames: function(collectionId, ids) {
    if (!ids || !ids.length) return "(none)";
    var names = [];
    for (var i = 0; i < ids.length; i++) {
      names.push(this.resolveRelationName(collectionId, ids[i]));
    }
    return names.join(", ");
  },

  // =========================================================================
  // Create descriptions — specific per collection
  // =========================================================================
  buildCreateDescription: function(colName, record) {
    switch (colName) {
      case "sales": {
        var ref = this.getStr(record, "receiptNumber");
        var customer = this.getStr(record, "customerName");
        var total = this.getFloat(record, "totalAmount");
        var desc = "New sale " + ref;
        if (customer) desc = desc + " for " + customer;
        desc = desc + " — " + this.peso(total);
        return desc;
      }
      case "products": {
        var name = this.getStr(record, "name");
        var price = this.getFloat(record, "price");
        return "Added product '" + name + "' at " + this.peso(price);
      }
      case "services": {
        var name = this.getStr(record, "name");
        var price = this.getFloat(record, "price");
        return "Added service '" + name + "' at " + this.peso(price);
      }
      case "customers": {
        var name = this.getStr(record, "name");
        var phone = this.getStr(record, "phone");
        var desc = "New customer '" + name + "'";
        if (phone) desc = desc + " (" + phone + ")";
        return desc;
      }
      case "employees": {
        var name = this.getStr(record, "name");
        var salary = this.getFloat(record, "baseSalary");
        var desc = "Added employee '" + name + "'";
        if (salary) desc = desc + " with base salary " + this.peso(salary);
        return desc;
      }
      case "payments": {
        var amount = this.getFloat(record, "amount");
        var method = this.getStr(record, "paymentMethod");
        var type = this.getStr(record, "type");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        var methodLabel = this.PAYMENT_METHOD_LABELS[method] || method;
        var typeLabel = this.PAYMENT_TYPE_LABELS[type] || type;
        return "Recorded " + typeLabel.toLowerCase() + " of " + this.peso(amount) + " via " + methodLabel + " for " + saleRef;
      }
      case "employeeAttendances": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        var isPresent = this.getBool(record, "isPresent");
        var status = isPresent ? "present" : "absent";
        return "Marked " + empName + " as " + status;
      }
      case "employeeDeductions": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        var dedName = this.getStr(record, "name");
        var value = this.getFloat(record, "value");
        var desc = "Added deduction '" + dedName + "' for " + empName;
        if (value) desc = desc + " — " + this.peso(value);
        return desc;
      }
      case "saleItems": {
        var prodName = this.getStr(record, "productName");
        var qty = this.getFloat(record, "quantity");
        var subtotal = this.getFloat(record, "subtotal");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        return "Added " + qty + "x " + prodName + " (" + this.peso(subtotal) + ") to " + saleRef;
      }
      case "saleServiceItems": {
        var svcName = this.getStr(record, "serviceName");
        var qty = this.getFloat(record, "quantity");
        var subtotal = this.getFloat(record, "subtotal");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        return "Added " + qty + "x " + svcName + " (" + this.peso(subtotal) + ") to " + saleRef;
      }
      case "promos": {
        var name = this.getStr(record, "name");
        var required = this.getFloat(record, "requiredOrders");
        var reward = this.getFloat(record, "rewardFreeWeight");
        return "Created promo '" + name + "' — " + required + " orders for " + reward + "kg free";
      }
      case "branches": {
        var name = this.getStr(record, "name");
        return "Added branch '" + name + "'";
      }
      case "machines": {
        var name = this.getStr(record, "name");
        var type = this.getStr(record, "type");
        var typeLabel = this.MACHINE_TYPE_LABELS[type] || type;
        return "Added machine '" + name + "' (" + typeLabel + ")";
      }
      case "storages": {
        var name = this.getStr(record, "name");
        return "Added storage '" + name + "'";
      }
      case "users": {
        var name = this.getStr(record, "name");
        return "Created user '" + name + "'";
      }
      case "userRoles": {
        var name = this.getStr(record, "name");
        return "Created role '" + name + "'";
      }
      default: {
        var label = this.COLLECTION_LABELS[colName] || colName;
        var name = this.getRecordName(record, colName);
        var desc = "Created " + label;
        if (name) desc = desc + " '" + name + "'";
        return desc;
      }
    }
  },

  // =========================================================================
  // Update descriptions — specific per collection
  // =========================================================================
  buildUpdateDescription: function(colName, record, changes, changedFields) {
    var name = this.getRecordName(record, colName);

    switch (colName) {
      case "sales": {
        var parts = [];
        if (changes["orderStatus"]) {
          var from = this.ORDER_STATUS_LABELS[changes["orderStatus"]["old"]] || changes["orderStatus"]["old"];
          var to = this.ORDER_STATUS_LABELS[changes["orderStatus"]["new"]] || changes["orderStatus"]["new"];
          parts.push("Order moved from " + from + " to " + to);
        }
        if (changes["status"]) {
          var from = this.SALE_STATUS_LABELS[changes["status"]["old"]] || changes["status"]["old"];
          var to = this.SALE_STATUS_LABELS[changes["status"]["new"]] || changes["status"]["new"];
          parts.push("Sale marked as " + to);
        }
        if (changes["isPaid"]) {
          var val = changes["isPaid"]["new"];
          parts.push(val ? "Marked as paid" : "Marked as unpaid");
        }
        if (changes["totalAmount"]) {
          parts.push("Total adjusted to " + this.peso(changes["totalAmount"]["new"]));
        }
        if (changes["packs"]) {
          parts.push("Packs set to " + changes["packs"]["new"]);
        }
        if (changes["notes"]) {
          parts.push("Notes updated");
        }
        if (parts.length > 0) {
          return parts.join(". ") + " — " + name;
        }
        return "Updated sale " + name;
      }

      case "products": {
        var parts = [];
        if (changes["price"]) parts.push("price to " + this.peso(changes["price"]["new"]));
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["description"]) parts.push("description");
        if (changes["quantity"]) parts.push("stock to " + changes["quantity"]["new"]);
        if (changes["stockThreshold"]) parts.push("stock threshold to " + changes["stockThreshold"]["new"]);
        if (changes["forSale"]) parts.push(changes["forSale"]["new"] ? "listed for sale" : "unlisted from sale");
        if (changes["unitCost"]) parts.push("unit cost to " + this.peso(changes["unitCost"]["new"]));
        // Catch remaining
        if (parts.length === 0) {
          var labels = [];
          for (var i = 0; i < changedFields.length; i++) labels.push(changedFields[i]);
          parts.push(labels.join(", "));
        }
        return "Updated product '" + name + "' — " + parts.join(", ");
      }

      case "services": {
        var parts = [];
        if (changes["price"]) parts.push("price to " + this.peso(changes["price"]["new"]));
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["description"]) parts.push("description");
        if (changes["estimatedDuration"]) parts.push("duration to " + changes["estimatedDuration"]["new"] + " min");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated service '" + name + "' — " + parts.join(", ");
      }

      case "customers": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["phone"]) parts.push("phone to " + changes["phone"]["new"]);
        if (changes["address"]) parts.push("address");
        if (changes["notes"]) parts.push("notes");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated customer '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      case "employees": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["baseSalary"]) parts.push("base salary to " + this.peso(changes["baseSalary"]["new"]));
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated employee '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      case "payments": {
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        var parts = [];
        if (changes["amount"]) parts.push("amount to " + this.peso(changes["amount"]["new"]));
        if (changes["paymentMethod"]) {
          var m = this.PAYMENT_METHOD_LABELS[changes["paymentMethod"]["new"]] || changes["paymentMethod"]["new"];
          parts.push("method to " + m);
        }
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated payment for " + saleRef + " — " + parts.join(", ");
      }

      case "employeeAttendances": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        if (changes["isPresent"]) {
          var val = changes["isPresent"]["new"];
          return "Set " + empName + " as " + (val ? "present" : "absent");
        }
        if (changes["notes"]) {
          return "Updated attendance notes for " + empName;
        }
        return "Updated attendance for " + empName;
      }

      case "employeeDeductions": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        var dedName = this.getStr(record, "name");
        var parts = [];
        if (changes["value"]) parts.push("value to " + this.peso(changes["value"]["new"]));
        if (changes["isActive"]) parts.push(changes["isActive"]["new"] ? "activated" : "deactivated");
        if (changes["name"]) parts.push("renamed to '" + changes["name"]["new"] + "'");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated deduction '" + dedName + "' for " + empName + " — " + parts.join(", ");
      }

      case "saleItems": {
        var prodName = this.getStr(record, "productName");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        var parts = [];
        if (changes["quantity"]) parts.push("qty to " + changes["quantity"]["new"]);
        if (changes["unitPrice"]) parts.push("price to " + this.peso(changes["unitPrice"]["new"]));
        if (changes["subtotal"]) parts.push("subtotal to " + this.peso(changes["subtotal"]["new"]));
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated " + prodName + " in " + saleRef + " — " + parts.join(", ");
      }

      case "saleServiceItems": {
        var svcName = this.getStr(record, "serviceName");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        if (changes["status"]) {
          var to = this.SERVICE_ITEM_STATUS_LABELS[changes["status"]["new"]] || changes["status"]["new"];
          return "Set " + svcName + " to " + to + " in " + saleRef;
        }
        if (changes["machine"] || changes["machineName"]) {
          var machineName = changes["machineName"] ? changes["machineName"]["new"] : "";
          return "Assigned machine " + machineName + " to " + svcName + " in " + saleRef;
        }
        if (changes["storage"] || changes["storageName"]) {
          var storageName = changes["storageName"] ? changes["storageName"]["new"] : "";
          return "Assigned storage " + storageName + " to " + svcName + " in " + saleRef;
        }
        var parts = [];
        if (changes["quantity"]) parts.push("qty to " + changes["quantity"]["new"]);
        if (changes["unitPrice"]) parts.push("price to " + this.peso(changes["unitPrice"]["new"]));
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated " + svcName + " in " + saleRef + " — " + parts.join(", ");
      }

      case "promos": {
        var parts = [];
        if (changes["isActive"]) parts.push(changes["isActive"]["new"] ? "activated" : "deactivated");
        if (changes["name"]) parts.push("renamed to '" + changes["name"]["new"] + "'");
        if (changes["requiredOrders"]) parts.push("required orders to " + changes["requiredOrders"]["new"]);
        if (changes["rewardFreeWeight"]) parts.push("reward to " + changes["rewardFreeWeight"]["new"] + "kg");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated promo '" + name + "' — " + parts.join(", ");
      }

      case "branches": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["address"]) parts.push("address");
        if (changes["contactNumber"]) parts.push("contact number");
        if (changes["operatingHours"]) parts.push("operating hours");
        if (changes["incentiveAmount"]) parts.push("incentive to " + this.peso(changes["incentiveAmount"]["new"]));
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated branch '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      case "machines": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["type"]) {
          var t = this.MACHINE_TYPE_LABELS[changes["type"]["new"]] || changes["type"]["new"];
          parts.push("type to " + t);
        }
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated machine '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      case "storages": {
        if (changes["name"]) return "Renamed storage '" + changes["name"]["old"] + "' to '" + changes["name"]["new"] + "'";
        return "Updated storage '" + name + "'";
      }

      case "users": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["role"]) parts.push("role changed");
        if (changes["branch"]) parts.push("branch changed");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated user '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      case "userRoles": {
        var parts = [];
        if (changes["name"]) parts.push("name to '" + changes["name"]["new"] + "'");
        if (changes["permissions"]) parts.push("permissions updated");
        if (changes["description"]) parts.push("description");
        if (parts.length === 0) parts.push(changedFields.join(", "));
        return "Updated role '" + (changes["name"] ? changes["name"]["old"] : name) + "' — " + parts.join(", ");
      }

      default: {
        var label = this.COLLECTION_LABELS[colName] || colName;
        var desc = "Updated " + label;
        if (name) desc = desc + " '" + name + "'";
        return desc;
      }
    }
  },

  // =========================================================================
  // Delete descriptions — specific per collection
  // =========================================================================
  buildDeleteDescription: function(colName, record) {
    switch (colName) {
      case "sales":
        return "Deleted sale " + this.getStr(record, "receiptNumber");
      case "products":
        return "Removed product '" + this.getStr(record, "name") + "'";
      case "services":
        return "Removed service '" + this.getStr(record, "name") + "'";
      case "customers":
        return "Removed customer '" + this.getStr(record, "name") + "'";
      case "employees":
        return "Removed employee '" + this.getStr(record, "name") + "'";
      case "payments": {
        var amount = this.getFloat(record, "amount");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        return "Deleted payment of " + this.peso(amount) + " from " + saleRef;
      }
      case "employeeAttendances": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        return "Deleted attendance record for " + empName;
      }
      case "employeeDeductions": {
        var empId = this.getStr(record, "employee");
        var empName = this.resolveRelationName("employees", empId);
        var dedName = this.getStr(record, "name");
        return "Removed deduction '" + dedName + "' from " + empName;
      }
      case "saleItems": {
        var prodName = this.getStr(record, "productName");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        return "Removed " + prodName + " from " + saleRef;
      }
      case "saleServiceItems": {
        var svcName = this.getStr(record, "serviceName");
        var saleId = this.getStr(record, "sale");
        var saleRef = this.resolveRelationName("sales", saleId);
        return "Removed " + svcName + " from " + saleRef;
      }
      case "promos":
        return "Removed promo '" + this.getStr(record, "name") + "'";
      case "branches":
        return "Removed branch '" + this.getStr(record, "name") + "'";
      case "machines":
        return "Removed machine '" + this.getStr(record, "name") + "'";
      case "storages":
        return "Removed storage '" + this.getStr(record, "name") + "'";
      case "users":
        return "Deleted user '" + this.getStr(record, "name") + "'";
      case "userRoles":
        return "Deleted role '" + this.getStr(record, "name") + "'";
      default: {
        var label = this.COLLECTION_LABELS[colName] || colName;
        var n = this.getRecordName(record, colName);
        var desc = "Deleted " + label;
        if (n) desc = desc + " '" + n + "'";
        return desc;
      }
    }
  },

  computeChanges: function(original, current, colName) {
    var changes = {};
    var changedFields = [];
    var fields = [];
    var fieldMeta = {};

    try {
      var col = $app.findCollectionByNameOrId(colName);
      var schemaFields = col.fields;
      for (var i = 0; i < schemaFields.length; i++) {
        var f = schemaFields[i];
        fields.push(f.name);
        if (f.type === "relation") {
          fieldMeta[f.name] = {
            type: "relation",
            collectionId: f.collectionId,
            maxSelect: f.maxSelect || 1
          };
        }
      }
    } catch (err) {
      return { changes: changes, changedFields: changedFields };
    }

    for (var i = 0; i < fields.length; i++) {
      var field = fields[i];
      if (this.SKIP_FIELDS[field]) continue;

      var oldVal = original.get(field);
      var newVal = current.get(field);

      var oldStr = JSON.stringify(oldVal);
      var newStr = JSON.stringify(newVal);

      if (oldStr !== newStr) {
        var meta = fieldMeta[field];
        if (meta) {
          var oldDisplay, newDisplay;
          if (meta.maxSelect === 1) {
            oldDisplay = this.resolveRelationName(meta.collectionId, oldVal);
            newDisplay = this.resolveRelationName(meta.collectionId, newVal);
          } else {
            oldDisplay = this.resolveRelationNames(meta.collectionId, oldVal);
            newDisplay = this.resolveRelationNames(meta.collectionId, newVal);
          }
          changes[field] = { "old": oldDisplay, "new": newDisplay };
        } else {
          changes[field] = { "old": oldVal, "new": newVal };
        }
        changedFields.push(field);
      }
    }

    return { changes: changes, changedFields: changedFields };
  },

  getUserId: function(e) {
    // Try all known PocketBase API versions to get auth user ID
    var attempts = [];

    // v0.25+: e.auth
    try {
      if (e.auth && e.auth.id) return e.auth.id;
      attempts.push("e.auth=" + JSON.stringify(e.auth));
    } catch (err) { attempts.push("e.auth:err"); }

    // v0.23+: e.requestInfo
    try {
      if (e.requestInfo) {
        var info = e.requestInfo;
        if (typeof info === "function") info = info();
        if (info && info.auth && info.auth.id) return info.auth.id;
        if (info && info.authRecord && info.authRecord.id) return info.authRecord.id;
        attempts.push("requestInfo.auth=" + JSON.stringify(info ? info.auth : null));
      }
    } catch (err) { attempts.push("requestInfo:err"); }

    // httpContext approach
    try {
      if (e.httpContext) {
        var auth = e.httpContext.get("auth");
        if (auth && auth.id) return auth.id;
      }
    } catch (err) { attempts.push("httpContext:err"); }

    // $apis.requestInfo
    try {
      if (typeof $apis !== "undefined" && e.httpContext) {
        var reqInfo = $apis.requestInfo(e.httpContext);
        if (reqInfo && reqInfo.authRecord && reqInfo.authRecord.id) return reqInfo.authRecord.id;
        attempts.push("$apis.requestInfo.authRecord=" + JSON.stringify(reqInfo ? reqInfo.authRecord : null));
      }
    } catch (err) { attempts.push("$apis:err"); }

    console.log("[ACTIVITY_LOGGER] Could not get userId. Attempts: " + attempts.join(", "));
    return "";
  },

  logCreate: function(e) {
    var record = e.record;
    var colName = record.collection().name;
    var userId = this.getUserId(e);
    var description = this.buildCreateDescription(colName, record);

    var logCollection = $app.findCollectionByNameOrId("activityLogs");
    var logRecord = new Record(logCollection);
    logRecord.set("collection", colName);
    logRecord.set("recordId", record.id);
    logRecord.set("action", "create");
    logRecord.set("description", description);
    if (userId) {
      logRecord.set("user", userId);
    }
    $app.save(logRecord);
  },

  logUpdate: function(e) {
    var record = e.record;
    var colName = record.collection().name;
    var userId = this.getUserId(e);

    var result = this.computeChanges(record.original(), record, colName);
    if (result.changedFields.length === 0) return;

    var description = this.buildUpdateDescription(colName, record, result.changes, result.changedFields);

    var logCollection = $app.findCollectionByNameOrId("activityLogs");
    var logRecord = new Record(logCollection);
    logRecord.set("collection", colName);
    logRecord.set("recordId", record.id);
    logRecord.set("action", "update");
    logRecord.set("description", description);
    logRecord.set("changes", result.changes);
    if (userId) {
      logRecord.set("user", userId);
    }
    $app.save(logRecord);
  },

  logDelete: function(e) {
    var record = e.record;
    var colName = record.collection().name;
    var userId = this.getUserId(e);
    var description = this.buildDeleteDescription(colName, record);

    var logCollection = $app.findCollectionByNameOrId("activityLogs");
    var logRecord = new Record(logCollection);
    logRecord.set("collection", colName);
    logRecord.set("recordId", record.id);
    logRecord.set("action", "delete");
    logRecord.set("description", description);
    if (userId) {
      logRecord.set("user", userId);
    }
    $app.save(logRecord);
  }
};
