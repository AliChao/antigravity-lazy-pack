# 🌌 Antigravity 專案駕駛艙 (ANTIGRAVITY.md)

> **專案名稱**：Antigravity 全自動化開發懶人包  
> **當前狀態**：🟢 開發中 (Active)  
> **關聯 GitHub**：`AliChao/antigravity-lazy-pack`  
> **關聯 NotebookLM 雲端硬碟檔案**：`G:\我的雲端硬碟\NotebookLM_Sources\project_context_for_notebooklm.md`  

---

## 📅 今日待辦清單 (Todo List)

- `[ ]` 步驟一：驗證「開工」自動化技能。
- `[ ]` 步驟二：進行「收工」安全檢測與 GitHub 推送測試。
- `[ ]` 步驟三：測試 NotebookLM 與 Google Drive 的一鍵同步打包。
- `[ ]` 步驟四：使用原生生圖引擎測試繁體中文「AI 教育代理人」資訊圖表生成。

---

## 📈 專案歷史與最近變更 (Recent Logs)

- **2026-05-23**：由 Antigravity 2.0 完成本地 Git 身份註冊（Alichao）與可攜式 GitHub CLI (gh) 部署登入。
- **2026-05-23**：成功打通「本地 ➡️ Google Drive ➡️ NotebookLM」的一鍵自動化同步工作流。
- **2026-05-23**：從遠端複製 `antigravity-lazy-pack`，開始配置「開工/收工/專案初始化」三大自動化 SOP 技能。

---

## 🤖 代理人自動化 SOP 指南 (Agent Rules)

當使用者在對話中提及以下關鍵字時，AI 代理人必須立即執行對應的操作：

### 1. 🟢 當使用者說「開工」或「我來了」時：
AI 代理人必須執行 `.\sop-actions.ps1 -Action Start`：
* 檢查當前 Git 分支與狀態。
* 讀取最近 3 次 Commit。
* 讀取本檔案 (`ANTIGRAVITY.md`) 的「今日待辦清單」，並給出今日工作建議。

### 2. 🔴 當使用者說「收工」或「下班了」時：
AI 代理人必須執行 `.\sop-actions.ps1 -Action Stop`：
* 自動掃描代碼是否包含敏感金鑰（如 `API_KEY`、`SECRET`、`.env` 檔案等）。
* 執行 `git add .`、生成 Commit Message 並完成 Git 提交與推送。
* 自動調用 `.\package-project.ps1`，將最新程式碼打包同步到 Google Drive，確保 NotebookLM 為最新狀態！
* 在 `ANTIGRAVITY.md` 的變更紀錄中寫入今日進度。

### 3. 🔵 當使用者說「初始化專案」時：
AI 代理人必須執行 `.\sop-actions.ps1 -Action Init`：
* 在新目錄中建立 `.gitignore`、`ANTIGRAVITY.md` 與 `package-project.ps1`。
* 執行 `git init`，並首次 Commit 與 Push。
