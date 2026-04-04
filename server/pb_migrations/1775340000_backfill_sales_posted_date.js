/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  // Backfill postedDate with created for sales records that have no postedDate set.
  // Older orders were created before the postedDate field was added and are
  // invisible to the kanban board and reports which filter by postedDate.
  try {
    app.db()
      .newQuery("UPDATE sales SET postedDate = created WHERE postedDate IS NULL OR postedDate = ''")
      .execute();
  } catch (e) {
    console.log("Backfill postedDate migration skipped:", e);
  }
}, (app) => {
  // No rollback needed - we don't want to null out postedDate
})
