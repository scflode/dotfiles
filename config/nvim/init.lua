local ok, err = pcall(require, "user")

if not ok then
    error("Error loading" .. "\n\n" .. err)
end
