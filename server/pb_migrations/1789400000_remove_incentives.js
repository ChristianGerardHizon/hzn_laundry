/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Drop incentiveTiers collection (unused feature).
  try {
    const tiers = app.findCollectionByNameOrId("incentiveTiers");
    app.delete(tiers);
  } catch (e) {
    console.log("incentiveTiers already removed, skipping:", e);
  }

  // Remove legacy flat incentive fields from branches.
  try {
    const branches = app.findCollectionByNameOrId("branches");
    try {
      branches.fields.removeById("number565159659"); // incentiveAmount
    } catch (e) {
      console.log("incentiveAmount field already removed, skipping:", e);
    }
    try {
      branches.fields.removeById("number3808722339"); // incentivePerServiceItems
    } catch (e) {
      console.log("incentivePerServiceItems field already removed, skipping:", e);
    }
    return app.save(branches);
  } catch (e) {
    console.log("branches incentive field cleanup skipped:", e);
  }
}, (app) => {
  // No-op down: incentives feature was removed permanently.
})
