---@class render.md.Extmark
---@field private id? integer
---@field private mark render.md.Mark
local Extmark = {}
Extmark.__index = Extmark

---@param mark render.md.Mark
---@return render.md.Extmark
function Extmark.new(mark)
    local self = setmetatable({}, Extmark)
    self.id = nil
    self.mark = mark
    return self
end

---@return render.md.Mark
function Extmark:get()
    return self.mark
end

---@param range? render.md.Range
---@return boolean
function Extmark:inside(range)
    if range == nil then
        return false
    end
    local row = self.mark.start_row
    return range:contains(row, row)
end

---@param ns integer
---@param buf integer
function Extmark:show(ns, buf)
    if self.id ~= nil then
        return
    end
    local mark = self.mark
    mark.opts.strict = false
    local ok, id = pcall(vim.api.nvim_buf_set_extmark, buf, ns, mark.start_row, mark.start_col, mark.opts)
    if ok then
        self.id = id
    else
        local message = {
            string.format('render-markdown.nvim set extmark error (%s)', id),
            'you are running an old build of neovim that has now been released',
            'your build does not have all the features that are in the release',
            'update your build or switch to the release version',
        }
        vim.notify_once(table.concat(message, '\n'), vim.log.levels.ERROR)
    end
end

---@param ns integer
---@param buf integer
function Extmark:hide(ns, buf)
    if self.id == nil then
        return
    end
    vim.api.nvim_buf_del_extmark(buf, ns, self.id)
    self.id = nil
end

return Extmark
