# CLAUDE.md

Advanced behavioral guidelines and SQL coding rules for AI agent execution, customized for the Vinatech MES & Groupware Database project.

---

## 1. Hierarchy of Truth

When executing tasks, refer to these files as the absolute sources of truth:
1.  **AI Behavior & Rules**: [CLAUDE.md](file:///C:/Users/duc01/OneDrive/Desktop/vinatech/database/CLAUDE.md)
2.  **Schema & Column Names**: [docs/DATABASE_SCHEMA_QUICKREF.md](file:///C:/Users/duc01/OneDrive/Desktop/vinatech/database/docs/DATABASE_SCHEMA_QUICKREF.md)
3.  **Troubleshooting & Bug Indexes**: [MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md](file:///C:/Users/duc01/OneDrive/Desktop/vinatech/database/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
4.  **Operational Guideline**: [AI_CONFIG.md](file:///C:/Users/duc01/OneDrive/Desktop/vinatech/database/AI_CONFIG.md)

---

## 2. SQL Coding & Safety Constraints

### ❌ Negative Constraints (Strict Prohibitions)
-   **No Unauthorized Stored Procedure/Data Updates**: The AI is NOT allowed to directly update stored procedures, views, functions, or database data on the server without the USER's explicit instruction and approval. All modifications must be proposed to the USER first.
-   **SELECT-Only Tool Restriction**: The AI is ONLY allowed to run `SELECT` queries on the database. NEVER execute `INSERT`, `UPDATE`, or `DELETE` statements directly using tools.
-   **No Direct Production Mutation**: Always write data modification scripts inside a Transaction block (`BEGIN TRAN ... ROLLBACK / COMMIT`) and guide the USER to run them on SSMS.
-   **Never Use `SELECT *`**: Always list columns explicitly in proposed queries to keep them performant and clear.
-   **Never Use Triggers**: The system operates inventory recursively inside Stored Procedures. Never write or propose database Triggers.
-   **Never Omit `WITH(NOLOCK)`**: Transactional tables like `STB_ProdRouteHist` and `STB_MaterialLotInfo` are heavily queried. Always append `WITH(NOLOCK)` to prevent table locking and database hangs (block sessions).

### ⚙️ Transaction Safety Template
Always wrap data fix scripts in this format for the USER:
```sql
BEGIN TRANSACTION;
-- 1. Verify target rows first
SELECT COUNT(*) FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '...';

-- 2. Execute mutation using exact Primary Keys
UPDATE STB_SetInfo SET DefectQty = 0, IsDefect = 0 WHERE Barcode = '...';

-- 3. Verify changes
SELECT Barcode, DefectQty, IsDefect FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '...';

ROLLBACK TRANSACTION; -- Instruct the user to change to COMMIT only after manual check
```

---

## 3. Stored Procedure Workflow

-   **Always Query Fresh**: Do not rely on local files or cached definitions. Retrieve the latest SP definition using:
    ```sql
    SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_name')
    ```
-   **Immediate Cleanup**: Once the current request is complete, and immediately upon receiving the next user request, delete any generated/downloaded Stored Procedure definition files to keep the workspace clean and avoid caching stale logic.

---

## 4. Think & Simplify

-   **Think Before Coding**: Explicitly state assumptions. Ask if requirements are ambiguous.
-   **Simplicity First**: Write the minimum SQL necessary. Refuse over-engineering or speculative performance optimizations.
-   **Surgical Changes**: Only modify the exact files or lines requested. Match formatting and keyword capitalization exactly.
