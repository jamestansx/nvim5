local M = {}

local rocks_path = string.format("%s/site/pack/luarocks", vim.fn.stdpath("data"))

function M.add(spec, opts)
    local inject_luarocks = function(fn)
        return function(args)
            M.install(args)
            if type(fn) == "function" then
                fn(args)
            end
        end
    end

    local post_install = spec["hooks"] and spec["hooks"]["post_install"]
    local post_checkout = spec["hooks"] and spec["hooks"]["post_checkout"]
    spec = vim.tbl_deep_extend("force", spec, {
        hooks = {
            post_install = inject_luarocks(post_install),
            post_checkout = inject_luarocks(post_checkout),
        },
    })

    MiniDeps.add(spec, opts)
end

function M.install(args)
    assert(vim.fn.executable("luarocks") == 1)

    local rockspec = vim.fs.find(function(name, _)
        return name:match(".*%-1.rockspec$")
    end, { path = args.path, type = "file", limit = 1 })[1]

    if rockspec == nil then
        error(
            string.format(
                "[Luarocks] %s: Rockspec is missing",
                args.source
            )
        )
    end

    vim.notify("[Luarocks] Installing dependencies")
    local obj = vim.system({
        "luarocks",
        "--tree", rocks_path,
        "install",
        "--deps-only",
        "--lua-version", "5.1",
        "--deps-mode", "one",
        rockspec,
    }):wait()

    if obj.code ~= 0 then
        error(
            string.format(
                "[Luarocks] %s: luarocks install failed with code %s!\n%s",
                args.source,
                obj.code,
                obj.stderr
            )
        )
    end
end

function M.setup()
    local path = string.format("%s/share/lua/5.1", rocks_path)
    local cpath = string.format("%s/lib/lua/5.1", rocks_path)

    package.path = table.concat({
        package.path,
        string.format("%s/?.lua", path),
        string.format("%s/?/init.lua", path),
    }, ";")

    package.cpath = table.concat({
        package.cpath,
        string.format("%s/?.lua", cpath),
        string.format("%s/?/init.lua", cpath),
    }, ";")
end

return M
