# Credo configuration for outreach_manager_bot
# Suppressions tracked in GTD; see CLAUDE.md "Credo Suppressions with GTD Tracking"

%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Design.TodoComment,
         [
           exit_status: 0,
           priority: :low
         ]},
        {Credo.Check.Refactor.NestedFunctionCalls,
         [
           excluded_functions: [],
           max_nesting: 3
         ]}
      ]
    }
  ]
}
