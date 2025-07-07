return {
  "ldelossa/gh.nvim",

  cmd = {
    "GHCloseCommit",
    "GHExpandCommit",
    "GHOpenToCommit",
    "GHPopOutCommit",
    "GHCollapseCommit",
    "GHPreviewIssue",
    "LTPanel",
    "GHClosePR",
    "GHPRDetails",
    "GHExpandPR",
    "GHOpenPR",
    "GHPopOutPR",
    "GHRefreshPR",
    "GHOpenToPR",
    "GHCollapsePR",
    "GHStartReview",
    "GHCloseReview",
    "GHDeleteReview",
    "GHExpandReview",
    "GHSubmitReview",
    "GHCollapseReview",
    "GHCreateThread",
    "GHNextThread",
    "GHToggleThread",
  },

  dependencies = {
    {
      "ldelossa/litee.nvim",
      config = function()
        require("litee.lib").setup()
      end,
    },
  },
  config = function()
    require("litee.gh").setup()
  end,
}
