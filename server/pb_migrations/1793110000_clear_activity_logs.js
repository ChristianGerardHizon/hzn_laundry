/// <reference path="../pb_data/types.d.ts" />
// Clears activityLogs for environments that already applied
// 1793100000 before the clear-on-scope change (e.g. local).
// Staging/prod that get the updated 1793100000 will already be empty;
// this migration is then a no-op.
migrate((app) => {
  const logs = app.findAllRecords("activityLogs");
  for (let i = 0; i < logs.length; i++) {
    app.delete(logs[i]);
  }
}, (app) => {
  // Irreversible data clear — down migration is a no-op.
});
