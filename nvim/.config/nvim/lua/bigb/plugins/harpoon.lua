return {
    "thePrimeagen/harpoon",
    enabled = true,
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")
        -- local conf = require("telescope.config").values

        harpoon:setup({
            global_settings = {
                save_on_toggle = true,
                save_on_change = true,
            },
        })

        -- NOTE: Experimenting
        -- Telescope into Harpoon function
        -- local function toggle_telescope(harpoon_files)
        -- 	local file_paths = {}
        -- 	for _, item in ipairs(harpoon_files.items) do
        -- 		table.insert(file_paths, item.value)
        -- 	end
        -- 	require("telescope.pickers")
        -- 		.new({}, {
        -- 			prompt_title = "Harpoon",
        -- 			finder = require("telescope.finders").new_table({
        -- 				results = file_paths,
        -- 			}),
        -- 			previewer = conf.file_previewer({}),
        -- 			sorter = conf.generic_sorter({}),
        -- 		})
        -- 		:find()
        -- end

        local map = vim.keymap.set

        -- Add / browse
        map("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
        map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
        map("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon menu" })
        map("n", "<C-e>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon menu" })

        -- Jump to marked files. <M-n> keeps a one-chord jump without stealing
        -- <C-i> (which the terminal sends as <Tab>: it would break the jumplist)
        for i = 1, 4 do
            map("n", "<leader>h" .. i, function() harpoon:list():select(i) end,
                { desc = "Harpoon file " .. i })
            map("n", "<M-" .. i .. ">", function() harpoon:list():select(i) end,
                { desc = "Harpoon file " .. i })
        end

        -- Cycle the list
        map("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon previous" })
        map("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon next" })

        -- Telescope inside Harpoon Window
        -- vim.keymap.set("n", "<C-f>", function()
        -- 	toggle_telescope(harpoon:list())
        -- end)
    end,
}
