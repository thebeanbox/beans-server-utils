-- base/sql.lua (SHARED)

-- make sure foreign keys are enabled (this is needed for referencing which is used to avoid bad deletions (ex: deleting a group which players are still in))
if BSU.SQLQueryValue("PRAGMA foreign_keys") == "0" then
  BSU.SQLQuery("PRAGMA foreign_keys = ON")
end