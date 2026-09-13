---@meta

---@class fsr.formatter.Formatter.LanguageServerChoice
---@field name string

---@class fsr.formatter.Formatter.LanguageServer
---@field language_server fsr.formatter.Formatter.LanguageServerChoice

---@class fsr.formatter.Formatter.External.ExternalCommand
---@field command string
---@field arguments string[]?

---@class fsr.formatter.Formatter.External
---@field external fsr.formatter.Formatter.External.ExternalCommand

---@class fsr.formatter.Formatter.CodeAction
---@field code_action string

---@alias fsr.formatter.Formatter fsr.formatter.Formatter.LanguageServer|fsr.formatter.Formatter.External|fsr.formatter.Formatter.CodeAction
